/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */

@isTest
private class TEST_ScheduleUpdateContacts {
	
	public static Contact	newContact	{get; set;}


    static testMethod void scheduleUpdateContactsTest() {
        // 
		
		buildTestData();
		
		Test.startTest();

		new ScheduleUpdateContacts().execute(null);
		
   		Test.stopTest();

		Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Status__c
														  FROM Contact]);

		System.assertEquals(contactMap.get(clientNowContact.Id).Status__c,'Current');
		System.assertEquals(contactMap.get(attorneyFourMonthContact.Id).Status__c,'Current');
		System.assertEquals(contactMap.get(clientFourMonthContact.Id).Status__c,'Current');
		System.assertEquals(contactMap.get(attorneyOneYearContact.Id).Status__c,'Current');
		System.assertEquals(contactMap.get(clientOneYearContact.Id).Status__c,'Former');
		System.assertEquals(contactMap.get(volunteerOneYearContact.Id).Status__c,'Current');
		System.assertEquals(contactMap.get(donor9MonthContact.Id).Status__c,'Current');


	}

    private static Contact clientNowContact, attorneyFourMonthContact, clientFourMonthContact, attorneyOneYearContact,
		clientOneYearContact, volunteerOneYearContact, donor9MonthContact;

	private static void buildTestData() {    
    	List<Contact> testContacts = new List<Contact>();
        clientNowContact = new Contact( firstname = '0',
        							lastname='Zero', 
        							Last_Service_Date__c=Datetime.now(), 
        							Category__c='Client', 
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(clientNowContact);  // Should remain Current

        attorneyFourMonthContact = new Contact( firstname='1', 
        							lastname='One', 
									Last_Service_Date__c=DateTime.now().addMonths(-4), 
        							Category__c='Attorney', 
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(attorneyFourMonthContact);// Should remain Current

        clientFourMonthContact = new Contact( firstname='2', 
        							lastname='Two', 
									Last_Service_Date__c=DateTime.now().addMonths(-4), 
        							Category__c='Client', 
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(clientFourMonthContact);// Should remain Current

        attorneyOneYearContact = new Contact( firstname='3', 
        							lastname='Three', 
									Last_Service_Date__c=DateTime.now().addYears(-1), 
        							Category__c='Attorney', 
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(attorneyOneYearContact);// Should remain Current

	    clientOneYearContact = new Contact( firstname='4', 
        							lastname='Four', 
									Last_Service_Date__c=DateTime.now().addYears(-1), 
        							Category__c='Client', 
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(clientOneYearContact);// Should be updated to Former

	    volunteerOneYearContact = new Contact( firstname='5', 
        							lastname='Five', 
									Last_Service_Date__c=DateTime.now().addYears(-1), 
        							Category__c='Volunteer', 
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(volunteerOneYearContact);// Should remain Current

        donor9MonthContact = new Contact( firstname='6', 
        							lastname='Six', 
									Last_Service_Date__c=DateTime.now().addMonths(-9), 
        							Category__c='Donor',
        							Status__c='Current', 
        							email='plinyplatypus@gmail.com');
        testContacts.add(donor9MonthContact);// Should remain Current

        insert testContacts;

    }  	
}