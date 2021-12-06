@isTest(SeeAllData=true)
/*
SFDC will not put records in openactivity object when seealldata is false.. lol lame!!!
They encourage as if it were gospel to have see all data = false but won't you do it in this case
 */
private class TEST_vfCase20_VIEW_ActivityHistory {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCase            ctrl                        { get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   Consultation__c     newService                  { get; set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static   CaseUtils           caseUtils                   { get; set; }
    public static   Subject__c          newSubject                  { get; set; }
    public static   Attachment          newAttachment               { get; set; }
    public static   Task                newTask                     { get; set; }
    public static   Applied_Resource__c newAppliedResource          { get; set; }
    public static   Loop__DDP__c        newDdp                      {get;set;}
    public static   Survey_Feedback__c  newSurveyFeedback           { get; set; }

    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prCase = Page.vfCase;
        //coreExecution('', '', '', '');
        Datetime   dtTstStart        = Datetime.now();
        Profile p = [select id from profile where name = 'System Administrator' limit 1];
        User u = [select id from user where profileid = :p.id and isactive = true limit 1];
        uTstExecUser = u;
        caseUtils = new CaseUtils();
        newSubject = new Subject__c();

        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'jur1';
        newSubject.Status__c = 'Active';
        newSubject.Type__c = 'Pending';
        newSubject.Litigation__c = 'Pending';
        //newSubject.Show_Litigation_Questions__c = true;
        insert newSubject;

        newClient = TEST_TestUtils.createContact('Client');

        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);

        newAttachment = new Attachment();

        Blob b = Blob.valueOf('Test Data');
        newAttachment.ParentId = newCase.id;
        newAttachment.Name = 'Test Attachment';
        newAttachment.Body = b;
        insert newAttachment;

        newSurveyFeedback = new Survey_Feedback__c();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Survey_Feedback__c','CSS');
        newSurveyFeedback.case__c = newCase.id;
        newSurveyFeedback.recordtype = rt;
        insert newSurveyFeedback;

        newService = caseUtils.buildNewService(newCase);
        insert newService;
        Account a = TEST_TestUtils.createAcct('Legal Referral', newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id,newService.id,a);

        Task t = new Task();
        t.whatId = newCase.id;
        t.subject = 'Service Task Test';
        RecordType rt2 = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','General_Task');
        t.recordtype = rt2;
        t.ActivityDate = System.today();
        t.type = 'Task';
        t.support_type__c = 'Myself';
        t.OwnerId = uTstExecUser.id;
        t.Status = 'Open';

        insert t;
        newTask = t;


        Task t2 = new Task();
        t2.whatId = newCase.id;
        t2.subject = 'Service Task Test';
        RecordType rt3 = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','System_Assigned');
        t2.recordtype = rt3;
        t2.ActivityDate = System.today();
        t2.type = '1_';

        t2.support_type__c = 'AOC';
        t2.group__c = 'AOC';
        t2.OwnerId = uTstExecUser.id;
        t2.Status = 'Open';

        insert t2;

        Event e1 = new Event();
        e1.whatId = newCase.id;
        e1.subject = 'Service Event Test';

        e1.StartDateTime = System.now();
        e1.EndDateTime = System.now();
        e1.ActivityDate = System.today();
        e1.type = 'Event';
        e1.OwnerId = uTstExecUser.id;


        insert e1;
        newDdp = TEST_TestUtils.createDdp(newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id, newService.id,newDdp);

        Test.startTest();

        System.runAs(uTstExecUser) {
            //testReviewCase();
            prCase = Page.vfCase;
            Test.setCurrentPage(prCase);
            Map<String,String> mParms = prCase.getParameters();
            mParms.put('id',newCase.id);
            mParms.put('review','true');
            mParms.put('fromSearch','false');
            mParms.put('tempCase','false');
            ctrl = new ctrlCase(new ApexPages.StandardController(newCase));
            ctrl.doInit(); //really the constructor handles all now.
            ctrl.doRefreshCaseSummary();

            Boolean anyTasksToClose = ctrl.getAnyTasksToClose();
            if(anyTasksToClose) {
                ctrl.selectedId = newTask.id;
                ctrl.doCloseTask();
                ctrl.refreshCaseSummaryData();
            } 
            ctrlCase.retrieveDdpRecord(newDdp.id);
            ctrl.getTheController();
            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }

