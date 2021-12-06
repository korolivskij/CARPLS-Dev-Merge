/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_Account_triggers {
    
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
      
        testAccountDesc();
        testAccountAfterInsert();
        testAccountAfterInsert2();
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }

    private static void testAccountDesc() {
        Account a = new Account ( name='TEST Account Name', description= 'TEST Account Desc');
        insert a;
        
        a.description = 'TEST Account Desc Update'; 
        update a;   
    }  
    private static void testAccountAfterInsert() {

      Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resources').getRecordTypeId();
        Subject__c subject = new Subject__c(Title__c ='Test Subject1', Status__c ='Active');
        insert subject;

        Account a = new Account ( name='Test1', RecordTypeId = recordTypeId, All_Subjects__c = true);
        insert a;

        List<Account_Subject_Junction__c> accSubJunList =[SELECT id, Account__c, Subject__c FROM Account_Subject_Junction__c WHERE Account__c =: a.Id];
        List<Eligible_Problem_Codes__c> eligCodesList = [SELECT Id FROM Eligible_Problem_Codes__c WHERE Account__c =: a.Id];
        System.assertEquals(1 , accSubJunList.size());
        System.assertEquals(273 , eligCodesList.size());
        System.assertEquals(subject.Id, accSubJunList[0].Subject__c);
        System.assertEquals(a.Id , accSubJunList[0].Account__c);

        a.name ='Test2';
        update a;

        List<Account_Subject_Junction__c> accSubJunList2 =[SELECT id, Account__c, Subject__c FROM Account_Subject_Junction__c WHERE Account__c =: a.Id];
        List<Eligible_Problem_Codes__c> eligCodesList2 = [SELECT Id FROM Eligible_Problem_Codes__c WHERE Account__c =: a.Id];
        System.assertEquals(1 , accSubJunList2.size());
        System.assertEquals(273 , eligCodesList2.size());
        System.assertEquals(subject.Id, accSubJunList2[0].Subject__c);
        System.assertEquals(a.Id , accSubJunList2[0].Account__c);
          
    }  
    private static void testAccountAfterInsert2() {

      Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resources').getRecordTypeId();
        Subject__c subject = new Subject__c(Title__c ='Test Subject1', Status__c ='Active');
        insert subject;

        Account a = new Account ( name='Test1', RecordTypeId = recordTypeId, All_Subjects__c = false);
        insert a;

        List<Eligible_Problem_Codes__c> eligCodesList = [SELECT Id FROM Eligible_Problem_Codes__c WHERE Account__c =: a.Id];
        List<Account_Subject_Junction__c> accSubJunList =[SELECT id, Account__c, Subject__c FROM Account_Subject_Junction__c WHERE Account__c =: a.Id];
        System.assertEquals(0 , accSubJunList.size());
        System.assertEquals(0 , eligCodesList.size());

        a.All_Subjects__c = true;
        update a;

        List<Account_Subject_Junction__c> accSubJunList2 =[SELECT id, Account__c, Subject__c FROM Account_Subject_Junction__c WHERE Account__c =: a.Id];
        List<Eligible_Problem_Codes__c> eligCodesList2 = [SELECT Id FROM Eligible_Problem_Codes__c WHERE Account__c =: a.Id];
        //two Subjects were inserted so size =2
        System.assertEquals(2 , accSubJunList2.size());
        System.assertEquals(273 , eligCodesList2.size());
        System.assertEquals(a.Id , accSubJunList2[0].Account__c);
          
    }  

}