@IsTest
public with sharing class trgOnTaskHandlerTest {
    
    @testSetup
    private static void makeData(){
        List<SObject> insertTestDataSObject = new List<SObject>();
        
        List<GroupMember> groupMembers= new List<GroupMember>();
        GroupMember groupMember = new GroupMember();
             
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
            Lead testLead = new Lead();
            testLead.FirstName = 'test Lead';
            testLead.LastName = 'test';
            testLead.Company = 'test';
        	insertTestDataSObject.add(testLead);
            Activity_Assignment__c testActivity = new Activity_Assignment__c();
            testActivity.support_type__c = 'AOC';
            testActivity.Current_User__c = user.Id;
        	insertTestDataSObject.add(testActivity);
   			
        
        
        	Case caseTest = new Case(Status='Open');
        	insertTestDataSObject.add(caseTest);
        	insert insertTestDataSObject;
           
    }
    
    @IsTest
    public static void testTaskTrigger(){   
        User user = [SELECT Id , Name FROM User WHERE FirstName = 'first' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Case caseId = [SELECT Id FROM Case LIMIT 1];

        System.runAs(user) {
            Test.StartTest();
            Group groupQueueTest = new Group(Name='Test', Type='Queue', DeveloperName='GroupQeueTest');
            insert groupQueueTest;
            System.debug('Group MEMBER 1');
            GroupMember groupMember = new GroupMember();
            groupMember.UserOrGroupId = user.Id;
            groupMember.GroupId = groupQueueTest.Id;
            //groupMembers.add(groupMember);
            insert groupMember;

            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Group__c = 'AOC';
            task.Subject = 'Lunch Meeting';
            task.Status = 'Open';
            task.WhoId = lead.Id;
            task.Priority = 'Low';
            task.ActivityDate = Date.today();
            task.OwnerId = user.Id;
            
            Task taskWithCase = new Task();
            taskWithCase.Group__c = 'Myself';
            taskWithCase.Subject = 'Lunch Meeting Email: test@gamil.coms';
            taskWithCase.Status = 'Open';
            taskWithCase.WhoId = lead.Id;
            taskWithCase.WhatId = caseId.Id;
            taskWithCase.Priority = 'Low';
            taskWithCase.ActivityDate = Date.today();
            taskWithCase.OwnerId = user.Id;
            
            Task taskWithCase2 = new Task();
            
            taskWithCase2.Subject = 'Lunch Meeting Email: test@gamil.coms';
            taskWithCase2.Status = 'Open';
            taskWithCase2.WhoId = lead.Id;
            taskWithCase2.WhatId = caseId.Id;
            taskWithCase2.Priority = 'Low';
            taskWithCase2.ActivityDate = Date.today();
            taskWithCase2.OwnerId = user.Id;
            
            tasks.add(taskWithCase2);
            tasks.add(taskWithCase);
            insert task;
            taskWithCase.Subject = 'Lunch Meeting Email: ';
			
            insert tasks;
            // trgOnTaskHandler.mapSupportTypes(listTasks);
            //trgOnTaskHandler.assignLeadTasksToQueue(listTasks);
            Test.StopTest();
        }
    }
}