/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */

@isTest
private class TEST_scheduleUpdateSubject {

    public static Subject__c newSubject {get; set;}

    static testMethod void scheduleUpdateContactsTest() {
        
        buildTestData();
    
        Test.startTest();

        new ScheduleUpdateSubject().execute(null);

        Test.stopTest();

        Map<Id, Subject__c> subjectsMap = new Map<Id,Subject__c>([SELECT Id,  Status__c 
                                                                  FROM Subject__c]);

        System.assertEquals(subjectsMap.get(nowRecordFAQ.Id).Status__c,'Current');
        System.assertEquals(subjectsMap.get(fourMonthRecordFAQ.Id).Status__c,'Current');
        System.assertEquals(subjectsMap.get(sixMonthRecordFAQ.Id).Status__c,'Current');
        System.assertEquals(subjectsMap.get(nineMonthRecordFAQ.Id).Status__c,'Archived');
        System.assertEquals(subjectsMap.get(oneMonthRecordDDP.Id).Status__c,'Current');
        System.assertEquals(subjectsMap.get(nineMonthRecordDDP.Id).Status__c,'Current');

    }

    private static Subject__c nowRecordFAQ, fourMonthRecordFAQ, sixMonthRecordFAQ,
        nineMonthRecordFAQ, oneMonthRecordDDP, nineMonthRecordDDP;

    private static void buildTestData() {    
        Contact newClient = TEST_TestUtils.createContact('Client');
        Case newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        Consultation__c testService = new CaseUtils().buildNewService(newCase);
        insert testService;
        LOOP__DDP__c testDDP = TEST_TestUtils.createDDP();
        Applied_Resource__c appRes = TEST_TestUtils.createAr(newCase.id, testService.id, testDDP);

        // Should remain Current
        nowRecordFAQ = new Subject__c(Status__c='Current', Title__c='Title');
        insert nowRecordFAQ;
        appRes = appRes.clone(false, true, false, false);
        appRes.Type__C='FAQ';
        appRes.Subject__c = nowRecordFAQ.Id;
        insert appRes;
        Test.setCreatedDate(appRes.Id, DateTime.now());
        
        // Should remain Current
        fourMonthRecordFAQ = new Subject__c(Status__c='Current', Title__c='Title');
        insert fourMonthRecordFAQ;
        appRes = appRes.clone(false, true, false, false);
        appRes.Type__C='FAQ';
        appRes.Subject__c = fourMonthRecordFAQ.Id;
        insert appRes;
        Test.setCreatedDate(appRes.Id, DateTime.now().addMonths(-4));

        // Should remain Current
        sixMonthRecordFAQ = new Subject__c(Status__c='Current', Title__c='Title');
        insert sixMonthRecordFAQ;
        appRes = appRes.clone(false, true, false, false);
        appRes.Type__C='FAQ';
        appRes.Subject__c = sixMonthRecordFAQ.Id;
        insert appRes;
        Test.setCreatedDate(appRes.Id, DateTime.now().addMonths(-6));

        // Should be archived
        nineMonthRecordFAQ = new Subject__c(Status__c='Current', Title__c='Title');
        insert nineMonthRecordFAQ;
        appRes = appRes.clone(false, true, false, false);
        appRes.Type__C='FAQ';
        appRes.Subject__c = nineMonthRecordFAQ.Id;
        insert appRes;
        Test.setCreatedDate(appRes.Id, DateTime.now().addMonths(-9));

        // Should remain Current
        oneMonthRecordDDP = new Subject__c(Status__c='Current', Title__c='Title');
        insert oneMonthRecordDDP;
        appRes = appRes.clone(false, true, false, false);
        appRes.Type__C='DDP';
        appRes.Subject__c = oneMonthRecordDDP.Id;     
        insert appRes;
        Test.setCreatedDate(appRes.Id, DateTime.now().addMonths(-1));

        // Should remain Current
        nineMonthRecordDDP = new Subject__c(Status__c='Current', Title__c='Title');
        insert nineMonthRecordDDP;
        appRes = appRes.clone(false, true, false, false);
        appRes.Type__C='DDP';
        appRes.Subject__c = nineMonthRecordDDP.Id;
        insert appRes;
        Test.setCreatedDate(appRes.Id, DateTime.now().addMonths(-9));
        

    }   


}