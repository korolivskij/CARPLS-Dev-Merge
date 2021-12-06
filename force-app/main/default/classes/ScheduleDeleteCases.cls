/****
**    Servio Consulting, LLC.
** Erica Cox
** 11/30/16
**
** Usage: Scheduled job 
** NOTE: This is one of 4 scheduled jobs that must run in a particular order:
**  
**    1. *** THIS JOB (ScheduleDeleteCases) 
**    2. ScheduleIncompleteToInquiry
**	  3. ScheduleContactCleanup
**    4. DeleteContactsNoCategory
** 
** Description: Cleanup Case records left by tab close during intake or incomplete clients. MUST be scheduled several hours prior to 
** 				ScheduleContactCleanup.
****/
global class ScheduleDeleteCases implements Schedulable {
    //every day at 11pm
    //public static String CRON_EXP = '0 0 23 * * ?';
      
    global void execute(SchedulableContext ctx) { 
                
        String email = 'Erica.cox@servioconsulting.com';
        List<String> lEmails = new List<String> { email };
 
        // Delete cases that are Carpls Cases (not defects), have no problem code, and no services
        // Can't check for null description in an SOQL call, unfortunately

		String soqlDeleteCase = 'select c.ID  from Case c where '
				   + ' RecordType.name = \'Carpls Cases\''
                   + ' and Problem_Code__c = \'\''
                   + ' and c.ID not in (select Case__c from Consultation__c)';

        BatchDeleteCases batch = new BatchDeleteCases(soqlDeleteCase,lEmails);
        ID myBatchJobID1 = database.executebatch(batch);
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlDeleteCase='+myBatchJobID1);

        
    }
}