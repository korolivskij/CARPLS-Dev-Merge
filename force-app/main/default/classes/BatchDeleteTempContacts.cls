global class BatchDeleteTempContacts implements DataBase.Batchable<sObject> {
	
	String soqlDelete;
	List<String>  lSendToEmails; 
		
 	global BatchDeleteTempContacts(String sDelete, List<String> sendToEmails){
 		if(sendToEmails == null || sendToEmails.isEmpty()) {
 			lSendToEmails = new List<String>{'rnendza@gmail.com'};
 		} else {
 			lSendToEmails = sendToEmails;
 		}
 		soqlDelete = sDelete;
 	}

	global Database.querylocator start(Database.BatchableContext BC){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		//mail.setToAddresses(new String[] {email});
		mail.setToAddresses(lSendToEmails);
		mail.setSenderDisplayName('Carpls Salesforce Automation');
		
		mail.setSubject('Carpls - Batch Temp Contact Delete / Lead Convert Process Initiated');
		mail.setPlainTextBody('Initiating process to delete temp Contact records and create as leads.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return Database.getQueryLocator(soqlDelete);
    }
    
	global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
			try {
				List<Contact> delContacts =  (List<Contact>)scope;
				List<Id> cIds = new List<Id>();
				//Get all fields on Contact
				if(delContacts != null && !delContacts.isEmpty()) {
					for(Contact c : delContacts) {
						cIds.add(c.id);
					}
				} else {
					return;	
				}
				//delContacts.clear();
				
				//--------delContacts = ContactUtils.retrieveAllContactInfo(cIds);
				delContacts = LeadUtils.retrieveContactsForLeadCopy(cIds);
 			
				if(delContacts!=null && !delContacts.isEmpty()) {
					Set<Id> sLeadIdsIns = LeadUtils.createLeads(delContacts);
				}
				
				Set<Id> delContactIds = new Set<Id>();
				for(Contact c : delContacts) {
					delContactIds.add(c.id);
				}	
							
				Set<Id> deletedContactIds = ContactUtils.deleteContacts(delContactIds);
				Integer numDel = 0;
				if(deletedContactIds != null) {
					numDel = deletedContactIds.size();
				}
				System.debug(LoggingLevel.INFO, '  Deleted TEMP Contact RECORDS.. # deleted -->'+numDel);	
			} catch (Exception e) {
				System.debug(LoggingLevel.ERROR, ' ERROR DELETING TEMP Contact RECORDS -->'+e);	
			}
   }
 	
	global void finish(Database.BatchableContext BC){
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      					TotalJobItems, CreatedBy.Email
      					FROM AsyncApexJob WHERE Id =
      						:BC.getJobId()];
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
		mail.setToAddresses(lSendToEmails);
		
		mail.setSenderDisplayName('Carpls Batch Processing');
		
		mail.setSubject('Batch Temp Contact Delete Process status -- '+a.status);
		
		String msg = 'The batch Apex job processed ' + a.TotalJobItems +
   					 ' batches with '+ a.NumberOfErrors + ' failures. Note.. exact counts will come in a future upgrade. see SFDC Leads tab to confirm for now.';
   					 
   
		mail.setPlainTextBody(msg);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}