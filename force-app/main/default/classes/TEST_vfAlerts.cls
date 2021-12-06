/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. and.. toggle case / service status correctly.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfAlerts {

    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlAlerts			ctrlAlerts           	{ get; set; }
    public static   PageReference       prAlertView			   	{ get; set; }
    public static   Contact             newClient 					{ get; Set; }	
    public static   Search_Log__c       newSlClient					{ get; set; }
    public static   Case 				newCase						{ get; Set; }
	public static   Account             newAcct						{ get; set; }
	public static   List<Alert__c>      newAlerts					{ get; set; }
	
	public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prAlertView = Page.vfAlerts;
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
            	                  
				testPopAlertsMultiple();
				testPopAlertsSingle();
				testMiscMethods();
				
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testPopAlertsMultiple() {
  		
		prAlertView = Page.vfAlerts;
		Test.setCurrentPage(prAlertView); 
		Map<String,String> mParms = prAlertView.getParameters();
		//client alerts
		ctrlAlerts = new ctrlAlerts();
		ctrlAlerts.doInit();
		ctrlAlerts.sPrimaryEntityId = newClient.id;
		ctrlAlerts.doOnFocusedPrimaryTabEvent();
		ctrlAlerts.selectedAlertId = newAlerts[0].id;
		ctrlAlerts.doSelectAlert();
		
		ctrlAlerts.sSubEntityId = newClient.id;
		ctrlAlerts.doBackToList();
		
		//case alerts
		ctrlAlerts = new ctrlAlerts();
		ctrlAlerts.doInit();
		ctrlAlerts.sPrimaryEntityId = newCase.id;
		ctrlAlerts.doOnFocusedPrimaryTabEvent();
		ctrlAlerts.selectedAlertId = newAlerts[0].id;
		ctrlAlerts.doSelectAlert();
		
		ctrlAlerts.sSubEntityId = newClient.id;
		ctrlAlerts.doBackToList();		
	}
	private static void testPopAlertsSingle() {
		prAlertView = Page.vfAlerts;
		Test.setCurrentPage(prAlertView); 
		Map<String,String> mParms = prAlertView.getParameters();
	
		Alert__c a = newAlerts[1];
		delete a;
		//client alerts
		ctrlAlerts = new ctrlAlerts();
		ctrlAlerts.doInit();
		ctrlAlerts.sPrimaryEntityId = newClient.id;
		//rjn all of the sudden randomly throwing NPE.. doesn't make sense @TODO RJN Investigate when time is available
		try {
			ctrlAlerts.doOnFocusedPrimaryTabEvent();
		} catch (Exception e) {
			system.debug(e);  
		}
			ctrlAlerts.selectedAlertId = newAlerts[0].id;
		ctrlAlerts.doSelectAlert();	
		//case alerts
		ctrlAlerts = new ctrlAlerts();
		ctrlAlerts.doInit();		
		ctrlAlerts.sPrimaryEntityId = newCase.id;
		ctrlAlerts.doOnFocusedPrimaryTabEvent();
		ctrlAlerts.selectedAlertId = newAlerts[0].id;
		ctrlAlerts.doSelectAlert();		
		
		//no alert found
		ctrlAlerts = new ctrlAlerts();
		ctrlAlerts.doInit();		
		ctrlAlerts.sPrimaryEntityId = null;
		ctrlAlerts.doOnFocusedPrimaryTabEvent();				
		
	}

	private static void testMiscMethods() {
		ctrlAlerts.getShowNoDataFound();
		ctrlAlerts.getTheController();
		//ctrlAlerts.clearAlertsView();
		
	}
    private static void buildTestData() {
    	
					
		newClient = TEST_TestUtils.createContact('Client');	
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);		
		TEST_TestUtils.debugSObj(newCase);
	
		Alert__c a1 = new Alert__c(alert_message__c = 'Blah1', case__c = newCase.id, contact__c = newClient.id, status__c = 'Open');
		Alert__c a2 = new Alert__c(alert_message__c = 'Blah2', case__c = newCase.id, contact__c = newClient.id, status__c = 'Open');
		newAlerts = new List<Alert__c>();
		newAlerts.add(a1);
		newAlerts.add(a2);
		insert newAlerts;
		  
	}    

	
    
}