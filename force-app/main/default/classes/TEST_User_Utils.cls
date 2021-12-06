/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_User_Utils {
     
    public static   User         				uTstExecUser       { get; set; }
	public static   User         				newUser		       { get; set; }
   
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
  
  	private static void buildTestData() {
  		
		//build test user
  		 TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('','','','' );
  		 Datetime   dtTstStart        = Datetime.now();
	
	   	CollaborationGroup cg = new CollaborationGroup();
    	cg.Name = 'Case Documents - Read Only - UNIT TEST';
    	cg.CollaborationType = 'Public';
    	insert cg;   
		
		User u  = new User();
		
		Double x = Math.random() * 10000;
		String rd = String.valueOf(Integer.valueOf(x));
		User usr = new User();
		usr.FirstName = 'testfirstopmem';
		usr.LastName = 'testlastopmem';
		usr.EmailEncodingKey = 'ISO-8859-1';
		usr.Email = 'info@ext-it.com';
		usr.Alias = rd;
		usr.TimeZoneSidKey = 'America/Los_Angeles';
		usr.Username = 'somenam' + rd + '@ext-it.com';
		usr.LanguageLocaleKey = 'en_US';
		usr.LocaleSidKey = 'en_US';
		usr.CommunityNickname = 'somename' + rd;
		
		if (sec.pr.length() > 0) {
			usr.ProfileId = sec.pr;
		} else {
			usr.ProfileId = UserUtils.getProfileByName('System Administrator').id;
		}
		if (sec.rl.length() > 0)
			usr.UserRoleId = sec.rl;
			
	
		insert usr;		
		newUser = usr;
		
		
		
		Contact c = new Contact(lastname='Mock user contacdt');
		c.OwnerId = newUser.id;
		insert c;
		
  	}
  
	/**
	 * @TODO Asserts!!
	 */
    private static void testAllUtils() {    	
    	 
    	system.assertEquals(UserUtils.getProfileByName('System Administrator').name,'System Administrator'); 
    	system.assertEquals(UserUtils.getProfileByName(null),null);  
    	
    	system.assertEquals(UserUtils.getProfileNameByUserId(newUser.id),'System Administrator'); 
 		
 		Profile profSa = UserUtils.getProfileByName('System Administrator');
 		system.assert(Utilities.doesListHaveValue(UserUtils.getUsersByProfileId(profSa.id)));
 		
 		List<User> lUsers1 = UserUtils.retrieveAllUsers(newUser.id);
 		UserUtils.retrieveAllOrgProfiles();
 		UserUtils.retrieveUserOwnedContacts(newUser.id);
 		UserUtils.getUsersTasks(newUser.id, 'Open', 2);
 		UserUtils.retrieveUserById(newUser.id); 		
 		UserUtils.retrieveTodaysServicedClients(newUser.id);
 		UserUtils.retrieveCases(newUser.id, 'Open', 'Carpls_Cases', 2); 
 		UserUtils.retrieveNewsItems(2);
   		
    }  

}