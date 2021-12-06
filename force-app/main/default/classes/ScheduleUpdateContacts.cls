/*
**	This class will execute the class UpdateContactsToFormer on a schedule
** 	UpdateContactsToFormer will change the status on the Contact record to 
**	Former if the Last_Service_Date__c field is more than 6 months in the past. 
**	This only touches those records with a Category of Client. 
**	Note: category is a multi-select picklist
**	Suggestion to run as a nightly, or even weekly, scheduled job.
** 	Modified by Sergii Korolivskyi at 10/26/2020 
**	Removed call of UpdateContactsToFormer.cls as he is deprecated and replaced by BatchUpdateContactsToFormer.cls   
*/

global class ScheduleUpdateContacts implements Schedulable {

	global void execute(SchedulableContext sc) {
		
		//new UpdateContactsToFormer();
        BatchUpdateContactsToFormer batch = new BatchUpdateContactsToFormer(); //ur batch class
      	database.executebatch(batch,200);
	}

}