/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. and.. toggle case / service status correctly.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfDdpView {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlDdpView         ctrlDdpView                 { get; set; }
    public static   PageReference       prDdpView                   { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   Loop__DDP__c        newDdp                      { get; set; }
    
    public static   CaseUtils           caseUtils                   { get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prDdpView = Page.vfDdpView;
        caseUtils = new CaseUtils();
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
        
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {                              
                testViewDdp();
                testMiscMethods();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    private static void testViewDdp() {
        
        prDdpView = Page.vfDdpView;
        Test.setCurrentPage(prDdpView); 
        Map<String,String> mParms = prDdpView.getParameters();
        mParms.put('caseId',newCase.id);
        mParms.put('id',newDdp.id); 
            
        ctrlDdpView = new ctrlDdpView(new ApexPages.StandardController(newDdp));
        ctrlDdpView.doInitPage();
        ctrlDdpView.doSelectResource();
            
        newCase.Status = 'Closed';
        update newCase;
        List<Consultation__c> caseServices = caseUtils.retrieveConsultations(newCase);
        for(Consultation__c s : caseServices) {
            s.status__c = 'Closed';
        }
        update caseServices;
        
        Test.setCurrentPage(prDdpView); 
        ctrlDdpView = new ctrlDdpView(new ApexPages.StandardController(newDdp));
        ctrlDdpView.doInitPage();
        ctrlDdpView.doCancelSelectResource();       
    }

    private static void testMiscMethods() {
        
        //hit evalCaseStatus again.. for some reason the above not hitting closed cases.
        ctrlDdpView.cse.status = 'Closed';
        ctrlDdpView.evalCaseStatus();
        
        //update the current case serivce to closed then hit evalservicestatus
        Consultation__c currentService = caseUtils.retrieveCurrentCaseConsultation(newCase);
        ctrlDdpView.cse.status = 'Open';
        currentService.status__c = 'Closed';
        update currentService;
        
    }
    private static void buildTestData() {
        newDdp = TEST_TestUtils.createDdp();
                    
        newClient = TEST_TestUtils.createContact('Client'); 
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);  
        ContentVersion cv = buildContentVersion(newCase.id);    
        TEST_TestUtils.debugSObj(newCase);              
    }  
    //--- @TODO MOVE THE BELOW METHODS TO TEST_TESTUTILS WHEN VALIDATED. (SHARE WITH CONTENT TRIGGERS)
    private static ContentVersion buildContentVersion(Id caseId) {
        Blob fileContent = Blob.valueOf('Unit Test Document Body');
        ContentVersion cv = new ContentVersion();
        cv.Case__c = newCase.id;
        cv.versionData = fileContent; 
        cv.title = 'UNIT TEST TITLE';
        cv.Description = 'Blah Unit Test CV DESC';
        cv.Custom_Type__c ='Client Document';
        cv.PathOnClient = '/test';
        List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'User Attached Documents'];
        cv.firstPublishLocationId = CWList.get(0).Id;   
        return cv;      
    }  
    private static void createCollabGroup() {
        //-- special case, even though see all data is false, sfdc won't let is
        //-- insert an imaginary collab group with the name name in a unit test
        //-- do not change the name of the below!;
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'Case Documents - Read Only - UNIT TEST';
        cg.CollaborationType = 'Public';
        insert cg;      
    }     

    
    
}