/**
 * This class contains unit tests for validating the behavior of ctrlSubjectArchive
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfSubjectArchive {

    public static   User                uTstExecUser            	{ get; set; }
    public static   ctrlSubjectArchive	ctrlSubjectArchive         	{ get; set; }
    public static   PageReference       prSubjectArchive		   	{ get; set; }
	public static   Subject__c          newSubject					{ get; set; }
	

    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        prSubjectArchive = Page.vfSubjectArchive;

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
				testArchiveSubject();
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
         
    }
  	private static void testArchiveSubject() {
  		
  		prSubjectArchive = Page.vfSubjectArchive;
		Test.setCurrentPage(prSubjectArchive); 
		Map<String,String> mParms = prSubjectArchive.getParameters();
		mParms.put('Id',newSubject.id);		
		ctrlSubjectArchive = new ctrlSubjectArchive();
		//ctrlSubjectArchive.doCancelNewVersion();
		ctrlSubjectArchive.doSaveNewVersion();
		
		Subject__c newSubj = SubjectUtils.retrieveSubject(newSubject.id);
		system.assertEquals(newSubj.archive_resource_brief__c, 'rb1');
		system.assertEquals(newSubj.archive_practice_brief__c, 'pb1');
		system.assertEquals(newSubj.archive_solutions__c, 's1');
		system.assertEquals(newSubj.versioning_user__c, uTstExecUser.id );
		system.assertEquals(newSubj.version_date__c, Date.today());							
		
	}


    private static void buildTestData() {
    	
		newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'Chicago';
    	newSubject.resource_brief__c = 'rb1';
    	newSubject.practice_brief__c = 'pb1';
    	newSubject.solutions__c = 's1';
    	insert newSubject;        
		  		
	}    

	
    
}