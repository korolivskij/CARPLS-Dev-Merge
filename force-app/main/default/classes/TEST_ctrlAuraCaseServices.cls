/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=false)
public class TEST_ctrlAuraCaseServices {

    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCase      		ctrl              			{ get; set; }
    public static   ctrlAuraCaseServices ctrlSvc                    { get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static	Subject__c			newSubject					{ get; set; }
    public static   Subject__c          newSubject2                 { get; set; }
    public static   Consultation__c     newSvc                      {get;set;}
    public static   Account             newLegalRef                 {get;set;}
    public static   Account             newWebLink                  {get;set;}
    public static   Account             newSocialRef                {get;set;}

    public static   CaseUtils			caseUtils					{ get; set; }
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {

        prCase = Page.vfCase;

        //coreExecution('', '', '', '');
        caseUtils = new CaseUtils();
        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('','','','' );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
       // buildTestData(); //<--- Build Any needed clients / and caseparties / contacts..
        newClient = TEST_TestUtils.createContact('Client');

        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCaseParties = caseUtils.retrieveCaseParties(newCase);

        newSubject = new Subject__c();

        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'jur1';
        newSubject.Status__c = 'Active';
        newSubject.Type__c = 'Pending';
        newSubject.Litigation__c = 'Pending';
        //newSubject.Show_Litigation_Questions__c = true;
        insert newSubject;
        newSubject2 = new Subject__c();

        newSubject2.Title__c = 'Unit Test Case Subject';
        newSubject2.Practice_Area__c = 'pa1';
        newSubject2.Problem_Category__c = 'pcat1';
        newSubject2.Problem_Code__c = 'pc1';
        newSubject2.Jurisdiction__c = 'jur1';
        newSubject2.Status__c = 'Active';
        newSubject2.Type__c = 'Pending';
        newSubject2.Litigation__c = 'Pending';
        //newSubject.Show_Litigation_Questions__c = true;
        insert newSubject2;
        CaseUtils cseUtils = new CaseUtils();
        newSvc = cseUtils.buildNewService(newCase);
        newLegalRef = TEST_TestUtils.createAcct('Legal Referrals', newSubject);
        newWebLink = TEST_TestUtils.createAcct('Web Links', newSubject);
        newSocialRef = TEST_TestUtils.createAcct('Social Referrals', newSubject);

        newCase.selected_subject__c = newSubject.id;
        update newCase;

        Activity_Assignment__c aa = new Activity_Assignment__c();
        aa.support_type__c = 'AOC';
        aa.current_status__c = 'Available';
        aa.current_user__c = uTstExecUser.id;
        insert aa;

        TEST_TestUtils.debugSObj(newCase);
        TEST_TestUtils.debugSObjs(newCaseParties);
        Test.startTest();
        System.runAs(uTstExecUser) {
           // testNewService();
//ctrlAuraCaseServices.retrieveSvcAndNote(null);
            ctrlAuraCaseServices.updateServiceArToggles(null,null);

            Consultation__c blankSvc = ctrlAuraCaseServices.retrieveSvc();
            ctrlAuraCaseServices.retrieveFollowUpPlValues();
            ctrlAuraCaseServices.retrieveDispositionPlValues();
            ctrlAuraCaseServices.retrieveProjectPlValues();
            ctrlAuraCaseServices.retrieveFollowUpReasonPlValues();
            ctrlAuraCaseServices.retrieveDispositionAndServiceCodePlValues();

            Note n = new Note();
            n.body = 'Unit test code coverage testing sucks!';
            newSvc.Follow_Up_Public_Group__c = 'AOC';
            newSvc.Request_Follow_Up_Reason_PL__c = 'AOC';

            ResponseDTO dto = ctrlAuraCaseServices.upsertSvc(newSvc,n,false,false);
            system.debug('DTO='+dto);
            system.assert(dto.isSuccess);
            Consultation__c svcCreated = (Consultation__c)dto.values.get('Consultation__c');
            system.assert(svcCreated != null);
            svcCreated.service_form_guid__c = new CaseUtils().createGuid();
            update svcCreated;
            Applied_Resource__c arLegal = TEST_TestUtils.createAr(newCase.id,svcCreated.id,newLegalRef);
            arLegal.type__C = 'Legal Referrals';
            Applied_Resource__c arWebLink = TEST_TestUtils.createAr(newCase.id,svcCreated.id,newWebLink);
            arWebLink.type__c = 'Web Links';
            Applied_Resource__c arSocialRef = TEST_TestUtils.createAr(newCase.id,svcCreated.id,newSocialRef);
            arSocialRef.type__c = 'Social Referrals';

            arLegal.service_form_guid__C = null;
            arLegal.consultation__c = null;
            arSocialRef.service_form_guid__c = null;
            arSocialRef.consultation__c = null;
            arWebLink.service_form_guid__C = svcCreated.service_form_guid__c;

            update arLegal;
            update arWebLink;
            update arSocialRef;
            newCase.selected_subject__c = newSubject2.id;
            update newCase;
            //--

            dto = ctrlAuraCaseServices.upsertSvc(svcCreated,n,true,false);
            ctrlAuraCaseServices.retrieveSvcAndNote(svcCreated.id);
            ctrlAuraCaseServices.addCaseSubjectAsAppliedResource(svcCreated);
            ctrlAuraCaseServices.upsertSvc(null,null,false,false);
            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }
        Test.stopTest();
    }
    /**
     * The core launch point for this test class.
     */
    /*
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {




        Test.startTest();

        System.runAs(uTstExecUser) {
            testNewService();
            System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());
        }
        Test.stopTest();

    }
    */

    //private static void testNewService() {

    //}


    //private static void buildTestData() {


    //}
}