/****
**    Servio Consulting, LLC.
** Erica Cox
** 12/17/2016
**
** 
** 
** 
** Description: test ScheduleIncompleteToInquiry
****/
@isTest(SeeAllData=false)
public class TEST_ScheduleIncompleteToInquiry {

    public static   User                uTstExecUser                { get; set; }
    public static 	List<Id>			cIds = new List<Id>();
    
     public static testMethod void executeTest() {
        coreExecution('', '', '', '');
    }
    
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
        
        Datetime   dtTstStart        = Datetime.now();
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        
        buildTestData(); //<--- Build Any needed Contacts / caseparties...
        
        Test.startTest();
        Integer c = 0;
        
        System.runAs(uTstExecUser) {  
            
            c = [SELECT COUNT() FROM Contact where id = :cIds];
            System.debug('coreExecution-contacts.size():'+ c);
            System.assertEquals(5, c);
                   
	        new ScheduleIncompleteToInquiry().execute(null);

            c = [SELECT COUNT() FROM Contact where id = :cIds];
	        System.debug('before stopTest: ' + c);
        }
        Test.stopTest();

        List<Contact> cs = [SELECT category__c, Lastname, status__c  FROM Contact where id = :cIds order by lastname];
        for (Contact ca: cs) {
        	if (ca.lastname.contains('1'))
        		System.assert(ca.Category__c.contains('Inquiry'));        	
        	if (ca.lastname.contains('2'))
        		System.assertEquals('Inquiry', ca.Category__c);
        	//if (ca.lastname.contains('4'))
        	//	System.assertEquals('', ca.Category__c);
        	if (ca.lastname.contains('5'))
        		System.assertEquals('Client', ca.Category__c);
        		
        }
        
        System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
    }
    
    private static void buildTestData()
    {
        List<Contact> contacts = new List<Contact>();

        // category=client, status=Incomplete
        // Category --> Inquiry
        Contact contact1 = new Contact(LastName='TEST Contact LN 1', Status__c = 'Incomplete', Category__c = 'Client');
        contacts.add(contact1); 
                      
        // category = '', status = Incomplete
        // category --> Inquiry
        Contact contact2 = new Contact(LastName='TEST Contact LN 2', category__c = '', Status__c = 'Incomplete');
        contacts.add(contact2);
         
        // category=Donor;Staff;Client, status = Incomplete
        // category --> Donor;Staff;Inquiry
        Contact contact3 = new Contact(LastName='TEST Contact LN 3', category__c = 'Donor;Staff', Status__c = 'Incomplete');
        contacts.add(contact3);
        
        // category = '', status= Pending
        // category --> ''
        Contact contact4 = new Contact(LastName='TEST Contact LN 4', category__c = '', Status__c = 'Pending');
        contacts.add(contact4);

        // category = Client, status= Pending
        // category --> Client
        Contact contact5 = new Contact(LastName='TEST Contact LN 5', Category__c = 'Client', Status__c = 'Pending');
        contacts.add(contact5);
                 
    	insert contacts;
    	
    	// added for later assertion
    	for (Contact c: contacts) {
    		cIds.add(c.id);
    	}
                 
        List<Case_Party__c> cps = new List<Case_Party__c>();
         
        
        Case_Party__c cp = new Case_Party__c(contact__C = contact5.id, Primacy__C = 'Primary', Type__c = 'Client');
    	cps.add(cp);

        insert cps;
        
        /*
        List<Contact> lc = [SELECT Id,Category__c  FROM Contact];
        
        System.debug('buildTestData-contacts.size():'+ lc.size());
       
        for (Contact contact: lc) {
           System.debug('Contact2.ID:' + contact.Id + ', Contact2.Category__c:' + contact.Category__c);
		}
		*/
     }
   
}