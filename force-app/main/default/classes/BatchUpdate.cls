global class BatchUpdate implements DataBase.Batchable<sObject>, Database.Stateful {
    
    String soqlUpdate;
    String status;
    List<String> emailAddys;
    static String baseUrl =  URL.getSalesforceBaseUrl().toExternalForm();
    
    global List<SObject> sObjectsQueried = new List<SObject>();
    global Integer iRowsProcessed = 0;
    global Integer iRowsUpdated = 0;
    global Boolean bCommitTrans = false;
   

        
    global BatchUpdate (String sUPDATE, List<String> pEmailAddys,  Boolean pCommitTrans ){
            emailAddys = pEmailAddys;
            soqlUpdate = sUPDATE;
            bCommitTrans = pCommitTrans;
    }

    global Database.querylocator start(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(emailAddys);
        mail.setSenderDisplayName('CARPLS Salesforce.com Automation - BATCH UPDATE');
        
        mail.setSubject('Salesforce.com Batch UPDATE - Initiating Process');
        mail.setPlainTextBody('Initiating UPDATE process for: '+ soqlUpdate);
        mail.setHtmlBody('Initiating UPDATE Process for: '+soqlUpdate);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return Database.getQueryLocator(soqlUpdate);
    }
    
    global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
        if(scope != null && !scope.isEmpty()) {
            
            //rowsProcessed += scope.size();
            List<SObject> sObjects = scope;         

            
            if(sObjects!= null && !sObjects.isEmpty()) {
                
                    try {
                        Savepoint sp = Database.setSavepoint();
                        UPDATE sObjects;
                        iRowsUpdated += sObjects.size();
                        if(!bCommitTrans) {
                            Database.rollback(sp);
                        }                       
                    
                    } catch (DmlException dmlEx) {
                        System.debug(logginglevel.error, dmlEx);
                        sendErrorEmail(dmlEx.getMessage(), dmlEx.getStackTraceString(), emailAddys);
                    } catch (Exception e) {
                        System.debug(logginglevel.error, e);
                        sendErrorEmail(e.getMessage(), e.getStackTraceString(), emailAddys);
                    }
            
            }                       
        }
   }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob WHERE Id =
                            :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        mail.setToAddresses(emailAddys);
        mail.setSenderDisplayName('CARPLS Salesforce.com Automation - Batch UPDATE');
        
        mail.setSubject('CARPLS Salesforce.com Batch UPDATE Status: -- '+a.status);
        String msg = '<html><body>';
        msg =   'The batch Apex job processed ' + a.TotalJobItems +
                ' batches with '+ a.NumberOfErrors + ' failures.';
        
        msg += '<br/><br/><b>Parameters Passed and Execution Counters:</b>';         
        msg += '<br/>=========================================================================';
        msg += '<br/>=';             
        msg += '<br/>=   soqlUpdate parm                  = '+soqlUpdate;
        msg += '<br/>=   bCommitTrans parm                = '+bCommitTrans;
        msg += '<br/>=   BaseUrl of Environment Executed =  '+baseUrl;
        msg += '<br/>=';
        msg += '<br/>=   TOTAL # of records UPDATED  => ' + iRowsUpdated;       
        msg += '<br/>=';
        if(bCommitTrans){   
            msg += '<br/>=<font color=blue>   Transaction is Comitted and Database Changes Saved!</font>';      
        } else {
            msg += '<br/>= <font color=red>  xx Tranaction is Rolled Back Per Parm Passed.. No Database Changes Made xx </font> ';
        }            
        msg += '<br/>=========================================================================';             
        msg += '</body></html>';
        mail.setHtmlBody(msg);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    global void sendErrorEmail(String subject, String body, List<String> emailAddys) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        mail.setToAddresses(emailAddys);
        mail.setSenderDisplayName('CARPLS Salesforce.com Automation - Batch UPDATE');    
        mail.setSubject('CARPLS Salesforce.com Batch UPDATE Error: -- '+subject);        
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}