/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/21/09
**
** Rev. 2016/21/09: created
** 
** Usage: ScheduleContactCleanup
** 
** Description: Cleanup Case records.
****/
global class BatchDeleteCases implements DataBase.Batchable<sObject> {
    
    String soqlDelete;
	List<String>  lSendToEmails; 
    
        
    global BatchDeleteCases(String sDelete, List<String> sendToEmails){
    	if(sendToEmails == null || sendToEmails.isEmpty()) {
 			lSendToEmails = new List<String>{'Erica.cox@servioconsulting.com'};
 		} else {
 			lSendToEmails = sendToEmails;
 		}
            soqlDelete = sDelete;
            String msg = '\r------ BatchDeleteCases Constructor --------\r';
            msg += '--> SOQL Delete='+sDelete + '\r';
            msg += '-->  sendToEmail ='+lSendToEmails;
            System.debug(logginglevel.info, msg);
    }

    global Database.querylocator start(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(lSendToEmails);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        
        mail.setSubject('Contact Cleanup / Delete cases with no service record  Process Initiated.');
        mail.setPlainTextBody('Initiating process.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return Database.getQueryLocator(soqlDelete);
    }
    
    global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
        
        Id jobId = BC.getJobId();   
                       	
    	if(scope != null && !scope.isEmpty()) { 
    		Integer iScopeSize = scope.size();	
      		delete scope; 
      		String msg = '\r------ BatchDeleteCases Execute() --------\r';
            msg += '--> jobId='+jobId + '\r';
            msg += '--> scopeSize='+iScopeSize;
            System.debug(logginglevel.info, msg);
    	} 
   }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob WHERE Id =
                            :BC.getJobId()];
        String dmsg = '\r------ BatchDeleteCases Finish() --------\r';
        Id jobId = BC.getJobId();
        String sStatus = a.status;
        dmsg += '--> jobId='+jobId + '\r';
        dmsg += '--> status='+sStatus;
        System.debug(logginglevel.info, dmsg);                    
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        mail.setToAddresses(lSendToEmails);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        
        mail.setSubject('Contact Cleanup / Delete cases with no service record Process -- '+a.status);
        
        String msg = 'The batch Apex job processed ' + a.TotalJobItems +
                     ' batches with '+ a.NumberOfErrors + ' failures. Exact counts to come in future release';
                     
   
        mail.setPlainTextBody(msg);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}