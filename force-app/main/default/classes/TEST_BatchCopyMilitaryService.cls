/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_BatchCopyMilitaryService {

    public static User uTstExecUser { get; set; }

    public static Contact newClient { get; Set; }

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

        Datetime dtTstStart = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId, sRoleId, sPermSetId);
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:' + uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:' + customSetting);

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

        soql += ' SELECT 	military_service__c, military_service_legacy__c ' ;
        soql += ' From 		Contact c Where	 c.military_service__c != null ';
        soql += ' limit 1 ';


        BatchCopyMilitaryService batchUpd =
                new BatchCopyMilitaryService(soql, emailAddys, bCommitTrans);
        id batchId = Database.executeBatch(batchUpd,1);
        System.debug(logginglevel.info, '\n=========== Executing batch id=' + batchId);


    }


    private static void buildTestData() {
        CaseUtils caseUtils = new CaseUtils();
        newClient = TEST_TestUtils.createContact('Client');
        newClient.military_service__c = 'None';
        update newClient;
    }
}