/**
 * Tests schedulable and batch apex for deleting search logs and attached possible conflict objects.
 */
@isTest(SeeAllData=false)
public class TEST_BatchDeleteSearchLogs {

    public static   User                	uTstExecUser            	{ get; set; }
    public static   Contact             	newClient 					{ get; Set; }
    public static   Search_Log__c       	newSlClient					{ get; set; }
    public static   Possible_Conflict__c    newPc               		{ get; set; }
   
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
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
         *-- START THE actual TEST. ---------------
         * Note! any assertions of your class's actual behavior
         *  (e.g., querying to confirm expected changes) must occur after test.stopTest when using the Schedulable Interface.
         *  Merely testing the scheduled class does not test the batch class the scheduler instantiates. we must do that manually.
         *  and check the results after stopTest.
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {                              
				testScheduleDeleteSearchLogs();
				testBatchDeleteSearchLogsExecution();
            }
            
	        List<Search_Log__c> slClients = [select id from Search_Log__c];    
    	    System.assert(!slClients.isEmpty());   //make sure there are currently slClients.   
        	
        	List<Possible_Conflict__c> pcs = [select id from Possible_Conflict__c];    
        	System.assert(!pcs.isEmpty());   //make sure there are currently possible conflict records.
        	   
         Test.stopTest();
    
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
        slClients = null;
		slClients = [select id from Search_Log__c];  
        System.assert(slClients == null || slClients.isEmpty());   //make sure there are NO slClients.    

		pcs = null;        
        pcs = [select id from Possible_Conflict__c];    
        System.assert(pcs == null || pcs.isEmpty());   //make sure there are NO POSSIBLE CONFLICT records.
         
    }
    /**
     * We must manually trigger the execute() method which will call start / finish methods.
     *
     */
    private static void testBatchDeleteSearchLogsExecution() {
    	String sEmail = 'rnendza@gmail.com';
    	List<String> lEmails = new List<String> { sEmail };
    	lEmails.add('ericacox10@gmail.com');
    	
        String soqlDeleteSl = 'select id from search_log__c';
    	BatchDeleteSearchLogs batchSl = new BatchDeleteSearchLogs(soqlDeleteSl,lEmails);
    	ID myBatchJobID1 = database.executebatch(batchSl,200);
    	
        String soqlDeletePc = 'select id from Possible_Conflict__c';
        BatchDeleteSearchLogs batch2 = new BatchDeleteSearchLogs(soqlDeletePc,lEmails);
        ID myBatchJobID2 = database.executebatch(batch2,200);
        System.debug(logginglevel.warn,'Scheduled batchJobId for pcDelete='+myBatchJobID2);     	
    }   
    /**
     * Merely Covers the ScheduleDeleteSearchLogs class. does not test the batch class it fires.
     */
  	private static void testScheduleDeleteSearchLogs() {
  		Datetime cronDt = Datetime.now()  + (0.024305);
  		
		String CRON_EXP = cronDt.format('s m H d M \'?\' yyyy');
        String jobId = System.schedule('Test ScheduleDeleteSearchLogs', CRON_EXP, new ScheduleDeleteSearchLogs() );
		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(cronDt, ct.NextFireTime);   
	}

    private static void buildTestData() {    	
					
		newClient = TEST_TestUtils.createContact('Client');	
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
		insert newSlClient;
		newPc   = new Possible_Conflict__c(Search_Log_Client__c = newSlClient.id);    
        insert newPc;       
		  		
	}    
    
}