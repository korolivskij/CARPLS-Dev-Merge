/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/26/09
**
** Rev. 2016/26/09: created
** Rev. 2016/13/10: assert contacts aren't changed
** Usage: Test BatchDeleteCases class
** 
** Description: 
****/
@isTest(SeeAllData=false)
private class TEST_BatchDeleteCases {

    static testmethod void test() {
        
        String email = 'alex.grinevich@gnc-international.com';
        List<String> lEmails = new List<String> { email };
            
        // The query used by the batch job.
        String query = 'select c.ID  from Case c where '
                   + ' Contact.Category__c INCLUDES(\'Inquiry\') and Contact.Status__c = \'Incomplete\''
                   + ' and c.ID not in (select Case__c from Consultation__c)'
                   + ' and CreatedDate = LAST_N_DAYS:1';
       

       // Create some test items to be deleted
       //   by the batch job.
	   buildTestData();
        
       List<Case> cases = [select c.ID  from Case c where Contact.Category__c INCLUDES('Inquiry') and Contact.Status__c = 'Incomplete'
                            and c.ID not in (select Case__c from Consultation__c) and CreatedDate = LAST_N_DAYS:1];
        
       System.debug('Cases by criteria list size:' + cases.size());
        
       List<Contact> contacts = [select ID, Category__c, Status__c   from Contact where Category__c INCLUDES('Inquiry') and Contact.Status__c = 'Incomplete'];
        
        Integer contactssize = contacts.size();
        
       System.debug('Contacts with Inquiry and Incomplete. Before:' + contacts.size());
       
       Test.startTest();
       BatchDeleteCases c = new BatchDeleteCases(query, lEmails);
       Database.executeBatch(c);
       Test.stopTest();

       Integer i = [SELECT COUNT() from Case c where 
                    Contact.Category__c INCLUDES('Inquiry') and Contact.Status__c = 'Incomplete'
                     and c.ID not in (select Case__c from Consultation__c)
                     and CreatedDate > LAST_N_DAYS:1];
        
        Integer j = [SELECT COUNT() from Case ];
        
        contacts = [select ID, Category__c, Status__c   from Contact where Category__c INCLUDES('Inquiry') and Contact.Status__c = 'Incomplete'];
        
        System.debug('Contacts with Inquiry and Incomplete. After:' + contacts.size());
        System.assertEquals(contactssize, contacts.size());// Contacts shouldn't be modified
        
        System.debug('Total Cases:' + j);
        System.debug('Cases w/o service:' + i);
        
       System.assertEquals(i, 0);
    }
    
     private static void buildTestData() {
         
        //List<Contact> contacts = new List<Contact>();
    	Contact c1 = new Contact(LastName='TEST Contact LN 1', category__c = 'Inquiry', Status__c = 'Incomplete');
    	//contacts.add(c1);
    	insert c1;
         
        Case cse = new Case();//should not be deleted by batch class
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');         
		cse = new Case(	ContactId = c1.id,subject='Test Case',project__c='TEST PROJECT A', Origin='TEST Origin', 
						description = ' TEST DESC', recordtypeId=rt.id);	
		cse.Practice_Area__c = 'pa1';
		cse.Problem_Category__c = 'pcat1';
		cse.Problem_Code__c = 'pc1';	
         
        insert cse;
         
        Consultation__c cons    = new Consultation__c();
        cons.Case__c = cse.id;
        cons.Status__c = 'Open';
        cons.Subject__c = 'Service ' + string.valueOf(date.today());
        cons.Consultation_Category__c = cse.Practice_Area__c + '_' +
                                                        cse.Problem_Category__c + '_' + cse.Problem_Code__c;
        cons.last_contact__c = date.today();
        cons.contact_xx__c = cse.contactId;  
         
        insert cons;
                  
        Case cse2 = new Case();//should be deleted by batch class
     
		cse2 = new Case(	ContactId = c1.id,subject='Test Case 2',project__c='TEST PROJECT A', Origin='TEST Origin', 
						description = ' TEST DESC 2', recordtypeId=rt.id);	
		cse2.Practice_Area__c = 'pa1';
		cse2.Problem_Category__c = 'pcat1';
		cse2.Problem_Code__c = 'pc1';	
         
        insert cse2;
        
         
       
            
       /*
       for (Integer i=0;i<10;i++) {
           Contact c = new Contact(
               Name='Contact ' + i);
           contacts.add(c);
       }
		*/
       //insert contacts;
         
         

     }
}