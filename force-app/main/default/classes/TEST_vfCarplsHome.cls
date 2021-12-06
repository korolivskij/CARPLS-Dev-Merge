/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. 
 *
 */ 
@isTest(SeeAllData=false)
public class TEST_vfCarplsHome {

    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlCarplsHome_NewDesign ctrlHome          		{ get; set; }
  
    public static   PageReference       prHome			   			{ get; set; }
   
    public static   Contact             newClient 					{ get; Set; }	
    public static   Search_Log__c       newSlClient					{ get; set; }
    public static   Case 				newCase						{ get; Set; }
	public static   Account             newAcct						{ get; set; }
	 
	public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prHome = Page.vfCarplsHome;
        caseUtils = new CaseUtils();
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
        
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {                              
				testOpenCases();
				testNoOpenCases();			
				testMiscMethods();
				testRemoteMethods();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testOpenCases() {
  		
		prHome = Page.vfCarplsHome;
		Test.setCurrentPage(prHome); 
		Map<String,String> mParms = prHome.getParameters();
		
		ctrlHome = new ctrlCarplsHome_NewDesign();

	}
	
  	private static void testNoOpenCases() {
  		
		prHome = Page.vfCarplsHome;
		Test.setCurrentPage(prHome); 
		Map<String,String> mParms = prHome.getParameters();
		newCase.Status = 'Closed';
		update newCase;	
		ctrlHome = new ctrlCarplsHome_NewDesign();

	}

	private static void testMiscMethods() {
		ctrlHome.doNothing();
		ctrlHome.doCheckForOpenCases();

		ctrlHome.doIntakeSearch();
		ctrlHome.doRefreshTasks();
		ctrlHome.doRefreshCases();
		ctrlHome.doRefreshNews();


		ctrlHome.doRefreshUserServicedClients();
		ctrlHome.refreshUserNewsItems();
		ctrlHome.refreshUserCases();
		ctrlHome.doRefreshLeftOpenCases();
		ctrlHome.doRefreshAllPendingContacts();
		ctrlHome.refreshUserOwnedContacts();
		
		ctrlHome.doViewSearch();

		//ctrlHome.getDisplayTaskResults();
		ctrlHome.getDisplayCaseResults();
		ctrlHome.getDisplayPendingContactsResults();
		ctrlHome.getDisplaySearchLogResults();
		ctrlHome.getCountSearchLogResults();		
		ctrlHome.getDisplayUserServicedClients();
		Id taskId = [select id from task limit 1].id;
		ctrlHome.selectedId = taskId;
		ctrlHome.doCloseTask();
		ctrlHome.getDisplayEventResults();
		ctrlHome.getDisplayMyServices();
		Double d = ctrlHome.offset;
		//ctrlHome.getOffset();



		
		
	}
	//RJN TABX
	private static void testRemoteMethods() {
		//Delete an incomplete service. (well any service but force it)
		Id caseId = newCase.Id;
		List<Consultation__c> svcsToDel = [select id from consultation__c where case__c = :caseId];
		if(svcsToDel != null && !svcsToDel.isEmpty()) {
			Consultation__c svcToDel = svcsToDel[0];
			Id svcIdToDel = svcToDel.id;
			Boolean deleted = ctrlCarplsHome_NewDesign.remoteDeleteIncompleteService(svcIdToDel);
			System.assert(deleted);
			
			String svcBogusID = 'bogusIdGoBoom';
			deleted = ctrlCarplsHome_NewDesign.remoteDeleteIncompleteService(svcBogusId);
			System.assertNotEquals(deleted,true);
		}
	}
    private static void buildTestData() {
    						
		newClient = TEST_TestUtils.createContact('Client');	
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);		
		TEST_TestUtils.debugSObj(newCase);
		List<News_Item__c> newsItems = new List<News_Item__c>();
		newsItems.add(new News_Item__c(Description__c='I love news1',title__c='UT Title1', profile__c='All'));
		newsItems.add(new News_Item__c(Description__c='I love news2',title__c='UT Title2', profile__c='All'));
		insert newsItems;
		Task t = new Task();
		t.ownerId = uTstExecUser.id;
		t.subject = 'blah';
		t.status = 'Open';
		t.priority = 'Normal';
		t.activityDate = Date.today();
		insert t;

	}    
}