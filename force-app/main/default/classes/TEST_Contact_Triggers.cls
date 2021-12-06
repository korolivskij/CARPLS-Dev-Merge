/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)   
public class TEST_Contact_Triggers {
    
    public static   User                    uTstExecUser        { get; set; }
    public static   Contact                 newC1               { get; set; }

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
          testAutoPopLnWithOrgName();
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }

    /*
     * @see trgOnContact on Contact (before insert, before update) {
     */
    private static void testAutoPopLnWithOrgName (){
        insert newC1;
        Contact c1 = [select lastname, birthdate from contact where id = :newC1.id limit 1];
        System.assertEquals(c1.lastname, 'TEST ORG NAME');
        
        c1.lastname = null;
        c1.birthdate = Date.today().addDays(-2);
        update c1;
        c1 = [select lastname, text_birthdate2__c from contact where id = :newC1.id limit 1];
        System.assertEquals(c1.lastname, 'TEST ORG NAME');    
        System.assertEquals(c1.text_birthdate2__c, String.valueOf(Date.today().addDays(-2)).replace('-','') );    
    }
    
    private static void buildTestData() {   
        newC1 = new Contact(lastname=null,Org_Name__c = 'TEST ORG NAME', Contact_Type__c='Organization', Birthdate=date.today() );      
    } 
}