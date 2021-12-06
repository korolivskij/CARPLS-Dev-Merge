/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. 
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfDefects {

    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlDefectLauncher	ctrlDefectLauncher          { get; set; }
    public static   ctrlDefectSaveResults	ctrlDefectSaveResults   { get; set; }
    public static   PageReference       prDefLauncher			   	{ get; set; }
    public static   PageReference       prDefSaveResults			{ get; set; }
    public static   Contact             newClient 					{ get; Set; }	
    public static   Search_Log__c       newSlClient					{ get; set; }
    public static   Case 				newCase						{ get; Set; }
	public static   Account             newAcct						{ get; set; }
	
	public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prDefLauncher = Page.vfDefectLauncher;
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
				testDefectEntry();			
				testMiscMethods();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testDefectEntry() {
  		
		prDefLauncher = Page.vfDefectLauncher;
		Test.setCurrentPage(prDefLauncher); 
		Map<String,String> mParms = prDefLauncher.getParameters();
		
		ctrlDefectLauncher = new ctrlDefectLauncher();
		ctrlDefectLauncher.doInit();
		ctrlDefectLauncher.sPrimaryEntityId = newClient.id;
		ctrlDefectLauncher.doOnFocusedPrimaryTabEvent();
		ctrlDefectLauncher.sSubEntityId = newClient.id;
		ctrlDefectLauncher.doOnFocusedSubTabEvent();
		
		ctrlDefectLauncher.c.subject = 'BLAH DEFECT';
		prDefSaveResults = ctrlDefectLauncher.doSaveCase();
		
		
		// pr = new PageReference('/apex/vfDefectSaveResults?id='+caseIdInserted);
		Test.setCurrentPageReference(prDefSaveResults);
		String caseId = prDefSaveResults.getParameters().get('id');
		System.assert(caseId != null);
		Case cse = [select id from case where id = :caseId];
		ctrlDefectSaveResults = new ctrlDefectSaveResults(new ApexPages.StandardController(cse));
		ctrlDefectSaveResults.doInitPage();	
		ctrlDefectSaveResults.getTheController();
		ctrlDefectSaveResults.doClose();
	}
	private static void testMiscMethods() {
		
	}
    private static void buildTestData() {
    						
		newClient = TEST_TestUtils.createContact('Client');	
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);		
		TEST_TestUtils.debugSObj(newCase);
	}    
}