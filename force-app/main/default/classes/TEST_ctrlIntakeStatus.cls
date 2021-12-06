@IsTest
public class TEST_ctrlIntakeStatus {
    
    
    @IsTest
    static void testGetAccountStatus() {
        
        
        Id resourceRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Resources').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Referral Partner'];
        
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.RecordTypeId = resourceRT;
        acc.Active__c = true;
        acc.Intake_Status__c = 'Closed';
        acc.Partner_Type__c = 'New Leaf';
        insert acc;
        
        Contact cnt = new Contact();
        cnt.LastName = 'test Name';
        insert cnt;
        
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com', ContactID = cnt.id);
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = acc.id;
        acr.ContactId = cnt.id;
        insert acr;
        
        String type = 'New Leaf';
        System.runAs(u) {
        	ctrlIntakeStatus.getAccountStatus(type);
        }
        
    }

}