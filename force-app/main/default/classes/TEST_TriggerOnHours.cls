@isTest(SeeAllData=false)
public class TEST_TriggerOnHours {

    public static testMethod void executeTest() {
        //-- Get testing user ---
        User                uTstExecUser;
        Datetime   dtTstStart        = Datetime.now();
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('', '','', '' );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        uTstExecUser.email = 'testemail@test.com';
        update uTstExecUser;
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        Account a = new Account ( 	name='TEST Account Name1', description= 'TEST Account Desc1',Active__c = true);
        insert a;

        Contact c = new Contact(	lastname='UT TEST Contact',category__c='Volunteer', firstname='UT Test ContactFirst'
        ,phone='630-310-0898',Birthdate=Date.today(), Last_Four_SSN__c='1234'
        ,mailingstreet='123', aliases__c='Aliases', mailingPostalCode='66666',email=uTstExecUser.email, accountId = a.id);
        c.related_user__c = uTstExecUser.id;
        insert c;



        Campaign c1 = new Campaign();
        c1.name = 'Test camp 1';
        c1.status = 'In Progress';
        c1.StartDate = system.today();
        c1.EndDate = system.today() + 20;
        c1.Type = 'Volunteers';
        insert c1;

        CampaignMember cm = new CampaignMember();
        cm.status = 'Confirmed';
        // cm.type = 'Contact';
        cm.campaignId = c1.id;
        cm.contactId = c.id;
        insert cm;

        GW_Volunteers__Volunteer_Job__c job = new GW_Volunteers__Volunteer_Job__c();
        job.name = 'Volunteer Hotline PM Shift';
        job.GW_Volunteers__Campaign__c = c1.id;
        job.GW_Volunteers__Skills_Needed__c = 'Computer';
        insert job;

        GW_Volunteers__Job_Recurrence_Schedule__c rs = new GW_Volunteers__Job_Recurrence_Schedule__c();
        rs.GW_Volunteers__Days_of_Week__c = 'Monday';
        rs.GW_Volunteers__Volunteer_Job__c = job.id;
        rs.GW_Volunteers__Schedule_Start_Date_Time__c = system.now();
        rs.GW_Volunteers__Schedule_End_Date__c  = system.today().addDays(10);
        rs.GW_Volunteers__Weekly_Occurrence__c = 'Every';
        rs.GW_Volunteers__Duration__c = 4;
        rs.GW_Volunteers__Desired_Number_of_Volunteers__c = 4;
        insert rs;

        GW_Volunteers__Volunteer_Recurrence_Schedule__c vrs = new GW_Volunteers__Volunteer_Recurrence_Schedule__c();
        vrs.GW_Volunteers__Contact__c = c.id;
        vrs.GW_Volunteers__Volunteer_Job__c = job.id;
        vrs.GW_Volunteers__Schedule_Start_Date_Time__c = system.now();
        vrs.GW_Volunteers__Schedule_End_Date__c = system.today();
        vrs.GW_Volunteers__Duration__c = 4;
        vrs.GW_Volunteers__Weekly_Occurrence__c = 'Every';
        vrs.GW_Volunteers__Days_of_Week__c = 'Monday';
        vrs.GW_Volunteers__Volunteer_Hours_Status__c = 'Confirmed';
        insert vrs;


        GW_Volunteers__Volunteer_Shift__c shift = new GW_Volunteers__Volunteer_Shift__c();
        shift.GW_Volunteers__Volunteer_Job__c = job.id;
        shift.GW_Volunteers__Job_Recurrence_Schedule__c = rs.id;
        shift.GW_Volunteers__Start_Date_Time__c = system.now();
        shift.GW_Volunteers__Duration__c = 4;
        shift.GW_Volunteers__Desired_Number_of_Volunteers__c = 4;
        insert shift;

        Test.startTest();
            System.runAs(uTstExecUser) {
                GW_Volunteers__Volunteer_Hours__c hours = new GW_Volunteers__Volunteer_Hours__c();
                hours.GW_Volunteers__Contact__c = c.id;
                hours.GW_Volunteers__Volunteer_Job__c = job.id;
                hours.GW_Volunteers__Volunteer_Shift__c = shift.id;
                hours.GW_Volunteers__Volunteer_Recurrence_Schedule__c = vrs.id;
                hours.GW_Volunteers__Start_Date__c = system.today();
                hours.GW_Volunteers__End_Date__c = system.today();
                hours.GW_Volunteers__Hours_Worked__c = 4;
                hours.GW_Volunteers__Status__c = 'Completed';
                insert hours;
                try {
                    Event e = [select id from event where ownerId = :uTstExecUser.id limit 1];
                    system.debug('event created=' + e);
                    //system.assert( e != null);
                } catch  (Exception e) {
                    system.debug(e);
                }

               // hours.


                hours.event_created__c = false;
                update hours;


            }
        Test.stopTest();
    }

}