/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. 
 **/
@isTest(SeeAllData=false) 
public with sharing class TEST_DDP_Triggers {
    
    public static   User                    uTstExecUser        { get; set; }
    public static   Loop__DDP__c            newDDP              { get; set; }
    
    
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
        
        //test somthing! use case and it's service childs
        testDDPAdds();
        testDDPUpdates();
         
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  
  private static void testDDPAdds() {
    // this long test string is 51 characters up to the end of the 1st # sequence.
    String longString = 'LONG TEST <div> STRING WITH TAGS <strong>  123456789';  
    String shorterString = longString.stripHtmlTags().left(254);
    newDDP = new Loop__DDP__c(name = longString);
    insert newDDP;
    
    refreshNewDDP();
    
    system.assertEquals(newDDP.title__c, shorterString);
  }
  
  private static void testDDPUpdates() {
    
    String longString = 'DIFFERENT LONG TEST <div> STRING WITH TAGS <strong>  123456789';  
    String shorterString = longString.stripHtmlTags().left(254);
    newDDP.name = longString;
    update newDDP;
    
    refreshNewDDP();
    
    system.assertEquals(newDDP.title__c, shorterString);
  }
  
 
  private static void refreshNewDDP() {
 
    newDDP = [select    id, name, title__c
                from    Loop__DDP__c
                where   id = :newDDP.id];
  
  }
}