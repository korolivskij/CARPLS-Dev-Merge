/**
* Provisio Partners
* @author David Cox <david.cox@provisiopartners.com>
* @date 10/01/2020
* @group Appointments
*
* @description Test for ScheduleAppts 
*
* @history David Cox 10/01/2020 Initial Version
**/
@isTest
public class ScheduleApptsTest {
    @isTest
    static void ScheduleApptsTest() {

        String jobId = System.schedule('ScheduleAppts', '0 0 0 31 12 ? 2100', new ScheduleAppts());
        CronTrigger ct = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('2100-12-31 00:00:00', String.valueOf(ct.NextFireTime));

    }
}