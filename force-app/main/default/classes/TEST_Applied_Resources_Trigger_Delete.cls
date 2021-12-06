/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 *
 * Since much of this trigger was changed to future methods, the deletes needed to be moved to
 * a separate test class.  Otherwise there was no assurance that there was something to delete
 * so the code wouldn't always run.
 */
@isTest(SeeAllData=false)
public class TEST_Applied_Resources_Trigger_Delete {

    public static   User                    uTstExecUser        { get; set; }
    public static	Subject__c				newSubject			{ get; set; }
    public static   Case                    newCase             { get; set; }
    public static   Consultation__c         newConsultation     { get; set; }
    public static   Loop__DDP__c            newDDP              { get; set; }
    public static   Account                 newAccount          { get; set; }
    
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
	refreshNewConsultation();
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {
        
        testAppliedResourcesDeletes();     
         
      }
        
    Test.stopTest();
 
 	// have to refresh after the stopTest to ensure that future methods have fired
    refreshNewConsultation();
    refreshNewDDP();
    refreshNewAccount();
    System.assertEquals(newDDP.Total_Nbr_of_Applied_Resources__c, 0);
    System.assertEquals(newAccount.Total_Nbr_of_Applied_Resources__c, 0);   
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
    private static void testAppliedResourcesDeletes() {
        
        if (newConsultation.Applied_Resources__r != null) {
            for (Applied_Resource__c ar : newConsultation.Applied_Resources__r) {
                delete ar;
            }
        }
       
    }  
    /**
     * Build new case, contact and child services and add to static var.. requery after adding services. 
     */
    private static void buildTestData() { 
 
 		newSubject = new Subject__c(Title__c='TEST SUBJECT');
 		insert newSubject;          
        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin');
        insert newCase;
        newConsultation = new Consultation__c(case__c=newCase.id);
        insert newConsultation;
        newAccount = new Account(name='TEST ACCOUNT',/*CARPLS_Connect__c = true*/ Partner_Type__c = 'CARPLS Connect');
        insert newAccount;
        newDDP = new Loop__DDP__c();
        insert newDDP;
        Applied_Resource__c ar1 = new Applied_Resource__c(case__c=newCase.id,account__c=newAccount.id,consultation__c=newConsultation.id);
       	insert ar1;
        Applied_Resource__c ar2 = new Applied_Resource__c(case__c=newCase.id,DDP__c=newDDP.id,consultation__c=newConsultation.id);
       	insert ar2;
       	Applied_Resource__c ar3 = new Applied_Resource__c(case__c=newCase.id,subject__c=newSubject.id,consultation__c=newConsultation.id,
        						type__c='FAQ');
       	insert ar3;
    } 
    /**
     * .......
     */
    private static void refreshNewConsultation() {
        newConsultation = [select   id, case__c,
                                (select id from applied_resources__r)
                            from consultation__c
                            where id = :newConsultation.id LIMIT 1]; 
    }
    private static void refreshNewDDP() {
        
        newDDP = [ Select  id, total_nbr_of_applied_resources__c
                    From    Loop__DDP__c
                    Where   id = :newDDP.id limit 1];      
    }
     private static void refreshNewAccount() {
        
        newAccount = [  Select  id, total_nbr_of_applied_resources__c 
                    From    Account
                    Where   id = :newAccount.id limit 1];       
    }
       
}