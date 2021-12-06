/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. @TODO At limit of SOQL Queries.. try to trim.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfClient_REVIEW_FROM_SEARCH_Cont {

    public static   User                        uTstExecUser                { get; set; }
    public static   ctrlClient                  ctrlClient                  { get; set; }
    public static   PageReference               prClient                    { get; set; }
    public static   Contact                     newClient                   { get; Set; }
    public static   Contact                     newParty                    { get; set; }   
    public static   Search_Log__c               newSlClient                 { get; set; }
    public static   Search_Log_Children__c      newSlParty					{ get; set; }
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
            	                    
                testClientReviewFromPartySearch();
                
                

                testMiscMethods();
                
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }

    
    
    private static void testClientReviewFromPartySearch() {
        buildTestData('Client');
        prClient = Page.vfClient;
        Test.setCurrentPage(prClient); 
        Map<String,String> mParms = prClient.getParameters();
        mParms.put('id',newClient.id);
        mParms.put('view','true');
        mParms.put('fromSearch','true');
        mParms.put('searchType','Party');
        mParms.put('reviewParty','false');
        mParms.put('tempContact','false');
        
        mParms.put('currentPartySl',newSlParty.id);
        
        ctrlClient = new ctrlClient(new ApexPages.StandardController(newClient));
        ctrlClient.doInit();   
        ctrlClient.evalAndMaybeCreatePossibleConflicts(null, 'Party', newClient, newSlClient, newSlParty);
        ctrlClient.evalAndMaybeCreatePossibleConflicts(newCaseParties, null, newClient, newSlClient, newSlParty);
        ctrlClient.evalAndMaybeCreatePossibleConflicts(newCaseParties, 'Party', null, newSlClient, newSlParty);
        ctrlClient.evalAndMaybeCreatePossibleConflicts(newCaseParties, 'Party', newClient, null, newSlParty);
        
        ctrlClient.evalAndMaybeCreatePossibleConflicts(newCaseParties, 'Party', newClient, newSlClient, newSlParty);
        ctrlClient.evalAndMaybeCreatePossibleConflicts(newCaseParties, 'Client', newClient, newSlClient, newSlParty);
    
    }

    private static void testMiscMethods() {

        
    }
    private static void buildTestData(String clientCategory) {
        CaseUtils caseUtils = new CaseUtils();
        if(clientCategory == 'Client') {
            newClient = TEST_TestUtils.createContact(clientCategory);
        } else if (clientCategory == 'Party') {
            newParty = TEST_TestUtils.createContact(clientCategory);
        }
       
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        

        	List<Contact> lParties = new List<Contact>();
        	List<Id> pIds = new List<Id>();
        	
        	for(Case_Party__c cp : newCaseParties) {
        		if(cp.Type__c != 'Client') {
        			pIds.add(cp.contact__c);
        		}       		
        	}
        	lParties = ContactUtils.retrieveAllContactInfo(pIds);
        	if(clientCategory == 'Client') {
        		newSlClient = TEST_TestUtils.createSearchLog(newClient, lParties, uTstExecUser);
        	} else {
        		newSlClient = TEST_TestUtils.createSearchLog(newParty, lParties, uTstExecUser);
        	}
      		newSlParty = newSlClient.Search_Log_Children__r[0];
        
        
        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);

        newIncomeDetails = ContactUtils.retrieveContactIncomeDetails(newClient.id);     
    }   
   
}