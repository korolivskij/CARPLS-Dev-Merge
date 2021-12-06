/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. 
 *
 * Gov Limits imposed on test classes sucks .... YES IT DOES!!
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfCase_VIEW2 {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCaseDetail      ctrlCaseDetail              { get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static   CaseUtils			caseUtils					{ get; set; }
	public static	Subject__c			newSubject					{ get; set; }
	public static	Attachment			newAttachment				{ get; set; }
	public static	Applied_Resource__c	newAppliedResource			{ get; set; }

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
        
        Datetime   dtTstStart        = Datetime.now();
        
        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        
        caseUtils = new CaseUtils();
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {                              
                testReviewCase();
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    private static void testReviewCase() {
        prCase = Page.vfCaseDetail;
        Test.setCurrentPage(prCase); 
        Map<String,String> mParms = prCase.getParameters();
        mParms.put('id',newCase.id);
        mParms.put('review','true');
        mParms.put('fromSearch','false');
        mParms.put('tempCase','false');
        ctrlCaseDetail = new ctrlCaseDetail(new ApexPages.StandardController(newCase));
        ctrlCaseDetail.doInitCase();
        
        /// test add party search.
        ctrlCaseDetail.doAddPartySearch(); //really nothing to assert. 
        
        //Add a new service.. hit save and continue on service page.
        ctrlCaseDetail.doSaveAndContinueNewServicePage();
        ctrlCaseDetail.serviceSubTabAction = 'Create';
        ctrlCaseDetail.serviceSubTabObjectId = ctrlCaseDetail.currentConsultation.id;
 		ctrlCaseDetail.doServiceSaved();
 		
 		ctrlCaseDetail.doServiceCancelled();
 		
 		

    }

    private static void buildTestData() {
        
        newSubject = new Subject__c();
    	
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'jur1';
    	newSubject.Status__c = 'Active';
    	newSubject.Type__c = 'Pending';
    	newSubject.Litigation__c = 'Pending';
    	//newSubject.Show_Litigation_Questions__c = true;
    	insert newSubject;     
        
        newClient = TEST_TestUtils.createContact('Client');
        
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        TEST_TestUtils.debugSObj(newCase);  
        TEST_TestUtils.debugSObjs(newCaseParties);    
        
        newAttachment = new Attachment();
        
        Blob b = Blob.valueOf('Test Data');  
 	    newAttachment.ParentId = newCase.id;  
    	newAttachment.Name = 'Test Attachment';  
    	newAttachment.Body = b;  
        insert newAttachment;
        
        
    }    

    
    
}