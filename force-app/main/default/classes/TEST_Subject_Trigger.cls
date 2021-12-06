/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)   
public class TEST_Subject_Trigger {
    
    public static   User                        uTstExecUser        { get; set; }

    public static   Subject__c                  newSubject          { get; set; }   
    
    public static   Loop__DDP__c                newDdp              { get; set; }
    public static   Eligible_Problem_Codes__c   newDDPEpc           { get; set; }
    
    public static   Account                     newAcct             { get; set; }   
    public static   Eligible_Problem_Codes__c   newAcctEpc          { get; set; }
    
    public static   Consultation_Question__c    newCaseQ            { get; set; }
    public static   Eligible_Problem_Codes__c   newCaseQEpc         { get; set; }     
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
            
            testSubjectAdd();

        }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }

    private static void testSubjectAdd() {

        newSubject = new Subject__c();
        newSubject.Title__c = 'UT Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'Ricks House';
        insert newSubject; 
        
        List<Account_Subject_Junction__c> asjs = [select id from Account_Subject_Junction__c where account__C = :newAcct.id and Subject__c = :newSubject.id];
  //      System.assert(Utilities.doesListHaveValue(asjs));
        List<DDP_Subject_Junction__c> dsjs = [select id from DDP_Subject_Junction__c where ddp__c = :newDDP.id and Subject__c = :newSubject.id];
  //      System.assertEquals(dsjs.size(), 1);
        List<Question_Subject_Junction__c> qsjs = [select id from Question_Subject_Junction__c where Case_Question__c = :newCaseQ.id and Subject__c = :newSubject.id];
  //      System.assertEquals(qsjs.size(), 1);
        
                
    }
    private static void buildTestData() {   

        newAcct = new Account ( name='TEST Account Name1', description= 'TEST Account Desc1', All_Subjects__c = true);
        insert newAcct;
             
        newDdp = new Loop__DDP__c(Name='UT DDP');
        insert newDdp;
        
        newCaseQ = new Consultation_Question__c();
        newCaseQ.Name__c = 'Question custom name';
        newCaseQ.Case_Answer_Field_Name__c = 'Case answer field name';
        newCaseQ.Question__c = 'Why does SFDC Suck so much?';
        insert newCaseQ;        
        
         
        newDDPEpc = new Eligible_Problem_Codes__c();
        newDDPEpc.Practice_Area__c = 'pa1';
        newDDPEpc.Problem_Category__c = 'pcat1';
        newDDPEpc.Problem_Code__c = 'pc1';
        newDDPEpc.ddp__c = newDdp.id;
        insert newDDPEpc;
        
        newAcctEpc = new Eligible_Problem_Codes__c();
        newAcctEPc.Practice_Area__c = 'pa1';
        newAcctEPc.Problem_Category__c = 'pcat1';
        newAcctEPc.Problem_Code__c = 'pc1';
        newAcctEPc.Account__c = newAcct.id;
        insert newAcctEPc;
        
        newCaseQEpc = new Eligible_Problem_Codes__c();
        newCaseQEpc.Practice_Area__c = 'pa1';
        newCaseQEpc.Problem_Category__c = 'pcat1';
        newCaseQEpc.Problem_Code__c = 'pc1';
        newCaseQEpc.Case_Question__c = newCaseQ.id;
        insert newCaseQEpc;         
    }   
   
}