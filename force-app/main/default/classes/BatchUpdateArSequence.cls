/**
 * Note: one should turn off the process builder processes on AR before executing this.
 */
global class BatchUpdateArSequence implements DataBase.Batchable<sObject>, Database.Stateful {

    String soqlUpdate;
    String status;
    List<String> emailAddys;
    static String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

    global List<SObject> sObjectsQueried = new List<SObject>();
    global Integer iArRowsUpdated = 0;
    global Boolean bCommitTrans = false;


    global BatchUpdateArSequence(String sUPDATE, List<String> pEmailAddys, Boolean pCommitTrans) {
        emailAddys = pEmailAddys;
        soqlUpdate = sUPDATE;
        bCommitTrans = pCommitTrans;

    }

    global Database.querylocator start(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(emailAddys);
        mail.setSenderDisplayName('CARPLS Salesforce.com Automation');

        mail.setSubject('Salesforce.com Batch UPDATE Applied Resources - Initiating Process');
        mail.setPlainTextBody('Initiating UPDATE process for: ' + soqlUpdate);
        mail.setHtmlBody('Initiating UPDATE Process for: ' + soqlUpdate);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });

        return Database.getQueryLocator(soqlUpdate);
    }

    global void execute(Database.BatchableContext BC,
            List<sObject> scope) {
        if (scope != null && !scope.isEmpty()) {
            //rowsProcessed += scope.size();
            List<SObject> sObjects = scope;

            if (sObjects != null && !sObjects.isEmpty()) {
                List<Applied_Resource__c> ars = new List<Applied_Resource__c>();
                Map<Id, Map<String, List<Applied_Resource__c>>> mCaseId_mArTypeArs = new Map<Id, Map<String, List<Applied_Resource__c>>>();

                for (Sobject so : sObjects) {
                    Applied_Resource__c ar = (Applied_Resource__c) so;
                    if (!mCaseId_mArTypeArs.containsKey(ar.case__C)) {
                        mCaseId_mArTypeArs.put(ar.case__c, new Map<String, List<Applied_Resource__c>>{
                                ar.type__c => new List<Applied_Resource__c>{
                                        ar
                                }
                        });
                    } else {
                        Map<String, List<Applied_Resource__c>> mTypeArs = (Map<String, List<Applied_Resource__c>>) mCaseId_mArTypeArs.get(ar.case__c);
                        if (!mTypeArs.containsKey(ar.type__c)) {
                            mTypeArs.put(ar.type__c, new List<Applied_Resource__c>{
                                    ar
                            });
                        } else {
                            List<Applied_Resource__c> caseArs = (List<Applied_Resource__c>) mTypeArs.get(ar.type__c);
                            caseArs.add(ar);
                        }
                    }
                }
                List<Applied_Resource__c> arsToUpd = new List<Applied_Resource__c>();
                for (Id caseId : mCaseId_mArTypeArs.keySet()) {

                    Map<String, List<Applied_Resource__c>> mTypeArs = (Map<String, List<Applied_Resource__c>>) mCaseId_mArTypeArs.get(caseId);
                    system.debug(mTypeArs);
                    for (String arType : mTypeArs.keySet()) {
                        Integer iTypeSeq = 1;
                        List<Applied_Resource__c> typeArs = mTypeArs.get(arType);
                        for (Applied_Resource__c ar : typeArs) {
                            ar.case_sequence__c = iTypeSeq;
                            iTypeSeq++;
                            arsToUpd.add(ar);
                        }
                    }
                }

                if (!arsToUpd.isEmpty()) {
                    try {
                        Savepoint sp = Database.setSavepoint();
                        update arsToUpd;
                        iArRowsUpdated = iArRowsUpdated + arsToUpd.size();
                        if(!bCommitTrans) {
                            Database.rollback(sp);
                        }
                    } catch (Exception e) {
                        System.debug(logginglevel.error, e);
                        sendErrorEmail(e.getMessage(), e.getStackTraceString(), emailAddys);
                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('---- arrowsUpdated='+iArRowsUpdated);
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =
                        :BC.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(emailAddys);
        mail.setSenderDisplayName('CARPLS Salesforce.com Automation - Batch UPDATE');

        mail.setSubject('CARPLS Salesforce.com Batch UPDATE - AR Seq by AR Type: -- ' + a.status);
        String msg = '<html><body>';
        msg = 'The batch Apex job processed ' + a.TotalJobItems +
                ' batches with ' + a.NumberOfErrors + ' failures.';

        msg += '<br/><br/><b>Parameters Passed and Execution Counters:</b>';
        msg += '<br/>=========================================================================';
        msg += '<br/>=';
        msg += '<br/>=   soqlUpdate parm                  = ' + soqlUpdate;
        msg += '<br/>=   bCommitTrans parm                = ' + bCommitTrans;
        msg += '<br/>=   BaseUrl of Environment Executed =  ' + baseUrl;
        msg += '<br/>=';
        msg += '<br/>=   TOTAL # of AR records UPDATED  => ' + iArRowsUpdated;
        msg += '<br/>=';
        if (bCommitTrans) {
            msg += '<br/>=<font color=blue>   Transaction is Comitted and Database Changes Saved!</font>';
        } else {
            msg += '<br/>= <font color=red>  xx Tranaction is Rolled Back Per Parm Passed.. No Database Changes Made xx </font> ';
        }
        msg += '<br/>=========================================================================';
        msg += '</body></html>';
        mail.setHtmlBody(msg);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
    global void sendErrorEmail(String subject, String body, List<String> emailAddys) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(emailAddys);
        mail.setSenderDisplayName('CARPLS Salesforce.com Automation - Batch UPDATE');
        mail.setSubject('CARPLS Salesforce.com Batch UPDATE Error: -- ' + subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}