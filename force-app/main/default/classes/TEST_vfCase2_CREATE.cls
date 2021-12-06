/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfCase2_CREATE {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCase      		ctrl              			{ get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static	Subject__c			newSubject					{ get; set; }
    
    public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {

        prCase = Page.vfCase;
        
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
            	                            
                testNewCase();
               
                
            
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
                
                 
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }

    private static void testNewCase() {
        
        prCase = Page.vfCase;
        Test.setCurrentPage(prCase); 
        Map<String,String> mParms = prCase.getParameters();
        mParms.put('id',newCase.id);
        mParms.put('newCase','true');
        ctrl = new ctrlCase(new ApexPages.StandardController(newCase));
        ctrl.doInit();
        system.assert(ctrl.isNewCase);
        
        ctrl.doSaveNewCase();  
        ctrl.actionId = newSubject.id;
        ctrl.doSelectSubject();
        ctrl.doSaveAndContinue();
        ctrl.doSaveAndContinueStartService();
        Consultation__C service = caseUtils.buildNewService(newCase);
        service.service_code__c = 'Legal Advice';
        insert service; //@todo put in other fields.
        ctrl.doSaveServiceAura();
        ctrl.doRefreshCaseSummary();
        ctrl.doAddPartySearch();

        ctrl.formInfo.clickedId = service.id;

        ctrl.doEditServiceAura();
        //ctrl.actionId = service.id;
        //ctrl.doAddNewCaseReview();
        //ctrl.doCreateCaseReview();


        ctrl.doCloseCase();//null reference exception!  
       //TODO:
       /*
       doCancelNewCase() 
       doSaveAndContinue()
       
       doAddService() 
       doSaveAndContinueStartService
       doSaveAddService()
       doCreateCaseReview()
       
       */

    }

   
    private static void buildTestData() {        
        
        newClient = TEST_TestUtils.createContact('Client');
        newClient.email = 'rnendza@gmail.com';
        
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;

        update newSlClient;

        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        
        
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
    	

    	   
        TEST_TestUtils.debugSObj(newCase);  
        TEST_TestUtils.debugSObjs(newCaseParties);    
    }    
}