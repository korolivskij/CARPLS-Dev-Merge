@istest(seealldata=false)
private class TEST_vfAppliedResource {
    public static   User                uTstExecUser                { get; set; }
    public static   ctrlApplResEdit     ctrl                        { get; set; }
    public static   PageReference       prAr                     { get; set; }
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
        prAr = Page.vfAppliedResource;
        /*
         *  Just pass blank parms for user now. This is a luxury that I wish we had but we may
         *  run out of time before we can test multiple users / roles / profiles via code.
         *  In the above scenario, a user will be created on the fly and is a system admin
         *  with no roles / permission sets applied.
         *
         *  @TODO maybe pull testing user from custom setting.
         *  @TODO maybe create different users from different roles / profiles on the fly
         */
       // coreExecution('', '', '', '');
        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('', '','', '' );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);

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
        newClient.email = 'rnendza@gmail.com';
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCase.contactid = newClient.id;
        update newCase;

        TEST_TestUtils.debugSObj(newCase);


        newService = new CaseUtils().buildNewService(newCase);
        insert newService;
        Account a = TEST_TestUtils.createAcct('Legal Referrals', newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id,newService.id,a);
        newAppliedResource.type__c = 'Legal Referrals';
        update newAppliedResource;

        Test.startTest();

        System.runAs(uTstExecUser) {
            //testAppliedResourceEdit();

            Test.setCurrentPage(prAr);
            Map<String,String> mParms =prAr.getParameters();
            mParms.put('id',newAppliedResource.id);

            ctrl = new ctrlApplResEdit(new ApexPages.StandardController(newAppliedResource));
            ctrl.doInitPage(); //really the constructor handles all now.
            ctrl.selectedDist = 'A';
            ctrl.doSaveAr();

            newAppliedResource.type__c = 'DDP';
            update newAppliedResource;
            ctrl = new ctrlApplResEdit(new ApexPages.StandardController(newAppliedResource));
            ctrl.doInitPage(); //really the constructor handles all now.

            newAppliedResource.type__c = 'Trump';
            update newAppliedResource;
            ctrl = new ctrlApplResEdit(new ApexPages.StandardController(newAppliedResource));
            ctrl.doInitPage(); //really the constructor handles all now.


            ctrl.doCancelAr();
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

        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts..


        Test.startTest();

        System.runAs(uTstExecUser) {
            testAppliedResourceEdit();

            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }

        Test.stopTest();

    }
    */
    /*
    private static void testAppliedResourceEdit() {

        Test.setCurrentPage(prAr);
        Map<String,String> mParms =prAr.getParameters();
        mParms.put('id',newAppliedResource.id);

        ctrl = new ctrlApplResEdit(new ApexPages.StandardController(newAppliedResource));
        ctrl.doInitPage(); //really the constructor handles all now.
        ctrl.selectedDist = 'A';
        ctrl.doSaveAr();

        newAppliedResource.type__c = 'DDP';
        update newAppliedResource;
        ctrl = new ctrlApplResEdit(new ApexPages.StandardController(newAppliedResource));
        ctrl.doInitPage(); //really the constructor handles all now.

        newAppliedResource.type__c = 'Trump';
        update newAppliedResource;
        ctrl = new ctrlApplResEdit(new ApexPages.StandardController(newAppliedResource));
        ctrl.doInitPage(); //really the constructor handles all now.


        ctrl.doCancelAr();
    }
    */
/*
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
        newClient.email = 'rnendza@gmail.com';
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCase.contactid = newClient.id;
        update newCase;

        TEST_TestUtils.debugSObj(newCase);


        newService = new CaseUtils().buildNewService(newCase);
        insert newService;
        Account a = TEST_TestUtils.createAcct('Legal Referrals', newSubject);
        newAppliedResource = TEST_TestUtils.createAr(newCase.id,newService.id,a);
        newAppliedResource.type__c = 'Legal Referrals';
        update newAppliedResource;

    }
*/

}