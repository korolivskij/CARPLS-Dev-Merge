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
public class TEST_Case_Review_Triggers {
    
    public static   User                    uTstExecUser        { get; set; }
    public static   Contact                 newC1               { get; set; }
    public static   Case                    newCase             { get; set; }
    public static	Consultation__c			newService			{ get; set; }
    public static   Case_Review__c         	newCaseReview       { get; set; }

        
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
        testCaseReviewAdds();
        testCaseReviewUpdates();     
         
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
    /**
     * blah blah i love to type.
     * 
     */
    private static void testCaseReviewAdds() {  
    	   
        //What are we working with test data wise should be 2 case reviews and a total of 20 minutes for both.
        
        System.assertEquals(newCase.Total_Review_Time__c,20);        
        
        newCaseReview = new Case_Review__c(   case__c = newCase.id , service__c = newService.id ); 
        
        insert newCaseReview;
        
        refreshNewCase();
        // trying to reduce SOQL query count - this is in next method
        //refreshNewCaseReview();
        
         
        // This will not yet have updated because the time_closed will not be set until status__c = Closed
        System.assertEquals(newCase.Total_Review_Time__c,20);
                                                                
    }
    private static void testCaseReviewUpdates() {
        
		
        newCaseReview.review_status__c = 'Closed';                

        update newCaseReview;
        
        // trying to reduce SOQL count
        //refreshNewCase();
        refreshNewCaseReview();
        
        System.assertEquals(newCaseReview.review_status__c, 'Closed');
        System.assertNotEquals(newCaseReview.end_time__c, null);
        // TODO assert to test the new elapsed time.  Not sure how to do it tho because the
        // system is setting the datetime fields, so don't know how much time will have passed.
    }   
    private static void testCaseReviewDeletes() {
        
        if (newCase.case_reviews__r != null) {
            for (Case_Review__c cr : newCase.case_reviews__r) {
                delete cr;
            }
        }
        refreshNewCase();
        system.assert(newCase.case_reviews__r.isEmpty(), 'case review list not empty');
        system.assertEquals(newCase.Total_Review_Time__c, 0);
    }
    /**
     * Build new case, contact and child services and add to static var.. requery after adding services. 
     */
    private static void buildTestData() {    
        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin');
        insert newCase;
        
        List<Consultation__c> newServices = new List<Consultation__c>();
        Consultation__c s1 = new Consultation__c(case__c=newCase.id);        
        Consultation__c s2 = new Consultation__c(case__c=newCase.id);
        // this last service is global because it will be used in the Case Review inserted during the test 
        newService = new Consultation__c(case__c=newCase.id);
        newServices.add(s1);
        newServices.add(s2);
        newServices.add(newService);
        insert newServices;
                
        List<Case_Review__c> caseReviews = new List<Case_Review__c>();
        
        Case_Review__c cr1 = new Case_Review__c(   case__c = newCase.id, service__c = s1.id, review_status__c='Closed',
                                                    Start_Time__c=DateTime.now().addMinutes(-20), End_Time__c=DateTime.now().addMinutes(-10) );    
        Case_Review__c cr2 = new Case_Review__c(   case__c = newCase.id, service__c = s2.id, review_status__c='Closed',
                                                    Start_Time__c=DateTime.now().addMinutes(-10), End_Time__c=DateTime.now()); 
        caseReviews.add(cr1);
        caseReviews.add(cr2);
        insert caseReviews;
        
        refreshNewCase();
    } 
    /**
     * .......
     */
    private static void refreshNewCase() {
        
        newCase = [ Select  id, status,Total_Review_Time__c,
                            (select id,start_time__c, end_time__c, review_status__c from case_reviews__r)
                    From    Case
                    Where   id = :newCase.id limit 1];      
    }
     private static void refreshNewCaseReview() {
        
        newCaseReview = [  Select  id,start_time__c, end_time__c, review_status__c 
                    From    Case_Review__c
                    Where   id = :newCaseReview.id limit 1];       
    }
   
}