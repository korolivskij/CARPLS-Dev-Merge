/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO haven't even started this! 
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfSubjectView {

    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlSubjectView		ctrlSubjectView           	{ get; set; }
    public static   PageReference       prSubjectView			   	{ get; set; }
    public static   Contact             newClient 					{ get; Set; }	
    public static   Search_Log__c       newSlClient					{ get; set; }
    public static   Case 				newCase						{ get; Set; }
	public static   Subject__c          newSubject					{ get; set; }
	
	public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prSubjectView = Page.vfSubjectView;
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
				testViewSubject();
				testSelectSubject();
				testViewSubjectWithAppliedResources();
				testMiscMethods();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testViewSubject() {
  		
  		prSubjectView = Page.vfSubjectView;
		Test.setCurrentPage(prSubjectView); 
		Map<String,String> mParms = prSubjectView.getParameters();
		mParms.put('caseId',newCase.id);
		mParms.put('id',newSubject.id);
		//constructor a
		ctrlSubjectView = new ctrlSubjectView();
		ctrlSubjectView.setClickedSubjectId(newSubject.id);
		ctrlSubjectView.doInitComponent();
		//constructor b
		ctrlSubjectView = new ctrlSubjectView(new ApexPages.StandardController(newSubject));
		ctrlSubjectView.doInitPage();	
		ctrlSubjectView.showPopup();
		ctrlSubjectView.saveTask();
		
	}

	private static void testSelectSubject() {
		prSubjectView = Page.vfSubjectView;
		Test.setCurrentPage(prSubjectView); 
		Map<String,String> mParms = prSubjectView.getParameters();
		mParms.put('caseId',newCase.id);
		mParms.put('id',newSubject.id);	
		
		newCase.Selected_Subject__c = newSubject.id;
		update newCase;
		ctrlSubjectView = new ctrlSubjectView(new ApexPages.StandardController(newSubject));
		ctrlSubjectView.doInitPage();		
		
	}
	private static void testMiscMethods() {
		ctrlSubjectView.getClickedSubjectId();
		ctrlSubjectView.doSelectSubject();
		ctrlSubjectView.doCancelSubjectSelect();


		
	}
    private static void buildTestData() {
    	
					
		newClient = TEST_TestUtils.createContact('Client');	
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Open');
        
    	newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'Ricks House';
    	insert newSubject;        
        		
		TEST_TestUtils.debugSObj(newCase);
		  		
	}

	/**
	 * User has already added resources to a previous service but they are still active.
	 * no no no. .one can not do that!
	 */
	private static void testViewSubjectWithAppliedResources() {

		Carplsv20Settings__c settings = [	select 	id, SubjectView_Check_Active_Resources__c
		from 	Carplsv20Settings__c ];
		settings.SubjectView_Check_Active_Resources__c = true;
		update settings;

		prSubjectView = Page.vfSubjectView;
		Consultation__c newSvc1 = new Consultation__c(status__c = 'Open', case__C = newCase.id);
		insert newSvc1;
		Account newLrAcct1 = TEST_TestUtils.createAcct('Legal Referral');
		Account newLrAcct2 = TEST_TestUtils.createAcct('Legal Referral');
		Applied_Resource__c ar = new AppliedResourceUtils().buildAppliedResource(newLrAcct1,newCase, newSvc1);
		insert ar;

		Test.setCurrentPage(prSubjectView);
		Map<String,String> mParms = prSubjectView.getParameters();
		mParms.put('caseId',newCase.id);
		mParms.put('id',newSubject.id);
		//constructor a
		ctrlSubjectView = new ctrlSubjectView();
		ctrlSubjectView.setClickedSubjectId(newSubject.id);
		ctrlSubjectView.doInitComponent();
		//constructor b
		ctrlSubjectView = new ctrlSubjectView(new ApexPages.StandardController(newSubject));
		ctrlSubjectView.doInitPage();
		system.assert(ctrlSubjectView.getActiveResourceIds().contains(ar.id));
	}

	
    
}