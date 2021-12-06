/****
**    Servio Consulting, LLC.
** Erica COx
** 12/16/2016

**
** Usage: Scheduled job 
** NOTE: This is one of 4 scheduled jobs that must run in a particular order:
**  
**    1. ScheduleDeleteCases
**    2. *** This job (ScheduleIncompleteToInquiry)
**	  3. ScheduleContactCleanup
**    4. DeleteContactsNoCategory
**
** Description: Will add Inquiry to the category of a contact with Incomplete status if it isn't already there
****/
global class ScheduleIncompleteToInquiry implements Schedulable { 
    //every day at 1am
    public static String CRON_EXP = '0 0 01 * * ?';
      
    global void execute(SchedulableContext ctx) { 
                
        String email = 'Erica.cox@servioconsulting.com';
        List<String> lEmails = new List<String> { email };
               
        // Those that do have an Incomplete status should be changed to Inquiry. There won't be a category of client because that will be deleted with the case
         String soqlIncompleteToInquiry = 'SELECT ID, Category__c FROM Contact '
        	+' WHERE Category__c EXCLUDES(\'Inquiry\') '         
            +' and Status__c = \'Incomplete\'';
 
    	BatchIncompleteToInquiry batch3 = new BatchIncompleteToInquiry(soqlIncompleteToInquiry,lEmails);
        ID myBatchJobID3 = database.executebatch(batch3);
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlIncompleteToInquiry='+myBatchJobID3);
    }
}