        Test.stopTest();
    }
    /**
     * The core launch point for this test class.
     */
    /*
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {

        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);

        Profile p = [select id from profile where name = 'System Administrator' limit 1];
        User u = [select id from user where profileid = :p.id and isactive = true limit 1];
        uTstExecUser = u;
        caseUtils = new CaseUtils();
       // buildTestData(); //<--- Build Any needed clients / and caseparties / contacts..
        newSubject = new Subject__c();

        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'jur1';
        newSubject.Status__c = 'Active';
        newSubject.Type__c = 'Pending';
        newSubject.Litigation__c = 'Pending';
        //newSubject.Show_Litigation_Questions__c = true;
        insert newSubject;

        newClient = TEST_TestUtils.createContact('Client');

        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);

        newAttachment = new Attachment();

        Blob b = Blob.valueOf('Test Data');
        newAttachment.ParentId = newCase.id;
        newAttachment.Name = 'Test Attachment';
        newAttachment.Body = b;
        insert newAttachment;

        newSurveyFeedback = new Survey_Feedback__c();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Survey_Feedback__c','CSS');
        newSurveyFeedback.case__c = newCase.id;
        newSurveyFeedback.recordtype = rt;
        insert newSurveyFeedback;

        newService = caseUtils.buildNewService(newCase);
        insert newService;
        Account a = TEST_TestUtils.createAcct('Legal Referral', newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id,newService.id,a);

        Task t = new Task();
        t.whatId = newCase.id;
        t.subject = 'Service Task Test';
        RecordType rt2 = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','General_Task');
        t.recordtype = rt2;
        t.ActivityDate = System.today();
        t.type = 'Task';
        t.support_type__c = 'Myself';
        t.OwnerId = uTstExecUser.id;
        t.Status = 'Open';

        insert t;
        newTask = t;


        Task t2 = new Task();
        t2.whatId = newCase.id;
        t2.subject = 'Service Task Test';
        RecordType rt3 = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','System_Assigned');
        t2.recordtype = rt3;
        t2.ActivityDate = System.today();
        t2.type = '1_';

        t2.support_type__c = 'AOC';
        t2.group__c = 'AOC';
        t2.OwnerId = uTstExecUser.id;
        t2.Status = 'Open';

        insert t2;

        Event e1 = new Event();
        e1.whatId = newCase.id;
        e1.subject = 'Service Event Test';

        e1.StartDateTime = System.now();
        e1.EndDateTime = System.now();
        e1.ActivityDate = System.today();
        e1.type = 'Event';
        e1.OwnerId = uTstExecUser.id;


        insert e1;
        newDdp = TEST_TestUtils.createDdp(newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id, newService.id,newDdp);

        Test.startTest();

        System.runAs(uTstExecUser) {
            //testReviewCase();
            prCase = Page.vfCase;
            Test.setCurrentPage(prCase);
            Map<String,String> mParms = prCase.getParameters();
            mParms.put('id',newCase.id);
            mParms.put('review','true');
            mParms.put('fromSearch','false');
            mParms.put('tempCase','false');
            ctrl = new ctrlCase(new ApexPages.StandardController(newCase));
            ctrl.doInit(); //really the constructor handles all now.
            ctrl.doRefreshCaseSummary();

            Boolean anyTasksToClose = ctrl.getAnyTasksToClose();
            if(anyTasksToClose) {
                ctrl.selectedId = newTask.id;
                ctrl.doCloseTask();
                ctrl.refreshCaseSummaryData();
            }
            ctrlCase.retrieveDdpRecord(newDdp.id);
            ctrl.getTheController();
            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }

        Test.stopTest();

    }
    private static void testReviewCase() {
        prCase = Page.vfCase;
        Test.setCurrentPage(prCase);
        Map<String,String> mParms = prCase.getParameters();
        mParms.put('id',newCase.id);
        mParms.put('review','true');
        mParms.put('fromSearch','false');
        mParms.put('tempCase','false');
        ctrl = new ctrlCase(new ApexPages.StandardController(newCase));
        ctrl.doInit(); //really the constructor handles all now.
        ctrl.doRefreshCaseSummary();

        Boolean anyTasksToClose = ctrl.getAnyTasksToClose();
        if(anyTasksToClose) {
            ctrl.selectedId = newTask.id;
            ctrl.doCloseTask();
            ctrl.refreshCaseSummaryData();
        }
        ctrlCase.retrieveDdpRecord(newDdp.id);
        ctrl.getTheController();









    }

    private static void buildTestData() {

        newSubject = new Subject__c();

        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'jur1';
        newSubject.Status__c = 'Active';
        newSubject.Type__c = 'Pending';
        newSubject.Litigation__c = 'Pending';
        //newSubject.Show_Litigation_Questions__c = true;
        insert newSubject;

        newClient = TEST_TestUtils.createContact('Client');

        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);

        newAttachment = new Attachment();

        Blob b = Blob.valueOf('Test Data');
        newAttachment.ParentId = newCase.id;
        newAttachment.Name = 'Test Attachment';
        newAttachment.Body = b;
        insert newAttachment;

        newSurveyFeedback = new Survey_Feedback__c();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Survey_Feedback__c','CSS');
        newSurveyFeedback.case__c = newCase.id;
        newSurveyFeedback.recordtype = rt;
        insert newSurveyFeedback;

        newService = caseUtils.buildNewService(newCase);
        insert newService;
        Account a = TEST_TestUtils.createAcct('Legal Referral', newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id,newService.id,a);

        Task t = new Task();
        t.whatId = newCase.id;
        t.subject = 'Service Task Test';
        RecordType rt2 = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','General_Task');
        t.recordtype = rt2;
        t.ActivityDate = System.today();
        t.type = 'Task';
        t.support_type__c = 'Myself';
        t.OwnerId = uTstExecUser.id;
        t.Status = 'Open';

        insert t;
        newTask = t;


        Task t2 = new Task();
        t2.whatId = newCase.id;
        t2.subject = 'Service Task Test';
        RecordType rt3 = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','System_Assigned');
        t2.recordtype = rt3;
        t2.ActivityDate = System.today();
        t2.type = '1_';

        t2.support_type__c = 'AOC';
        t2.group__c = 'AOC';
        t2.OwnerId = uTstExecUser.id;
        t2.Status = 'Open';

        insert t2;

        Event e1 = new Event();
        e1.whatId = newCase.id;
        e1.subject = 'Service Event Test';

        e1.StartDateTime = System.now();
        e1.EndDateTime = System.now();
        e1.ActivityDate = System.today();
        e1.type = 'Event';
        e1.OwnerId = uTstExecUser.id;


        insert e1;
        newDdp = TEST_TestUtils.createDdp(newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id, newService.id,newDdp);
    }

*/

}