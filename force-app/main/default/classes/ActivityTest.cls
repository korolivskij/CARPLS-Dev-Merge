@isTest
public class ActivityTest {
	@TestSetup
    static void makeData(){
        List<Activity_Assignment__c> activityAssignmentsTest = new List<Activity_Assignment__c>();
        List<String> supportTypes = new List<String>{'AOC', 'POC', 'POCDesk', 'AOC-IL-AFLAN', 'AOC-New-Leaf'};
            for(Integer i = 0; i < 5; i++){
                Activity_Assignment__c ac = new Activity_Assignment__c();
        		ac.Support_Type__c = supportTypes[i];
        		ac.Current_User__c = UserInfo.getUserId();
                activityAssignmentsTest.add(ac);
            }
        insert activityAssignmentsTest;
        Id uId = UserInfo.getUserId();
        User u = [SELECT Id FROM User WHERE Id = :uId];
        System.runAs(u){
            Contact con = new Contact(
        		FirstName='Joe',
        		LastName='Smith',
        		Phone='415.555.1212');
    		insert con;
            
            Event event = new Event();
            event.Subject = 'Test Subject';
            event.WhoId = con.Id;
            event.EndDateTime = Date.today().addDays(3);
            event.StartDateTime = Date.today().addDays(1);
            event.ActivityDate = Date.today();
            insert event;
            
            EventRelation er = new EventRelation();
            er.EventId = event.Id;
            er.RelationId = con.Id;
            insert er;
        }
         
    }
    
    @IsTest
    static void retrieveAllActivityAssignmentsTest(){
        List<Activity_Assignment__c> allActivityAssignments = Activity.retrieveAllActivityAssignments();
        system.assertEquals(5, allActivityAssignments.size());
    }
    
    @IsTest 
    static void retrieveOnCallPersonBySupportTypeTest(){
        Id id = Activity.retrieveOnCallPersonBySupportType('POC-IL-AFLAN');
    }
    
    @IsTest 
    static void retrieveOnCallPersonBySupportTypeForTheCaseService(){
        Id id = Activity.retrieveOnCallPersonBySupportTypeForTheCaseService('POC-IL-AFLAN');
        system.assertNotEquals(null, id);
    }
    
    @IsTest
    static void retrieveActivityAssignmentTest(){
        Activity_Assignment__c ac = [SELECT Id, Support_Type__c, Current_User__c FROM Activity_Assignment__c LIMIT 1];
        Activity_Assignment__c acTest = Activity.retrieveActivityAssignment(ac.Id);
        system.assertEquals(ac.Support_Type__c, acTest.Support_Type__c);
        system.assertEquals(ac.Current_User__c, acTest.Current_User__c);
    }
    
    @IsTest
    static void retrieveUserTodaysEventsTest(){
        Contact con = [Select Id FROM Contact WHERE FirstName = 'Joe' LIMIT 1];
        List<EventRelation> ers = Activity.retrieveUserTodaysEvents(con.Id);
        system.assertEquals(1, ers.size());
    }
    @IsTest
    static void retrieveUserTodaysOwnedEventsAndInvitedEventsTest(){
        List<Event> events = Activity.retrieveUserTodaysOwnedEventsAndInvitedEvents(UserInfo.getUserId());
        system.assertEquals(1, events.size());
    }
}