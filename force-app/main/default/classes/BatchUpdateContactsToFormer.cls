/*
**	This class will execute the class BatchUpdateContactsToFormer on a schedule
** 	BatchUpdateContactsToFormer will change the status on the Contact record to 
**	Former if the Last_Service_Date__c field is more than 6 months in the past. 
**	This only touches those records with a Category of Client. 
**	Note: category is a multi-select picklist
**	Suggestion to run as a nightly, or even weekly, scheduled job.
** 	Created by Sergii Korolivskyi at 10/26/2020
*/

global class BatchUpdateContactsToFormer implements Database.Batchable <SObject> {
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id '+
            'FROM Contact '+ 
            'WHERE Last_Service_Date__c < LAST_N_MONTHS:6 '+  
            'AND Category__c INCLUDES (\'Client\') '+
            'AND Status__c <> \'Former\'';
        return Database.getQueryLocator(query);
    }
    
    
    //Execute Method
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        if(scope != null && !scope.isEmpty()) {
            for (Contact c : scope)  {
                c.Status__c = 'Former';
            }
            update scope;
        }
    }
    
    //Finish Method
    global void finish(Database.BatchableContext bc) {
        Id batchId = bc.getJobId();
        system.debug('BatchId::'+ batchId);
    }
    
}