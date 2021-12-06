/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfClient_VIEW {

    public static   User                        uTstExecUser                { get; set; }
    public static   ctrlClient                  ctrlClient                  { get; set; }
    public static   PageReference               prClient                    { get; set; }
    public static   Contact                     newClient                   { get; Set; }
    public static   Contact                     newParty                    { get; set; }   
    public static   Search_Log__c               newSlClient                 { get; set; }
    public static   Case                        newCase                     { get; Set; }
    public static   List<Case_Party__c>         newCaseParties              { get; Set; }
    public static   List<Income_Detail__c>      newIncomeDetails            { get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prClient = Page.vfClient;
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
        
        buildTestData('Client'); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {                 
               
                testViewFromCase();
                testConflictSearchComplete();
                testMiscMethods();
                
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }

    private static void testViewFromCase() {
        //ewSubActivity('/apex/vfClient?id={!cp.Contact__c}&view=false&fromSearch=false&fromCase=true&fromCaseId={!cse.id}','Edit: {!cp.contact__r.name}');return false;"
        prClient = Page.vfClient;
        Test.setCurrentPage(prClient); 
        Map<String,String> mParms = prClient.getParameters();
        Id clientId = newCaseParties[0].id;
        mParms.put('id',clientId);
        mParms.put('view','false');
        mParms.put('fromSearch','false');
        mParms.put('fromCase','true');      
        mParms.put('fromCaseId',newCase.id);
        ctrlClient = new ctrlClient(new ApexPages.StandardController(newClient));
        ctrlClient.doInit();
        ctrlClient.doEditMode();
        ctrlClient.doCancel();  
            
    }   
    
    private static void testConflictSearchComplete() {
    	//var urls = ["/apex/vfClient?id={!slClient.Contact_Reviewed__c}&clientSlId={!slClient.id}&fromSearch=false&view=true&reviewParty=false&showAddCaseBtn=true&conflictSearchComplete=true"];      	
 		prClient = Page.vfClient;
        Test.setCurrentPage(prClient); 
        Map<String,String> mParms = prClient.getParameters();
        Id clientId = newCaseParties[0].id;
        mParms.put('id',clientId);
        mParms.put('clientSlId',newSlClient.id);
        mParms.put('view','true');
        mParms.put('fromSearch','false');
        mParms.put('reviewParty','false');      
        mParms.put('showAddCaseBtn','true');
        mParms.put('conflictSearchComplete','true');
        
        ctrlClient = new ctrlClient(new ApexPages.StandardController(newClient));
        ctrlClient.doInit();    
        ctrlClient.doAddParties();	
    }
 
    private static void buildTestData(String clientCategory) {
        CaseUtils caseUtils = new CaseUtils();
        if(clientCategory == 'Client') {
            newClient = TEST_TestUtils.createContact(clientCategory);
        } else if (clientCategory == 'Party') {
            newParty = TEST_TestUtils.createContact(clientCategory);
        }
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);

        newIncomeDetails = ContactUtils.retrieveContactIncomeDetails(newClient.id);     
    }  
    private static void testMiscMethods() {
    	IncomeDetailWrapper idw = new IncomeDetailWrapper(newIncomeDetails[0],1); 
    
    	ctrlClient.getClientIncomeDetails();
    	ctrlClient.setClientIncomeDetails(new List<Income_Detail__c>());
    	ctrlClient.customPageMessage = 'blah';
    	ctrlClient.getCustomPageMessage();
    	
    	
    } 
   
}