/*
**	This class will change the status on the Contact record to 
**	Former if the Last_Service_Date__c field is more than 6 months in the past. 
**	This only touches those records with a Category of Client. 
**	Note: category is a multi-select picklist
**  Class is deprecated and replaced with BatchUpdateContactsToFormer.cls 
**  by Sergii Korolivskyi at 10/26/2020
*/


public with sharing class UpdateContactsToFormer {
    
    public UpdateContactsToFormer() {
        
        processContacts();
    }
    
    
    private void processContacts() {
        
        List<Contact> contacts;
       
                contacts = [SELECT Id
                            FROM Contact
                            WHERE Last_Service_Date__c < LAST_N_MONTHS:6
                            AND Category__c INCLUDES ('Client')
                            AND Status__c <> 'Former'];
        
        for (Contact c : contacts) {
            c.Status__c = 'Former';
        }
        
        try {
            update contacts;
        } catch (Exception e) {
            System.debug('Exception in UpdateContactsToFormer when updating contacts '+e);
        }
    }
}