/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_WrapperBeans_Continued{
     
    public static   User         				uTstExecUser       	{ get; set; }
	public static   User         				newUser		       	{ get; set; }	
	public static   Contact						newClient			{ get; set; }
	public static   Case						newCase				{ get; set; }
	public static   List<Consultation__c>		newServices			{ get; set; }
	public static   CaseUtils					caseUtils			{ get; set; }


	public static   Account						newAcctWebLink1		{ get; set; }
	public static   Account						newAcctWebLink2		{ get; set; }
	
	public static   Loop__DDP__c				newDdp1				{ get; set; }
	public static   Loop__DDP__c				newDdp2				{ get; set; }
	
	   
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
      	      	
        testWebLinkBeans();
      	testDdpBeans();
      	
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
  		
  		
  		newAcctWebLink1 = TEST_TestUtils.createAcct('Web Links');
  		newAcctWebLink1 = AccountUtils.retrieveAccount(newAcctWebLink1.id);
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctWebLink1);
  		newAcctWebLink1 = AccountUtils.retrieveAccount(newAcctWebLink1.id);
  		newAcctWebLink2 = TEST_TestUtils.createAcct('Web Links');
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctWebLink2);
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newAcctWebLink2);
  		newAcctWebLink2 = AccountUtils.retrieveAccount(newAcctWebLink2.id);  	
  		
  		newDdp1 = TEST_TestUtils.createDdp();	
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newDdp1);
  		newDdp1 = DDPUtils.retrieveDdp(newDdp1.id);
  		
  		newDdp2 = TEST_TestUtils.createDdp();	
  		TEST_TestUtils.createAr(newCase.id, newServices[0].id, newDdp2);
  		newDdp2 = DDPUtils.retrieveDdp(newDdp2.id);  		

  	}

    
    private static void testWebLinkBeans() { 
    	List<WebLinkRefWrapper> wlWraps1 = new List<WebLinkRefWrapper>();
    	wlWraps1.add(new WebLinkRefWrapper(newAcctWebLink1,true));
    	wlWraps1.add(new WebLinkRefWrapper(newAcctWebLink2,false));
    	wlWraps1.sort();		

    	List<WebLinkRefWrapper> wlWraps2 = new List<WebLinkRefWrapper>();
    	wlWraps2.add(new WebLinkRefWrapper(newAcctWebLink2,true));
    	wlWraps2.add(new WebLinkRefWrapper(newAcctWebLink1,false));
    	wlWraps2.sort();	 
    	
    	WebLinkRefWrapper wlWrapper = new WebLinkRefWrapper(newAcctWebLink1,true);
    	wlWrapper.setResource(newAcctWebLink1);
    	wlWrapper.getResource();  		
    	
    	wlWrapper.setCheckBox(true);
    	wlWrapper.getCheckBox();
    	
    	wlWrapper.setSortOrder(1);
    	wlWrapper.getSortOrder();
    	
    	wlWrapper.setResType(ResourceType.WEBLINK);
    	wlWrapper.getResType();
    }  
    
    private static void testDdpBeans() { 
    	List<DdpWrapper> ddpWraps1 = new List<DdpWrapper>();
    	ddpWraps1.add(new DdpWrapper(newDdp1,true));
    	ddpWraps1.add(new DdpWrapper(newDdp2,false));
    	ddpWraps1.sort();		

    	List<DdpWrapper> ddpWraps2 = new List<DdpWrapper>();
    	ddpWraps2.add(new DdpWrapper(newDdp2,true));
    	ddpWraps2.add(new DdpWrapper(newDdp1,false));
    	ddpWraps2.sort();	 
    	
    	DdpWrapper ddpWrapper = new DdpWrapper(newDdp1,true);
    	ddpWrapper.checkBox = false;
    	ddpWrapper.ddp = newDdp1;
    	ddpWrapper.sortOrder = 1;
	
    	/*
    	ddpWrapper.setCheckBox(true);
    	ddpWrapper.getCheckBox();
    	
    	ddpWrapper.setSortOrder(1);
    	ddpWrapper.getSortOrder();
    	
    	ddpWrapper.setResType(ResourceType.DDP);
    	ddpWrapper.getResType();
    	*/
    }         

}