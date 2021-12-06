/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. 
 *
 * @TODO Resume Case
 *
 */
@isTest(SeeAllData=false)
public class TEST_CaseUtils {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCaseDetail      ctrlCaseDetail              { get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static   Conflict_Log__c     newConflictLog				{ get; set; }
    public static   CaseUtils			caseUtils					{ get; set; }
    public static   Subject__c          newSubject                  { get; set; }
    public static   Consultation__c      newSvc                     { get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prCase = Page.vfCaseDetail;
        /* 
         *  Just pass blank parms for user now. This is a luxury that I wish we had but we may
         *  run out of time before we can test multiple users / roles / profiles via code.
         *  In the above scenario, a user will be created on the fly and is a system admin
         *  with no roles / permission sets applied.
         * 
         *  @TODO maybe pull testing user from custom setting.
         *  @TODO maybe create different users from different roles / profiles on the fly
         */
        coreExecution('', '', '', '');
    }
    /**
     * The core launch point for this test class.
     */
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
        
        caseUtils = new CaseUtils();
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {  
            	testConflictStuff();
                testMiscMethods();
                testNewCaseFlowMethods();
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
 	private static void testConflictStuff() {
 		caseUtils.retrieveConflictLogs(newConflictLog.id);
 		caseUtils.retrieveContlictLogs(newCase);
 		caseUtils.retrieveContlictLogs(newClient);
 	}
    private static void testNewCaseFlowMethods() {
		try {
			List<Consultation__c> services = caseUtils.retrieveConsultations(newCase);
			Consultation__c service = services[0];
			if(newClient.Email == null) {
				newClient.Email = 'rnendza@gmail.com';
				update newClient;
			}
			service.Service_Code__c = 'Legal Advice';
			update service;
			Boolean emailSent = caseUtils.sendClientSatSurvey(newCase, service);
			System.assert(emailSent);
			
			emailSent = caseUtils.sendClientSatSurvey(null, service); //get it to fail with no params
			System.assertNotEquals(emailSent,true);

			service.Service_Code__c ='I love SFDC';
			update service;
			emailSent = caseUtils.sendClientSatSurvey(newCase, service); //get it to fail service critera where it won't be sent
			System.assertNotEquals(emailSent,true);
            caseUtils.retrieveCaseLitigationQuestions(newSubject);
            caseUtils.retrieveCaseLitQuestions(newSubject);
            caseUtils.retrieveLatestCaseSvcNote(newCase,newSvc);

			
		} catch (Exception e) {
			System.debug(logginglevel.error, 'error while running testNeCaseFlowMethods in UT class TEST_CaseUtils..'+e);
		}
    } 	
    private static void testMiscMethods() {
		//Consultation__c service = newCase.consultations__r[0];
		List<Consultation__c> services = caseUtils.retrieveConsultations(newCase);
		caseUtils.buildConsultationNote(newCase, services[0]);
		caseUtils.possibleConflictingCasePartyRecords(newClient.id, ''); //@TODO why is searchtype not used in method?
        
    }
    private static void buildTestData() {

        caseUtils = new CaseUtils();
           
        newClient = TEST_TestUtils.createContact('Client');
        
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
 		
 		List<Contact> lParties = new List<Contact>();
        List<Id> pIds = new List<Id>();
        	
        for(Case_Party__c cp : newCaseParties) {
        	if(cp.Type__c != 'Client') {
        		pIds.add(cp.contact__c);
        	}       		
        }
        lParties = ContactUtils.retrieveAllContactInfo(pIds);
        uTstExecUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        newSlClient = TEST_TestUtils.createSearchLog(newClient, lParties, uTstExecUser);
        newConflictLog = new Conflict_Log__c(case__c = newCase.id, contact__c = newClient.id);
        insert newConflictLog;
        TEST_TestUtils.debugSObj(newCase);  
        TEST_TestUtils.debugSObjs(newCaseParties);

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

        newSvc = caseUtils.buildNewService(newCase);
        insert newSvc;

    }    

    @IsTest
    static void addLeftOpenCasesPostsTest() {
        buildTestData();
        List<Case> casesTest = new List<Case>();
        casesTest.add(TEST_TestUtils.createFullClientPartyCase(newClient,'Open'));             
        Test.startTest();
        List<FeedItem> result = caseUtils.addLeftOpenCasesPosts(casesTest);
        Test.stopTest();
        System.assertEquals(1, result.size()); 
    }

    @IsTest
    static void retrieveCaseReviewsTest(){
        buildTestData();
        Test.startTest();
        List<Case_Review__c> result = caseUtils.retrieveCaseReviews(newCase);
        List<Case_Review__c> result2 = caseUtils.retrieveCaseReviews(null);
        Test.stopTest();
        system.assertEquals(null, result2);
    }

    @IsTest
    static void retrieveCaseAttachmentsTest(){
        buildTestData();
        Test.startTest();
        List<Attachment> result = caseUtils.retrieveCaseAttachments(newCase);
        List<Attachment> result2 = caseUtils.retrieveCaseAttachments(null);
        Test.stopTest();
        system.assertEquals(null, result2);
        
    }

    @IsTest
    static void retrieveCasesLeftOpenTest(){
        buildTestData();
        Test.startTest();
        List<Case> result = caseUtils.retrieveCasesLeftOpen('Open', 10);
        List<Case> result2 = caseUtils.retrieveCasesLeftOpen('Closed', 10);
        Test.stopTest();
    }

    @IsTest
    static void retrieveCurrentCaseConsultationTest(){
        buildTestData();
        Test.startTest();
        Consultation__c result = caseUtils.retrieveCurrentCaseConsultation(newCase);
        Consultation__c result2 = caseUtils.retrieveCurrentCaseConsultation(null);
        Test.stopTest();
        System.assertEquals(newCase.Id, result.Case__c);
        System.assertEquals(null, result2);
    }

    @IsTest
    static void retrieveCaseSummaryDataWithActivitiesTest(){
        buildTestData();
        Test.startTest();
        Case result = caseUtils.retrieveCaseSummaryDataWithActivities(newCase.Id);
        Case result2 = caseUtils.retrieveCaseSummaryDataWithActivities(null);
        Test.stopTest();
        system.assertEquals('Test Case', result.Subject);
        system.assertEquals(null, result2);
    }

    @IsTest
    static void retrieveCaseSummaryDataTest(){
        buildTestData();
        Test.startTest();
        Case result = caseUtils.retrieveCaseSummaryData(newCase.Id);
        Case result2 = caseUtils.retrieveCaseSummaryData(null);
        Test.stopTest();
        system.assertEquals(newClient.Id, result.ContactId);
        system.assertEquals(null, result2);
    }
    
    @IsTest
    static void retrieveCasePartyTest(){
        buildTestData();
        Test.startTest();
        Case_Party__c result = caseUtils.retrieveCaseParty(newCase.Id, newClient.Id);
        Case_Party__c result2 = caseUtils.retrieveCaseParty(null, null);
        Test.stopTest();
        system.assertEquals(newCase.Id, result.Case__c);
        system.assertEquals(newClient.Id, result.Contact__c);
        system.assertEquals(null, result2);
               
    }

    @IsTest
    static void retrieveCasePartiesTest(){
        
        buildTestData();
        Test.startTest();
        List<Case_Party__c> result = caseUtils.retrieveCaseParties(newCase);
        Test.stopTest();
        
    }

    @IsTest
    static void retrieveCasePartyWithCasePartyIdTest(){
        buildTestData();
        Test.startTest();
        Case_Party__c result = caseUtils.retrieveCaseParty(newCaseParties[0].Id);
        Case_Party__c result2 = caseUtils.retrieveCaseParty(null);
        Test.stopTest();
        system.assertEquals(newCase.Id, result.Case__c);
        system.assertEquals(newClient.Id, result.Contact__c);
        system.assertEquals(null, result2);
    }

    @IsTest
    static void retrieveConsultationByServiceTest(){
        buildTestData();
        Test.startTest();
        Consultation__C serviceTest = [SELECT Id FROM Consultation__C LIMIT 1];
        Consultation__C result = caseUtils.retrieveConsultation(serviceTest.Id);
        Consultation__C result2 = caseUtils.retrieveConsultation(null);
        Test.stopTest();
        system.assertEquals(newCase.Id, result.Case__c);
        system.assertEquals(null, result2);
        
        
    }

    @IsTest
    static void retrieveConsultationByCaseTest(){
        buildTestData();
        Test.startTest();
        List<Consultation__c> result = caseUtils.retrieveConsultations(newCase);
        Test.stopTest();
        system.assertEquals(newCase.Id, result[0].Case__c);
        
    }

    @IsTest
    static void retrieveConsultationsByCaseTest(){
        buildTestData();
        Test.startTest();
        List<Consultation__C> result = caseUtils.retrieveConsultations(newCase);
        Test.stopTest();
        system.assertEquals(newCase.Id, result[0].Case__c);
        
    }

    @IsTest
    static void retrieveContlictLogsByCaseTest(){
        buildTestData();
        Test.startTest();
        List<Conflict_Log__c> result = caseUtils.retrieveContlictLogs(newCase);
        Test.stopTest();
        system.assertEquals(newCase.Id, result[0].Case__c);
        
        
    }

    @IsTest
    static void retrieveContlictLogsByClientTest(){
        buildTestData();
        Test.startTest();
        List<Conflict_Log__c> result = caseUtils.retrieveContlictLogs(newClient);
        Test.stopTest();
        system.assertEquals(newCase.Id, result[0].Case__c);
    }

    @IsTest
    static void retrieveContlictLogsByClientIdTest(){
        buildTestData();
        Test.startTest();
        List<Conflict_Log__c> result = caseUtils.retrieveConflictLogs(newClient.Id);
        Test.stopTest();
        
    }

    @IsTest
    static void retrieveConflictLogsBySearchLogIdTest(){
        buildTestData();
        Test.startTest();
        List<Conflict_Log__c> result = caseUtils.retrieveConflictLogsBySearchLogId(newSlClient.Id);
        Test.stopTest();
        
    }

    @IsTest
    static void retrieveConflictLogs(){
        buildTestData();
        al.NestableCondition whereCand = new al.AndCondition();
        Test.startTest();
        List<Conflict_Log__c> result = caseUtils.retrieveConflictLogs(whereCand);
        Test.stopTest();
        system.assertEquals(newCase.Id, result[0].Case__c);
        
    }

    @IsTest
    static void retrieveCasesByReferral(){
        CaseUtils caseUtilsTest = new CaseUtils();

        Account accountTest = TEST_TestUtils.createAcct('Household');
        
        Test.startTest();
        List<Case> result = caseUtilsTest.retrieveCasesByReferral(accountTest, '', '');
        List<Case> result2 = caseUtilsTest.retrieveCasesByReferral(null, '', '');
        Test.stopTest();
    }

    @IsTest
    static void retrieveCasesBySubjectTest(){
        buildTestData();
        Test.startTest();
        List<Case> result = caseUtils.retrieveCasesBySubject(newSubject);
        List<Case> result2 = caseUtils.retrieveCasesBySubject(null);
        Test.stopTest();
        
    }

    @IsTest
    static void retrieveLatestCaseSvcNoteTest(){
        buildTestData();
        Test.startTest();
        Note result = caseUtils.retrieveLatestCaseSvcNote(newCase, newSvc);
        Test.stopTest();
        
    }

    @IsTest
    static void retrieveCaseConsultationNotesWrapsTest(){
        buildTestData();
        Test.startTest();
        List<NotesWrapper> result = caseUtils.retrieveCaseConsultationNotesWraps(newCase);
        Test.stopTest();
        
    }

    @IsTest
    static void buildConsultationAndNoteTest(){
        buildTestData();
        Test.startTest();
        Consultation__c cons = caseUtils.buildConsultation(newCase);
        Note note = caseUtils.buildConsultationNote(newCase, cons);
        Test.stopTest();

        System.assertEquals(newCase.id, cons.Case__c);
        system.assertEquals(cons.Id, note.ParentId);
        
    }

    @IsTest
    static void retrievePossibleCaseConflictsTest(){
        buildTestData();
        Test.startTest();
        List<Possible_Conflict__c> result = caseUtils.retrievePossibleCaseConflicts(newSlClient.Id, 'Client');
        Test.stopTest();

        System.assertEquals(0, result.size());
        
    }

    @IsTest
    static void retrieveCaseLitQuestionsTest(){
        buildTestData();
        Test.startTest();
        List<Consultation_Question__c> result1 = caseUtils.retrieveCaseLitQuestions(null);
        List<Consultation_Question__c> result2 = caseUtils.retrieveCaseLitQuestions(newSubject);
        Test.stopTest();

        System.assertEquals(null, result1);
        System.assertEquals(null, result2);
    }

    @IsTest
    static void retrieveSurveysByCaseTest(){
        buildTestData();
        Test.startTest();
        List<Survey_Feedback__c> result1 = caseUtils.retrieveSurveysByCase(null);
        List<Survey_Feedback__c> result2 = caseUtils.retrieveSurveysByCase(newCase);
        Test.stopTest();
        System.assertEquals(null, result1);        
    }

    @IsTest
    static void retrieveSurveys(){
        buildTestData();
        al.NestableCondition whereCand = new al.AndCondition();
        Test.startTest();
        List<Survey_Feedback__c> result = caseUtils.retrieveSurveys(whereCand);
        Test.stopTest(); 
    }

    @IsTest
    static void createGuid(){
        CaseUtils caseUtilsTest = new CaseUtils();

        Test.startTest();
        String result = caseUtilsTest.createGuid();
        Test.stopTest();     
    }

    @IsTest
    static void buildCaseCats(){
        buildTestData();
        Test.startTest();
        List<String> result = caseUtils.buildCaseCats(newCase);
        Test.stopTest();
        System.assertEquals(3, result.size());
        
    }

}