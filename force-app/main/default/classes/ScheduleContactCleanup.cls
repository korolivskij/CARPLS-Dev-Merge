/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/21/09

**
** Rev. 2016/21/09: created
** Rev. 2016/10/24: ELC: removed typo from new Inquiry category
** Rev. 2016/11/13: ELC: Added Attorney to CaseParty type check
** Rev. 2016/11/27: ELC: Simplified delete case SOQL to just check for Incomplete status. Added better support for contacts without category.
** Rev. 2016/11/30: ELC: moved BatchDeleteCase call to another scheduled job, as these batches are async and it needed to happen first
** Rev. 2016/12/16: ELC: changed to ONLY remove invalid categories of Party and Client. Calling several async jobs was causing issues with concurrency
**
** Usage: Scheduled job 
** NOTE: This is one of 4 scheduled jobs that must run in a particular order:
**  
**    1. ScheduleDeleteCases
**    2. ScheduleIncompleteToInquiry
**	  3. *** This job (ScheduleContactCleanup)
**    4. DeleteContactsNoCategory
**
** Description: Will remove a category of Client or Party if is in not valid (no appropriate case party records)
****/
global class ScheduleContactCleanup implements Schedulable {
    //every day at 1am
    public static String CRON_EXP = '0 0 01 * * ?';
      
    global void execute(SchedulableContext ctx) { 
                
        String email = 'Erica.cox@servioconsulting.com';
        List<String> lEmails = new List<String> { email };
 
 		// ELC - had to move this to a separate batch job that needs to be called several hours prior to this one. Because these are 
 		// scheduled asynchronously, we couldn't count on this processing before the contact cleanup jobs as required. Also made more 
 		// broad to include those cases left incomplete through a tab close.          
        //------------------------------------------
        //i.	Delete case created that day with no service record attached (associated case party records will be automatically deleted)
        //select c.ID from Case c where Contact.Category__c INCLUDES('Inquiry')
        /*
		String soqlDeleteCase = 'select c.ID  from Case c where '
                   + ' Contact.Status__c = \'Incomplete\''
                   + ' and c.ID not in (select Case__c from Consultation__c)'
                   + ' and CreatedDate = LAST_N_DAYS:1';

        BatchDeleteCases batch = new BatchDeleteCases(soqlDeleteCase,lEmails);
        ID myBatchJobID1 = database.executebatch(batch);
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlDeleteCase='+myBatchJobID1);
        //------------------------------------------
       
        // First clean up party records with no caseParty records as Party       
        String soqlCleanupPartyCategory = 'SELECT ID, Category__c FROM Contact WHERE Category__c INCLUDES(\'Party\') '
            +' and ID not in (SELECT Contact__c from Case_Party__c WHERE Type__c in(\'Adverse party\',\'Interested party\',\'Attorney\'))';
        //TODO: i.	remove category of Party 
        //TODO: ii.	delete contact record if category is now empty
        BatchCleanupInvalidContactCategory batch1 = new BatchCleanupInvalidContactCategory(soqlCleanupPartyCategory,'Party','', lEmails);
        ID myBatchJobID1 = database.executebatch(batch1);
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlChangePartyCategory='+myBatchJobID1);
        //------------------------------------------
 */
 
        // Note that contacts can be left with a Party category but no caseParty if an intake search is cancelled before the case is created.        
        String soqlCleanupClientCategory = 'SELECT ID, Category__c FROM Contact WHERE Category__c INCLUDES(\'Party\') '
            +' and ID not in (SELECT Contact__c from Case_Party__c WHERE Type__c in(\'Adverse party\',\'Interested party\',\'Attorney\'))';
        //TODO: i.	remove category of Party
        BatchCleanupInvalidContactCategory batch2 = new BatchCleanupInvalidContactCategory(soqlCleanupClientCategory,'Party', lEmails); 
        ID myBatchJobID2 = database.executebatch(batch2); 
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlChangePartyCategory='+myBatchJobID2);
        //------------------------------------------
               
        // Those that do have an Incomplete status should be changed to Inquiry. There shouldn't be a category of client here, but just in case...
         String soqlCleanupClientCategory2 = 'SELECT ID, Category__c FROM Contact '
        	+' WHERE Category__c INCLUDES(\'Client\') '         
            +' and ID not in (SELECT Contact__c from Case_Party__c WHERE Type__c = \'Client\')';
     	//TODO: i.	remove Category of Client 
    	BatchCleanupInvalidContactCategory batch3 = new BatchCleanupInvalidContactCategory(soqlCleanupClientCategory2,'Client', lEmails);
        ID myBatchJobID3 = database.executebatch(batch3);
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlChangeClientCategory='+myBatchJobID3);
        
    }
}