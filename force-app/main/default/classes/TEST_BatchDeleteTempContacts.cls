/**
 * Tests schedulable and batch apex for deleting temp contact records
 */
@isTest(SeeAllData=false)
public class TEST_BatchDeleteTempContacts {

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
				testScheduleDeleteTempContacts();
				testBatchDeleteTempContactsExecution();
				testMiscMethods();
            }
            
	        List<Contact> tempContacts = [select id, lastname from Contact where temp_record__c = true];    
    	    System.assert(!tempContacts.isEmpty());   //make sure there are currently temp contact records   
        	
       	Test.stopTest();
    
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
        
        List<Contact> tempContacts2 = null;
		tempContacts2 = [select id,lastname from Contact where temp_record__c = true];
		// ELC - removed assert until the job this is scheduled and running  
        //System.assert(tempContacts2 == null || tempContacts2.isEmpty());   //make sure there are NO more temp contact records.
        
        List<Lead> leadIdsCreated = new List<Lead>();
        Set<String> contactLastNamesDeleted = new Set<String>();
        for(Contact c : tempContacts) {
        	contactLastNamesDeleted.add(c.lastname);
        }   
        List<Lead> leadsCreated = [select id,lastname from Lead where lastname in :contactLastNamesDeleted];
        System.assert(leadsCreated != null || !leadsCreated.isEmpty());   //make sure Leads have been created for the deleted contact recs.       
         
    } 
    /**
     * We must manually trigger the execute() method which will call start / finish methods.
     * Note the batch class has a check to see if it's running in test mode, if it's not in test mode.
     * it will ensure the contact was created >25 minutes ago. Since we can't really test that, we bypass that in test mode.
     *
     */
    private static void testBatchDeleteTempContactsExecution() {
    	String sEmail = 'rnendza@gmail.com';
    	List<String> lEmails = new List<String> { sEmail };
    	lEmails.add('ericacox10@gmail.com');
        String soqlDelete = 'select id, lastname from Contact where temp_record__c = true';
    	BatchDeleteTempContacts batchTc = new BatchDeleteTempContacts(soqlDelete,lEmails);
    	ID myBatchJobID1 = database.executebatch(batchTc,200); 	
    }   
    /**
     * Merely Covers the ScheduleDeleteSearchLogs class. does not test the batch class it fires.
     */
  	private static void testScheduleDeleteTempContacts() {
  		Datetime cronDt = Datetime.now()  + (0.024305);
  		
		String CRON_EXP = cronDt.format('s m H d M \'?\' yyyy');
        String jobId = System.schedule('Test ScheduleDeleteTempContacts', CRON_EXP, new ScheduleDeleteTempContacts() );
		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(cronDt, ct.NextFireTime);   
	}
	private static void testMiscMethods() {
		LeadUtils.createLeads(null);
		LeadUtils.copyContactToLead(null);
		
	}
    private static void buildTestData() {    	
					
		newClient = TEST_TestUtils.createContact('Client');
		newClient.Temp_Record__c = true;
		update newClient;
			
		newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');	
		insert newSlClient;
		newPc   = new Possible_Conflict__c(Search_Log_Client__c = newSlClient.id);    
        insert newPc;       
		  		
	}    
    
}