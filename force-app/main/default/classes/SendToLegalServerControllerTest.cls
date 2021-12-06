/**
 * Provisio Partners
 * @author Stepan Mahdziak <stepan.mahdziak@redtag.pro>
 * @date 11 March 2021
 *
 * @description Test Class for SendToLegalServerController class and for LegalServerRestService class ;
 **/
@isTest
public class SendToLegalServerControllerTest {
 
    @isTest 
    static void testSendToLegalServerPositive() {
        makeData(false);
        Integer statusCode = 200;
        String responseBody = '{"results": {"unique_id":"test"}}';
        Test.setMock(HttpCalloutMock.class, new SendToLegalServerControllerMock(statusCode, responseBody, true));
        Applied_Resource__c ap = [SELECT Id FROM Applied_Resource__c ap LIMIT 1];
        Test.startTest();
            SendToLegalServerController.sendToLegalServer(ap.Id);
        Test.stopTest();
    }

    @isTest 
    static void testSendToLegalServerNegative() {
        makeData(true);
        Integer statusCode = 200;
        String responseBody = '{"results": {"unique_id":"test"}}';
        Test.setMock(HttpCalloutMock.class, new SendToLegalServerControllerMock(statusCode, responseBody, true));
        Applied_Resource__c ap = [SELECT Id FROM Applied_Resource__c ap LIMIT 1];
        Test.startTest();
            SendToLegalServerController.sendToLegalServer(ap.Id);
        Test.stopTest();
    }

    @isTest 
    static void testSendToLegalServerBodyError() {
        makeData(false);
        Integer statusCode = 200;
        String responseBody = '{"error": "test error"}';
        Test.setMock(HttpCalloutMock.class, new SendToLegalServerControllerMock(statusCode, responseBody, true));
        Applied_Resource__c ap = [SELECT Id FROM Applied_Resource__c ap LIMIT 1];
        Test.startTest();
            SendToLegalServerController.sendToLegalServer(ap.Id);
        Test.stopTest();
    }
    
    @isTest
     static void testSendToLegalServerBadStatus() {
        makeData(true);
        Integer badStatusCode = 300;
        String responseBody = '{"results": "test"}';
        Test.setMock(HttpCalloutMock.class, new SendToLegalServerControllerMock(badStatusCode, responseBody, false));
        Applied_Resource__c ap = [SELECT Id FROM Applied_Resource__c ap LIMIT 1];
        Test.startTest();
            SendToLegalServerController.sendToLegalServer(ap.Id);
        Test.stopTest();
    }
    
    static void makeData(Boolean toCreateBadData){
        Contact con = new Contact(
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Birthdate = Date.today(),
            Middle_Initial_Suffix__c = 'Test',
            Phone = '666-876-899',
            Email = 'test@aol.com',
            MailingStreet  = '123 main',
            MailingCity  = 'Chicago',
            County__c = 'Cook',
            MailingState = 'Nevada',
            MailingPostalCode  = '60654',
            Nbr_of_Adults__c = 2,
            Nbr_of_Minors__c = 2,
            Gender__c = 'Male',
            Ethnicity__c = 'Latino',
            Language__c = 'English',
            Marital__c	 = 'Widowed',
            Last_Four_SSN__c = 'test',
            Referred_By__c = 'Court',
            Employment_Status__c = 'Unemployed',
            Housing__c = 'Own Home',
            Military_Service__c = 'None',
            Branch__c = 'Navy',
            Rank__c = 'Officer',
            nbr_of_Deployments__c = '1',
            Entry_Date_text_yyyy__c = '2000',
            Exit_Date_text_yyyy__c = '2000',
            Military_Status__c = 'Former-Retired',
            VDisablity__c = 'None',
            Highest_Degree__c = 'None'
        );
        
        if (toCreateBadData) {
            con.Gender__c = 'test';
            con.Ethnicity__c = 'test';
            con.Language__c = 'test';
            con.Marital__c = 'test';
            con.County__c = 'Cook';
        }
        insert con;

        Case testCase = new Case(
            Subject = 'TestSubject',
            ContactId = con.Id
        );
        insert testCase;
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account ';
        testAccount.Server_Name__c = 'LegalAidChicago';
        testAccount.Legal_Server_Status__c = 'Production';
        if(toCreateBadData){
            testAccount.Legal_Server_Status__c = 'Test';
        }
        
        insert testAccount;

        Applied_Resource__c ap = new Applied_Resource__c();
        ap.Case__c = testCase.Id;
        ap.Account__c = testAccount.Id;
        ap.Type__c ='Legal Referrals';
        insert ap;
	}
}