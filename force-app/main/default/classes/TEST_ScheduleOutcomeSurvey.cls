/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *

 */
@isTest
private class TEST_ScheduleOutcomeSurvey {

	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	public static Contact	newContact	{get; set;}
	public static Case		newCase		{get; set;}
 
    static testMethod void fireSurveyEmailTest() {
        // 
		buildTestData();
		
		TEST.startTest();
		
		      // Schedule the test job

      String jobId = System.schedule('TEST Schedule Survey Email',
      						CRON_EXP, 
         					new ScheduleOutcomeSurvey());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));
      System.assertNotEquals(true,
         [SELECT survey_sent__c from case where id = :newCase.id].survey_sent__c);

   		Test.stopTest();
    }
    private static void buildTestData() {    
    
 
        newContact = new Contact( lastname='TEST',email='ericacox10@gmail.com');
        insert newContact;
        
    	newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', 
    				Origin='TEST Origin', description = ' TEST DESC',contact=newContact);
    	insert newCase;
    	
    }  	
    	
}