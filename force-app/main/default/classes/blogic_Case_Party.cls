global class blogic_Case_Party {
      
    public static void updateName(list<Case_Party__c> newCaseParties){
        map<Id,set<id>> caseContacts = new map<Id,set<id>>();
        list<Case_Party__c> oldPartiesToDelete = new list<Case_Party__c>();
        for (Case_Party__c cp : newCaseParties){
        	if(cp.Primacy__c == null) {
        		System.debug(logginglevel.warn, 'skipping update of name of cp record because primacy is null cp record='+cp); 
        		continue;
        	}
        	if(cp.Type__c == null) {
        		System.debug(logginglevel.warn, 'skipping update of name of cp record because type is null cp record='+cp); 
        		continue;
        	}
            cp.Name = cp.Primacy__c.replace(' ','').trim().toLowerCase() + cp.Type__c.replace(' ','').trim().toLowerCase() + cp.Case__c;
            if (!caseContacts.containsKey(cp.case__c)){
                caseContacts.put(cp.case__c, new set<id>());
            }
            caseContacts.get(cp.case__c).add(cp.contact__c);
        }
        List<Case_Party__c> matchingCases = [SELECT Id, Contact__c, Case__c FROM Case_Party__c WHERE Case__c in:caseContacts.keyset() AND ID not in :newCaseParties];
        for (Case_Party__c cp : matchingCases) {
            if(caseContacts.get(cp.case__c).contains(cp.contact__c)){
                oldPartiesToDelete.add(cp);
            }
        }
        if (oldPartiesToDelete.size() > 0){
            delete oldPartiesToDelete;
        }
        
    }
	/**
	 *	For the passed list of caseParty objects, seek on the associated contact records
	 *  and update the contact.category__c field if necessary.
	 *
	 *  What makes this so complicated is the need for bulkprocessing. and multiple loops albeit
	 *  it should be fast as there is only 1 query executed.
	 *
	 *  1. Roll through all the case parties and store in a map of contactId, List of Types.. (ie associations).
	 *  2. Get the keys.. contacIds from the Map and use to select possible contact records to update.
	 *  3. IF the case party type is of interested party or associated party go back to the contact record.
	 *     and ensure the contact record has as part of it's category labeled Party.
	 *  4. If the case party type is of Attorney go back to the contact record and
	 *     ensure the contact record has as part of it's category labeled Attorney.
	 *	5. If the case party type is of Client go back to the contact record and
	 *	   ensure the contact record has as part of it's category labeled Client.  // added ELC 8/14
	 *  6. Return Contact Ids updated.
	 *
	 *  @parm the list of Case_party__c records to evaluate.
	 *  @returns a Set<Id> of any contact Ids that were updated. 
	 *
	 *  @TODO write method that listens for delete of Case party, then seeks out all of case party 
	 *  records associated to the contact, if none, or if none are flagged as interested or adverse party
	 *  remove the party categoery from the contact.
	 *
	 */	
	public static Set<Id> updateContactCategories(list<Case_Party__c> caseParties) {
		
		Set<Id> contactIdsUpdated;
		if(caseParties == null || caseParties.isEmpty()) {
			System.debug(LoggingLevel.WARN,'Case Party LIST passed is null or empty.. nothing to do');
			return null;	
		}		
		
		Map<Id,Contact> m_ContactId_Contact = new Map<Id,Contact>(); 
		Map<Id,Set<String>> mContactId_Categories = new Map<Id,Set<String>>();
		
		Set<Id> contactIds = new Set<Id>();
		for(Case_Party__c cp : caseParties) {
			if(!mContactId_Categories.containsKey(cp.contact__c)) {
				mContactId_Categories.put(cp.contact__c, new Set<String> {cp.type__c});
			} else {
				Set<String> storedAssociations = mContactId_Categories.get(cp.contact__c);
				if(!storedAssociations.contains(cp.type__c)) {
					storedAssociations.add(cp.type__c);
					mContactId_Categories.put(cp.contact__c, storedAssociations);
				}
			}
		}		
		if(!mContactId_Categories.isEmpty() ) {
			Set<Id> contactIdsToFind = mContactId_Categories.keySet();
			List<Contact> contacts = [select Id, category__c, type__c from Contact where Id in :contactIdsToFind];
			Boolean bAnyContactsChanged = false;
			for(Contact c : contacts) {
				Set<String> contactAssociations = mContactId_Categories.get(c.Id);
				String newCategory = '';
				Boolean bContactCategoryChanged = false;
				
				if(c.category__c != null) {
					for(String assoc : contactAssociations) {
						// added Other here to account for those migrated CaseParty records with that designation
						if(assoc == 'Adverse Party' || assoc == 'Interested Party' || assoc =='AP' || assoc == 'Other') {
							if(!c.category__c.contains('Party')) {
								newCategory = c.category__c + ';' + 'Party;';
								bContactCategoryChanged = true;
								break;
							}
						}
						if(assoc == 'Attorney') {
							if(!c.category__c.contains('Attorney')) {
								newCategory = c.category__c + ';' + 'Attorney;';
								bContactCategoryChanged = true;
								break;
							}
						}	
						// ELC - Added in insert of Client to Category.  Needed for those instances
						// in which an existing party is now added as a client.
						if(assoc == 'Client') {
							if(!c.category__c.contains('Client')) {
								if (c.category__c.contains('Inquiry')) {
									newCategory = c.category__c.replace('Inquiry','Client');
									bContactCategoryChanged = true;
									break;
								} else {
									newCategory = c.category__c + ';' + 'Client;';
									bContactCategoryChanged = true;
									break;
								}
							}
						}					
					}
				} else {					
					for(String assoc : contactAssociations) {
						if(assoc == 'Adverse Party' || assoc == 'Interested Party' || assoc =='AP' || assoc == 'Other') {
							newCategory += 'Party' + ';';
							bContactCategoryChanged = true;
							break;
						}
						if(assoc == 'Attorney') {
							newCategory += 'Attorney' + ';';
							bContactCategoryChanged = true;
							break;
						}
						if(assoc == 'Client') {
							newCategory += 'Client' + ';';
							bContactCategoryChanged = true;
							break;
						}												
					}
				}
				if(bContactCategoryChanged) {
					if(newCategory.endsWith(';')) {
						newCategory = newCategory.subString(0,newCategory.length()-1);	
					}					
					c.category__c = newCategory;
					m_ContactId_Contact.put(c.Id,c);
					bAnyContactsChanged = true;
				}				
			}
			if(bAnyContactsChanged) {
				List<Contact> contactsToUpd = m_ContactId_Contact.values();
				try {
					System.debug(LoggingLevel.INFO,'Attemping to update '+contactsToUpd.size() + ' contacts for their category__c');
					contactIdsUpdated = DmlUtils.DBUpdate(contactsToUpd,false); 
				} catch (Exception e) {
					System.debug(LoggingLevel.ERROR,'Error updating contact categories : e='+e);	
				}
			} else {
				System.debug(LoggingLevel.INFO, ' No Contact Categories to update for caseParties passed...');	
			}
		} else {
			System.debug(LoggingLevel.INFO, ' No Contacts to update for caseParties passed...');	
		}	
		return contactIdsUpdated;
	}
		/**
	 *	To be run after delete on CaseParty
	 *
	 *  1. Roll through all the case parties and get a list of contact Ids
	 *  2. Use this list to select possible contact records to update, with case party associations.
	 *  3. Cycle through the contact records.
	 *  3. IF the contact category includes Party, check if there are any Party associations.  If not, flag
	 *     the record as needing to change.  If there are, add 'Party' to the new category string.
	 *  4. IF the contact category includes Client, check if there are any Client associations.  If not, flag
	 *     the record as needing to change.  If there are, add 'Client' to the new category string.
	 *	5. Otherwise, add the category to the newCategory string.
	 *	6. If the category for this contact was changed, add it to the map for later update.
	 *	5. Update those contact records that were added to the map.
	 *  6. Return Contact Ids updated.
	 *
	 *  @parm the list of Case_party__c records to evaluate.
	 *  @returns a Set<Id> of any contact Ids that were updated. 
	 *
	 *  
	 *
	 */	
	public static Set<Id> updateContactCategoriesOnCpDelete(list<Case_Party__c> caseParties) {
		
		System.debug(LoggingLevel.Debug, 'In updateCategoriesOnCpDelete');
		
		Set<Id> contactIdsUpdated;
		if(caseParties == null || caseParties.isEmpty()) {
			System.debug(LoggingLevel.WARN,'Case Party LIST passed is null or empty.. nothing to do');
			return null;	
		}		
		
		Map<Id,Contact> m_ContactId_Contact = new Map<Id,Contact>(); 
		
		Set<Id> contactIdsToFind = new Set<Id>();
		
		// add all of the contact ids to a set for the query
		for(Case_Party__c cp : caseParties) {
			contactIdsToFind.add(cp.contact__c);
		}		
		if(!contactIdsToFind.isEmpty() ) {
			// get the contact info and associated case parties
			List<Contact> contacts = [select Id, category__c,  (select type__c from case_parties__r), name from Contact where Id in :contactIdsToFind];
			Boolean bAnyContactsChanged = false;

			for(Contact c : contacts) {
				System.debug(logginglevel.debug, 'In contact loop, name = '+c.name);
				Set<String> contactAssociations = new Set<String>();
				
				// get the remaining case party associations for this contactAssociations
				// convert to upperCase for the comparison in case there are any inconsistencies
				for (Case_Party__c cp : c.case_parties__r) {
					System.debug(logginglevel.debug, 'In case party loop, cp.type = '+cp.type__c);
					
					if(!contactAssociations.contains(cp.type__c)) {
						contactAssociations.add(cp.type__c.toUpperCase());
					}
				}
	
				String newCategory = '';
				Boolean bContactCategoryChanged = false;
				
				System.debug(logginglevel.debug, 'contactAssociations = '+contactAssociations);
				
				// need to figure out what to do when contactAssociations is empty  Should delete contact if only category values are Party or Client
				if (c.category__c != null) {
					List<String> contactTypes = c.category__c.split(';');
					System.debug(logginglevel.debug, 'contactTypes = '+contactTypes);
					
					for(String s:contactTypes) {
						if (s == 'Party') {
							if (!(contactAssociations.contains('ADVERSE PARTY') 
									|| contactAssociations.contains('INTERESTED PARTY') 
									|| contactAssociations.contains('AP')
									|| contactAssociations.contains('OTHER'))) {
								bContactCategoryChanged = true;			
							} else {
								newCategory += 'Party' + ';';
							}
						} else if (s == 'Client') {
							if (!contactAssociations.contains('CLIENT')) {
								bContactCategoryChanged = true;
							} else {
								newCategory += 'Client' + ';';
							}
						} else {
							// not client or party, so add to new category.  This will catch Volunteer, etc
							newCategory += s + ';';
						
						} 
					}
				}
				System.debug(LoggingLevel.DEBUG,'bContactCategoryChanged = '+bContactCategoryChanged);
				System.debug(LoggingLevel.Debug,'newCategory = '+newCategory);
				if(bContactCategoryChanged) {
					if(newCategory.endsWith(';')) {
						newCategory = newCategory.subString(0,newCategory.length()-1);	
					}					
					c.category__c = newCategory;
					m_ContactId_Contact.put(c.Id,c);
					bAnyContactsChanged = true;
				}				
			}
			if(bAnyContactsChanged) {
				List<Contact> contactsToUpd = m_ContactId_Contact.values();
				try {
					System.debug(LoggingLevel.INFO,'Attemping to update '+contactsToUpd.size() + ' contacts for their category__c');
					contactIdsUpdated = DmlUtils.DBUpdate(contactsToUpd,false); 
				} catch (Exception e) {
					System.debug(LoggingLevel.ERROR,'Error updating contact categories : e='+e);	
				}
			} else {
				System.debug(LoggingLevel.INFO, ' No Contact Categories to update for caseParties passed...');	
			}
		} else {
			System.debug(LoggingLevel.INFO, ' No Contacts to update for caseParties passed...');	
		}	
		return contactIdsUpdated;
	}

    public static void cascadeCaseDeletes(Map<id,Case> oldCases){
        List<Case_Party__c> parties = [SELECT 	Id 
        								FROM 	Case_Party__c 
        								WHERE 	Case__c in :oldCases.keySet()];
        if(parties!=null && !parties.isEmpty()) {
        	try {
        		delete parties;
        	} catch (DmlException e) {
        		System.debug(logginglevel.warn,e);
        	}
        }								
    	
    }
    public static void updateFromCase(Map<id,Case> newCases){
        List<Case_Party__c> parties = [SELECT Id, case__c, contact__c, isInsert__c, Name, Primacy__c, Type__c FROM Case_Party__c WHERE Primacy__c = 'Primary' AND (Type__c = 'Client' OR Type__C = 'Adverse') AND Case__c in :newCases.keySet()];
        Map<string,Case_Party__c> partySet = new Map<string,Case_Party__c>();
        list<Case_Party__c> updateParties = new List<Case_Party__c>();
        list<Case_Party__c> insertParties = new List<Case_Party__c>();
        set<string> avoid = new set<string>();
        for (Case_Party__c cp : parties) {
            partySet.put(cp.Name, cp);
        }

        for (case c : newCases.values()) {
            if (c.contactId != null) {
                if (partySet.containsKey('primaryclient'+c.Id)){
                    //update?
                    Case_Party__c cp = partySet.get('primaryclient'+c.Id);
                    if (c.contactId != cp.contact__c){
                        //change the old entry
                        cp.Primacy__c = 'Secondary';
                        cp.isInsert__c = true;
                        updateParties.add(cp);
                        //add the new entry
                        Case_Party__c ncp = new Case_Party__c();
                        ncp.case__c = c.Id;
                        ncp.contact__c = c.contactId;
                        ncp.Primacy__c = 'Primary';
                        ncp.Type__c = 'Client';
                        ncp.isInsert__c = true;
                        insertParties.add(ncp);
                    }
                } else {
                    //add the new entry
                    Case_Party__c ncp = new Case_Party__c();
                    ncp.case__c = c.Id;
                    ncp.contact__c = c.contactId;
                    ncp.Primacy__c = 'Primary';
                    if (c.practice_area__c == 'Possible Conflict') {
                    	ncp.Type__c = 'Possible Conflict';
                    } else {
                    	ncp.Type__c = 'Client';
                    }
                    ncp.isInsert__c = true;
                    insertParties.add(ncp);
                }
                
            }
            /*
            if (c.adverse_party__c != null) {
                if (partySet.containsKey('primaryadverse'+c.Id)){
                    //update
                    Case_Party__c cp = partySet.get('primaryadverse'+c.Id);
                    if (c.adverse_party__c != cp.contact__c){
                        cp.Primacy__c = 'Secondary';
                        cp.isInsert__c = true;
                        updateParties.add(cp);
                        Case_Party__c ncp = new Case_Party__c();
                        ncp.case__c = c.Id;
                        ncp.contact__c = c.adverse_party__c;
                        ncp.Primacy__c = 'Primary';
                        ncp.Type__c = 'Adverse';
                        ncp.isInsert__c = true;
                        insertParties.add(ncp);
                    }
                }else {
                    Case_Party__c ncp = new Case_Party__c();
                    ncp.case__c = c.Id;
                    ncp.contact__c = c.adverse_party__c;
                    ncp.Primacy__c = 'Primary';
                    ncp.Type__c = 'Adverse';
                    ncp.isInsert__c = true;
                    insertParties.add(ncp);
                }
            }
            */
        }
        if(updateParties.size() > 0){
            update updateParties;
        }
        if(insertParties.size() > 0){
            insert insertParties;
        }
    }
}