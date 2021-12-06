/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)	
public class TEST_Income_Triggers {
	
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
   	buildTestData(); 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {
    	  testUpdateIncomeDetail();
    	  testDeleteIncomeDetail();
    	  testMiscWrappers();
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  
  	private static void testUpdateIncomeDetail() {
		if(newC1 == null) {
			buildTestData();
		}
		Income_Detail__c id = newC1.income_details__r[0];
		//@TODO modify / assert blah blah..
		update id;
  	}
  	private static void testDeleteIncomeDetail() {
		if(newC1 == null) {
			buildTestData();
		}
		Income_Detail__c id = newC1.income_details__r[0];
		//@TODO assert blah blah..
		delete id;	  		
  	}
  	private static void testMiscWrappers() {
  		new PovertyBean(); 		
  	}

    private static void buildTestData() {    
    	newC1 = new Contact(lastname='Test Contact Last Name',Contact_Type__c='Individual' ); 
    	insert newC1;
    	Income_Detail__c id = new Income_Detail__c();
    	id.Contact__c = newC1.id;
    	id.Active__c = true;
    	id.Amount__c = 1000;
    	id.Frequency__c = 'Weekly';
    	id.Income_Type__c = 'Income - Benefits';
    	insert id;
    	refreshNewContact();
    	
    } 
    
    /**
     * .......
     */
	private static void refreshNewContact() {
		newC1 = refreshContact(newC1.Id);
	}
    private static Contact refreshContact(Id contactId) {
 	   	Contact c;
 	 	 		c = [	Select 	c.Total_Residents_in_Household__c, c.Total_Nbr_of_Active_Income_Details__c, c.LastName, c.Id, c.Annual_Income_Realtime__c, 
 	 					(	Select 	Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
 	 								LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
 	 								Active__c, Amount__c, Contact__c, Frequency__c, Income_Type__c, 
 	 								Annualized_Income__c 
 	 						From 	Income_Details__r) 
 	 					From 	Contact c
 	 					Where	c.id = :contactId limit 1];
    	return c;			 	
    }    
}