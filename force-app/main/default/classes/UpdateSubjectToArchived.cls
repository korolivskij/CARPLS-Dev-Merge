/*
** 	This class changes the status of Subject records
**  to Archived if they haven't been used in 6 months. 
**	The test for use is an entry in 
**	the AppliedResources object with the given 
**	Subject and a type of FAQ. The second check 
**	is necessary because the subject 
**	field is populated for other resources as well.
*/

public with sharing class UpdateSubjectToArchived {

	public UpdateSubjectToArchived() {
				
		processSubjectRecords();
	}

	private void processSubjectRecords() {

		List<Subject__c> subjects = new List<Subject__c>();
		
		List<AggregateResult> appliedResources = 
		   [SELECT Subject__c SubjectId
			FROM Applied_Resource__c
			WHERE Type__c = 'FAQ' AND Subject__r.Status__c <> 'Archived'
			GROUP BY Subject__c
			HAVING Max(CreatedDate) < LAST_N_MONTHS:6];

		for (AggregateResult ar : appliedResources) {
		
			subjects.add(
				new Subject__c(
					Id=(Id)ar.get('SubjectId'), 
					Status__c = 'Archived'
				)
			);
		}

		try {
			update subjects;
		} catch (Exception e) {
			System.debug('Exception in UpdateSubjectToArchived when updating Subjects '+e);
		}
	}
}