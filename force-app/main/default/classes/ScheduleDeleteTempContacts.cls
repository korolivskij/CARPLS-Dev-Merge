global class ScheduleDeleteTempContacts implements Schedulable {
    
    global void execute(SchedulableContext ctx) { 
        String soqlDelete = '';
        
        String email = 'rnendza@gmail.com';
        List<String> lEmails = new List<String> { email };
        lEmails.add('ericacox10@gmail.com');
        soqlDelete = 'select id, lastname from Contact where temp_record__c = true';
        if(!Test.isRunningTest()) {
        	 soqlDelete += ' and Creation_Age_In_Minutes__c >= 25';
        }
        soqlDelete += ' and of_Case_Party_Records__c = 0';
        BatchDeleteTempContacts batch = new BatchDeleteTempContacts(soqlDelete,lEmails);
        ID myBatchJobID1 = database.executebatch(batch);
        System.debug(logginglevel.warn,'Scheduled batchJobId='+myBatchJobID1);        
    }
}