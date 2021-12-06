/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *

 */
@isTest
private class TEST_Opportunity_Trigger {
	public static   User         		uTstExecUser       	{ get; set; }
	public static   Contact	 			newC1				{ get; set; }
	public static   Contact	 			newC2				{ get; set; }
	public static   Contact	 			newC3				{ get; set; }	
	public static	Account				newAcct				{ get; set; }
	public static	Opportunity			newOpp				{ get; set; }
	public static	List<OpportunityContactRole>  CRs			{ get; set; }
    public static   NpspUtils			npspUtils			{ get; set; }
    
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
    npe01__Contacts_And_Orgs_Settings__c npspCustomSetting = npe01__Contacts_And_Orgs_Settings__c.getInstance(uTstExecUser.id);
    System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting+npspCustomSetting);
    
    // Create trigger handler records and add the custom class for the trigger that we're testing
    npsp__Trigger_Handler__c oppTDTM = 
    	new npsp__Trigger_Handler__c(npsp__Class__c = 'OPP_ContactCategory_TDTM',
    								npsp__Active__c = true,
    								npsp__Object__c = 'Opportunity',
    								npsp__User_Managed__c = true,
    								npsp__Load_Order__c = 4,
    								npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate');
   	List<npsp__Trigger_Handler__c> THs = new List<npsp__Trigger_Handler__c>();
   	THs.add(oppTDTM);  
   	oppTDTM = new npsp__Trigger_Handler__c(npsp__Class__c = 'OPP_OppContactRoleSolic_TDTM',
    								npsp__Active__c = true,
    								npsp__Object__c = 'Opportunity',
    								npsp__User_Managed__c = true,
    								npsp__Load_Order__c = 5,
    								npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate');
    THs.add(oppTDTM);								
    npspUtils = new NpspUtils(THs);
    //npspUtils.makeAllTriggersActive();
    
   	//-- Prepare data outside of starttest if possible.
   	buildTestData(); 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {
    	  testAddOpportunity();
		  getContactRoles();
		  system.assert(CRs != null && CRs.size() > 0);  
		  system.assert(CRs[0].contactid == newC2.id);  	  
    	  updateSolicitor();
    	  getContactRoles();
		  system.assert(CRs != null && CRs.size() > 0);  
		  system.assert(CRs[0].contactid == newC3.id);  
      }
  	refreshContact();
  	system.assert(newC1.category__c.contains('Donor'));
  	getContactRoles();


        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  
	private static void testAddOpportunity() {
		newOpp = new Opportunity(AccountId=newAcct.id,StageName='Received',
				Name='Test Opp',Amount=10, CloseDate=Date.today(), solicitor__c=newC2.id);
		insert newOpp;
	}
	private static void updateSolicitor() {
		newOpp.solicitor__c = newC3.id;
		update newOpp;
	}
    private static void buildTestData() {    

		// get the id for the Organization record type for Account
 		List<RecordType> RtList = [select id from recordtype where name = 'Household Account'];
		Id rtId = RtList[0].Id;   
		
		newAcct = new Account(name='Test Household',recordTypeId=rtId); 
		insert newAcct;	
    	newC1 = new Contact(lastname='Test Client Last Name',accountid=newAcct.id,Contact_Type__c='Individual',Category__c='Client' ); 
    	insert newC1;  	
    	newC2 = new Contact(lastname='Test Solicitor Last Name',Contact_Type__c='Individual',Category__c='Donor' ); 
    	insert newC2;     
    	newC3 = new Contact(lastname='Test Solicitor2 Last Name',Contact_Type__c='Individual',Category__c='Donor' ); 
    	insert newC3;     
    } 
    private static void refreshContact() {    

		newC1 = [select category__c, id, name from Contact where id = :newC1.id];
    } 
    private static void getContactRoles() {    

		CRs = [select Role, ContactId from OpportunityContactRole 
		                where Role = 'Solicitor' and OpportunityId = :newOpp.id];
    }         

}