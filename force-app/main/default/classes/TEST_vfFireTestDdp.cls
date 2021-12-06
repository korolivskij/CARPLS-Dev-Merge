/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. and.. toggle case / service status correctly.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfFireTestDdp {
 
    public static   User                	uTstExecUser                { get; set; }
    public static   ctrlFireTestDdp     	ctrlFireTestDdp             { get; set; }
    public static   PageReference       	prFireTestDdp               { get; set; }
    public static   Contact           	  	newClient                   { get; Set; }   
    public static   Case                	newCase                     { get; Set; }
    public static   List<Consultation__c> 	newServices		        	{ get; Set; }
    public static   Applied_Resource__c 	newAr						{ get; set; }
    public static   Loop__DDP__c       	 	newDdp                      { get; set; }
    
    public static   CaseUtils           	caseUtils                   { get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prFireTestDdp = Page.vfDdpView;
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
                testViewPageWithParms();     
                testFilters();       
                testViewPageNoParms();    
                testMiscMethods();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    private static void testViewPageWithParms() {
        
        prFireTestDdp = Page.vfDdpView;
        Test.setCurrentPage(prFireTestDdp); 
        Map<String,String> mParms = prFireTestDdp.getParameters();
        mParms.put('caseId',newCase.id);
        mParms.put('contactId',newClient.id);
        mParms.put('appliedResourceId',newAr.id); 
            
        ctrlFireTestDdp = new ctrlFireTestDdp();
		ctrlFireTestDdp.doInitPage();       
    }
    private static void testFilters() {
    	ctrlFireTestDdp.showGis = true;
    	ctrlFireTestDdp.doRefreshDdpList();
    	
    	ctrlFireTestDdp.selectedTestStatus = 'I love SFDC';
    	ctrlFireTestDdp.doRefreshDdpList();
    	
    	ctrlFireTestDdp.selectedClientLanguage = 'Spanish';
    	ctrlFireTestDdp.doSelectClientLanguage();
    	ctrlFireTestDdp.selectedClientLanguage = 'English';
    	ctrlFireTestDdp.doSelectClientLanguage();
    	
    	ctrlFireTestDdp.SelectedServiceLevel = 'blah';
    	ctrlFireTestDdp.doRefreshDdpList();
    	
    	ctrlFireTestDdp.ddpIdClicked = newDdp.id;
    	ctrlFireTestDdp.doUpdateAppliedResource(); 	    	
    }
    private static void testViewPageNoParms() {
        
        prFireTestDdp = Page.vfDdpView;
        Test.setCurrentPage(prFireTestDdp);            
        ctrlFireTestDdp = new ctrlFireTestDdp();
		ctrlFireTestDdp.doInitPage();       
    }    

    private static void buildTestData() {
    	newClient = TEST_TestUtils.createContact('Client');
        newDdp = TEST_TestUtils.createDdp();      
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);
        newServices = caseUtils.retrieveConsultations(newCase);
        newAr = TEST_TestUtils.createAr(newCase.id,newServices[0].id, newDdp);        
    }    
    
    private static void testMiscMethods() {
    	ctrlFireTestDdp.getClientLanguageOptions();
    	ctrlFireTestDdp.getTestStatusOptions();
    	ctrlFireTestDdp.getServiceLevelOptions();
    	
    }
    
}