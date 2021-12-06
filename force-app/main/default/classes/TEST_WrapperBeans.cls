/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_WrapperBeans{
     
    public static   User         				uTstExecUser       	{ get; set; }
	public static   User         				newUser		       	{ get; set; }	
	public static   Contact						newClient			{ get; set; }
	public static   Case						newCase				{ get; set; }
	public static   List<Consultation__c>		newServices			{ get; set; }
	public static   CaseUtils					caseUtils			{ get; set; }

	public static   Account						newAcctLegal1		{ get; set; }
	public static   Account						newAcctLegal2		{ get; set; }
   
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
    caseUtils = new CaseUtils();   
    buildTestData(); 
 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {      	
      	
        testLegalBeans();
      
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  
  	private static void buildTestData() {
 		
 		newClient = TEST_TestUtils.createContact('Client');
 		newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Open');		
  		newServices = caseUtils.retrieveConsultations(newCase);
  		
  		newAcctLegal1 = TEST_TestUtils.createAcct('Legal Referral');
  		newAcctLegal1 = AccountUtils.retrieveAccount(newAcctLegal1.id);
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctLegal1);
  		newAcctLegal1 = AccountUtils.retrieveAccount(newAcctLegal1.id);
  		newAcctLegal2 = TEST_TestUtils.createAcct('Legal Referral');
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctLegal2);
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctLegal2);
  		newAcctLegal2 = AccountUtils.retrieveAccount(newAcctLegal2.id);


  	}
	/**
	 * @TODO Asserts!!
	 */
    private static void testLegalBeans() { 
    	List<LegalRefWrapper> lrWraps1 = new List<LegalRefWrapper>();
    	lrWraps1.add(new LegalRefWrapper(newAcctLegal1,true));
    	lrWraps1.add(new LegalRefWrapper(newAcctLegal2,false));
    	lrWraps1.sort();		

    	List<LegalRefWrapper> lrWraps2 = new List<LegalRefWrapper>();
    	lrWraps2.add(new LegalRefWrapper(newAcctLegal2,true));
    	lrWraps2.add(new LegalRefWrapper(newAcctLegal1,false));
    	lrWraps2.sort();	 
    	
    	LegalRefWrapper lrWrapper = new LegalRefWrapper(newAcctLegal1,true);
    	lrWrapper.setResource(newAcctLegal1);
    	lrWrapper.getResource();  		
    	
    	lrWrapper.setCheckBox(true);
    	lrWrapper.getCheckBox();
    	
    	lrWrapper.setSortOrder(1);
    	lrWrapper.getSortOrder();
    	
    	lrWrapper.setResType(ResourceType.LEGAL);
    	lrWrapper.getResType();
    }  
    

}