/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/28/10
**
** Rev - Will only delete those without a Category. Also includes account information so that delete can leave the contact recoverable
** 
** Usage: Scheduled job
** NOTE: This is one of 4 scheduled jobs that must run in a particular order:
**  
**    1. ScheduleDeleteCases
**    2. ScheduleIncompleteToInquiry
**	  3. ScheduleContactCleanup
**    4. **** THIS JOB (DeleteContactsNoCategory)
** 
** Description: All contacts with a null or empty category and no case party records should be deleted. 
****/
global class ScheduleDeleteContacts implements Schedulable {
   
    //every day at midnight - BEFORE the contact updates
    public static String CRON_EXP = '0 0 12 * * ?';
     
    public static String SOQL_DELETE = 'SELECT Id, AccountId, Account.npsp__Number_of_Household_Members__c, Account.RecordType.Name '
    		+ ' FROM Contact WHERE (Category__c = null or Category__c =\'\')'
            + 'and id not in(SELECT Contact__c from Case_Party__c) '
            + 'and npo02__TotalOppAmount__c = 0 and npo02__LastCloseDateHH__c =null';
     
    global void execute(SchedulableContext ctx) { 
                
        String email = 'Erica.cox@servioconsulting.com';
        List<String> lEmails = new List<String> { email };

        BatchDeleteContacts batch = new BatchDeleteContacts(SOQL_DELETE,lEmails);
        ID myBatchJobID = database.executebatch(batch);
        System.debug(logginglevel.warn,'Scheduled batchJobId for soqlDelete='+myBatchJobID);
    }

}