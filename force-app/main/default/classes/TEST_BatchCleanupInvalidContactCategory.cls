/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/26/09
**
** Rev. 2016/26/09: created
** Rev. 2016/12/17: Revised to reflect breakup of scheduled job - ELC
** 
** Usage: Test BatchCleanupInvalidContactCategory class
** 
** Description: 
****/
@isTest(SeeAllData=false)
public class TEST_BatchCleanupInvalidContactCategory {

	
	
     public static testMethod void test() {
        
       String email = 'alex.grinevich@gnc-international.com';
       List<String> lEmails = new List<String> { email };
            
        // The query used by the batch job.
       String query1 = 'SELECT ID, Category__c FROM Contact WHERE Category__c INCLUDES(\'Party\') '
            +' and ID not in (SELECT Contact__c from Case_Party__c WHERE Type__c in(\'Adverse party\',\'Interested party\',\'Attorney\'))';
        
       String query2 = 'SELECT ID, Category__c FROM Contact '
        	+' WHERE Category__c INCLUDES(\'Client\') '         
            +' and ID not in (SELECT Contact__c from Case_Party__c WHERE Type__c = \'Client\')';
       
	   List<Id> cIds = buildTestData();
        
       Integer i = [SELECT COUNT() from Contact where id = :cIds];
       System.debug('Total contacts count:' + i);
       System.assertEquals(6, i, 'Total contacts count');
               
       Test.startTest();
       
       BatchCleanupInvalidContactCategory bc1 = new BatchCleanupInvalidContactCategory(query1,'Party', lEmails);
       Database.executeBatch(bc1);
        
       //BatchCleanupInvalidContactCategory bc2 = new BatchCleanupInvalidContactCategory(query2,'Client', lEmails);
       //Database.executeBatch(bc2);
        
       Test.stopTest();
        
        List<Contact> cs = [SELECT category__c, Lastname, status__c  FROM Contact where id = :cIds order by lastname];
        for (Contact ca: cs) {
        	if (ca.lastname.contains('1'))
        		System.assertEquals(null, ca.Category__c);        	
        	if (ca.lastname.contains('2'))
        		System.assertEquals('Staff', ca.Category__c);
        	if (ca.lastname.contains('3'))
        		System.assertEquals('Party', ca.Category__c);        		

        }        		
    }
    
     private static List<Id> buildTestData() {
         
        List<Contact> contacts = new List<Contact>();
    	Contact contact1 = new Contact(LastName='TEST Contact LN 1', category__c = 'Party');//should be removed
        contacts.add(contact1);//no CaseParty records with Type in (‘Adverse Party’,‘Interested Party’)
        
        Contact contact2 = new Contact(LastName='TEST Contact LN 2', category__c = 'Party;Staff');//should be removed 'Party'
        contacts.add(contact2);//no CaseParty records with Type in (‘Adverse Party’,‘Interested Party’)
         
        Contact contact3 = new Contact(LastName='TEST Contact LN 3', category__c = 'Party');//should not be removed
        contacts.add(contact3);//with CaseParty records with Type in (‘Adverse Party’,‘Interested Party’)
        
        Contact contact4 = new Contact(LastName='TEST Contact LN 4', category__c = 'Client');
        contacts.add(contact4);// w/o case, new category should be null
         
        Contact contact5 = new Contact(LastName='TEST Contact LN 5', category__c = 'Client;Donor', Status__c = 'Current');
        contacts.add(contact5);// w/o case, new category should be as: 'Donor'
         
        Contact contact6 = new Contact(LastName='TEST Contact LN 6', category__c = 'Client;Donor', Status__c = 'Current');
        contacts.add(contact6);// with case, category should not be changed
         
    	insert contacts;

		// build list of Ids for assertions
		List<Id> pIds = new List<Id>();
		for (Contact c: contacts) {
			pIds.add(c.id);
		}                 
        List<Case> cases = new List<Case>();
        
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');   
         
		Case cse1 = new Case(	ContactId = contact6.id,subject='Test Case',project__c='TEST PROJECT A', Origin='TEST Origin', 
						description = ' TEST DESC', recordtypeId=rt.id, Practice_Area__c = 'pa1',
                      Problem_Category__c = 'pcat1', Problem_Code__c = 'pc1');	
        cases.add(cse1);
         
         
         Case cse2 = new Case(	ContactId = contact2.id,subject='Test Case',project__c='TEST PROJECT A', Origin='TEST Origin', 
                             description = ' TEST DESC 2', recordtypeId=rt.id, Practice_Area__c = 'pa1',
                             Problem_Category__c = 'pcat1', Problem_Code__c = 'pc1');	
        cases.add(cse2);
         /*
        Case cse3 = new Case(	ContactId = contact3.id,subject='Test Case',project__c='TEST PROJECT A', Origin='TEST Origin', 
                             description = ' TEST DESC 3', recordtypeId=rt.id, Practice_Area__c = 'pa1',
                             Problem_Category__c = 'pcat1', Problem_Code__c = 'pc1');	
        cases.add(cse3);
         */
        insert cases;
         
        List<Case_Party__c> cps = new List<Case_Party__c>();
         
        Case_Party__c cp = new Case_Party__c(contact__C = contact3.id, /*case__C = cse1.id,*/ Primacy__C = 'Primary',
                                            Type__c = 'Adverse Party');
    	cps.add(cp);
         
        cp = new Case_Party__c(contact__C = contact2.id, case__C = cse2.id, Primacy__C = 'Primary',
                                            Type__c = 'Other');
    	cps.add(cp);

        cp = new Case_Party__c(contact__C = contact6.id, case__C = cse1.id, Primacy__C = 'Primary',
                                            Type__c = 'Client');
    	cps.add(cp);
        insert cps;
         
		return pIds;
     }
}