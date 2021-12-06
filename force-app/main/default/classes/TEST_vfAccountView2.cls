/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. and.. toggle case / service status correctly.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfAccountView2 {

    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlAccountView		ctrlAccountView           	{ get; set; }
    public static   PageReference       prAccountView			   	{ get; set; }
    public static   Contact             newClient 					{ get; Set; }	
    public static   Search_Log__c       newSlClient					{ get; set; }
    public static   Case 				newCase						{ get; Set; }
	public static   Account             newAcct						{ get; set; }
	
	public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prAccountView = Page.vfAccountView;
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
				testViewAccountWithAppliedResources();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }

	/**
	 * User has already added resources to a previous service but they are still active.
	 * no no no. .one can not do that!
	 */
	private static void testViewAccountWithAppliedResources() {

		//Carplsv20Settings__c settings = Carplsv20Settings__c.getInstance();
		Carplsv20Settings__c settings = [	select 	id, AccountView_Check_Active_Resources__c
											from 	Carplsv20Settings__c ];
		settings.AccountView_Check_Active_Resources__c = true;
		update settings;
		prAccountView = Page.vfAccountView;
		Test.setCurrentPage(prAccountView);
		Map<String,String> mParms = prAccountView.getParameters();
		mParms.put('caseId',newCase.id);
		mParms.put('id',newAcct.id);

		Consultation__c newSvc1 = new Consultation__c(status__c = 'Open', case__C = newCase.id);
		insert newSvc1;
		Account newLrAcct1 = TEST_TestUtils.createAcct('Legal Referral');
		Applied_Resource__c ar = new AppliedResourceUtils().buildAppliedResource(newLrAcct1,newCase, newSvc1);
		insert ar;

		Test.setCurrentPage(prAccountView);
		ctrlAccountView = new ctrlAccountView(new ApexPages.StandardController(newAcct));
		ctrlAccountView.doInitPage();
		ctrlAccountView.saveResource();
		ctrlAccountView.shareDocuments(ar.Id);
        
        ctrlAccountview.eRefNote = '';
        ctrlAccountView.eReferralApproved = TRUE;
        ctrlAccountView.doSaveEReferral();
	}
    

    private static void buildTestData() {
    	newAcct = TEST_TestUtils.createAcct('Legal Referral');
        newAcct.military_service__c = true;
        update newAcct;
        
		/* Create Community User for testing */
        Contact newCommContact = new Contact(lastname='Comm User', AccountId = newAcct.id);
        insert newCommContact;
		User usr = new User();
		usr.FirstName = 'test ';
		usr.LastName = 'community user';
		usr.EmailEncodingKey = 'ISO-8859-1';
		usr.Email = 'info@ext-it.com';
		usr.Alias = '1234';
		usr.TimeZoneSidKey = 'America/Los_Angeles';
		usr.Username = 'commtest' + '@ext-it.com';
		usr.LanguageLocaleKey = 'en_US';
		usr.LocaleSidKey = 'en_US';
		usr.CommunityNickname = 'testcomm';
        usr.ContactId = newCommContact.Id;
		usr.ProfileId = UserUtils.getProfileByName('Referral Partner').id;
        insert usr;
		      
        
        
        
		newClient = TEST_TestUtils.createContact('Client');	        
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);		
		TEST_TestUtils.debugSObj(newCase);
		
		//newCase.IsClosed = false;
		//update newCase;
		setupContent();  		 
	}    
	public static void setupContent(){ 
		//RecordType ContentRT = [select Id FROM RecordType WHERE Name='Sales Documents'];
		
        ContentVersion testContentInsert = new ContentVersion(); 
         testContentInsert.VersionData=Blob.valueOf('TEST data');
         testContentInsert.Title ='Test File';
         testContentInsert.ContentLocation='S';
         testContentInsert.PathOnClient = 'Test File.docx';
         testContentInsert.FirstPublishLocationId = newCase.Id;
         //testContentInsert.RecordTypeId = ContentRT.Id; 
		 //testContentInsert.Case__c = newCase.id;
         insert testContentInsert;
        
         ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id]; 
       //  ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name='User Attached Documents']; 
        
         //ContentWorkspaceDoc newWorkspaceDoc =new ContentWorkspaceDoc(); 
         //newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
         //newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
         //insert newWorkspaceDoc;
        
        
        testContent.Case__c = newCase.id;

		System.debug('ContentVersion testContent '+testContent);
        //update testContent;

   }
}