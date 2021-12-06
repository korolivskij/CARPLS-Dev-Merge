/**
 * @File Name          : BatchScheduleUpdateCases.cls
 * @Description        : 
 * @Author             : apauk
 * @Group              : 
 * @Last Modified By   : apauk
 * @Last Modified On   : 2/13/2020, 5:18:31 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/13/2020   apauk     Initial Version
**/
global class BatchScheduleUpdateCases implements Schedulable {
	global void execute(SchedulableContext sc) {
		proccessSchedule();
	}
    	private void proccessSchedule() {
            
            BatchUpdateCases batchCases = new BatchUpdateCases();
            Date d = System.today();
            System.debug('d===== ' + d);
            Datetime dt = (DateTime)d;
            String dayOfWeek = dt.format('u');
            Datetime selectedDate;
			if( dayOfWeek == '7'){
                selectedDate = d.addDays(-5);
                system.debug('TEST--->This is Monday; '+dayOfWeek);
                system.debug('selected date->'+selectedDate);
            
        	}else{
                selectedDate = d.addDays(-3);
                system.debug('this is not monday for leap and not leap year--->'+dayOfWeek);
                system.debug('selected date->'+selectedDate);
       		}
        
        

            String pickListValue = 'Legal Referrals';
        
            String classQuery = 'SELECT Id,Dialer_Status__c  FROM Applied_Resource__c WHERE is_electronic_referral__c = false AND Type__c = :pickListValue AND createddate <= :selectedDate';
            
            List<Applied_Resource__c> appResList = Database.query(classQuery);
            if (!appResList.isEmpty()) {
                //Check if there are less than 5 batches active, otherwise wait for 5 minutes and try again
                Integer numberOfBatch = [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN('Processing', 'Preparing', 'Queued')];
                if (numberOfBatch < 5 ) {
                    Database.executeBatch(batchCases, 200);
                } 
                if (numberOfBatch >= 5 || Test.isRunningTest()) {
                    BatchScheduleUpdateCases delayBachCases = new BatchScheduleUpdateCases();
                    Datetime dt2 = Datetime.now().addMinutes(5);
                    String timeForScheduler = dt2.format('s m H d M \'?\' yyyy');
                    Id schedId = System.Schedule('Update Applied Resources Batch' + timeForScheduler, timeForScheduler, delayBachCases);
                }
		}
	}
}