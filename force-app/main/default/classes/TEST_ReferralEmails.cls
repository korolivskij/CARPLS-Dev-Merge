@isTest
/**
 * @TODO toggle custom metadata types so we can cover more use cases.
 * This is kinda a pain in the ass the the way salesforce prevents an update on a MDT.
 * and requires redic hacks..
 */
public class TEST_ReferralEmails {
    @testSetup static void setup() {


        Contact newClient;
        newClient = TEST_TestUtils.createContact('Client');
        newClient = [select id, county__c from contact where id = :newClient.id];
        newClient.county__c = 'Rock Island'; //west region.....
        update newClient;

        Subject__c newSubject;
        newSubject = new Subject__c();
        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'jur1';
        newSubject.Status__c = 'Active';
        newSubject.Type__c = 'Pending';
        newSubject.Litigation__c = 'Pending';
        insert newSubject;

        Search_Log__c newSlClient;
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;

        Case newCase;
        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCase.problem_code__c = 'pc1';
        update newCase;
    }
    /**
     *
     */
    static testMethod void testReferralEmail_noDepartmentFiltering_Success() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'batman',
                Email='test@forceledger.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        List<OutBound_Emails__mdt> outboundEmailMdts = CustomMdtUtil.getOutboundEmailsMdts(true,'New Referral');
        system.debug('===== email mdt='+outboundEmailMdts);

        system.runAs(portalAccountOwner1) {

            Test.startTest();

            Account newAcct = new Account(  Name = 'Test Community Acct', ownerid = portalAccountOwner1.id,
                                            Sub_Type__c = 'Legal Aid', 	Military_Service__c = true);
            insert newAcct;

            Contact newContact = new Contact(   FirstName = 'commAcctUserFirst' ,LastName = 'commAcctUserLast',
                    AccountId = newAcct.id, Email = System.now().millisecond() + 'test@test.com');
            insert newContact;
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            User portalUser = createUser(portalProfile.id, newContact.id);
            //insert(portalUser);


            Case cse = [select id from case limit 1];

            Applied_Resource__c ar1 = new Applied_Resource__c();
            ar1.case__c = cse.id;
            //ar2.recordtypeid = '0121D0000004LAH';
            ar1.type__c = 'Legal Referrals';
            ar1.account__c = newAcct.id;
            ar1.title__C = 'Test Legal PSLA 5';
            Insert ar1;

            Test.stopTest();
        }
    }

    static User createUser(Id profileId, Id contactId) {
        User user = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contactId,
                ProfileId = profileId,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                Enable_Email_Notifications_for_Referrals__c = true
        );
        return user;
    }
    public static SObject getMetadata(SObjectType metadataSObjectType, Map<String, Object> fields) {
        Map<String, Object> jsonFields = new Map<String, Object> {
                'attributes' => new Map<String, Object> {
                        'type' => metadataSObjectType.getDescribe().getName()
                }
        };
        if(fields != null) {
            jsonFields.putAll(fields);
        }
        return (SObject) JSON.deserialize(JSON.serialize(jsonFields), SObject.class);
    }
}