/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO haven't even started this! 
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfSubjectEdit {
 
    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlSubjectExtension			ctrlSubjectExtension           		{ get; set; }
    public static   PageReference       prSubjectView			   	{ get; set; }
    public static   Contact             newClient 					{ get; Set; }	
    public static   Search_Log__c       newSlClient					{ get; set; }
    public static   Case 				newCase						{ get; Set; }
	public static   Subject__c          newSubject					{ get; set; }
	
	public static   Account				newAcctWebLink				{ get; set; }
	public static   Account				newAcctLegal				{ get; set; }
	public static   Account				newAcctSocial				{ get; set; }
	public static   Loop__DDP__c		newDdp						{ get; set; } 
	public static   Consultation_Question__c	newCaseQ			{ get; set; }
	
	public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prSubjectView = Page.vfSubject;
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
				testEditWebLinks();
				testEditLegalRefs();
				testEditSocialRefs();
				/*
				testEditDdps();
				testEditQuestions();
				testMiscMethods();
				*/
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testViewSubject() {
  		
  		prSubjectView = Page.vfSubject;
		Test.setCurrentPage(prSubjectView); 
		Map<String,String> mParms = prSubjectView.getParameters();		
		mParms.put('id',newSubject.id);
		ctrlSubjectExtension = new ctrlSubjectExtension(new ApexPages.StandardController(newSubject));

	}
	private static void testEditWebLinks() {
		ctrlSubjectExtension.doEditWebLinks();
		ctrlSubjectExtension.clickedAcctType = 'WEBLINK';
		ctrlSubjectExtension.doSaveAccounts();
		//-- uncheck some (delete junctions)
		ctrlSubjectExtension.doEditWebLinks();
		for(ctrlSubjectExtension.WebLinkWrapper wlWrap : ctrlSubjectExtension.webLinkWraps) {
			wlWrap.checkBox = false;
		}				
		ctrlSubjectExtension.doSaveAccounts();			
		
		ctrlSubjectExtension.doCancel();
	}
	private static void testEditLegalRefs() {
		ctrlSubjectExtension.doEditLegalRefs();
		ctrlSubjectExtension.clickedAcctType = 'LEGAL';
		ctrlSubjectExtension.doSaveAccounts();
		//-- uncheck some (delete junctions)
		ctrlSubjectExtension.doEditWebLinks();
		for(ctrlSubjectExtension.LegalRefWrapper lrWrap : ctrlSubjectExtension.legalRefWraps) {
			lrWrap.checkBox = false;
		}				
		ctrlSubjectExtension.doSaveAccounts();		
		ctrlSubjectExtension.doCancel();
	}
	private static void testEditSocialRefs() {
		ctrlSubjectExtension.doEditSocialRefs();
		ctrlSubjectExtension.clickedAcctType = 'SOCIAL';
		ctrlSubjectExtension.doSaveAccounts();
		//-- uncheck some (delete junctions)
		ctrlSubjectExtension.doEditWebLinks();
		for(ctrlSubjectExtension.SocialRefWrapper srWrap : ctrlSubjectExtension.socialRefWraps) {
			srWrap.checkBox = false;
		}				
		ctrlSubjectExtension.doSaveAccounts();			
		ctrlSubjectExtension.doCancel();
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
        
        
        newAcctWebLink = TEST_TestUtils.createAcct('WebLink','Resources',newSubject);
        newAcctLegal = TEST_TestUtils.createAcct('Legal Referral','Resources',newSubject);
        newAcctSocial = TEST_TestUtils.createAcct('Social Service Referral','Resources',newSubject);
        newDdp = TEST_TestUtils.createDdp(newSubject);
        
        newCaseQ = TEST_TestUtils.createQuestion('answer_court_case_nbr__c', newSubject, true);
        
        //insert a second of each
        TEST_TestUtils.createAcct('WebLink','Resources',newSubject);
        TEST_TestUtils.createAcct('Legal Referral','Resources',newSubject);
        TEST_TestUtils.createAcct('Social Service Referral','Resources',newSubject);
        TEST_TestUtils.createDdp(newSubject);
        TEST_TestUtils.createQuestion('answer_court_case_nbr__c', newSubject, false);
        
        TEST_TestUtils.debugSObj(newAcctWebLink);
        
        		
		TEST_TestUtils.debugSObj(newCase);
		  		
	}    

	
    
}