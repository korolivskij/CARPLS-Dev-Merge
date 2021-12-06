/****
**    Servio Consulting, LLC.
** Erica Cox
** 12/16/2016
**
** Usage: ScheduleIncompleteToInquiry
** 
** Description: Add category of Inquiry if it doesn't exist and status is Incomplete.
****/
global class BatchIncompleteToInquiry implements DataBase.Batchable<sObject> {
    
    String soqlUpdate;
	List<String>  lSendToEmails; 
        
    global BatchIncompleteToInquiry(String sUpdate, List<String> sendToEmails){
    	if(sendToEmails == null || sendToEmails.isEmpty()) {
 			lSendToEmails = new List<String>{'Erica.cox@servioconsulting.com'};
 		} else {
 			lSendToEmails = sendToEmails;
 		}
        soqlUpdate = sUpdate;
                                                   
        String msg = '\r------ BatchCleanupInvalidContactCategory Constructor --------\r';
        msg += '--> SOQL Update='+sUpdate + '\r';
        msg += '-->  sendToEmail ='+lSendToEmails;
        System.debug(logginglevel.info, msg);
    }

    global Database.querylocator start(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(lSendToEmails);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        
        mail.setSubject('Set contacts to Inquiry process Initiated');
        mail.setPlainTextBody('Initiating process.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return Database.getQueryLocator(soqlUpdate);
    }
    
    global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
        
        Id jobId = BC.getJobId();   
                       	
    	if(scope != null && !scope.isEmpty()) { 
    		Integer iScopeSize = scope.size();
            
            List<Contact> clist = (List<Contact>)scope;
            List<Contact> listToUpdate = new List<Contact>();
             
            for(Contact c : clist)
            {
                //System.debug('Batch.Execute:c.Id:' + c.Id);
                System.debug('c.Category__c before addition of Inquiry:' + c.Category__c);
                if (c.Category__c != null || c.Category__c == '') {
                	c.Category__c = 'Inquiry; '+ c.Category__c;               	
                } else {
                	c.Category__c = 'Inquiry';
                }
                
                System.debug('c.Category__c after addition:' + c.Category__c);
  				listToUpdate.add(c);
            }
            
            if(!listToUpdate.isEmpty())
               update listToUpdate;
            
            
      		String msg = '\r------ BatchIncompleteToInquiry Execute() --------\r';
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
        String dmsg = '\r------ BatchCleanupInvalidContactCategoryIncompleteToInquiry Finish() --------\r';
        Id jobId = BC.getJobId();
        String sStatus = a.status;
        dmsg += '--> jobId='+jobId + '\r';
        dmsg += '--> status='+sStatus;
        System.debug(logginglevel.info, dmsg);                    
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        mail.setToAddresses(lSendToEmails);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        
        mail.setSubject('Incomplete to Inquiry Process -- '+a.status);
        
        String msg = 'The batch Apex job processed ' + a.TotalJobItems +
                     ' batches with '+ a.NumberOfErrors + ' failures. Exact counts to come in future release';
   
        mail.setPlainTextBody(msg);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}