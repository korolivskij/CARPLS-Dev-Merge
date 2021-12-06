/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_WrapperBeans_Continued2{
     
    public static   User         				uTstExecUser       	{ get; set; }
	public static   User         				newUser		       	{ get; set; }	
	public static   Contact						newClient			{ get; set; }
	public static   Case						newCase				{ get; set; }
	public static   List<Consultation__c>		newServices			{ get; set; }
	public static   CaseUtils					caseUtils			{ get; set; }

	public static   Account						newAcctSocial1		{ get; set; }
	public static   Account						newAcctSocial2		{ get; set; }	
  
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
      	
        testSocialBeans();
      
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

  		newAcctSocial1 = TEST_TestUtils.createAcct('Social Referrals');
  		newAcctSocial1 = AccountUtils.retrieveAccount(newAcctSocial1.id);
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctSocial1);
  		newAcctSocial1 = AccountUtils.retrieveAccount(newAcctSocial1.id);
  		newAcctSocial2 = TEST_TestUtils.createAcct('Social Referrals');
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctSocial2);
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctSocial2);
  		newAcctSocial2 = AccountUtils.retrieveAccount(newAcctSocial2.id);
  		


  	}
/** TO DO: ASSERTS
**/ 
    
    private static void testSocialBeans() { 
    	List<SocialRefWrapper> srWraps1 = new List<SocialRefWrapper>();
    	srWraps1.add(new SocialRefWrapper(newAcctSocial1,true));
    	srWraps1.add(new SocialRefWrapper(newAcctSocial2,false));
    	srWraps1.sort();		

    	List<SocialRefWrapper> srWraps2 = new List<SocialRefWrapper>();
    	srWraps2.add(new SocialRefWrapper(newAcctSocial2,true));
    	srWraps2.add(new SocialRefWrapper(newAcctSocial1,false));
    	srWraps2.sort();	 
    	
    	SocialRefWrapper srWrapper = new SocialRefWrapper(newAcctSocial1,true);
    	srWrapper.setResource(newAcctSocial1);
    	srWrapper.getResource();  		
    	
    	srWrapper.setCheckBox(true);
    	srWrapper.getCheckBox();
    	
    	srWrapper.setSortOrder(1);
    	srWrapper.getSortOrder();
    	
    	srWrapper.setResType(ResourceType.SOCIAL);
    	srWrapper.getResType();
    }  
    
    

}