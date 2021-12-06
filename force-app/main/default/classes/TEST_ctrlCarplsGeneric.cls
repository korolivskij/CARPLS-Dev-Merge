/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. @TODO this is lame as hell needs asserts!!
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_ctrlCarplsGeneric {
    
    public static   User         				uTstExecUser       	{ get; set; }
	public static   Contact        				newClient	       	{ get; set; }
	public static   Search_Log__c				newSlClient         { get; set; }
	public static   Search_Log_Children__c		newSlParty			{ get; set; }
	public static   ctrlCarplesGeneric			ctrl				{ get; set; }
   
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
	 * @TODO Asserts!!
	 */
    private static void testAllUtils() {
    	   
    	Pagereference pr = Page.vfCarplsHome;    	
    	TEST.setCurrentPage(pr); //any old page will do since this class is the grandfather of them all.
		Map<String,String> mParms = pr.getParameters();
		mParms.put('fromSearch','false');
		ctrl = new ctrlCarplesGeneric();

    	pr = Page.vfCarplsHome;    	
    	TEST.setCurrentPage(pr); //any old page will do since this class is the grandfather of them all.
		mParms = pr.getParameters();
		mParms.put('fromSearch','true');
		mParms.put('view','true');
		ctrl = new ctrlCarplesGeneric();		
 
    	
    	ctrl.getClientOrphanSearchCategories();
    	ctrl.getClientOtherSearchCategories();
    	ctrl.getShowChatterPanel();
    	ctrl.getResourceHeaderColor();
    	ctrl.getCustomSettingsGood();
    	ctrl.getExistingClientSearchCategories();
    	ctrl.getIsSysAdmin();
    	ctrl.getMyComponentController();
    	ctrl.getObjects();
    	ctrl.initSettings();
    	ctrl.getPartyOrphanSearchCategories();
    	ctrl.getPartyOtherSearchCategories();
 //   	ctrl.getClientSearchCategories();
    	ctrl.getExistingClientSearchCategories();
    	
    	ctrl.updateSearchLogMatchStatus(null, newSlClient.id, newClient.id,'Client');
    	ctrl.updateSearchLogMatchStatus('No', null, newClient.id,'Client');
    	ctrl.updateSearchLogMatchStatus('No', newSlClient.id, newClient.id,'Client');
    	ctrl.slClient = null;
    	ctrl.updateSearchLogMatchStatus('No', newSlClient.id, newClient.id,'Client');
    	
    	newSlClient.Result_Contact_Ids_No_Match__c = newClient.id;
    	update newSlClient;
    	ctrl = new ctrlCarplesGeneric();
    	ctrl.updateSearchLogMatchStatus('No', newSlClient.id, newClient.id,'Client');
    	ctrl.updateSearchLogMatchStatus('Yes', newSlClient.id, newClient.id,'Client');
    	
    	ctrl.updatePartySearchLogMatchStatus( null,newSlParty);
    	ctrl.updatePartySearchLogMatchStatus( 'Yes',null);
    	ctrl.updatePartySearchLogMatchStatus('Yes', newSlParty);
    	
    	newSlClient.Result_Party_Ids_No_Match__c = newSlParty.id;
    	update newSlClient;
		ctrl = new ctrlCarplesGeneric();
		ctrl.updatePartySearchLogMatchStatus('Yes', newSlParty);		    	

    	
    	ctrl.setComponentController(new ctrlComponentBase());
    	ctrl.getThis();
    	ctrl.generateSessionId();
    	
    	ctrl.findObjectNameForId( null );
    	ctrl.findObjectNameForId(newClient.id);
    	
    	ctrl.findSObjectResForApiName('Account');
    	   
    	ctrl.toggleChatter();
    	ctrl.toggleChatter();
    	
    	Exception ex;
    	try {
    		Integer i = 1/0;
    	} catch (Exception e) {
    		ex = e;
    	}
    		
    	ctrl.errorLog('blah1','blah2');  
    	ctrl.errorLog(ex, 'blah');
    	
    
    	ctrl.errorLog(ex);
    	ctrl.SetssCategories(ctrl.getssCategories());
    }  
    
    private static void buildTestData() {
		newClient = TEST_TestUtils.createContact('Client');	
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last', user__c=uTstExecUser.id);	
		insert newSlClient;

		Contact p1 = new Contact(lastname='Party1');
		Search_Log_Children__c slc1 = new Search_Log_Children__c();
		slc1.Client_Search_Log__c = newSlClient.id;
		insert slc1;
		newSlParty = slc1;		
    }
    
    

}