/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. 
 *
 * @TODO reported bug.
 * The 'after' trigger is setting the end_time column of the current consultation.  There is a formula field on 
 * consultation - Total_time or something like that.  Later in the trigger it is rolling up this formula field for the case, 
 * but I don't think that its been updated yet.  Hard to tell from the documentation how that should work."
 * 
 */
@isTest(SeeAllData=false)   
public class TEST_Applied_Resources_Trigger_2 {
    
    public static   User                    uTstExecUser        { get; set; }
    public static   Subject__c              newSubject          { get; set; }
    public static   Case                    newCase             { get; set; }
    public static   Consultation__c         newConsultation     { get; set; }
    public static   Loop__DDP__c            newDDP              { get; set; }
    public static   Account                 newAccount          { get; set; }
    public static   Applied_Resource__c     newAr               { get; set; }
        
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
        testAppliedResourcesAcceptedThenRejected();
        testCCAppliedResourcesAcceptedThenRejected();
         
      }
        
    Test.stopTest();
 
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
    private static void testAppliedResourcesAcceptedThenRejected() {

        Activity_Assignment__c aa = new Activity_Assignment__c();
        aa.current_status__C = 'Available';
        aa.support_type__c = 'AOC-IL-AFLAN';
        aa.current_user__c = uTstExecUser.id;
        aa.active__c = true;
        insert aa;

        Account acct = new Account();
        acct.name = 'BOOOGIE MAN';
        acct.sub_type__c = 'Legal Aid';
        //acct.Military_Service__c= true;
        acct.Partner_Type__c = 'Military Service';
        insert acct;

      //  RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Accepted');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Accepted';
        ar.distribution__c = 'Referral Accepted';
        //ar.closing_code__c ='Denied Service';
        update ar;
        rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        ar.status__c = 'Closed';
        ar.recordtypeid = rt.id;
        //ar.distribution__c = 'Referral Accepted';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        Task t = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        system.assert(t.subject == 'IL-AFLAN Referral Rejected');
        //system.assert(t.group__c == 'POC-IL-AFLAN');
        system.assert(t.group__c == 'AOC-IL-AFLAN');
    }
    private static void testCCAppliedResourcesAcceptedThenRejected() {

        Activity_Assignment__c aa = new Activity_Assignment__c();
        aa.current_status__C = 'Available';
        aa.support_type__c = 'AOC';
        aa.current_user__c = uTstExecUser.id;
        aa.active__c = true;
        insert aa;

        Account acct = new Account();
        acct.name = 'BOOOGIE MAN';
        acct.sub_type__c = 'Legal Aid';
        //acct.CARPLS_Connect__c= true;
        acct.Partner_Type__c = 'CARPLS Connect';
        acct.Community_Activated__c = true;
        insert acct;

      //  RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Accepted');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Accepted';
        ar.distribution__c = 'Referral Accepted';
        //ar.closing_code__c ='Denied Service';
        update ar;
        rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        ar.status__c = 'Closed';
        ar.recordtypeid = rt.id;
        //ar.distribution__c = 'Referral Accepted';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        Task t = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        system.assert(t.subject == 'Electronic Referral Rejected');
        system.assert(t.group__c == 'AOC');
    }    
    private static void testMiscMethods() {
        AppliedResourceUtils arUtils = new AppliedResourceUtils();

        Subject__c s  = new Subject__c();
        s.Title__c = 'Unit Test Case Subject';
        s.Practice_Area__c = 'pa1';
        s.Problem_Category__c = 'pcat1';
        s.Problem_Code__c = 'pc1';
        s.Jurisdiction__c = 'Ricks House';
        insert s;
        
        
        
        
        Applied_Resource__c ar = new Applied_Resource__c(   case__c = newCase.id, consultation__c=newConsultation.id
                                                        , DDP__C =newDDP.id,subject__c=s.id);
        insert ar;  
        arUtils.retrieveAppliedResource(ar.id);
        arUtils.retrieveAppliedResource(newCase, newDDP.id);  
        Case nullCase = null;
        arUtils.retrieveAppliedResources(nullCase, new List<al.OrderBy>());
        arUtils.retrieveAppliedREsources(nullCase, new Consultation__c());
        
        arUtils.retrieveAppliedResources(s);
                   
    }
    /**
     * Build new case, contact and child services and add to static var.. requery after adding services. 
     */
    private static void buildTestData() { 
 
        newSubject = new Subject__c(title__c='TEST SUBJECT');
        insert newSubject;          
        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin');
        insert newCase;
        newConsultation = new Consultation__c(case__c=newCase.id);
        insert newConsultation;
        newAccount = new Account(name='TEST ACCOUNT'/*CARPLS_Connect__c = true* Partner_Type__c = 'CARPLS Connect'*/);
        insert newAccount;
        newDDP = new Loop__DDP__c();
        insert newDDP;
        newAr = new Applied_Resource__c(case__c=newCase.id,account__c=newAccount.id,consultation__c=newConsultation.id,
                                distribution__c='Applied');
        insert newAr;
        
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