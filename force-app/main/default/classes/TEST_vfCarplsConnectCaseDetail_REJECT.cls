/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *

 */
@isTest
private class TEST_vfCarplsConnectCaseDetail_REJECT {
    
    public static final String          ACCT_USER_NAME = 'Test CARPLS Connect Account'; 
    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCarplsConnectCaseDetail ctrlCarplsConnectCaseDetail   { get; set; }
  
    public static   PageReference       prCcCase                    { get; set; }
   
    public static   Contact             newClient                   { get; Set; }   
    public static   Account             newAcct                     { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   Consultation__c     newService                  { get; set; }

    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {

        prCcCase = Page.vfCarplsConnectCaseDetail;
        
        /* 
         *  Just pass blank parms for user now. This is a luxury that I wish we had but we may
         *  run out of time before we can test multiple users / roles / profiles via code.
         *  In the above scenario, a user will be created on the fly and is a system admin
         *  with no roles / permission sets applied.
         * 
         *  @TODO maybe pull testing user from custom setting.
         *  @TODO maybe create different users from different roles / profiles on the fly
         */

        
        coreExecution();
    }
    /**
     * The core launch point for this test class.
     */
    public static void coreExecution() {
        
        Datetime   dtTstStart        = Datetime.now();
        
        //--Create testing user ---
        Id profileId = UserUtils.getProfileByName('System Administrator').id;
        uTstExecUser = getUserForTest(profileId, ACCT_USER_NAME);
        
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        //TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        //Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        //System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        
        buildTestData(); //<--- Build Any needed clients / and caseparties / contacts.. 
        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {   
                System.debug(logginglevel.debug, 'Starting test');   
                //testReturnToPend();                        
                testRejectCase();   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }

    private static void testReturnToPend() {
        prCcCase = Page.vfCarplsConnectCaseDetail;
        Test.setCurrentPage(prCcCase); 
        Map<String,String> mParms = prCcCase.getParameters();
        mParms.put('id',newCase.id);
        mParms.put('acctId',newAcct.id);
        ctrlCarplsConnectCaseDetail = new ctrlCarplsConnectCaseDetail(new ApexPages.StandardController(newCase));
        ctrlCarplsConnectCaseDetail.doInitCase();
        ctrlCarplsConnectCaseDetail.doPendReferral();
        ctrlCarplsConnectCaseDetail.doCancelPendReferral();
        ctrlCarplsConnectCaseDetail.doSavePendReferral();
    }
    private static void testRejectCase() {
        prCcCase = Page.vfCarplsConnectCaseDetail;
        Test.setCurrentPage(prCcCase); 
        Map<String,String> mParms = prCcCase.getParameters();
        mParms.put('id',newCase.id);
        mParms.put('acctId',newAcct.id);
        ctrlCarplsConnectCaseDetail = new ctrlCarplsConnectCaseDetail(new ApexPages.StandardController(newCase));
        ctrlCarplsConnectCaseDetail.doInitCase();
        ctrlCarplsConnectCaseDetail.doRejectReferral();
        ctrlCarplsConnectCaseDetail.doCancelRejectReferral();
        ctrlCarplsConnectCaseDetail.doSaveRejectReferral();        
    }

    private static User getUserForTest(Id pProfileId, String pName) {
        
        Double x = Math.random() * 10000;
        String rd = String.valueOf(Integer.valueOf(x));     
        User usr = new User();
        usr.FirstName = '';
        usr.LastName = pName;
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.Email = rd+'info@ext-it.com';
        usr.Alias = rd;
        usr.TimeZoneSidKey = 'America/Chicago';
        usr.Username = 'test'+rd+ '@ext-it.com';
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';
        usr.CommunityNickname = 'somename' + rd;
        usr.ProfileId = pProfileId;

        insert usr;
        return usr;
    }
    private static void buildTestData() {
    
        System.debug(logginglevel.debug, 'in build test data');

        // Create an account and make it a carpls connect account
        newAcct = new Account(name = ACCT_USER_NAME, /*carpls_connect__c = true*/ partner_type__c = 'CARPLS Connect');
        insert newAcct;
        // Create a contact for the account
        Contact userContact = new Contact(lastname = ACCT_USER_NAME, accountid=newAcct.id);
        insert userContact;
        // Create a client, case and consultation       
        newClient = TEST_TestUtils.createContact('Client'); 
        
        // Create a case 
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);      
        TEST_TestUtils.debugSObj(newCase);
        newService = new Consultation__c(case__c = newCase.id);
        insert newService;
        Applied_Resource__c ar = new Applied_Resource__c( case__c = newCase.id, consultation__c=newService.Id, 
                Account__c = newAcct.id, Status__c = 'Applied', Distribution__c = '');
        insert ar;
        
        
    }   

}