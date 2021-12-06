/**
 * Rolls through Caller_Id_Conversion__c and uses AES256 to encrypt contact_name__c and place in encrypted_contact_name__c
 * and ANI_DialNumber__c and place in encrypted_ANI_DialNumber__c. (I know these names are cryptic but it's Carpls after all!)
 * Will only update row if at least 1 of the 2 have a value.
 *
 * Note this object may be truncated after running this as it's only here for a simple import / export.
 */
global class BatchEncryptCallerId implements DataBase.Batchable<sObject>, Database.Stateful {

    global String soqlUpdate;
    global String status;
    global List<String> emailAddys;
    global String aes256Key;
    global Blob blobAes256Key;

    static String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    global Integer iRowsUpdated = 0;

    /**
     * Take in soql and other params and store.
     * @param sUPDATE
     * @param pEmailAddys
     * @param pAes256Key
     */
    global BatchEncryptCallerId(String sUPDATE, List<String> pEmailAddys, String pAes256Key) {
        emailAddys = pEmailAddys;
        soqlUpdate = sUPDATE;
        aes256Key = pAes256Key;
        blobAes256Key = Blob.valueOf(aes256key);
    }
    /**
     * return a ql with stored soql
     * @param BC
     * @return
     */
    global Database.querylocator start(Database.BatchableContext BC) {
        String htmlBody = 'Initiating Updated process for: ' + soqlUpdate;
        Utilities.sendEmail('rnendza@gmail.com', 'Salesforce.com Batch Encrypt Caller Id - Initiating Process', htmlBody, htmlBody);
        return Database.getQueryLocator(soqlUpdate);
    }
    /**
     * roll through scope, if caller_id__c is not null, attempt to encrypt it. if any error, abort the trans and send an error email.
     * savepoint exists merely for testing purposes.
     * @param BC
     * @param scope
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope != null && !scope.isEmpty()) {
            List<SObject> sObjects = scope;

            if (sObjects != null && !sObjects.isEmpty()) {
                List< Caller_Id_Conversion__c> cicsUpd = new List<Caller_Id_Conversion__c>();
                for (Sobject sObj : sObjects) {
                    Boolean anyUpdates = false;
                    Caller_Id_Conversion__c cic = (Caller_Id_Conversion__c) sObj;
                    if (cic.contact_name__c != null) {
                        try {
                            cic.encrypted_contact_name__c = doAes256Encrypt(String.valueOf(cic.contact_name__c));
                            anyUpdates = true;
                        } catch (EncryptException ee) {
                            sendErrorEmail('Error Encrypted clear Text', ee.getMessage() + ' ' + ee.getCause() + ' ' + ee.getStackTraceString(), emailAddys[0]);
                            break;
                        }
                    }
                    if (cic.ANI_DialNumber__c != null) {
                        try {
                            cic.encrypted_ani_dialnumber__c = doAes256Encrypt(String.valueOf(cic.ANI_DialNumber__c));
                            anyUpdates = true;
                        } catch (EncryptException ee) {
                            sendErrorEmail('Error Encrypted clear Text', ee.getMessage() + ' ' + ee.getCause() + ' ' + ee.getStackTraceString(), emailAddys[0]);
                            break;
                        }
                    }
                    if (anyUpdates) {
                        cicsUpd.add(cic); //only if there is no encrypting exception and there is a value.
                    }
                }
                if (!cicsUpd.isEmpty()) {
                    update cicsUpd;
                    iRowsUpdated = iRowsUpdated + cicsUpd.size();
                }
            }
        }
    }
    /**
     * @param clearText
     * @return encrypted string
     */
    private String doAes256Encrypt(String clearText) {
        String encodedCipherText;
        Blob iv;
        try {
            //@TODO move to custom meta data.
            iv = Blob.valueOf('carplsinitvector');
            Blob cipherText = Crypto.encrypt('AES256', blobAes256Key, iv, Blob.valueOf(clearText));
            encodedCipherText = EncodingUtil.base64Encode(cipherText);
        } catch (Exception e) {
            system.debug(logginglevel.error, e);
            throw new EncryptException('Problem encrypting ... clearText=' + clearText + ' with key=' + aes256Key + '..iv=' + EncodingUtil.base64Encode(iv), e);
        }
        return encodedCipherText;
    }
    /**
     *  here for testing for the most part.. used for asserts and example of how to decode.
     */
    @testVisible
    private String doAes256Decrypt(String encodedCipherText) {
        String decryptedClearText;
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        //@TODO move to custom metadata
        Blob iv = Blob.valueOf('carplsinitvector');
        Blob decryptedBlob = Crypto.decrypt('AES256', blobAes256Key, iv, encodedEncryptedBlob);
        decryptedClearText = decryptedBlob.toString();
        return decryptedClearText;
    }
    /**
     * Send an email with final results
     * @param BC
     */
    global void finish(Database.BatchableContext BC) {
        system.debug('---- rowsUpdated=' + iRowsUpdated);
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :BC.getJobId()
        ];
        String subject = 'CARPLS Salesforce.com Caller Id Batch UPDATE - status ' + a.status;
        String msg = '<html><body>';
        msg = 'The batch Apex job processed ' + a.TotalJobItems +
                ' batches with ' + a.NumberOfErrors + ' failures.';

        msg += '<br/><br/><b>Parameters Passed and Execution Counters:</b>';
        msg += '<br/>=========================================================================';
        msg += '<br/>=';
        msg += '<br/>=   soqlUpdate parm                  = ' + soqlUpdate;
        msg += '<br/>=   BaseUrl of Environment Executed =  ' + baseUrl;
        msg += '<br/>=';
        msg += '<br/>=   TOTAL # rows encrypted  => ' + iRowsUpdated;
        msg += '<br/>=';
        msg += '<br/>=========================================================================';
        msg += '</body></html>';

        String htmlBody = msg;
        Utilities.sendEmail('rnendza@gmail.com', subject, htmlBody, htmlBody);
    }
    global void sendErrorEmail(String subject, String body, String addy) {
        String htmlBody = body;
        Utilities.sendEmail(addy, subject, htmlBody, htmlBody);
    }
    public class EncryptException extends Exception {
    }
}