/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)    
public with sharing class TEST_ProblemCode_Utils {
    
    public static   User         				uTstExecUser       { get; set; }
    
    public static   Account						newAcct			   { get; set; }   
    public static   Eligible_Problem_Codes__c	newAcctPc		   { get; set; }
    
    public static   Case						newCase			   { get; set; } 
    public static   Subject__c					newSubject		   { get; set; } 
   
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
    buildTestData(); 
 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {      	
      	
        testAllUtils();
        testMiscPcWrapper();

      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
  
  	private static void buildTestData() {
  		
  		newAcct = new Account ( name='TEST Account Name1', description= 'TEST Account Desc1');
  		insert newAcct;
  		
  		newAcctPc = new Eligible_Problem_Codes__c();
  		newAcctPc.Practice_Area__c = 'pa1';
  		newAcctPc.Problem_Category__c = 'pcat1';
  		newAcctPc.Problem_Code__c = 'pc1';
  		newAcctPc.Account__c = newAcct.id;
  		insert newAcctPc;
  		
  		newCase = new Case(subject='Unit TEST Case Subject');
  		newCase.Practice_Area__c = 'pa1';
  		newCase.Problem_Category__c = 'pcat1';
  		newCase.Problem_Code__c = 'pc1';
  		newCase.Jurisdiction__c = 'Ricks House';
    	insert newCase;	
    	
    	newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'Ricks House';
    	insert newSubject;
 	
  	}
  
	/**
	 *
	 */
    private static void testAllUtils() {
    	
    	//@see retrieveEligibleProblemCodes(Id sObjectId, String sLookupFieldName)
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct.id, null),null);
    	system.assertNotEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct.id, 'account__c'),null);
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct.id, 'SFDCSUCKS'),null);
    	
    	//@TODO CATCH THIS IN UTILS CLASS. system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes('thisidwillblowitup', 'SFDCSUCKS'),null);
    	
    	List<ProblemCodeWrapper> pcWrapsNull = null;
    	List<ProblemCodeWrapper> pcWraps = new List<ProblemCodeWrapper> {new ProblemCodeWrapper(newAcctPc)};    	
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(pcWrapsNull, null),null);
    	system.assertEquals(ProblemCodeUtils.retrieveEligibleProblemCodes(pcWraps, null),null);
    	
    	List<Id> epcIdsFound = ProblemCodeUtils.retrieveEligibleProblemCodes(pcWraps, 'Account__c');
    	system.assert(Utilities.doesListHaveValue(epcIdsFound));
    	
    	//@see retrieveEligibleProblemCodes(Account a, Case cse) 
    	List<Eligible_Problem_Codes__c> epcsFound = ProblemCodeUtils.retrieveEligibleProblemCodes(newAcct,newCase);
    	system.assert(Utilities.doesListHaveValue(epcsFound));
    		
   		//@see retrieveEligibleProblemCodes(ProblemCodeWrapper pcWrap, String sLookupFieldName)
   		epcIdsFound = null;
   		epcIdsFound = ProblemCodeUtils.retrieveEligibleProblemCodes(new ProblemCodeWrapper(newCase),'account__c');
   		system.assert(Utilities.doesListHaveValue(epcIdsFound));
   		
    }  
    
    private static void testMiscPcWrapper() {
    	
    	new ProblemCodeWrapper();
    	system.assertEquals(new ProblemCodeWrapper(newSubject).practiceArea,'pa1');  
    	
    	Consultation_Question__c q = new Consultation_Question__c();
    	q.Name__c = 'Question custom name';
    	q.Case_Answer_Field_Name__c = 'Case answer field name';
    	q.Question__c = 'Why does SFDC Suck so much?';
    	insert q;
    	  		    
    }

}