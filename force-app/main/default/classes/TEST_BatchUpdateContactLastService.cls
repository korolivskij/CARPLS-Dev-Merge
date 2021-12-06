/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_BatchUpdateContactLastService {

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
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prService = Page.vfService;
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
				testBatchUpdate();
            }
        
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }
  	private static void testBatchUpdate() {

          
          String soql = '';
          List<String> emailAddys = new List<String>();
          emailAddys.add('rnendza@gmail.com');
          Boolean bCommitTrans = true;
          
          /**
           * Query All Records 
           */
 	 	 String sServiceStatus = 'Closed';
 	 	 
		 soql += ' SELECT 	c.Name, c.Last_Service_Date__c, c.Last_Service_By__c, c.Last_Service_Activity__c, c.Id, Last_Service_Info_Batch_Updated__c, ' ;
		 soql += ' 	(	Select 			Id, Name,status__c,Service_End_Time__c,LastModifiedById, createdById ';
		 soql += ' 		From 			Consultations__r  Where			Status__C = :sServiceStatus Order By		Service_End_Time__c DESC LIMIT 1	) '; 
		 soql += ' From 		Contact c Where		id in (select contact_xx__c from consultation__c) ';
		 soql += ' and          c.Last_Service_Info_Batch_Updated__c = false ';
		 soql += ' limit 199 ';
 
    
      	BatchUpdateContactLastService  batchUpd = 
        new BatchUpdateContactLastService(  soql,emailAddys,sServiceStatus,
                              bCommitTrans);
      	id batchId = Database.executeBatch(batchUpd); 
      	System.debug(logginglevel.info,'\n=========== Executing batch id='+batchId);
      	
               

		
	}
	
  
	
    private static void buildTestData() {
		CaseUtils caseUtils = new CaseUtils();		
		newClient = TEST_TestUtils.createContact('Client');
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient, 'Closed');
		newCaseParties = caseUtils.retrieveCaseParties(newCase);
		newServices = caseUtils.retrieveConsultations(newCase);
		
		

	} 
	
	private static void addGroupMember() {
		Group g = [select id from group where name = 'Attorney'];
		GroupMember gm = new GroupMember();
		gm.GroupId = g.id;
		gm.UserOrGroupId = uTstExecUser.id;
		insert gm;
				
	}  
}