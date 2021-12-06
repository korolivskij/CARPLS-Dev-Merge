@IsTest
public with sharing class trgUpdateEventTimeFieldTest {



    @IsTest
    public static void testEventTrigger(){
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            FirstName = 'first',
            LastName = 'last',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Schedule_Map__c = 'Schedule 1'
        );
        insert user;
        
        System.runAs(user) {

            Lead testLead = new Lead();
            testLead.FirstName = 'test Lead';
            testLead.LastName = 'test';
            testLead.Company = 'test';
            insert testLead;
    
            Event event = new Event();
            event.WhoId = testLead.Id;
            event.Group__c = 'AOC';
            event.New_Leaf_Appointment__c = true;
            event.DurationInMinutes = 2;
            event.ActivityDateTime = Date.today();
            event.ownerid = user.id;
            event.Subject = 'On Call Appointment';
            insert event;


            List<Event> listEvents = [SELECT Id ,Group__c,ownerId,WhoId,New_Leaf_Appointment__c, Subject FROM Event WHERE Subject = 'On Call Appointment'];
            Test.StartTest();
            eventTriggerHandler.assignLeadEventToCalendar(listEvents);
            eventTriggerHandler.mapSupportTypes(listEvents);
            Test.StopTest();
        }
    }
}