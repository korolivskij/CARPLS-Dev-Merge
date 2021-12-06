/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/28/10
**
** REV: Will only delete contacts with no category. Changed to delete the HH account if this is the last mamber. If not, something is probably wrong,
**		as this is likely a donor HH, so don't delete.
**		This assures that the contacts are still recoverable from the recycle bin. 
**
** Usage: ScheduleDeleteContacts
** 
** Description: delete Contact records.
****/
global class BatchDeleteContacts implements DataBase.Batchable<sObject> {
    
    public static String CRON_EXP = '0 0 01 * * ?';
   
    String soqlDelete;
	List<String>  lSendToEmails; 
      
    global BatchDeleteContacts(String sDelete, List<String> sendToEmails){
    	if(sendToEmails == null || sendToEmails.isEmpty()) {
 			lSendToEmails = new List<String>{'Erica.cox@servioconsulting.com'};
 		} else {
 			lSendToEmails = sendToEmails;
 		}
            soqlDelete = sDelete;
            String msg = '\r------ BatchDeleteContacts Constructor --------\r';
            msg += '--> SOQL Delete='+sDelete + '\r';
            msg += '-->  sendToEmail ='+lSendToEmails;
            System.debug(logginglevel.info, msg);
    }

    global Database.querylocator start(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(lSendToEmails);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        
        mail.setSubject('Delete Contacts process initiated.');
        mail.setPlainTextBody('Initiating process.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return Database.getQueryLocator(soqlDelete);
    }
    
    global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
        //system.debug('BatchDeleteContacts->execute()');
                           
        Id jobId = BC.getJobId();   
                       	
    	if(scope != null && !scope.isEmpty()) { 
    		Integer iScopeSize = scope.size();	
    		
            List<Contact> clist = (List<Contact>)scope;
            Set<Id> accountIdsToDelete = new Set<Id>();           
            //system.debug('BatchDeleteContacts->execute()->delete scope; ');
            
            for (Contact c: clist) {
            	if (c.Account.npsp__Number_of_Household_Members__c == 1) {
            		accountIdsToDelete.add(c.AccountId);
            	}
            }
      		delete [select id from Account where id = :accountIdsToDelete];            

      		 
      		String msg = '\r------ BatchDeleteContacts Execute() --------\r';
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
        String dmsg = '\r------ BatchDeleteContacts Finish() --------\r';
        Id jobId = BC.getJobId();
        String sStatus = a.status;
        dmsg += '--> jobId='+jobId + '\r';
        dmsg += '--> status='+sStatus;
        System.debug(logginglevel.info, dmsg);                    
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        mail.setToAddresses(lSendToEmails);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        
        mail.setSubject('Delete Contacts Process -- '+a.status);
        
        String msg = 'The batch Apex job processed ' + a.TotalJobItems +
                     ' batches with '+ a.NumberOfErrors + ' failures. Exact counts to come in future release';
                     
   
        mail.setPlainTextBody(msg);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  
}