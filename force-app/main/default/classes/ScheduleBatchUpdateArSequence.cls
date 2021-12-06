global class ScheduleBatchUpdateArSequence implements Schedulable {
    //every day at 1am
    public static String CRON_EXP = '0 0 01 * * ?';

    global void execute(SchedulableContext ctx) {
        String soql = '';
        Boolean bCommit = true;

        String email = 'rnendza@gmail.com';
        List<String> lEmails = new List<String>{email};
        /**
         * Query All Records not previously updated by this process..
         */
        soql += '   select id, case__c, createddate,case_sequence__c,type__c from applied_resource__c where case__c != null ';
        soql += '   and (case_sequence__c = null or case_sequence__c = 0) ';
        soql += '   order by case__c, createddate,case_sequence__c asc ';

        BatchUpdateArSequence batch = new BatchUpdateArSequence(soql, lEmails, bCommit);
        ID jobId = database.executebatch(batch,200);
        System.debug(logginglevel.warn, 'Scheduled batchJobId for ar seq update=' + jobId);
    }
}