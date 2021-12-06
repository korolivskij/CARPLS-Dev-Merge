/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfResourceLibrary {

    public static   User                			uTstExecUser                			{ get; set; }
    public static   ctrlResourcesAndComments		ctrlRes    			{ get; set; }
    public static   PageReference       			prResourceLibrary                      	{ get; set; }
    public static   Contact             			newClient                   			{ get; Set; }   
    public static   Search_Log__c       			newSlClient                 			{ get; set; }
    public static   Case                			newCase                    				{ get; Set; }
    public static   List<Case_Party__c> 			newCaseParties              			{ get; Set; }
    public static   Subject__c						newSubject								{ get; set; }
    public static   Consultation__c					newService								{ get; set; }
    public static   CaseUtils						caseUtils								{ get; set; }
    
    public static   Loop__DDP__c					newDDP									{ get; set; }
    public static   Account							newAcctLegal							{ get; set; }
    public static   Account							newAcctSocial							{ get; set; }
    public static   Account							newAcctWebLink							{ get; set; }
    
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {

        prResourceLibrary = Page.vfResourceLibrary;
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
            	testCaseResourcesLoad();
            	testServiceResourcesLoad();
            	testRemoteMethods();
                //testReviewCase();
			//	testAddNewService();
                testMiscMethods();
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
    
    private static void testCaseResourcesLoad() {
        prResourceLibrary = Page.vfResourceLibrary;
        Test.setCurrentPage(prResourceLibrary); 
        ctrlRes = new ctrlResourcesAndComments(); //Dont pass an id in the request.  
        
        prResourceLibrary = Page.vfResourceLibrary;
        Test.setCurrentPage(prResourceLibrary);        
        Map<String,String> mParms = prResourceLibrary.getParameters();
        mParms.put('id',newCase.id);        
        ctrlRes = new ctrlResourcesAndComments(); //pass a case id in the request.
        
        //- since there is no data the below wont refresh anything but still cover code in this case.
        ctrlRes.doRefreshDdps();
        ctrlRes.doRefreshLegalRefs();
        ctrlRes.doRefreshSocialRefs();
        ctrlRes.doRefreshWebLinksRefs();
        
        buildPossibleResources();
        //now we should get some results
        ctrlRes.doRefreshDdps();
        ctrlRes.doRefreshLegalRefs();
        ctrlRes.doRefreshSocialRefs();
        ctrlRes.doRefreshWebLinksRefs();    
        
        //now we should add some of these as applied resources..... @TODO 
        Applied_Resource__c arLegal 	= TEST_TestUtils.createAr(newCase.id, newService.id, newAcctLegal);
        Applied_Resource__c arSocial 	= TEST_TestUtils.createAr(newCase.id, newService.id, newAcctSocial);
        Applied_Resource__c arWebLink 	= TEST_TestUtils.createAr(newCase.id, newService.id, newAcctWebLink);
        Applied_Resource__c arDdp 		= TEST_TestUtils.createAr(newCase.id, newService.id, newDDP);        
        ctrlRes.doRefreshDdps();
        ctrlRes.doRefreshLegalRefs();
        ctrlRes.doRefreshSocialRefs();
        ctrlRes.doRefreshWebLinksRefs();         
        
    }
    
    private static void testServiceResourcesLoad() {
        prResourceLibrary = Page.vfResourceLibrary;
        Test.setCurrentPage(prResourceLibrary);        
        Map<String,String> mParms = prResourceLibrary.getParameters();
        mParms.put('id',newService.id);       
        mParms.put('caseId',newCase.id);
        ctrlRes = new ctrlResourcesAndComments(); //pass a service id and caseId as secondary    
           
    }
    /**
     * RJN TABX
     */
    private static void testRemoteMethods() {
		//Delete an incomplete service. (well any service but force it)
		Id caseId = newCase.Id;
		List<Consultation__c> svcsToDel = [select id from consultation__c where case__c = :caseId];
		if(svcsToDel != null && !svcsToDel.isEmpty()) {
			Consultation__c svcToDel = svcsToDel[0];
			Id svcIdToDel = svcToDel.id;
			Boolean deleted = ctrlResourcesAndComments.remoteDeleteIncompleteService(svcIdToDel);
			System.assert(deleted);
			
			String svcBogusID = 'bogusIdGoBoom';
			deleted = ctrlResourcesAndComments.remoteDeleteIncompleteService(svcBogusId);
			System.assertNotEquals(deleted,true);
		}    	
    }

    /*
	private static void testAddNewService() {
		Consultation__c service = caseUtils.buildNewService(newCase); 
		insert service;
		ctrlRes.doAddServiceNew(); //refresh of case summary data occurs in this method
	}
	*/
    private static void testMiscMethods() {
		ctrlRes.refreshSubjectId();
		
		ctrlRes.parentRecordId = '';
		ctrlRes.doFindParentRecordName(); //boom
		
		ctrlRes.parentRecordId = newCase.id;
		ctrlRes.doFindParentRecordName();
    }
    
    private static void buildTestData() {        
        newClient = TEST_TestUtils.createContact('Client');
                      
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;        
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Open');
        newCaseParties = caseUtils.retrieveCaseParties(newCase);
        
    	newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'Ricks House';
    	insert newSubject;          
        
        newCase.Selected_Subject__c = newSubject.id;
        update newCase;
        newService = caseUtils.retrieveConsultations(newCase)[0];
        
        
        
        TEST_TestUtils.debugSObj(newCase);  
        TEST_TestUtils.debugSObjs(newCaseParties);    
    }  
    
    private static void buildPossibleResources() {
    	newDDP = new Loop__DDP__c();
    	insert newDDP;
    	Eligible_Problem_Codes__c epc = new Eligible_Problem_Codes__c();
    	epc.DDP__c = newDDP.id;
    	epc.Practice_Area__c = 'pa1';
    	epc.Problem_Category__c = 'pcat1';
    	epc.Problem_Code__c = 'pc1';    	
    	insert epc;
    	
    	newAcctLegal 	=  	TEST_TestUtils.createAcct('Legal Referral');
    	Eligible_Problem_Codes__c epc2 = new Eligible_Problem_Codes__c();
    	epc2.account__c = newAcctLegal.id;
    	epc2.Practice_Area__c = 'pa1';
    	epc2.Problem_Category__c = 'pcat1';
    	epc2.Problem_Code__c = 'pc1';
    	insert epc2;    	
    	
    	newAcctSocial 	=  	TEST_TestUtils.createAcct('Social Service Referral');
    	Eligible_Problem_Codes__c epc3 = new Eligible_Problem_Codes__c();    
    	epc3.account__c = newAcctSocial.id;
    	epc3.Practice_Area__c = 'pa1';
    	epc3.Problem_Category__c = 'pcat1';
    	epc3.Problem_Code__c = 'pc1';
    	insert epc3;  
    	     	
    	newAcctWebLink 	= 	TEST_TestUtils.createAcct('WebLink'); 
     	Eligible_Problem_Codes__c epc4 = new Eligible_Problem_Codes__c();
    	epc4.account__c = newAcctWebLink.id;
    	epc4.Practice_Area__c = 'pa1';
    	epc4.Problem_Category__c = 'pcat1';
    	epc4.Problem_Code__c = 'pc1';
    	insert epc4;      	
    	
    	
    }   
    
}