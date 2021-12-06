/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfCase_MISC {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCaseDetail      ctrlCaseDetail    			{ get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static	Consultation__c		newService					{ get; set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static 	Applied_Resource__c	newAppliedResource			{ get; set; }
    public static	Subject__c			newSubject					{ get; set; }
    public static 	Attachment			newAttachment				{ get; set; }
    public static 	LOOP__DDP__c 		newDDP						{ get; set; }
    //  public static   ContentVersion      newContentV
    
    public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prCase = Page.vfCaseDetail;
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
        caseUtils = new CaseUtils();
        Datetime   dtTstStart        = Datetime.now();
        
        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {  
            	                            
                testMiscMethods();
                testAppliedResource();
                
               //------ testResumeCase(); @TODO Describe Gov limit hit.. check fields queried for conflict log.. too many of them.
                
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
                
                 
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    
    
    
    private static void testAppliedResource() {
    	
    	Consultation__c testService = caseUtils.buildNewService(newCase);
    	insert testService;
    	LOOP__DDP__c testDDP = TEST_TestUtils.createDDP();
        Applied_Resource__c testAppliedResource = TEST_TestUtils.createAr(newCase.id, testService.id, testDDP);
       	ctrlCaseDetail.cse = newCase;
		ctrlCaseDetail.actionID = testDDP.id;
       	ctrlCaseDetail.selectedAppliedResourceId = testAppliedResource.id;
       	
       	ctrlCaseDetail.doRefreshAppliedResourcesAfterSelected();
       	ctrlCaseDetail.doRemoveAppliedResource();
       	
        
    }
	
    private static void testMiscMethods() {
    	
		
       	
       	prCase = Page.vfCaseDetail;
        Test.setCurrentPage(prCase); 
        Map<String,String> mParms = prCase.getParameters();
        mParms.put('id',newCase.id);
        ctrlCaseDetail = new ctrlCaseDetail(new ApexPages.StandardController(newCase));
        ctrlCaseDetail.selectedId = newAttachment.id;
        
        ctrlCaseDetail.evalIsServiceComplete(newService);
       	ctrlCaseDetail.doCancelAddServiceEdit();
        ctrlCaseDetail.doDeleteAttachment();
        ctrlCaseDetail.refreshPotentialConflicts();
        ctrlCaseDetail.doClearCustomPageMessages();
       	
        
    }
    private static void buildTestData() {        
        
        newClient = TEST_TestUtils.createContact('Client');
        
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        
        newService = caseUtils.buildNewService(newCase);
        insert newService;
        
        newAttachment = new Attachment();
        
        Blob b = Blob.valueOf('Test Data');  
 	    newAttachment.ParentId = newCase.id;  
    	newAttachment.Name = 'Test Attachment';  
    	newAttachment.Body = b;  
        insert newAttachment;   
        
        newDDP = TEST_TestUtils.createDDP();
        newAppliedResource = TEST_TestUtils.createAr(newCase.id, newService.id, newDDP);
        
        TEST_TestUtils.debugSObj(newCase);  
        TEST_TestUtils.debugSObjs(newCaseParties);  
        TEST_TestUtils.debugSObj(newService);  
        TEST_TestUtils.debugSObj(newAppliedResource);
    }    
}