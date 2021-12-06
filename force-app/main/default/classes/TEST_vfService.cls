/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfService {
/*
    public static   User                	uTstExecUser            	{ get; set; }
    public static   ctrlServiceExtension	ctrl       					{ get; set; }
    public static   PageReference       	prService			        { get; set; }
    public static   Contact             	newClient 					{ get; Set; }	
    public static   Search_Log__c       	newSlClient					{ get; set; }
    public static   Case 					newCase						{ get; Set; }
	public static   List<Case_Party__c> 	newCaseParties		        { get; Set; }
	public static   List<Consultation__c> 	newServices		        	{ get; Set; }
	
	public static   Subject__c 				newSubj						{ get; set; }
	public static   Account					newAcct						{ get; set; }
	public static   Applied_Resource__c		newAr						{ get; set; }

    public static testMethod void executeTest() {

        prService = Page.vfService;

        coreExecution('', '', '', '');
    }

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
        

        Test.startTest();
        
            System.runAs(uTstExecUser) {  
            	addGroupMember(); //have to do here to avoid mixed DML opp error.                            
				testAddNewServiceToCase();
				testEditCaseService();
				testCancelCaseServices();
				//testAddNewServiceButCancelWhileAdding();
				testMiscMethods();
            }
        
        Test.stopTest();

    }
  	private static void testAddNewServiceToCase() {
  		// already have one service from buildTestData - adding another
  		
		Test.setCurrentPage(prService); 
		Map<String,String> mParms = prService.getParameters();
		//mParms.put('id',null);
		mParms.put('caseId',newCase.id);
		mParms.put('addingFromCase','true');
		
		ctrl = new ctrlServiceExtension(new ApexPages.StandardController(new Consultation__c()));
		ctrl.doInitPage();
		system.assert(ctrl.isAddingFromCase);
		
		ctrl.service.Follow_Up_Public_Group__c ='Attorney';
		ctrl.service.Follow_Up_Date__c = Date.today();
		ctrl.service.Follow_Up_Reason__c = 'FOLLOW UP REASON';
		ctrl.doFollowUpReasonSelect();
		
		ctrl.doSaveService();
		ctrl.doRefreshAppliedResourcesAfterSelected();
		system.assert(ctrl.saveSuccess);
		
	}
	
  	private static void testAddNewServiceButCancelWhileAdding() {
  		// already have one service from buildTestData - adding another
  		
		Test.setCurrentPage(prService); 
		Map<String,String> mParms = prService.getParameters();
		//mParms.put('id',null);
		mParms.put('caseId',newCase.id);
		mParms.put('addingFromCase','true');
		
		ctrl = new ctrlServiceExtension(new ApexPages.StandardController(new Consultation__c()));
		ctrl.doInitPage();
		system.assert(ctrl.isAddingFromCase);
		ctrl.doSaveService();
		ctrl.doCancelService();
		
		
	}	
	private static void testEditCaseService() {
		
		if(newServices == null || newServices.isEmpty()) {
			System.debug(logginglevel.error,'xxx you must add services to case first dummy!');
			return;
		}
		
		Consultation__c editService = newServices[0]; 
		
		Test.setCurrentPage(prService); 
		editService.Location__c = 'TEST LOCATION';
		Map<String,String> mParms = prService.getParameters();
		mParms.put('id',editService.id);
		mParms.put('caseId',newCase.id);
		// Not sure if this makes sense, but it's catching more lines this way
		mParms.put('addingFromCase', 'false');
		ctrl = new ctrlServiceExtension(new ApexPages.StandardController(new Consultation__c()));
		ctrl.doInitPage();
		ctrl.selectedAppliedResourceId = newAr.id;
		ctrl.doRemoveAppliedResource();
		
		//ctrl.doCancelService();
		
				
	}
	
	private static void testCancelCaseServices() {
		
		Consultation__c cancelService;
		if(newServices == null || newServices.isEmpty() ) {
			System.debug(logginglevel.error,'No Services to cancel!');
			return;
		} else {
			cancelService = newServices[0]; 
		} 
		
		Test.setCurrentPage(prService); 
		Map<String,String> mParms = prService.getParameters();	
		mParms.clear();
		mParms.put('caseId',newCase.id);
		mParms.put('id',cancelService.id);
		ctrl = new ctrlServiceExtension(new ApexPages.StandardController(new Consultation__c()));
		ctrl.doCancelNewService();
		
	}
	
	private static void testMiscMethods() {	
		ctrl.getFollowUpRequired();	
		ctrl.refreshAppliedResources();
		ctrl.refreshNotes();
		ctrl.doCancelEditService();
	}
	
    private static void buildTestData() {
		CaseUtils caseUtils = new CaseUtils();		
		newClient = TEST_TestUtils.createContact('Client');
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient);
		newCaseParties = caseUtils.retrieveCaseParties(newCase);
		newServices = caseUtils.retrieveConsultations(newCase);
		
		
		newSubj = SubjectUtils.retrieveSubject(newCase.selected_subject__c);
		newAcct = TEST_TestUtils.createAcct('Legal', newSubj);
		newAr = TEST_TestUtils.createAr(newCase.id,newServices[0].id,newAcct);
		
		
		
		TEST_TestUtils.debugSObj(newClient);
		TEST_TestUtils.debugSObj(newCase);  
		TEST_TestUtils.debugSObjs(newCaseParties); 
		TEST_TestUtils.debugSObjs(newServices); 
	} 
	
	private static void addGroupMember() {
		Group g = [select id from group where name = 'Attorney'];
		GroupMember gm = new GroupMember();
		gm.GroupId = g.id;
		gm.UserOrGroupId = uTstExecUser.id;
		insert gm;
				
	}
	*/
}