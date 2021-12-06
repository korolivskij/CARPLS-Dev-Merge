global class BatchDelete implements DataBase.Batchable<sObject>, Database.Stateful {
	
	String soqlDelete;
	String status;
	List<String> emailAddys;
	static String baseUrl =  URL.getSalesforceBaseUrl().toExternalForm();
	
	global List<SObject> sObjectsQueried = new List<SObject>();
	global Integer iRowsProcessed = 0;
	global Integer iRowsDeleted = 0;
	global Boolean bCommitTrans = false;
   

		
 	global BatchDelete(String sDelete, List<String> pEmailAddys,  Boolean pCommitTrans ){
 			emailAddys = pEmailAddys;
 			soqlDelete = sDelete;
  			bCommitTrans = pCommitTrans;
 	}

	global Database.querylocator start(Database.BatchableContext BC){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setToAddresses(emailAddys);
		mail.setSenderDisplayName('CARPLS Salesforce.com Automation - BATCH DELETE');
		
		mail.setSubject('Salesforce.com Batch Delete - Initiating Process');
		mail.setPlainTextBody('Initiating Delete process for: '+ soqlDelete);
		mail.setHtmlBody('Initiating Delete Process for: '+soqlDelete);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return Database.getQueryLocator(soqlDelete);
    }
    
	global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
        if(scope != null && !scope.isEmpty()) {
        	
        	//rowsProcessed += scope.size();
        	List<SObject> sObjects = scope;        	

        	
        	if(sObjects!= null && !sObjects.isEmpty()) {
        		
        			try {
        				Savepoint sp = Database.setSavepoint();
        				delete sObjects;
        				iRowsDeleted += sObjects.size();
        				if(!bCommitTrans) {
        					Database.rollback(sp);
        				}        				
        			
           			} catch (DmlException dmlEx) {
        				System.debug(logginglevel.error, dmlEx);
        			} catch (Exception e) {
        				System.debug(logginglevel.error, e);
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
		mail.setSenderDisplayName('CARPLS Salesforce.com Automation - Batch Delete');
		
		mail.setSubject('CARPLS Salesforce.com Batch Delete Status: -- '+a.status);
		String msg = '<html><body>';
		msg = 	'The batch Apex job processed ' + a.TotalJobItems +
   				' batches with '+ a.NumberOfErrors + ' failures.';
		
   		msg += '<br/><br/><b>Parameters Passed and Execution Counters:</b>';		 
   		msg += '<br/>=========================================================================';
   		msg += '<br/>=';			 
   		msg += '<br/>=   soqlDelete parm                  = '+soqlDelete;
   		msg += '<br/>=   bCommitTrans parm                = '+bCommitTrans;
   		msg += '<br/>=   BaseUrl of Environment Executed =  '+baseUrl;
   		msg += '<br/>=';
		msg += '<br/>=   TOTAL # of records DELETED  => ' + iRowsDeleted;		
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
}