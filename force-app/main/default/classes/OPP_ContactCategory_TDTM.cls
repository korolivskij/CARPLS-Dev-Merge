global without sharing class OPP_ContactCategory_TDTM extends npsp.TDTM_Runnable {
          	
    /*******************************************************************************************************
    * @description Trigger Handler on Opportunities that handles updating the Category to include Donor
    * @param newList List of Contacts from trigger new. 
    * @param oldList List of Contacts from trigger old. 
    * @param triggerAction Which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult DescribeSObjectResult for Contacts 
    * @return dmlWrapper The objects to insert/update/delete
    * This class adds Donor to the category field of the Primary Contact on a new opportunity
    * after first checking if it is already selected.
    ********************************************************************************************************/
 	List<Opportunity> newOpps				= new List<Opportunity>();
	Set<Id>			contactIds				= new Set<Id>();
	List<Contact> 	contactsToCheck			= new List<Contact>();
	List<Contact>	contactsToUpdate		= new List<Contact>();
 
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
    	DmlWrapper dmlWrapper = new DmlWrapper();

    	newOpps = (List<Opportunity>)trigger.new;
    	
		for (Opportunity o : newOpps) {
			if (o.npsp__Primary_Contact__c != null) {
				contactIds.add(o.npsp__Primary_Contact__c);
			}    	
		}
		System.debug('in OPP_ContactCategory...calling refreshContactsList');
		refreshContactsList();
		for (Contact c : contactsToCheck) {
			System.debug('OPP_ContactCategory...in loop with contact '+c.name+' ,category '+c.category__c);
			if (String.isBlank(c.category__c)) {
				c.category__c = 'Donor';
				contactsToUpdate.add(c);
			} else if (!c.category__c.contains('Donor')) {
				c.category__c += ';Donor';
				contactsToUpdate.add(c);
			}
		}

		if (!contactsToUpdate.isEmpty()) {
    		dmlWrapper.objectsToUpdate.AddAll((List<SObject>)contactsToUpdate);
		}
    	return dmlWrapper;
	}
    public void refreshContactsList() {
    
        contactsToCheck = (
            [   select  c.id, c.category__c, name                   
                from    Contact c
                where id in :contactIds]);
        System.debug(logginglevel.info, 'contactList='+contactsToUpdate);             
    }  	
}