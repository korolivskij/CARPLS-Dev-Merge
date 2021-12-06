/**
 * Created by thom on 7/17/18.
 */

@IsTest
private class AppliedResourceGeneratorTest {

    // This class is only testing the existance of objects. It is not testing their contents, as the class is meant to
    // be used as a flexible utility, and we do not want to create any uneeded dependencies, especially if any are
    // created via changing process automation tools

    @IsTest
    static void testBehavior() {

        Test.startTest();
        AppliedResourceGenerator.generateAccountInfo();
        AppliedResourceGenerator.generateClientContactInfo();
        AppliedResourceGenerator.generateCaseInfo();
        AppliedResourceGenerator.generateAppliedResourceInfo();
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        Account accountRecord = (accounts.size() == 1) ? accounts.get(0) : null;
        System.assertNotEquals(null, accountRecord);

        List<Zip__c> zips = [SELECT Id FROM Zip__c LIMIT 1];
        Zip__c zip = (zips.size() == 1) ? zips.get(0) : null;
        System.assertNotEquals(null, zip);

        List<Account_Zip_Junction__c> accountZipJunctions = [SELECT Id FROM Account_Zip_Junction__c LIMIT 1];
        Account_Zip_Junction__c accountZipJunction = (accountZipJunctions.size() == 1) ? accountZipJunctions.get(0) : null;
        System.assertNotEquals(null, accountZipJunction);

        List<Eligible_Problem_Codes__c> eligibleProblemCodes = [SELECT Id FROM Eligible_Problem_Codes__c LIMIT 1];
        Eligible_Problem_Codes__c eligibleProblemCode = (eligibleProblemCodes.size() == 1) ? eligibleProblemCodes.get(0) : null;
        System.assertNotEquals(null, eligibleProblemCode);

        List<Subject__c> subjects = [SELECT Id FROM Subject__c LIMIT 1];
        Subject__c subject = (subjects.size() == 1) ? subjects.get(0) : null;
        System.assertNotEquals(null, subject);

        List<Account_Subject_Junction__c> accountSubjectJunctions = [SELECT Id FROM Account_Subject_Junction__c LIMIT 1];
        Account_Subject_Junction__c accountSubjectJunction = (accountSubjectJunctions.size() == 1) ? accountSubjectJunctions.get(0) : null;
        System.assertNotEquals(null, accountSubjectJunction);

        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        Contact contactRecord = (contacts.size() == 1) ? contacts.get(0) : null;
        System.assertNotEquals(null, contactRecord);

        List<Income_Detail__c> incomeDetails = [SELECT Id FROM Income_Detail__c];
        System.assertEquals(2, incomeDetails.size());

        List<Case> cases = [SELECT Id FROM Case LIMIT 1];
        Case caseRecord = (cases.size() == 1) ? cases.get(0) : null;
        System.assertNotEquals(null, caseRecord);

        List<Applied_Resource__c> appliedResources = [SELECT Id FROM Applied_Resource__c LIMIT 1];
        Applied_Resource__c appliedResource = (appliedResources.size() == 1) ? appliedResources.get(0) : null;
        System.assertNotEquals(null, appliedResource);

        List<Referral_Party__c> referralParties = [SELECT Id FROM Referral_Party__c LIMIT 1];
        Referral_Party__c referralParty = (referralParties.size() == 1) ? referralParties.get(0) : null;
        System.assertNotEquals(null, referralParty);
    }
}