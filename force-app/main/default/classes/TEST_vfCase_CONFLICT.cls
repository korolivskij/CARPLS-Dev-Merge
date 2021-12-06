/**
 * Test all this conflict crap. (from point of view of what happens on the case page only)
 */
@isTest(SeeAllData=false)
public class TEST_vfCase_CONFLICT {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCaseDetail      ctrlCaseDetail              { get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   Case                newCase2                    { get; Set; } //used for multiple possible conflict recs
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static   CaseUtils			caseUtils					{ get; set; }
    public static   NpspUtils			npspUtils					{ get; set; }
    
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
        npspUtils = new NpspUtils();
        npspUtils.makeAllTriggersInactive();
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {                              
                testFiredFromClient();

                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    private static void testFiredFromClient() {
    	
        prCase = Page.vfCaseDetail;
        Test.setCurrentPage(prCase); 
        
        Map<String,String> mParms = prCase.getParameters();
        
        mParms.put('id',newCase.id);
 		mParms.put('review','true');
        mParms.put('tempCase','false');        
        mParms.put('potentialConflict','true');
        mParms.put('slId',newSlClient.id);
        mParms.put('searchType','Client');

        ctrlCaseDetail = new ctrlCaseDetail(new ApexPages.StandardController(newCase));
        ctrlCaseDetail.doInitCase();
      //  system.assert(ctrlCaseDetail.possibleCaseConflicts.size() == 2 );
        
        ctrlCaseDetail.doConflictNo();
       // system.assert(ctrlCaseDetail.conflictLog != null);
        
        //Fill in NO CONFLICT FORM AND SUBMIT
        ctrlCaseDetail.selectedApproverVal = ctrlCaseDetail.getApproverOptions()[0].getValue();
        ctrlCaseDetail.doAddConflictLog();
        //system.assert(ctrlCaseDetail.conflictLogsAdded.size() == 1);
        //system.assert(ctrlCaseDetail.possibleCaseConflicts.size() == 1 );
        
        ctrlCaseDetail.doConflictYes();
        //system.assert(ctrlCaseDetail.conflictLog.Finding__c == 'Conflict of Interest');
        
        //Fill in YES CONFLICT FORM AND SUBMIT
        ctrlCaseDetail.selectedApproverVal = ctrlCaseDetail.getApproverOptions()[0].getValue();
        ctrlCaseDetail.selectedReasonVal = ctrlCaseDetail.getReasonOptions()[0].getValue();
		
		ctrlCaseDetail.doAddConflictLog();
		//system.assert(ctrlCaseDetail.conflictLogsAdded.size() == 2);
       
        ctrlCaseDetail.doAbortCase();
        ctrlCaseDetail.doContinueToSearch();
        
        
    }

    private static void buildTestData() {
        
        newClient = TEST_TestUtils.createContact('Client');
        
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCase2 = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        
        List<Possible_Conflict__c> pcs = new List<Possible_Conflict__c>();
        Possible_Conflict__c pc1 = new Possible_Conflict__c();
        pc1.Search_Log_Client__c = newSlClient.id;
        pc1.Contact_Being_Reviewed__c = newClient.id;
        pc1.Possible_Reason__c = 'Client - Adverse Party';
        pc1.Case__c = newCase.id;

        Possible_Conflict__c pc2 = new Possible_Conflict__c();
        pc2.Search_Log_Client__c = newSlClient.id;
        pc2.Contact_Being_Reviewed__c = newClient.id;
        pc2.Possible_Reason__c = 'Client - Adverse Party';
        pc2.Case__c = newCase2.id;
        
        pcs.add(pc1);
        pcs.add(pc2);
        insert pcs;
            
        TEST_TestUtils.debugSObj(newCase);  
        TEST_TestUtils.debugSObjs(newCaseParties);    
    }    


    
}