@isTest(SeeAllData=false)
private class TEST_vfCase20_RELATEDLISTS {

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
    public static   ContentVersion      newContentVersion           { get; set; }
    public static   Task                newTask                     { get; set; }
    public static   Applied_Resource__c newAppliedResource          { get; set; }
    public static   Survey_Feedback__c  newSurveyFeedback           { get; set; }

    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prCase = Page.vfCase;
        //coreExecution('', '', '', '');

        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---

        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('','','', '' );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);

        caseUtils = new CaseUtils();
        //buildTestData(); //<--- Build Any needed clients / and caseparties / contacts..
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
        newClient.email = 'rnendza@gmail.com';

        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCase.contactid = newClient.id;
        update newCase;

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

       // newContentVersion = buildContentVersion(newCase.id);
        Blob fileContent = Blob.valueOf('Unit Test Document Body');
        ContentVersion cv = new ContentVersion();
        cv.Case__c = newCase.id;
        cv.versionData = fileContent;
        cv.title = 'UNIT TEST TITLE';
        cv.Description = 'Blah Unit Test CV DESC';
        cv.Custom_Type__c ='Client Document';
        cv.PathOnClient = '/test';
        List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'User Attached Documents'];
        cv.firstPublishLocationId = CWList.get(0).Id;
        newContentVersion = cv;

        insert newContentVersion;


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
            ctrlCase.retrieveArRecord(newAppliedResource.id);
            ctrl.actionId = newAppliedResource.id;
            ctrl.doRemoveAppliedResource();
            ctrl.doRefreshAppliedResourcesAfterModified();
            ctrl.doCancelCreateCaseReview();
            ctrl.subjCseId = 'man';
            ctrl.arType = 'cow';
            String s1 = ctrl.subjCseId;
            String s2 = ctrl.arType;

            ctrl.actionId = newContentVersion.id;
            ctrl.doDeleteDoc();

            ctrlCase.retrieveCaseState(newCase.id);
            /// test add party search.
            //ctrlDetail.doAddPartySearch(); //really nothing to assert.

            ctrl.currentSvc = newService;
            ctrl.doCloseCase();
            ctrl.doCancelNewCase();



            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }

        Test.stopTest();

    }
    /**
     * The core launch point for this test class.
     */

//    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {


  //  }
    //private static void testReviewCase() {


    //}

    //private static void buildTestData() {


    //}

    //private static ContentVersion buildContentVersion(Id caseId) {

      //  return cv;
    //}



}