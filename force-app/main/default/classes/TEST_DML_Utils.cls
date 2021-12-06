/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_DML_Utils {
    
    public static   User         uTstExecUser       { get; set; }
  
   
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
	 * @TODO fix DMlUtils  exception handeling and error reporting is not really correct.
	 */
    private static void testAllUtils() {
        Account a1 = new Account ( name='TEST Account Name1', description= 'TEST Account Desc1');
        Account a2 = new Account ( name='TEST Account Name2', description= 'TEST Account Desc2');
        
        List<Account> accts = new List<Account>();
        accts.add(a1);
        accts.add(a2);
                
        DmlUtils.DBInsert(accts, true);      
        DmlUtils.DBUpdate(accts, true);
        DmlUtils.DBUpsert(accts, true);       
        
        Account a3 = new Account ( name='TEST Account Name3', description= 'TEST Account Desc3');
        Account a4 = new Account ( name='TEST Account Name4', description= 'TEST Account Desc4');
        DmlUtils.DBInsert(a3);
        DmlUtils.DBUpdate(a3);        
        
        insert a4;
        DMLUtils.DBDelete(a4);
        
        //will blow up due to trying to insert a record that already has an id. (a1)
        Id idInserted;
        try {
        	 idInserted = DmlUtils.DBInsert(a1);
        } catch (DmlException e) {
			System.assertEquals('INVALID_FIELD_FOR_INSERT_UPDATE' , 
                                 e.getDmlStatusCode(0) );
       	}
        //will blow up due to trying update account name to too large of a value
        
        a1.name = '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
       
        Boolean success = false;
       	try {
        	success = DmlUtils.DBUpdate(a1);
        } catch (DmlException e) {
			System.assertEquals('STRING_TOO_LONG' , 
                                 e.getDmlStatusCode(0) );
       	}        
		   
        
   
    }  

}