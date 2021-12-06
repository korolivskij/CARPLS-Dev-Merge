/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_AccountUtils {
    
    public static   User         				uTstExecUser       { get; set; }
    
    public static   Account						newAcct			   { get; set; }  
   	public static   Account						newAcct2			{ get; set; }
    public static   Eligible_Problem_Codes__c	newAcctPc		   { get; set; }
    public static   Eligible_Problem_Codes__c	newAcctPc2		   { get; set; }
    
    public static   Contact						newClient		   { get; set; } 
    public static   Case						newCase			   { get; set; } 
    public static   Subject__c					newSubject		   { get; set; } 
   
  /**
   * Executed by SFDC when running unit test code via GUI
   */
  public static testMethod void executeTest() {
    
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
    buildTestData(); 
 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {      	
      	
        testAllUtils();
        

      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  

  
	/**
	 *
	 */
    private static void testAllUtils() {
    	
    	//-- Just toggle the static debugging crap which makes messages available vailable to the view.
    	system.assertEquals(AccountUtils.getHasDebugMessages(),false);
    	AccountUtils.startDebugging();
    	system.assertEquals(AccountUtils.getHasDebugMessages(),true);
    	AccountUtils.startDebugging();
    	AccountUtils.stopDebugging();
    	system.assertEquals(AccountUtils.getHasDebugMessages(),false);
    	AccountUtils.startDebugging();
    	
    	newAcct = AccountUtils.retrieveAccount(newAcct.id);

    	AccountUtils.retrieveWebLinks( newCase );
    	AccountUtils.retrieveWebLinks( new ProblemCodeWrapper(newCase) );
    	
    	AccountUtils.retrieveSocialRefs(newCase, newAcct);
    	AccountUtils.retrieveSocialRefs(new ProblemCodeWrapper(newCase));
    	
    	AccountUtils.retrieveLegalRefs ( newCase, newClient);
    	AccountUtils.retrieveLegalRefs( new ProblemCodeWrapper( newCase) );
    	 
    	AccountUtils.retrieveAccountResources(  ResourceType.LEGAL, null, newAcct, newClient );
    	ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(newCase);
    	pcWrap.practiceArea = null;
    	AccountUtils.retrieveAccountResources(  ResourceType.LEGAL,pcWrap , newAcct, newClient );    	
        
    	pcWrap.practiceArea = '';
    	pcWrap.problemCategory = '';
    	pcWrap.problemCode = '';
    	pcWrap.jurisdiction = '';
    	AccountUtils.retrieveAccountResources(  ResourceType.LEGAL,pcWrap , newAcct, newClient );    	
    	
    	AccountUtils.retrieveAcctIdsBySubject(newSubject.id, 'LEGAL');
    	AccountUtils.retrieveAcctIdsBySubject(newSubject.id, ResourceType.LEGAL);    	
    	
    	AccountUtils.retrieveAccounts(new Set<ID>{newAcct.id,newAcct2.id}, ResourceType.LEGAL,newClient); 
        
    	Account testAcct = AccountUtils.retrieveAccountWoLongText(newAcct.id);
        testAcct = AccountUtils.buildNewOrgAccount(newClient);
    	
    	/*
    	//@see retrieveEligibleProblemCodes(Id sObjectId, String sLookupFieldName)
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct.id, null),null);
    	system.assertNotEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct.id, 'account__c'),null);
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct.id, 'SFDCSUCKS'),null);
    	
    	//@TODO CATCH THIS IN UTILS CLASS. system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes('thisidwillblowitup', 'SFDCSUCKS'),null);
    	
    	List<ProblemCodeWrapper> pcWrapsNull = null;
    	List<ProblemCodeWrapper> pcWraps = new List<ProblemCodeWrapper> {new ProblemCodeWrapper(newAcctPc)};    	
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(pcWrapsNull, null),null);
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(pcWraps, null),null);
    	
    	List<Id> epcIdsFound = ProblemCodeUtils.retrieveEligibleProblemCodes(pcWraps, 'Account__c');
    	system.assert(Utilities.doesListHaveValue(epcIdsFound));
    	
    	//@see retrieveEligibleProblemCodes(Account a, Case cse) 
    	List<Eligible_Problem_Codes__c> epcsFound = ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct,newCase);
    	system.assert(Utilities.doesListHaveValue(epcsFound));
    		
   		//@see retrieveEligibleProblemCodes(ProblemCodeWrapper pcWrap, String sLookupFieldName)
   		epcIdsFound = null;
   		epcIdsFound = ProblemCodeUtils.retrieveEligibleProblemCodes(new ProblemCodeWrapper(newCase),'account__c');
   		system.assert(Utilities.doesListHaveValue(epcIdsFound));
   		*/
   		
    }  
  	private static void buildTestData() {
  		
  		newAcct = TEST_TestUtils.createAcct('Legal Referral');  
  		
  		
  		newAcctPc = new Eligible_Problem_Codes__c();
  		newAcctPc.Practice_Area__c = 'pa1';
  		newAcctPc.Problem_Category__c = 'pcat1';
  		newAcctPc.Problem_Code__c = 'pc1';
  		newAcctPc.Account__c = newAcct.id;
  		insert newAcctPc;

        newAcct2 = TEST_TestUtils.createAcct('Legal Referral2');  
        newAcct2.Age_Disability_Logic__c='OR';
        update newAcct2;
        
        newAcct2 = TEST_TestUtils.createAcct('Legal Referral2');  
        newAcct2.Age_Disability_Logic__c='OR';
        update newAcct2;  		  	
        
  		newAcctPc = new Eligible_Problem_Codes__c(Practice_Area__c = 'pa1',Problem_Category__c='pcat1',
                                                  Problem_Code__c='pc1',Account__c = newAcct2.id);
  		insert newAcctPc;
    	
    	newClient = TEST_TestUtils.createContact('Client');
    	newClient.Annual_Income_Realtime__c = 10000;
    	newClient.MailingPostalCode = '66666';
    	update newClient;
    	
    	newCase = TEST_TestUtils.createFullClientPartyCase(newClient, 'Open');
    	
    	newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'Ricks House';
    
    	insert newSubject;
    	
    	Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
    	asj.account__c = newAcct.id;
    	asj.subject__c = newSubject.id;
    	insert asj;   
        
    	Account_Subject_Junction__c asj2 = new Account_Subject_Junction__c();        
    	asj2.account__c = newAcct2.id;
    	asj2.subject__c = newSubject.id;        
    	insert asj2; 
        
    	List<Zip__c> zs = new List<Zip__c>();
    	Zip__c z1 = new Zip__c();
    	z1.name = '66666';
    	z1.City__c = 'Chicago';
    	z1.Geographic_Region__c = 'Illinois';
    	zs.add(z1);
    	insert zs;
    	
    	List<Account_Zip_Junction__c> azjs = new List<Account_Zip_Junction__c>();
    	
    	for(Zip__c z : zs) {
    		Account_Zip_Junction__c azj = new Account_Zip_Junction__c();
    		azj.Account__c = newAcct.id;
    		azj.zip__c = z.id;
    		azjs.adD(azj);   
            
    		Account_Zip_Junction__c azj2 = new Account_Zip_Junction__c();
    		azj2.Account__c = newAcct2.id;
    		azj2.zip__c = z.id;
    		azjs.adD(azj2);             
    	}
    	insert azjs;
 	
  	}    
    


}