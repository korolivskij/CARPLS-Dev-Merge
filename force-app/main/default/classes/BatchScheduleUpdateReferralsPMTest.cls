@isTest
public class BatchScheduleUpdateReferralsPMTest {

    @testSetup 
	public static void testSetup() {
        Date today = Date.today();
		Referral__c referralTest = new Referral__c(Client_First_Name__c= 'TestReferral', Preferred_Call_Back_Date__c  = today, Preferred_Call_Back_Time__c  = 'PM_1_5');
        insert referralTest;
	}

	@isTest static void executeBatchScheduleAttendanceCreateTest() {

		Test.startTest();
        String CRON_EXP = '0 0 0 31 12 ? 2050';
        String jobId = System.schedule('BatchScheduleUpdateReferralsPMTest', CRON_EXP, new BatchScheduleUpdateReferralsPM());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2050-12-31 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();

	}

}