@isTest
private class TEST_BatchEncryptCallerId {
    final static Integer iNumRows = 100;

    @testSetup static void setup() {
        Datetime dtTstStart = Datetime.now();
        Id saProfileId = [select id from profile where name = 'System Administrator'].id;
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('', saProfileId, '', '');
        TEST_TestUtils.getUserForTest(sec, dtTstStart);

        List<Caller_Id_Conversion__c> cics = new List<Caller_Id_Conversion__c>();
        for (Integer i = 0; i < iNumRows; i++) {
            Caller_Id_Conversion__c cic;
            if (i < 3) {
                cic = new Caller_Id_Conversion__c(Contact_Name__c = Decimal.valueOf('6303100898'), Ani_DialNumber__c = Decimal.valueOf('6303109999'));
            } else {
                cic = new Caller_Id_Conversion__c(Contact_Name__c = Decimal.valueOf('630310' + i), Ani_DialNumber__c = Decimal.valueOf('630310' + i));
            }
            cics.add(cic);
        }
        insert cics;
    }
    /**
     * Valid key.. valid update.. all rows updated. encrypt / decrypt match.. and 6303100898 is decrypted the same multiple times.
     */
    static testMethod void fireBatchEncrypt_success_update() {
        User uTstExecUser = [SELECT id from user limit 1];
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:' + uTstExecUser);

        String soql = '';
        List<String> emailAddys = new List<String>{
                'rnendza@gmail.com'
        };
        soql += '   select id, contact_name__c, encrypted_contact_name__c, ANI_DialNumber__c,encrypted_ANI_DialNumber__c ';
        soql += '   from   caller_id_conversion__c ';

        System.runAs(uTstExecUser) {
            List<Carpls_Secure_Setting__mdt> secureSettings = [
                    SELECT AES256_Key__c
                    FROM Carpls_Secure_Setting__mdt
                    WHERE DeveloperName = 'BatchEncryptCallerId'
            ];
            String aes256Key = secureSettings[0].AES256_Key__c;

            Test.startTest();
                BatchEncryptCallerId b = new BatchEncryptCallerId(soql, emailAddys, aes256Key);
                id batchId = Database.executeBatch(b);
            Test.stopTest();

            List<Caller_Id_conversion__c> cics = [
                    SELECT id, contact_name__c, encrypted_contact_name__c, ANI_DialNumber__c,encrypted_ANI_DialNumber__c
                    FROM Caller_Id_Conversion__c
                    WHERE Encrypted_Contact_Name__c != null
            ];
            system.assert(cics.size() == iNumRows);

            Decimal d = Decimal.valueOf('6303100898');
            List<Caller_Id_conversion__c> cicsCompares = [
                    SELECT id, contact_name__c, encrypted_contact_name__c, ANI_DialNumber__c,encrypted_ANI_DialNumber__c
                    FROM Caller_Id_Conversion__c
                    WHERE contact_name__c = :d
            ];

            for (Caller_Id_Conversion__c cicsCompare : cicsCompares) {
                system.assert(b.doAes256Decrypt(cicsCompare.encrypted_contact_name__c) == '6303100898');
                system.assert(b.doAes256Decrypt(cicsCompare.encrypted_contact_name__c) == String.valueOf(cicsCompare.contact_name__c));
            }
        }
    }
    /**
     * bad AES256 key no rows will be updated.
     */
    static testMethod void fireBatchEncrypt_force_badkeyexception() {
        User uTstExecUser = [SELECT id from user limit 1];
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:' + uTstExecUser);

        String soql = '';
        List<String> emailAddys = new List<String>{
                'rnendza@gmail.com'
        };
        soql += '   select  id, contact_name__c, encrypted_contact_name__c, ANI_DialNumber__c,encrypted_ANI_DialNumber__c ';
        soql += '   from   caller_id_conversion__c ';

        System.runAs(uTstExecUser) {
            String aes256Key = 'badkey';
            system.debug('running with key=' + aes256Key);

            Test.startTest();
                BatchEncryptCallerId b = new BatchEncryptCallerId(soql, emailAddys, aes256Key);
                id batchId = Database.executeBatch(b);
            Test.stopTest();

            List<Caller_Id_conversion__c> cics = [
                    SELECT id, contact_name__c, encrypted_contact_name__c, ANI_DialNumber__c,encrypted_ANI_DialNumber__c
                    FROM Caller_Id_Conversion__c
                    WHERE Encrypted_Caller_Id__c != null
            ];
            system.assert(cics.isEmpty());
        }
    }
}