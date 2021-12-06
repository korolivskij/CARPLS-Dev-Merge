/**
 * @File Name          : BatchScheduleUpdateReferralsPM.cls
 * @Description        : 
 * @Author             : Ihor Onyshchenko
 * @Group              : 
 * @Last Modified By   : apauk
 * @Last Modified On   : 2/12/2020, 1:12:10 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/12/2020   apauk     Initial Version
**/
global class BatchScheduleUpdateReferralsPM implements Schedulable {
	global void execute(SchedulableContext sc) {
		proccessSchedule();
	}
    	private void proccessSchedule() {
		BatchUpdateReferralsPM batchReferral = new BatchUpdateReferralsPM();
        date today = date.today();
        String pickListValue = 'PM_1_5';
		String classQuery =  'SELECT ID FROM Referral__c WHERE Preferred_Call_Back_Date__c = today AND Preferred_Call_Back_Time__c = :pickListValue';
		List<Referral__c> referralList = Database.query(classQuery);

		
		if (!referralList.isEmpty()) {
			//Check if there are less than 5 batches active, otherwise wait for 5 minutes and try again
			Integer numberOfBatch = [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN('Processing', 'Preparing', 'Queued')];
			if (numberOfBatch < 5 ) {
				Database.executeBatch(batchReferral, 200);
			} 
			if (numberOfBatch >= 5 || Test.isRunningTest()) {
				BatchScheduleUpdateReferralsPM delayBachAttendance = new BatchScheduleUpdateReferralsPM();
				Datetime dt = Datetime.now().addMinutes(5);
				String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
				Id schedId = System.Schedule('Update Referral Batch' + timeForScheduler, timeForScheduler, delayBachAttendance);
			}

		}

	/* At 1:00pm, on every Day
		BatchScheduleUpdateReferralsPM m = new BatchScheduleUpdateReferralsPM();
		String sch = '0 0 13 * * ?';
		String jobID = system.schedule('BatchScheduleUpdateReferrals 1pm Job', sch, m);

		*/
	}
}