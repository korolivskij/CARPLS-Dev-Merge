@isTest
private class TEST_ctrlSolutionView {

	public static User uTstExecUser { get; set; }
	public static ctrlSolutionView ctrlSolutionVie { get; set; }
	public static PageReference prSolutionView { get; set; }
	public static Solution__c newSolution { get; set; }
	public static Case newCase { get; Set; }
	public static Contact newClient { get; Set; }
	public static Search_Log__c newSlClient { get; set; }

	@isTest
	private static void executeTest() {
		prSolutionView = Page.vfSolutionView;

		coreExecution('', '', '', '');
	}

	public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {


		Datetime dtTstStart = Datetime.now();

		//-- Get testing user ---
		TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId, sRoleId, sPermSetId);
		uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
		System.debug(logginglevel.warn, ' ---------------> Running Test with User:' + uTstExecUser);

		//-- If no org level custom setting a new one will be created.. 
		TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
		Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
		System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:' + customSetting);
		

		buildTestData();

		testViewSol();
		testViewSolAppl();

	}

	private static void testViewSol() {
		ctrlSolutionVie = new ctrlSolutionView(new ApexPages.StandardController(newSolution));
		ctrlSolutionVie.doInitPage();
		ctrlSolutionVie.showPopup();
		ctrlSolutionVie.doSelectResource();
		
	}

	private static void testViewSolAppl() {
		Carplsv20Settings__c settings = [select id, SolutionView_Check_Active_Resources__c from Carplsv20Settings__c];
		System.debug('settings ' + settings);
		settings.SolutionView_Check_Active_Resources__c = true;
		update settings;
		System.debug('settings2 ' + settings);

		ctrlSolutionVie = new ctrlSolutionView(new ApexPages.StandardController(newSolution));
		ctrlSolutionVie.doInitPage();
		ctrlSolutionVie.showPopup();
		ctrlSolutionVie.doSelectResource();
	}

	private static void buildTestData() {
		newSolution = new Solution__c();
		newSolution.Title__c = 'testName';
		insert newSolution;

		newClient = TEST_TestUtils.createContact('Client');
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
		newCase = TEST_TestUtils.createFullClientPartyCase(newClient);
		Test.setCurrentPage(prSolutionView);
		Map<String, String> mParms = prSolutionView.getParameters();
		mParms.put('caseId', newCase.id);
		mParms.put('id', newSolution.id);
		


	}
}