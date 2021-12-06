/**
* Provisio Partners
* @author Mykhailo Kovalov <mykhailo.kovalov@redtag.com.ua>
* @date 02/17/2020
* @group Agreements
*
* @description Test class for BatchScheduleUpdateCases,BatchUpdateCases and BatchUpdateCasesHelper.
*
* 
* 
*	
**/
@IsTest
private class BatchScheduleUpdateCasesTest {
    @TestSetup
    static void buidData(){
        Case cs = new Case();
        insert cs;
        Applied_Resource__c newAs=new Applied_Resource__c(Case__c=cs.Id,Type__c='Legal Referrals');
        insert newAs;
        Test.setCreatedDate(newAs.Id, date.today().addDays(-10));
        
    }
    @IsTest 
    static void testDayOfWeekOne(){
        Test.startTest();
        String CRON_EXP = '0 0 0 25 12 ? 2050';
        String jobId = System.schedule('BatchScheduleUpdateCasesTest', CRON_EXP, new BatchScheduleUpdateCases());
        Test.stopTest();
    }
    @IsTest 
    static void testOtherDay(){
        Test.startTest();
        String CRON_EXP = '0 0 0 30 12 ? 2050';
        String jobId = System.schedule('BatchScheduleUpdateCasesTest', CRON_EXP, new BatchScheduleUpdateCases());
        Test.stopTest();
    }
    @IsTest
    static void testExceptionInHelper()
    {
        List<Applied_Resource__c> appList=[SELECT Id,Dialer_Status__c  from Applied_Resource__c];
        appList.add(new Applied_Resource__c());
        BatchUpdateCasesHelper.updateCases(appList);
    }
}