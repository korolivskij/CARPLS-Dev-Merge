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
public class TEST_Applied_Resources_Trigger_3 {
    
    public static   User                    uTstExecUser        { get; set; }
    public static	Subject__c				newSubject			{ get; set; }
    public static   Case                    newCase             { get; set; }
    public static   Consultation__c         newConsultation     { get; set; }
    public static   Loop__DDP__c            newDDP              { get; set; }
    public static   Account                 newAccount          { get; set; }
    public static	Applied_Resource__c		newAr				{ get; set; }
//  public static   Consultation__c         s3                  { get; set; }
    
        
        
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
        
        //test somthing! use case and it's service childs
        //testAppliedResourcesAdds();
        //testAppliedResourcesUpdates();
        //testAppliedResourcesRejected();
        //testCCAppliedResourcesRejected();
        testNLAppliedResourcesRejected();
        testAflanAppliedResourcesRejected();
        testCCLAHDAppliedResourcesRejected();
        testMiscMethods();
         
      }
        
    Test.stopTest();

	// Have to refresh after the stopTest to ensure that future methods have processed
    refreshNewConsultation();
    refreshNewDDP();
    refreshNewAccount(); 
    //System.assertEquals(newDDP.Total_Nbr_of_Applied_Resources__c, 3);
    //System.assertEquals(newAccount.Total_Nbr_of_Applied_Resources__c, 2);   
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
    /**
     * blah blah i love to type.
     * 
     */
    private static void testAppliedResourcesAdds() {     
        
        Applied_Resource__c ar2 = new Applied_Resource__c(   case__c = newCase.id, consultation__c=newConsultation.id, DDP__C =newDDP.id);
        Applied_Resource__c ar5 = new Applied_Resource__c(   case__c = newCase.id, consultation__c=newConsultation.id, DDP__C =newDDP.id);
        List<Applied_Resource__c> ars = new List<Applied_Resource__c>();
        ars.add(ar2);
        ars.add(ar5);
        //insert ar2;
        insert ars;
        
        Applied_Resource__c ar3 = new Applied_Resource__c( case__c = newCase.id, consultation__c=newConsultation.id, Account__c = newAccount.id);
        
        insert ar3;
 
        Applied_Resource__c ar4 = new Applied_Resource__c(case__c = newCase.id, consultation__c=newConsultation.id, type__c='FAQ',subject__c=newSubject.id);
        
        insert ar4;
                                                               
    }
    private static void testAppliedResourcesUpdates() {
        
		newAr.distribution__c = 'Referral Accepted';
		update newAr;
       // @TODO - add code here
        //RJN Test auto add followers of contacts associated to the account assocated to the AR.
        //note to truely test this we are going to have to create the right test data and a customer portal user..
        //not yet done.
        newAr.status__c = 'Accepted';
        update newAr;
       
    }
    private static void testAppliedResourcesRejected() {

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
        acct.Community_Activated__c = true;
        insert acct;
        
        Account acct2 = new Account();
        acct2.name = 'BOOOGIE MAN';
        acct2.sub_type__c = 'Legal Aid';
        acct2.Partner_Type__c = 'New Leaf';
        insert acct2;

        Contact acctContact = new Contact();
        acctContact.lastname = 'BOOGIE MAN CONTACT';
        acctContact.AccountId = acct.id;
        acctContact.email = 'test123@noemail.com';
        insert acctContact;

        Contact acctContact2 = new Contact();
        acctContact2.lastname = 'BOOGIE MAN CONTACT Inactive';
        acctContact2.AccountId = acct.id;
        acctContact2.Active__c = false;
        acctContact2.email = 'test123@noemail.com';
        insert acctContact2;

        AccountContactRelation acr = new AccountContactRelation(ContactId = acctContact2.id, AccountId=acct2.id);
        insert acr;
        
        Id p = [select id from profile where name='IL-AFLAN Community User'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = acctContact.Id,Enable_Email_Notifications_for_Referrals__c = true,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Closed';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        List<Task> tasks = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        Boolean taskFound = false;
        for (Task t: tasks) {
            if (t.subject == 'IL-AFLAN Referral Rejected' && t.group__c == 'AOC-IL-AFLAN') {
                taskFound = true;
            }
        }
        // system.assert(taskFound == true);
        //system.assert(t.group__c == 'POC-IL-AFLAN');
        //system.assert(t.group__c == 'AOC-IL-AFLAN');
    }
    
    private static void testCCAppliedResourcesRejected() {

        Account acct = new Account();
        acct.name = 'BOOOGIE MAN-CC';
        acct.sub_type__c = 'Legal Aid';
        //acct.CARPLS_Connect__c= true;
        acct.Partner_Type__c = 'CARPLS Connect';
        acct.Community_Activated__c = true;
        insert acct;

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Closed';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        // Task t = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        // system.assert(t.subject == 'Electronic Referral Rejected');
        // system.assert(t.group__c == 'AOC');
    }
    
    private static void testNLAppliedResourcesRejected() {

        Account acct = new Account();
        acct.name = 'BOOOGIE MAN-CC';
        acct.sub_type__c = 'Legal Aid';
        acct.Partner_Type__c = 'New Leaf';
        acct.Community_Activated__c = true;
        insert acct;

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Closed';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        // Task t = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        // system.assert(t.subject == 'Electronic Referral Rejected');
        // system.assert(t.group__c == 'AOC');
    }
    
    private static void testAflanAppliedResourcesRejected() {

        Account acct = new Account();
        acct.name = 'BOOOGIE MAN-CC';
        acct.sub_type__c = 'Legal Aid';
        acct.Partner_Type__c = 'Military Service';
        acct.Community_Activated__c = true;
        insert acct;

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Closed';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        // Task t = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        // system.assert(t.subject == 'Electronic Referral Rejected');
        // system.assert(t.group__c == 'AOC');
    }
    
    private static void testCCLAHDAppliedResourcesRejected() {

        Account acct = new Account();
        acct.name = 'BOOOGIE MAN-CC';
        acct.sub_type__c = 'Legal Aid';
        acct.Partner_Type__c = 'CCLAHD';
        acct.Community_Activated__c = true;
        insert acct;

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed');
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.recordtypeid = rt.id;
        ar.type__c = 'Legal Referrals';
        ar.account__c = acct.id;
        insert ar;

        ar.status__c = 'Closed';
        ar.closing_code__c ='Denied Service';
        update ar;

        ar = [select id,status__c,closing_code__c from applied_resource__c where id = :ar.id];
        system.assert(ar.status__c == 'Closed');
        system.assert(ar.closing_code__c == 'Denied Service');
        // Task t = [select id, Subject, Group__c from Task where WhatId = :ar.id];
        // system.assert(t.subject == 'Electronic Referral Rejected');
        // system.assert(t.group__c == 'AOC');
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
        newAccount = new Account(name='TEST ACCOUNT', /*CARPLS_Connect__c = true, Partner_Type__c = 'CARPLS Connect',*/ community_activated__c = true);
        insert newAccount;
        newDDP = new Loop__DDP__c();
        insert newDDP;
        newAr = new Applied_Resource__c(case__c=newCase.id,account__c=newAccount.id,consultation__c=newConsultation.id,
        						distribution__c='Applied',status__c='Applied');
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