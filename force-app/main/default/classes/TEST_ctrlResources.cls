@IsTest
private class TEST_ctrlResources {
    public static   User                uTstExecUser                { get; set; }
    public static   ctrlResources  		ctrl              			{ get; set; }
    public static   PageReference       prResources                 { get; set; }
    public static   Contact             newClient                   { get; Set; }
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static	Subject__c			newSubject					{ get; set; }
    public static   Subject__c          newSubject2                 { get; set; }
    public static   Consultation__c     newSvc                      {get;set;}
    public static   Account             newLegalRef                 {get;set;}
    public static   Account             newWebLink                  {get;set;}
    public static   Account             newSocialRef                {get;set;}

    public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {

        prResources = Page.vfResources;

        coreExecution('', '', '', '');
    }
    
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest2() {

        prResources = Page.vfResources;

        coreExecution2('', '', '', '');
    }
    /**
     * The core launch point for this test class.
     */
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
        caseUtils = new CaseUtils();
        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        //Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        Carplsv20Settings__c customSetting = [	select 	id, Display_Communities_Tab__c
        from 	Carplsv20Settings__c ];
        customSetting.Display_Communities_Tab__c = true;
		customSetting.SolutionView_Check_Active_Resources__c = true;
        update customSetting;
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);

        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts..

        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */
        Test.startTest();

        System.runAs(uTstExecUser) {
            testViewResources();
            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    
    public static void coreExecution2(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
        caseUtils = new CaseUtils();
        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        //Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        Carplsv20Settings__c customSetting = [	select 	id, Display_Communities_Tab__c
        from 	Carplsv20Settings__c ];
        customSetting.Display_Communities_Tab__c = true;
		customSetting.SolutionView_Check_Active_Resources__c = true;
        update customSetting;
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);

        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts..

        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */
        Test.startTest();

        System.runAs(uTstExecUser) {
            testViewResources2();
            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }

    private static void testViewResources() {
        Test.setCurrentPage(prResources);
        prResources.getParameters().put('id',newCase.id);
        ctrl = new ctrlResources();
        ctrl.refreshSubjectId();
       // ctrl.refreshRefs();
        ctrl.doRefreshEntirePage();
        ctrl.doRefreshDdps();
        ctrl.doRefreshLegalRefs();
        ctrl.doRefreshWebLinksRefs();
        ctrl.doRefreshSocialRefs();
        ctrl.getTotalDdps();
        ctrl.getTotalLegalRefs();
        ctrl.getTotalSocialRefs();
        ctrl.getTotalWebLinkRefs();
        ctrl.clickedRefAcctId = 'blah';
        String boo = ctrl.clickedRefAcctId;
        system.assert(ctrl.displayCommunitiesTab);


        /*Applied_Resource__c arLegal = TEST_TestUtils.createAr(newCase.id,newSvc.id,newLegalRef);
        arLegal.type__C = 'Legal Referrals';
        Applied_Resource__c arWebLink = TEST_TestUtils.createAr(newCase.id,newSvc.id,newWebLink);
        arWebLink.type__c = 'Web Links';
        Applied_Resource__c arSocialRef = TEST_TestUtils.createAr(newCase.id,newSvc.id,newSocialRef);
        arSocialRef.type__c = 'Social Referrals';

        arLegal.service_form_guid__C = null;
        arLegal.consultation__c = null;
        arSocialRef.service_form_guid__c = null;
        arSocialRef.consultation__c = null;
        arWebLink.service_form_guid__C = newSvc.service_form_guid__c;

        update arLegal;
        update arWebLink;
        update arSocialRef;

		List<Applied_Resource__c> listApplRes = new List<Applied_Resource__c>();
		listApplRes.add(arLegal);
		listApplRes.add(arWebLink);
		listApplRes.add(arSocialRef);
		ctrl.getSolution(newCase, listApplRes);
		ctrl.createNewSolution();
		ctrl.doSaveNewSolution();
		ctrl.showPopup();
		ctrl.saveComment();

        ctrl.doRefreshEntirePage();*/

    }
    
    private static void testViewResources2() {
        Test.setCurrentPage(prResources);
        prResources.getParameters().put('id',newCase.id);
        ctrl = new ctrlResources();
        
        Applied_Resource__c arLegal = TEST_TestUtils.createAr(newCase.id,newSvc.id,newLegalRef);
        arLegal.type__C = 'Legal Referrals';
        Applied_Resource__c arWebLink = TEST_TestUtils.createAr(newCase.id,newSvc.id,newWebLink);
        arWebLink.type__c = 'Web Links';
        Applied_Resource__c arSocialRef = TEST_TestUtils.createAr(newCase.id,newSvc.id,newSocialRef);
        arSocialRef.type__c = 'Social Referrals';

        arLegal.service_form_guid__C = null;
        arLegal.consultation__c = null;
        arSocialRef.service_form_guid__c = null;
        arSocialRef.consultation__c = null;
        arWebLink.service_form_guid__C = newSvc.service_form_guid__c;

        update arLegal;
        update arWebLink;
        update arSocialRef;

		List<Applied_Resource__c> listApplRes = new List<Applied_Resource__c>();
		listApplRes.add(arLegal);
		listApplRes.add(arWebLink);
		listApplRes.add(arSocialRef);
		ctrl.getSolution(newCase, listApplRes);
		ctrl.createNewSolution();
		ctrl.doSaveNewSolution();
		ctrl.showPopup();
		ctrl.saveComment();

        ctrl.doRefreshEntirePage();
    }


    private static void buildTestData() {

        newClient = TEST_TestUtils.createContact('Client');

        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);

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
        newSubject2 = new Subject__c();

        newSubject2.Title__c = 'Unit Test Case Subject';
        newSubject2.Practice_Area__c = 'pa1';
        newSubject2.Problem_Category__c = 'pcat1';
        newSubject2.Problem_Code__c = 'pc1';
        newSubject2.Jurisdiction__c = 'jur1';
        newSubject2.Status__c = 'Active';
        newSubject2.Type__c = 'Pending';
        newSubject2.Litigation__c = 'Pending';
        //newSubject.Show_Litigation_Questions__c = true;
        insert newSubject2;
        CaseUtils cseUtils = new CaseUtils();
        newSvc = cseUtils.buildNewService(newCase);
        insert newSvc;

        newLegalRef = TEST_TestUtils.createAcct('Legal Referrals', newSubject);
        newWebLink = TEST_TestUtils.createAcct('Web Links', newSubject);
        newSocialRef = TEST_TestUtils.createAcct('Social Referrals', newSubject);

        newCase.selected_subject__c = newSubject.id;
        update newCase;

        Activity_Assignment__c aa = new Activity_Assignment__c();
        aa.support_type__c = 'AOC';
        aa.current_status__c = 'Available';
        aa.current_user__c = uTstExecUser.id;
        insert aa;

		Solution__c sol = new Solution__c();
		sol.Title__c = 'testSolution';
		sol.Status__c = 'Active';
		//sol.Practice_Area__c = 'pa1';
		//sol.Problem_Category__c = 'pcat1';
		//sol.Problem_Code__c = 'pc1';	
		insert sol;

        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);
    }
}