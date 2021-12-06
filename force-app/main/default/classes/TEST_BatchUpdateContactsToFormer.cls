@isTest
public class TEST_BatchUpdateContactsToFormer {
    
    @testSetup
    static void setup() {
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i <100; i++) {
            contacts.add(new Contact(LastName = 'LastName'+i,
                                  FirstName='FirstName'+i, 
                                  Email='test'+i+'@theblogreaders.com',
                                  Last_Service_Date__c = Date.today().addMonths(-10),
                                  Category__c = 'Client',
                                  Status__c = 'Current' 
                                 ));
        }
        
        insert contacts;
    }
    
    static testmethod void test() {
        Test.startTest();
        BatchUpdateContactsToFormer lp = new BatchUpdateContactsToFormer();
        Id BatchId = Database.executeBatch(lp);
        Test.stopTest();
        System.assertEquals([select count() from Contact Where Status__c = 'Former'], 100);
    }
}