/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class TEST_vfClient_INCOME {

    public static   User                        uTstExecUser                { get; set; }
    public static   ctrlClient                  ctrlClient                  { get; set; }
    public static   PageReference               prClient                    { get; set; }
    public static   Contact                     newClient                   { get; Set; }
    public static   Contact                     newParty                    { get; set; }   
    public static   Search_Log__c               newSlClient                 { get; set; }
    public static   Case                        newCase                     { get; Set; }
    public static   List<Case_Party__c>         newCaseParties              { get; Set; }

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
                prepNewClientForTest();
				testAddNewClientIncomeDetails();
               
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    private static void prepNewClientForTest() {
        PageReference pr = Page.vfClient;
        Test.setCurrentPage(pr);        
        Map<String,String> mParms = pr.getParameters();
        mParms.put('id',newClient.id);
        mParms.put('newClient', 'true');
        mParms.put('newCaseId',newCase.id);
        ctrlClient = new ctrlClient(new ApexPages.StandardController(newClient));
        ctrlClient.doInit();
    }
    private static void testAddNewClientIncomeDetails() {
    	ctrlClient.client.Nbr_of_Adults__c = 1;
    	ctrlClient.client.Nbr_of_Minors__c = 1;
     	ctrlClient.newIncomeSource.amount__c = 1000;
     	ctrlClient.newIncomeSource.frequency__c = 'Weekly';
     	ctrlClient.newIncomeSource.income_type__c = 'Income - Benefits'; 
     	ctrlClient.onLoadAddNewIncomeSource = true;
     	ctrlClient.isDeletingIncome = false;
     	ctrlClient.doCalcIncome();     	
     	ctrlClient.doSaveAndContinueCurrentPage();    		
   		
   		Income_Detail__c id = ctrlClient.clientIncomeDetails[0];
   		ctrlClient.selectedId = id.id;
   		ctrlClient.doEditHhIncome();
   		ctrlClient.doSaveIncomeSource();
   		ctrlClient.doRemoveHhIncome();    		
   		
   		ctrlClient.doAddNewIncomeSource();
      	ctrlClient.newIncomeSource.amount__c = 1000;
     	ctrlClient.newIncomeSource.frequency__c = 'Weekly';
     	ctrlClient.newIncomeSource.income_type__c = 'Income - Benefits'; 
		ctrlClient.onLoadAddNewIncomeSource = true;
     	ctrlClient.isDeletingIncome = false;
     	ctrlClient.doCalcIncome();
     	id = ctrlClient.clientIncomeDetails[0];
     	ctrlClient.selectedId = id.id;
     	ctrlClient.doCancelHhIncome();   		 
     	
     	ctrlClient.client.Nbr_of_Adults__c = null;
     	ctrlClient.onLoadAddNewIncomeSource = true;
     	ctrlClient.isDeletingIncome = false;
     	ctrlClient.doSaveIncomeSource();

     	ctrlClient.client.Nbr_of_Minors__c = null;
     	ctrlClient.onLoadAddNewIncomeSource = false;
     	ctrlClient.doAddNewIncomeSource();
     	
     	//do this last
     	ctrlClient.clientIncomeDetails = null;
     	ctrlClient.doCalcIncome();   
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
        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);

        //newIncomeDetails = ContactUtils.retrieveContactIncomeDetails(newClient.id);     
    }   
}