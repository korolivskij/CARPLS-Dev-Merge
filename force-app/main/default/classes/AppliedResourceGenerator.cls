/**
 * Created by thom on 7/13/18.
 */

public with sharing class AppliedResourceGenerator {

    public static Account accountRecord;
    public static Contact clientContact;
    public static Subject__c subject;
    public static Case caseRecord;

    public AppliedResourceGenerator() {

        generateAccountInfo();
        generateClientContactInfo();
        generateCaseInfo();
        generateAppliedResourceInfo();
    }

    public static void generateAccountInfo() {
        accountRecord = new Account(
                Name = 'Chicago Volunteer Legal Services Veterans Project IL-AFLAN',
                Active__c = true,
                Type = 'Legal Referral',
                Intake_Status__c = 'Open',
                Sub_Type__c = 'Legal Aid',
                Geographic_Region__c = 'Cook IL',
                Languages__c = 'English',
                Military_Service__c = true,
                RecordTypeId = getRecordTypeIdByName('Account', 'Organization')
        );
        insert accountRecord;

        Zip__c zip = new Zip__c(
                City__c = 'Chicago',
                Name = '60642',
                Geographic_Region__c = 'Chicago'
        );
        insert zip;

        Account_Zip_Junction__c accountZipJunction = new Account_Zip_Junction__c(
                Account__c = accountRecord.Id,
                Zip__c = zip.Id
        );
        insert accountZipJunction;

        Eligible_Problem_Codes__c eligibleProblemCode = new Eligible_Problem_Codes__c(
                Practice_Area__c = 'Public Benefits/Health',
                Problem_Category__c = 'SSDI',
                Problem_Code__c = 'Application/Eligibility',
                Account__c = accountRecord.Id
        );
        insert eligibleProblemCode;

        subject = new Subject__c(
                Title__c = 'Complaint about prepaid money card',
                Practice_Area__c = 'Public Benefits/Health',
                Problem_Category__c = 'SSDI',
                Problem_Code__c = 'Application/Eligibility',
                Status__c = 'Active',
                Type__c = 'Published',
                Litigation__c = 'Pre Litigation'
        );
        insert subject;

        Account_Subject_Junction__c accountSubjectJunction = new Account_Subject_Junction__c(
                Account__c = accountRecord.Id,
                Subject__c = subject.Id
        );
        insert accountSubjectJunction;
    }

    public static void generateClientContactInfo() {
        clientContact = new Contact(
                FirstName = 'Thom',
                LastName = 'Behrens',
                MailingStreet = '1528 W Cortez St. Apartment G',
                MailingCity = 'Chicago',
                MailingState = 'Illinois',
                MailingPostalCode = '60642',
                County__c = 'Cook',
                Phone = '(574) 229-5446',
                Birthdate = Date.newInstance(1994, 02, 10),
                Email = 'thom.behrens94@gmail.com',
                Marital__c = 'Civil Union',
                Ethnicity__c = 'White',
                Gender__c = 'Male',
                Language__c = 'English',
                Veteran_Status__c = 'Current',
                Disability__c = 'Hearing',
                Nbr_of_Adults__c = 5,
                Nbr_of_Minors__c = 45,
                Citizenship__c = 'Documented',
                Housing__c = 'Private Housing Rental',
                Region__c = 'Cook',
                Military_Service__c = 'Service Member',
                Rank__c = 'Enlisted'

        );
        insert clientContact;

        Income_Detail__c incomeDetail1 = new Income_Detail__c(
                Contact__c = clientContact.Id,
                Income_Type__c = 'Income - Veteran Related Benefits',
                Frequency__c = 'Monthly',
                Amount__c = 500.00
        );

        Income_Detail__c incomeDetail2 = new Income_Detail__c(
                Contact__c = clientContact.Id,
                Income_Type__c = 'Income - Other Income',
                Amount__c = 10.00
        );
        insert new List<Income_Detail__c>{
                incomeDetail1, incomeDetail2
        };
    }

    public static void generateCaseInfo() {
        caseRecord = new Case(
                ContactId = clientContact.Id,
                Practice_Area__c = 'Public Benefits/Health',
                Problem_Category__c = 'SSDI',
                Problem_Code__c = 'Application/Eligibility',
                Project__c = 'IL-AFLAN Hotline',
                Selected_Subject__c = subject.Id,
                Status = 'Open',
                AccountId = accountRecord.Id
        );
        insert caseRecord;
    }

    public static void generateAppliedResourceInfo() {
        Applied_Resource__c appliedResource = new Applied_Resource__c(
                Title__c = 'Chicago Volunteer Legal Services Veterans Project IL-AFLAN',
                Case__c = caseRecord.Id,
                Status__c = 'Applied',
                Type__c = 'Legal Referrals',
                Account__c = accountRecord.Id,
                RecordTypeId = getRecordTypeIdByName('Applied_Resource__c', 'E Referral Pending')
        );
        insert appliedResource;

        Referral_Party__c referralParty = new Referral_Party__c(
                Party__c = clientContact.Id,
                Referral__c = appliedResource.Id
        );
        insert referralParty;
    }

    public static String getRecordTypeIdByName(String objectNameString, String developerName) {
        Id recordTypeId = Schema.getGlobalDescribe().get(objectNameString).getDescribe().getRecordTypeInfosByName()
                .get(developerName).getRecordTypeId();
        return recordTypeId;

    }


}