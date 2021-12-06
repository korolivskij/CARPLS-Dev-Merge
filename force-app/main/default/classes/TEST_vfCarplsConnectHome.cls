/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. 
 *
 */ 
@isTest(SeeAllData=false)
public with sharing class TEST_vfCarplsConnectHome {

	public static final String			ACCT_USER_NAME = 'Test CARPLS Connect Account';	
    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlCarplsConnectHome	ctrlCarplsConnectHome   { get; set; }
  
    public static   PageReference       prCcHome 		   		{ get; set; }
   
    public static   Contact             newClient 					{ get; Set; }	
    public static   Case 				newCase						{ get; Set; }
    public static	Consultation__c		newService					{ get; set; }
	public static   Account             newAcct						{ get; set; }
	 
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prCcHome = Page.vfCarplsconnectHome;
        
        /* 
         *  Just pass blank parms for user now. This is a luxury that I wish we had but we may
         *  run out of time before we can test multiple users / roles / profiles via code.
         *  In the above scenario, a user will be created on the fly and is a system admin
         *  with no roles / permission sets applied.
         * 
         *  @TODO maybe pull testing user from custom setting.
         *  @TODO maybe create different users from different roles / profiles on the fly
         */

        
        coreExecution();
    }
    /**
     * The core launch point for this test class.
     */
    public static void coreExecution() {
        
        Datetime   dtTstStart        = Datetime.now();
        
        //--Create testing user ---
        Id profileId = UserUtils.getProfileByName('System Administrator').id;
        uTstExecUser = getUserForTest(profileId, ACCT_USER_NAME);
        
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        //TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        //Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        //System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {   
            	System.debug(logginglevel.debug, 'Starting test');                     
				testNoPendingOrActedUponCases();
				testCasesExist();	
				List<Selectoption> so = ctrlCarplsConnectHome.getApplResStatusOptions();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testCasesExist() {
  		
		prCcHome = Page.vfCarplsconnectHome;
		Test.setCurrentPage(prCcHome); 
		ctrlCarplsConnectHome.getCurrentDateTime();   
		// Create a few applied resource rows
		Applied_Resource__c ar = new Applied_Resource__c( case__c = newCase.id, consultation__c=newService.Id, 
				Account__c = newAcct.id, Status__c = 'Applied', Closing_Code__c = '', 
				recordtype = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Pending'));
		insert ar;
		Applied_Resource__c ar2 = new Applied_Resource__c( case__c = newCase.id, consultation__c=newService.Id, 
				Account__c = newAcct.id, Status__c = 'Accepted',
				recordtype = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Accepted'));
		insert ar2;
		RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Closed');
		System.debug('record type = '+ rt);
		Applied_Resource__c ar3 = new Applied_Resource__c( recordtype = rt,
				case__c = newCase.id, consultation__c=newService.Id, 
				Account__c = newAcct.id, Status__c = 'Closed', Closing_Code__c = 'Denied Service', Disposition__c = 'Other/Unknown Denied Service');
		//insert ar3;
		Applied_Resource__c ar4 = new Applied_Resource__c( case__c = newCase.id, consultation__c=newService.Id, 
				Account__c = newAcct.id, Status__c = 'Closed', Closing_Code__c = 'None',
				recordtype = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Closed'));				
		insert ar4;
		ctrlCarplsConnectHome = new ctrlCarplsconnectHome();
		ctrlCarplsConnectHome.doInitPage();
	}
	
  	private static void testNoPendingOrActedUponCases() {
  		
		prCcHome = Page.vfCarplsconnectHome;
		Test.setCurrentPage(prCcHome); 
		ctrlCarplsConnectHome = new ctrlCarplsconnectHome();
		ctrlCarplsConnectHome.doInitPage();
        ctrlCarplsConnectHome.doRefreshPendingCases();
        ctrlCarplsConnectHome.doRefreshActedUponCases();
	}

	private static User getUserForTest(Id pProfileId, String pName) {
		
		Double x = Math.random() * 10000;
		String rd = String.valueOf(Integer.valueOf(x));		
		User usr = new User();
		usr.FirstName = '';
		usr.LastName = pName;
		usr.EmailEncodingKey = 'ISO-8859-1';
		usr.Email = rd+'info@ext-it.com';
		usr.Alias = rd;
		usr.TimeZoneSidKey = 'America/Los_Angeles';
		usr.Username = 'test'+rd+ '@ext-it.com';
		usr.LanguageLocaleKey = 'en_US';
		usr.LocaleSidKey = 'en_US';
		usr.CommunityNickname = 'somename' + rd;
		usr.ProfileId = pProfileId;

		insert usr;
//		if (secSettings.pm.length() > 0) {
//			PermissionSetAssignment psa = new PermissionSetAssignment();
//			psa.AssigneeId = usr.Id;
//			psa.PermissionSetId = secSettings.pm;
//			insert psa;
//		}
		return usr;
	}
    private static void buildTestData() {
	
		System.debug(logginglevel.debug, 'in build test data');
		// Create a client, case and consultation    	
    	newClient = TEST_TestUtils.createContact('Client');	
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);		
		TEST_TestUtils.debugSObj(newCase);
		newService = new Consultation__c(case__c = newCase.id);
		insert newService;
		// Create an account and make it a carpls connect account
		newAcct = new Account(name = ACCT_USER_NAME, /*carpls_connect__c = true*/ Partner_Type__c = 'CARPLS Connect');
		insert newAcct;
		// update the contact created via trigger for this account
		//Contact userContact = ContactUtils.retrieveContactInfoByName(ACCT_USER_NAME)[0];
		//userContact.accountId = newAcct.id;
		//update userContact;
		// Create a contact for the account
		Contact userContact = new Contact(lastname = ACCT_USER_NAME, accountid=newAcct.id);
		insert userContact;
		
	}    
}