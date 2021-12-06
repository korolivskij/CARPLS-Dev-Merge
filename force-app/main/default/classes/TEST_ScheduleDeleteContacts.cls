/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/28/10
**
** Rev. ELC 12/17/2016 - changed to reflect split of scheduled jobs for contact cleanup
** 
** 
** Description: test ScheduleDeleteContacts
****/
@isTest(SeeAllData=false)
public class TEST_ScheduleDeleteContacts {

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
            System.assertEquals(3, c);
                   
	        new ScheduleDeleteContacts().execute(null);

            c = [SELECT COUNT() FROM Contact where id = :cIds];
	        System.debug('before stopTest: ' + c);
        }
        Test.stopTest();

        c = [SELECT COUNT() FROM Contact where id = :cIds];
        System.debug('after stopTest: ' + c);
        System.assertEquals(2, c);
        
        System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
    }
    
    private static void buildTestData()
    {
        List<Contact> contacts = new List<Contact>();
        // All contacts with a null or empty category and no case party records should be deleted.
        // Total:                3
        // should be removed:    1
        // should not be removed:2
        
        // category=null, no cp, has donation data
        // should not be removed
        Contact contact1 = new Contact(LastName='TEST Contact LN 5', Status__c = 'Current', npo02__TotalOppAmount__c = 20.0);
        contacts.add(contact1); 
                      
        //no category, no cp
        //should be removed
        Contact contact4 = new Contact(LastName='TEST Contact LN 4', category__c = '', Status__c = 'Current');
        contacts.add(contact4);
         
        // category=null, has cp
        // should not be removed
        Contact contact5 = new Contact(LastName='TEST Contact LN 5', category__c = 'Client;Staff', Status__c = 'Current');
        contacts.add(contact5);

         
    	insert contacts;
    	// defaults to Donor, so need to set it back to null
    	contact4.category__c = null;
    	update contact4;
    	
    	// added for later assertion
    	for (Contact c: contacts) {
    		cIds.add(c.id);
    	}
                 
        List<Case_Party__c> cps = new List<Case_Party__c>();
         
        
        Case_Party__c cp = new Case_Party__c(contact__C = contact5.id, Primacy__C = 'Primary', Type__c = 'Other');
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