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
public class TEST_Service_Triggers {
    
    public static   User                    uTstExecUser        { get; set; }
    public static   Contact                 newC1               { get; set; }
    public static   Case                    newCase             { get; set; }
    public static   Consultation__c         newService          { get; set; }
//  public static   Consultation__c         s2                  { get; set; }
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
        testServiceAdds();
        testServiceUpdates();
        testServiceDeletes();       
         
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
    private static void testServiceAdds() {     
        //What are we working with test data wise should be 2 services and a total of 20 minutes for both.
        // ELC - remove comments on asserts
  //      System.assertEquals(newCase.Total_Nbr_of_Services__c,2);
  //      System.assertEquals(newCase.Total_Service_Time_Minutes__c,20);
        
        
        newService = new Consultation__c(   case__c = newCase.id, project__C ='TEST PROJECT 3',location__c='TEST LOC 3',
                                                    status__c='Open', Contact_xx__c = newC1.id ); //@TODO add more
        
        insert newService;
        
        refreshNewCase();
        refreshNewService();
        

        
        // TODO - refresh s3 and add systemAssert to check the start time
        // ELC - remove the comments from these asserts
   //     System.assertEquals(newCase.Total_Nbr_of_Services__c, 3);
        // This will not yet have updated because the time_closed will not be set until status__c = Closed
   //     System.assertEquals(newCase.Total_Service_Time_Minutes__c,20);
        //test project status and origin values as well.. continue on to updates and deletes..
   //     System.assertEquals(newCase.project__c, 'TEST PROJECT 3');
   //     System.assertEquals(newCase.origin, 'TEST LOC 1');  
                                                                
    }
    private static void testServiceUpdates() {
        

        newService.status__c = 'Closed';                
        newService.project__c = 'TEST PROJECT 3 UPDATED';
        update newService;
        
        refreshNewCase();
        refreshNewService();

        //test that last service by and last service date on the client was updated.
        newC1 = ContactUtils.retrieveAllContactInfo(newC1.id);
        // ELC - remove comments from asserts
 //       System.assertEquals(newService.Service_End_Time__c, newC1.Last_Service_Date__c);
 //       System.assertEquals(newService.LastModifiedById, newC1.Last_Service_By__c);
        
 //       System.assertEquals(newCase.project__c,newService.project__c); // failing!! why. 
    
 //       System.assertEquals(newService.status__c, 'Closed');
 //       System.assertNotEquals(newService.service_end_time__c, null);
        // TODO assert to test the new elapsed service time.  Not sure how to do it tho because the
        // system is setting the datetime fields, so don't know how much time will have passed.
    }   
    private static void testServiceDeletes() {
        
        if (newCase.consultations__r != null) {
            for (Consultation__c c : newCase.consultations__r) {
                delete c;
            }
        }
        refreshNewCase();
        // ELC- get rid of comments on asserts
 //       system.assert(newCase.consultations__r.isEmpty(), 'consultations list not empty');
 //       system.assertEquals(newCase.Total_Nbr_of_Services__c, 0);
 //       system.assertEquals(newCase.Total_Service_Time_Minutes__c, 0);
    }
    /**
     * Build new case, contact and child services and add to static var.. requery after adding services. 
     */
    private static void buildTestData() {    
        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin');
        insert newCase;
        
        List<Consultation__c> services = new List<Consultation__c>();
        newC1 = new Contact(lastname='TEST LAST');
        insert newC1;
        
        //Note Service_Time is FF = (Service_End_Time__c - Service_Start_Time__c)* 1440.. not even sure that's right...
        //@todo add other fields
        Consultation__c s1 = new Consultation__c(   case__c = newCase.id, project__C ='TEST PROJECT 1',location__c='TEST LOC 1',
                                                    status__c='Closed',Service_Start_Time__c=DateTime.now().addMinutes(-20),
                                                    Service_End_Time__c=DateTime.now().addMinutes(-10), Contact_xx__c = newC1.id ); //@TODO add more    
        Consultation__c s2 = new Consultation__c(   case__c = newCase.id, project__C ='TEST PROJECT 2',location__c='TEST LOC 2',
                                                    status__c='Closed',Service_Start_Time__c=DateTime.now().addMinutes(-10),
                                                    Service_End_Time__c=DateTime.now(), Contact_xx__c = newC1.id ); //@TODO add more
        services.add(s1);
        services.add(s2);
        insert services;
        
        refreshNewCase();
    } 
    /**
     * .......
     */
    private static void refreshNewCase() {
        
        newCase = [ Select  id, subject,project__c,status,origin,Total_Nbr_of_Services__c,Total_Service_Time__c,
                            Total_Service_Time_Minutes__c,
                            (select id,project__c, service_start_time__c, service_end_time__c, location__c, status__c from consultations__r)
                    From    Case
                    Where   id = :newCase.id limit 1];      
    }
     private static void refreshNewService() {
        
        newService = [  Select  id,project__c, service_start_time__c, service_end_time__c, location__c, status__c,
        						lastmodifiedbyid 
                    From    Consultation__c
                    Where   id = :newService.id limit 1];       
    }
   
}