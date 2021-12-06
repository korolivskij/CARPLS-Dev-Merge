/**
 * Created by thom on 6/28/18.
 */

@IsTest
global class LegalServerXmlCalloutTest {

    public static final Integer NUM_RECORDS = 10;

    public static String packageXmlOutputPreId = '<?xml version="1.0"?><matter><firstName>Thom</firstName>' +
            '<lastName>Behrens</lastName><addressHome><address1>1528 W Cortez St. Apartment G</address1>' +
            '<city>Chicago</city><state>IL</state><zip>60642</zip><county>17031</county></addressHome>' +
            '<phoneHome>(574) 229-5446</phoneHome><dateOfBirth>1994-02-10</dateOfBirth>' +
            '<email>thom.behrens94@gmail.com</email><maritalStatus>Common Law</maritalStatus><race>White</race>' +
            '<gender>Male</gender><language>English</language><veteran>true</veteran><disabled>true</disabled>' +
            '<eTransferOrganization>Legal Assistance Foundation of Metropolitan Chicago</eTransferOrganization>'+
            '<legalProblemCode>0110 Debtor\'s Relief</legalProblemCode>' +
            '<note>Boy oh boy do I love writing referral notes!</note><matter_xml_version>1</matter_xml_version>' +
            '<numberOfAdults>5</numberOfAdults><numberOfChildren>45</numberOfChildren><homeless>false</homeless>' +
            '<citizenshipStatus>Eligible Alien</citizenshipStatus><externalId>AFLAN-';

    public static String packageXmlOutputPostId = '</externalId><incomeType>Veterans\' Benefits</incomeType>' +
            '<incomeFrequency>12</incomeFrequency><incomeAmount>500000.00</incomeAmount></matter>';

    @IsTest
    public static void testCollectObjects() {
        List<Referral_Party__c> referralParties = buildTestCollectObjectsData();

        LegalServerXmlCalloutFactory testXmlCallout = new LegalServerXmlCalloutFactory();
        Test.startTest();
        testXmlCallout.collectObjects(referralParties);
        Test.stopTest();

        List<LegalServerXmlCallout> legalServerXmlCallouts = testXmlCallout.legalServerXmlCallouts;

        System.assertEquals(NUM_RECORDS, legalServerXmlCallouts.size());

        for (LegalServerXmlCallout eachLegalServerXmlCallout : legalServerXmlCallouts) {
            System.assertEquals(
                    eachLegalServerXmlCallout.contactRecord.Name,
                    eachLegalServerXmlCallout.appliedResource.Client_Name__c
            );
        }
    }

    @IsTest
    public static void testPackageXML() {
        List<Referral_Party__c> referralParties = buildPackageXmlData();

        LegalServerXmlCalloutFactory xmlCallout = new LegalServerXmlCalloutFactory();
        xmlCallout.collectObjects(referralParties);

        Test.startTest();
        xmlCallout.packageXml();
        Test.stopTest();

        String xmlOutput = xmlCallout.legalServerXmlCallouts[0].xmlOutput;
        System.debug('xmlOutput: ' + xmlOutput);
        System.assert(xmlOutput.contains(packageXmlOutputPreId));
        System.assert(xmlOutput.contains(packageXmlOutputPostId));
    }


    @IsTest static void testSend() {
        List<Referral_Party__c> referralParties = buildPackageXmlData();

        LegalServerXmlCalloutFactory xmlCallout = new LegalServerXmlCalloutFactory();
        xmlCallout.collectObjects(referralParties);

        xmlCallout.packageXml();

        Test.setMock(HttpCalloutMock.class, new LegalServerXmlCalloutMock());

        Test.startTest();
        xmlCallout.send();
        Test.stopTest();

        System.assertEquals(200, xmlCallout.legalServerXmlCallouts[0].responseStatusCode);
    }

    @IsTest static void testSendEmailNotification() {
        List<Referral_Party__c> referralParties = buildPackageXmlData();

        LegalServerXmlCalloutFactory xmlCallout = new LegalServerXmlCalloutFactory();
        xmlCallout.collectObjects(referralParties);


        xmlCallout.packageXml();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LegalServerXmlCalloutMock());
        xmlCallout.send();

        xmlCallout.sendEmailNotification();

        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(0, invocations);

    }

    @IsTest static void testSendEmailNotificationBadPacket() {
        List<Referral_Party__c> referralParties = buildPackageXmlData();

        LegalServerXmlCalloutFactory xmlCallout = new LegalServerXmlCalloutFactory();
        xmlCallout.collectObjects(referralParties);

        xmlCallout.packageXml();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LegalServerXmlCalloutMock());
        xmlCallout.send();

        xmlCallout.legalServerXmlCallouts[0].responseStatusCode = 999;
        xmlCallout.legalServerXmlCallouts[0].emailMessage = 'failure';

        xmlCallout.sendEmailNotification();

        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations);
    }

    public static List<Referral_Party__c> buildTestCollectObjectsData() {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < NUM_RECORDS; i++) {
            contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + i
            ));
        }
        insert contacts;

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < NUM_RECORDS; i++) {
            cases.add(new Case(
                    Description = 'Case for ' + contacts.get(i).Name,
                    ContactId = contacts.get(i).Id
            ));
        }
        insert cases;

        List<Applied_Resource__c> appliedResources = new List<Applied_Resource__c>();
        for (Integer i = 0; i < NUM_RECORDS; i++) {
            appliedResources.add(new Applied_Resource__c(
                    Case__c = cases.get(i).Id
            ));
        }
        insert appliedResources;

        List<Referral_Party__c> referralParties = new List<Referral_Party__c>();
        for (Integer i = 0; i < NUM_RECORDS; i++) {
            referralParties.add(new Referral_Party__c(
                    Party__c = contacts.get(i).Id,
                    Referral__c = appliedResources.get(i).Id
            ));
        }
        return referralParties;
    }

    public static List<Referral_Party__c> buildPackageXmlData() {

        Account accountRecord = new Account(
                Name = 'LAF Veteran\'s Rights Project IL-AFLAN'
        );
        insert accountRecord;

        Contact myContact = new Contact(
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
                Housing__c = 'Private Housing Rental'
        );
        insert myContact;

        Income_Detail__c incomeDetail1 = new Income_Detail__c(
                Contact__c = myContact.Id,
                Income_Type__c = 'Income - Veteran Related Benefits',
                Frequency__c = 'Monthly',
                Amount__c = 500000.00
        );

        Income_Detail__c incomeDetail2 = new Income_Detail__c(
                Contact__c = myContact.Id,
                Income_Type__c = 'Income - Other Income',
                Amount__c = 10.00
        );
        insert new List<Income_Detail__c>{
                incomeDetail1, incomeDetail2
        };

        Case myCase = new Case(
                Description = 'Case for Thom',
                ContactId = myContact.Id,
                Problem_Category__c = 'General Consumer Debt - Debtor'
        );
        insert myCase;

        Applied_Resource__c appliedResource = new Applied_Resource__c(
                Case__c = myCase.Id,
                IL_AFLAN_Referral_Note__c = 'Boy oh boy do I love writing referral notes!',
                Account__c = accountRecord.Id
        );
        insert appliedResource;

        Referral_Party__c referralParty = new Referral_Party__c(
                Party__c = myContact.Id,
                Referral__c = appliedResource.Id
        );
        return new List<Referral_Party__c>{
                referralParty
        };
    }


}