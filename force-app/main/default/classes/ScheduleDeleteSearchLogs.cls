global class ScheduleDeleteSearchLogs implements Schedulable {
    //every day at 1am
    public static String CRON_EXP = '0 0 01 * * ?';
     
    global void execute(SchedulableContext ctx) { 
        String soqlDelete = '';
        
        String email = 'rnendza@gmail.com';
        List<String> lEmails = new List<String> { email };
        lEmails.add('ericacox10@gmail.com');
        
        soqlDelete = 'select id from search_log__c';
        BatchDeleteSearchLogs batch = new BatchDeleteSearchLogs(soqlDelete,lEmails);
        ID myBatchJobID1 = database.executebatch(batch);
        System.debug(logginglevel.warn,'Scheduled batchJobId for slDelete='+myBatchJobID1);

        soqlDelete = 'select id from Possible_Conflict__c';
        BatchDeleteSearchLogs batch2 = new BatchDeleteSearchLogs(soqlDelete,lEmails);
        ID myBatchJobID2 = database.executebatch(batch2);
        System.debug(logginglevel.warn,'Scheduled batchJobId for pcDelete='+myBatchJobID2);        
    }
}