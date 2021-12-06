/*
** 	This class changes the status of Subject records
**  to Archived if they haven't been used in 6 months. 
**	The test for use is an entry in 
**	the AppliedResources object with the given 
**	Subject and a type of FAQ. The second check 
**	is necessary because the subject 
**	field is populated for other resources as well.
**  by Sergii Korolivskyi at 11/02/2020
*/

global class BatchUpdateSubjectToArchived implements Database.Batchable <SObject>  {
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Status__c, Title__c, '+
            '(SELECT Id, Type__C From Applied_Resources__r WHERE Type__c = \'FAQ\' AND CreatedDate > LAST_N_MONTHS:6 LIMIT 1) '+
            'FROM Subject__c WHERE Status__c <> \'Archived\' ' +
            'AND Id IN (SELECT Subject__c FROM Applied_Resource__c WHERE Type__c = \'FAQ\' AND CreatedDate < LAST_N_MONTHS:6)';
        return Database.getQueryLocator(query);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext bc, List<Subject__c> scope) {
 	
        if(scope != null && !scope.isEmpty()) {

            for (Subject__c sbj : scope) {
                if(sbj.Applied_Resources__r.isEmpty()){
                    sbj.Status__c = 'Archived';
                }
            }
            try {
                update scope;
            } catch (Exception e) {
                System.debug('Exception in UpdateSubjectToArchived when updating Subjects '+e);
            }
        }
    }
    
    //Finish Method
    global void finish(Database.BatchableContext bc) {
       
    }
}