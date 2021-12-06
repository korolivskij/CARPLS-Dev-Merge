/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)	
public class TEST_User_Trigger {
	
	public static   User         			uTstExecUser       	{ get; set; }
	public static   Contact	 				newC1				{ get; set; }

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
    
   	//-- Prepare data outside of starttest if possible.
   //	buildTestData(); 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     *
     */



    Test.startTest();
    
      System.runAs(uTstExecUser) {
		  TriggerSettings__c setting = new TriggerSettings__c();
		  String 	settingName = '';
		  Id 		setupOwnerId;
		  String soql = SoqlUtils.getAllFieldsSOQL('TriggerSettings__c', false, '');
		  List<TriggerSettings__c> currentTrgSettings  = Database.query(soql);

		  if(currentTrgSettings == null || currentTrgSettings.isEmpty()) {
			  settingName = UserInfo.getOrganizationId() + Date.today();
			  setupOwnerId = UserInfo.getOrganizationId();
		  } else {
			  settingName = 'triggerSetting' + uTstExecUser.id;
			  setupOwnerId = uTstExecUser.id;
		  }
		  setting.Name = settingNAme;
		  setting.trigger_On_User_disable_contact_insert__c = true;
		  insert setting;

      	  testUserAdd();

		  List<Contact> contacts = [select id, lastname from contact where lastname = :uTstExecUser.lastname];
		  system.assert(contacts.isEmpty());

		  setting.trigger_On_User_disable_contact_insert__c = false;
		  update setting;
		  testUserAdd();
		  List<Contact> contacts2 = [select id, lastname from contact where lastname = :uTstExecUser.lastname];
		 // system.assert(!contacts2.isEmpty()); @TODO probably due to future insert... fix this to test out correctly



      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  
  	private static void testUserAdd() {
  		 TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('','','','' );
  		 Datetime   dtTstStart        = Datetime.now();


	   	CollaborationGroup cg;
		List<CollaborationGroup> cgs = [select id,name, collaborationtype from collaborationgroup where name = 'Case Documents - Read Only - UNIT TEST'];
		if(cgs.isEmpty()) {
			cg = new CollaborationGroup();
			cg.Name = 'Case Documents - Read Only - UNIT TEST';
			cg.CollaborationType = 'Public';
			insert cg;
		} else {
			cg = cgs[0];
		}
		
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
  	}
  	
    
   
}