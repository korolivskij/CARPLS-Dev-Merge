public with sharing class PartySearchMatcher {

    public Set<String>             sFirstTerms         { get; set; }
    public Set<String>             sOrgTerms           { get; set; }
        
    public transient List<ContactResult>  allContactResults   { get; set; }
    public transient List<ContactResult>  someContactResults  { get; set; }
    public transient List<DebugMessage>   debugMessages       { get; set; }
    
    public Static Final Integer  MAX_DEBUG_MESSAGES = 50; //any more then 100 is probably worthless
    
    public PartySearchMatcher() {
        sFirstTerms = new Set<String>();    
        sOrgTerms = new Set<String>();

        this.allContactResults = new List<ContactResult>();
        this.someContactResults = new List<ContactResult> ();
        debugMessages = new List<DebugMessage>();
    }
    
    private ContactResult findContactAssoc(ContactResult contactResult) {
        Contact c = contactResult.c;
        
        if(c.case_parties__r != null) {
            Boolean isClient = false;
            Boolean isAdverse = false;
            
            for(Case_Party__c cp : c.case_parties__r) {
                            
                if('Client'.equalsIgnoreCase(cp.type__c)) {
                    isClient = true;
                }
                if('Adverse party'.equalsIgnoreCase(cp.type__c)) {
                    isAdverse = true;
                }                           
            }
            
            if(isClient && isAdverse) {
                contactResult.association = 'Both';
            } else if(isClient) {
                contactResult.association = 'Client';
            } else if(isAdverse) {
                contactResult.association = 'Adverse';
            } else {
                contactResult.association = 'Not Found';
            }           
        }
        return contactResult;
    }
    public void processSearchTerms(PartySearchWrapper sw) {
        if(sw == null) {
            System.debug(logginglevel.error,'Invalid null SearchWrapper passed');
            return;
        }
        Contact c = sw.contact;
        if(c == null) {
             System.debug(logginglevel.error,'Null contact property on search wrapper');
            return;             
        }
        if(!Utilities.isBLANK(c.firstName)) {
            sFirstTerms.add(c.FirstName.trim().toLowerCase());
            List<Name_Equivalents__c> nes = ContactUtils.retrieveNameEquivs(c.firstName);
            if(nes!= null) {
                for(Name_Equivalents__c ne : nes) {
                    if(!Utilities.isBLANK(ne.root__c)) {
                        sFirstTerms.add(ne.root__c.trim().toLowerCase());
                    }
                    if(!Utilities.isBLANK(ne.match__c)) {
                        sFirstTerms.add(ne.match__c.trim().toLowerCase());
                    }                       
                }
            }
        }
    
        if(!Utilities.isBLANK(c.org_Name__c)) {
            sOrgTerms.add(c.org_name__c.trim().toLowerCase());
            List<Name_Equivalents__c> nes = ContactUtils.retrieveNameEquivs(c.org_Name__c);
            if(nes!= null) {
                for(Name_Equivalents__c ne : nes) {
                    if(!Utilities.isBLANK(ne.root__c)) {
                        sOrgTerms.add(ne.root__c.trim().toLowerCase());
                    }
                    if(!Utilities.isBLANK(ne.match__c)) {
                        sOrgTerms.add(ne.match__c.trim().toLowerCase());
                    }                       
                }
            }
        }           
        
        
    
    }
    public List<ContactResult> buildSlMatches (List<ContactResult> contactResults, Search_Log__c sl) {
        if(sl == null) {
            System.debug(logginglevel.warn, 'Search log record passed is null.. returning');
            return contactResults;
        }
        List<Search_Log_Children__c> slcs = sl.search_log_children__r;
        List<ContactResult> returnedResults = new List<ContactResult>();
        for(ContactResult cr : contactResults) {
            if(cr.c == null) {
                System.debug(logginglevel.warn, 'In contactresult loop. contact attached to cr is null.. looping to next');
                continue;
            }
            String slMarkedAsNoMatchPartyIds = sl.Result_Party_Ids_No_Match__c;
            if(slMarkedAsNoMatchPartyIds != null) {
                if(slMarkedAsNoMatchPartyIds.contains(cr.c.id)) {
                    cr.markedAsMatch = 'No';
                }
            }
            // ELC 10/22/15 - trying to force look at Yes Matches
        	//if (cr.markedAsMatch != 'No') {
            	returnedResults.add(cr);
        	//}
        }
        return returnedResults;
    }    
    
        public void buildOrgMatches(List<Contact> contacts, PartySearchWrapper sw) {
          
          if(contacts != null && contacts.size() > 0) {
                Integer iDebugMessages = 0;
                if(someContactResults == null) {
  					if(debugMessages == null) { debugMessages = new List<DebugMessage>(); }
                    debugMessages.add(new DebugMessage('<font color=red>someContactResults was null creating a new emptyList!</font>'));
                    iDebugMessages++;              	
                	someContactResults = new List<ContactResult>();
                }    
                if(allContactResults == null) {
            		if(debugMessages == null) {debugMessages = new List<DebugMessage>(); }
            		debugMessages.add(new DebugMessage('<font color=red>allContactResults was null creating a new emptyList!</font>'));           		
            		allContactResults = new List<ContactResult>();                   	
                }
                for (Contact c : contacts) {
                   
                    ContactResult contactResult = new ContactResult();
                    contactResult.c = c;
                    contactResult.caseParties = c.case_parties__r;
                    
                    contactResult = this.findContactAssoc(contactResult);

                    string m = '';
                                
                    if(sw.contact.Org_Name__c != null && sOrgTerms != null && sOrgTerms.size()>0 && c.Org_Name__c != null){
                        if(sOrgTerms.contains(c.org_name__c.trim().toLowerCase())){
                            m +=  ' OrgName,';
                        }
                    }                    
                    if (sw.contact.Org_Name__c != null 
                    		&& c.org_name__c != null
                    		&& c.Org_Name__c.trim().toLowerCase().contains(sw.contact.Org_Name__c.toLowerCase())) {
                        	m += ' PartialName,';
                    } 
                    // the user entered an alias, so compare to this record's org name
                    if (sw.contact.Aliases__c != null && c.Org_Name__c != null && c.Org_Name__c.toLowerCase() == sw.contact.Aliases__c.toLowerCase()){
                    	if (!(m.contains('OrgName') || m.contains('Alias'))) {
                        	m +=  ' Alias,';
                    	}
                    }
                    // the user entered an alias, so compare to this record's aliases
                    if ((sw.contact.Aliases__c != null && c.Aliases__c != null) 
                            && (c.Aliases__c.toLowerCase().contains(sw.contact.Aliases__c.toLowerCase()))) { 
                       if (!(m.contains('OrgName') || m.contains('Alias'))) {
                        	m +=  ' Alias,';
                    	}
                    }
                    // the user just entered an org name, so compare to this record's aliases
                    if (sw.contact.Org_Name__c != null  && c.Aliases__c != null
                                    && c.Aliases__c.toLowerCase().contains(sw.contact.Org_Name__c.toLowerCase())){
                        if (!(m.contains('OrgName') || m.contains('Alias'))) {
                        	m +=  ' Alias,';
                    	}
                    }
                    
                    if (sw.contact.Phone != null && c.Phone !=null && c.phone == sw.contact.Phone){
                        m += ' Phone,';
                        }
                    if (sw.contact.MailingStreet != null && c.MailingStreet != null 
                        && c.MailingStreet.toLowerCase().contains(Utilities.shortenText(sw.contact.MailingStreet,10).toLowerCase())){
                        m += ' Street,';
                    }
                    
 /*                   
                    if (sw.contact.MailingCity != null && c.MailingCity!= null 
                        && c.MailingCity.toLowerCase() == sw.contact.MailingCity.toLowerCase()){
                        m += ' Add1,';
                    }
                    if (sw.contact.MailingPostalCode != null && c.MailingPostalCode != null 
                        && c.MailingPostalCode.toLowerCase() == sw.contact.MailingPostalCode.toLowerCase()){
                        m += ' Add2,';
                    }
 */
 
                    contactResult.matches = m;   
                    if (iDebugMessages < MAX_DEBUG_MESSAGES) { 
                    	if(debugMessages == null) { debugMessages = new List<DebugMessage>(); }
                        debugMessages.add(new DebugMessage('buildMessages: contactResult.matches:'+m));
                        iDebugMessages++;
                    }
                    string confidence = '';
                    integer matches = m.split(',').size();
                    
                    if(matches  < 4 && matches > 0) {
                         
                            if (m.contains('OrgName') || (m.contains('Alias')))  {
                                confidence += ' primary';
                            } else if (m.contains('PartialName')) {
                            	confidence += ' secondary';
                            } else if (m.contains('Phone')) {
                                confidence += ' secondary';
                            } else if (m.contains('Street')) {  
                                confidence += ' secondary';
                            }                       
                        
                            if (confidence.contains('primary')) {
                                contactResult.autoMatch = 'Yes';
                                contactResult.confidence = confidence;
                                contactResult.matchScore = matches + 20;
                            } else if (confidence.contains('secondary')) {
                                contactResult.autoMatch = 'Maybe';
                                contactResult.confidence = confidence;
                                contactResult.matchScore = matches;
                            } else {
                                contactResult.autoMatch = 'No';
                                contactResult.confidence = confidence;
                                contactResult.matchScore = 0;
                            }                   

                        if (contactResult.autoMatch != 'No') {
                           // intakeSearchResults.add(sc);
                            //somecontacts.add(sc);
                            someContactResults.add(contactResult);
                        }
                    } else {
                        if(matches >= 4) {
                            //complete match
                            contactResult.autoMatch= 'Exact';
                            contactResult.confidence = confidence;
                            contactResult.matchScore = 100;
                            someContactResults.add(contactResult);
                        } else {
                            //no match
                            contactResult.autoMatch= 'No';
                            contactResult.confidence = confidence;
                            contactResult.matchScore = 0;
                        }
                    }
                    if (iDebugMessages < MAX_DEBUG_MESSAGES) { 
                    	if(debugMessages == null) { debugMessages = new List<DebugMessage>(); }
                        debugMessages.add(new DebugMessage('buildMessages: contactResult.confidence:'+contactResult.confidence));
                        iDebugMessages++;
                    }
                    allContactResults.add(contactResult);                    
                }
              try {               
                allContactResults.sort();
               } catch (Exception e) {
                    System.debug(logginglevel.error,e);
               }
             
        }
    }
    public void buildMatches(List<Contact> contacts, PartySearchWrapper sw) {
           if(contacts != null && contacts.size() > 0) {
                Integer iDebugMessages = 0;
                if(someContactResults == null) {
  					if(debugMessages == null) { debugMessages = new List<DebugMessage>(); }
                    debugMessages.add(new DebugMessage('<font color=red>someContactResults was null creating a new emptyList!</font>'));
                    iDebugMessages++;              	
                	someContactResults = new List<ContactResult>();
                }    
                if(allContactResults == null) {
            		if(debugMessages == null) {debugMessages = new List<DebugMessage>(); }
            		debugMessages.add(new DebugMessage('<font color=red>allContactResults was null creating a new emptyList!</font>'));           		
            		allContactResults = new List<ContactResult>();                   	
                }         
                
              	String swStrippedLastName;
              	if (sw.contact.lastname != null) {
              		 swStrippedLastName = sw.contact.lastname.toLowerCase().replace('-','').replace(' ','').replace('\'','');
              	}
              	String swStrippedAlias;
              	if (sw.contact.aliases__c != null) {
              		sw.contact.aliases__c = sw.contact.aliases__c.toLowerCase().replace('-','').replace(' ','').replace('\'','');
              	}
              	
                for (Contact c : contacts) {
                   
                    ContactResult contactResult = new ContactResult();
                    contactResult.c = c;
                    contactResult.caseParties = c.case_parties__r;
                    
                    contactResult = this.findContactAssoc(contactResult);

                    string m = '';
                    
                    String cStrippedLastName;
                    if (c.lastName != null ) {
                    	cStrippedLastName = c.lastName.toLowerCase().replace('-','').replace(' ','').replace('\'','');
                    }
                    String cStrippedAlias;
                    if (c.aliases__c != null) {
                    	cStrippedAlias = c.aliases__c.toLowerCase().replace('-','').replace(' ','').replace('\'','');
                    }        
                                                       
                    if(sw.contact.FirstName != null && sFirstTerms != null && c.firstName != null){
                        if(sFirstTerms.contains(c.FirstName.trim().toLowerCase())){
                            m +=  ' FirstName,';
                        }
                    }
                    /* ELC 9/4/15 Getting rid of hyphens and white space for comparison of last names **/
                    if(sw.contact.LastName != null && swStrippedLastName != null  && c.lastName != null){
//                        if(sLastTerms.contains(c.Lastname.trim().toLowerCase())){
						if(swStrippedLastName.equals(cStrippedLastName)){
                            m +=  ' LastName,';
                        }
                    }  
                                 
                    // in the next 2,the user entered an alias, so we compare it to this record's name fields                
                    if (sw.contact.FirstName != null && c.FirstName != null
                        && /* (c.FirstName.toLowerCase() == sw.contact.FirstName.toLowerCase() 
                        ||*/ (sw.contact.Aliases__c != null && c.FirstName != null && c.FirstName.toLowerCase() == sw.contact.Aliases__c.toLowerCase()) ){
                        m +=  ' AliasF,';
                    }
                    if (sw.contact.LastName != null 
                        && 
                        /* ELC 9/4/15 added code to ignore spaces and hyphens */ 
                        (swStrippedAlias != null && c.lastName != null && cStrippedLastName.equals(swStrippedAlias))){
                        m +=  ' AliasL,';
                    }
                    // Check if Alias entered matches alias in record
                    if (swStrippedAlias != null && cStrippedAlias != null
                        &&  cStrippedAlias.contains(swStrippedAlias)){
                        m += ' AliasA,';
                    }
                    // if the next 2 ifs, the user did not enter an alias, but we will compare the name entered to this record's aliases
                    if (c.Aliases__c != null && sw.contact.FirstName != null 
                            && c.Aliases__c.toLowerCase().contains(sw.contact.FirstName.toLowerCase())){
                        m += ' AliasF,';
                    }
                    if (swStrippedLastName != null  && cStrippedAlias != null
                            && cStrippedAlias.contains(swStrippedLastName)){
                        m += ' AliasL,';
                    }
                    if (sw.contact.Middle_Initial_Suffix__c  != null 
                            && c.middle_Initial_Suffix__c != null 
                            && c.Middle_Initial_Suffix__c.toLowerCase() == sw.contact.Middle_Initial_Suffix__c.toLowerCase()){
                        m += ' MI,';
                        }
                    if (sw.contact.Phone != null && c.Phone !=null && c.phone == sw.contact.Phone){
                        m += ' Phone,';
                        }
                    if (sw.contact.MailingStreet != null && c.MailingStreet != null 
                        && c.MailingStreet.toLowerCase().contains(Utilities.shortenText(sw.contact.MailingStreet,10).toLowerCase())){
                        m += ' Street,';
                    }
                    
                    if (sw.contact.MailingCity != null && c.MailingCity!= null 
                        && c.MailingCity.toLowerCase() == sw.contact.MailingCity.toLowerCase()){
                        m += ' Add1,';
                    }
                    if (sw.contact.MailingPostalCode != null && c.MailingPostalCode != null 
                        && c.MailingPostalCode.toLowerCase() == sw.contact.MailingPostalCode.toLowerCase()){
                        m += ' Add2,';
                    }
                    // don't want to match on an invalid SSN
                    if (sw.contact.Last_Four_SSN__c  != null && c.Last_Four_SSN__c != null 
                        && sw.contact.Last_Four_SSN__c != '0000'
                        && c.Last_Four_SSN__c == sw.contact.Last_Four_SSN__c){
                        m += ' SSN,';
                    }
                    if (sw.contact.Birthdate!= null && c.Birthdate != null 
                        && c.Birthdate == sw.contact.Birthdate){
                        m += ' DOB,';
                    }
                            
                    contactResult.matches = m;  
                    if (iDebugMessages < MAX_DEBUG_MESSAGES) {   
                    	if(debugMessages == null) { debugMessages = new List<DebugMessage>(); }
                        debugMessages.add(new DebugMessage('buildMessages: contactResult.matches:'+m));
                        iDebugMessages++;
                    }
                    string confidence = '';
                    integer matches = m.split(',').size();
 
                    //including both the name and alias in the match count is messing with the score
                    if ((m.contains('FirstName')) && (m.contains('AliasF'))) {
                        matches = matches - 1;
                    }
                    if ((m.contains('LastName')) && (m.contains('AliasL'))) {
                        matches = matches - 1;
                    }
                                       
                    if(matches  < 9 && matches > 0) {
                        //partial match
                            if ((m.contains('LastName') || m.contains('AliasL') || m.contains('AliasA')) 
                                && (m.contains('SSN') || m.contains('Phone')
                                        || m.contains('DOB') || m.contains('Street')))   {
                                confidence += ' primary';
                            } else if (m.contains('DOB') && (m.contains('SSN') || m.contains('Street') ||
                                        m.contains('Phone'))) {
                                confidence += ' primary';
                            } else if (m.contains('SSN') && (m.contains('Street') || m.contains('Phone'))) {  
                                confidence += ' primary';
                            } else if (m.contains('Street') && m.contains('Phone')) {
                                confidence += ' primary';
                            }  else if (((m.contains('LastName') || m.contains('AliasL')) 
                                            && (m.contains('FirstName') || m.contains('AliasF'))) ||
                                        ((m.contains('LastName') || m.contains('AliasL')) && m.contains('AliasA')) ||
                                        ((m.contains('FirstName') || m.contains('AliasF')) && m.contains('AliasA'))) {
                                 confidence += 'secondary';
                            } else if (m.contains('Phone') || m.contains('Street') || m.contains('DOB')) {
                                confidence += 'secondary';
                            }                       
                        
                            if (confidence.contains('primary')) {
                                contactResult.autoMatch = 'Yes';
                                contactResult.confidence = confidence;
                                contactResult.matchScore = matches + 20;
                            } else if (confidence.contains('secondary')) {
                                contactResult.autoMatch = 'Maybe';
                                contactResult.confidence = confidence;
                                contactResult.matchScore = matches;
                            } else {
                                contactResult.autoMatch = 'No';
                                contactResult.confidence = confidence;
                                contactResult.matchScore = 0;
                            }                   
                        if (contactResult.autoMatch != 'No') {
                           // ixxntakeSearchResults.add(sc);
                            //somecontacts.add(sc);
                            someContactResults.add(contactResult);
                        }
                    } else {
                        if(matches >= 9) {
                            //complete match
                            contactResult.autoMatch= 'Exact';
                            contactResult.confidence = confidence;
                            contactResult.matchScore = 100;
                            //ixxntakeSearchResults.add(sc);
                           // somecontacts.add(sc);
                           someContactResults.add(contactResult);
                        } else {
                            //no match
                            contactResult.autoMatch= '';
                            contactResult.confidence = confidence;
                            contactResult.matchScore = 0;
                        }
                    }
                    // debugMessages.add(new DebugMessage('buildMessages: contactResult.confidence:'+contactResult.confidence));

                    allContactResults.add(contactResult);  
                    //debugMessages.add(new DebugMessage('PS.buildMatches: size of allContactResults: '+allContactResults.size()));                 
                }
              try {               
                allContactResults.sort();
               } catch (Exception e) {
                    System.debug(logginglevel.error,e);
               }
             } else {

            }             
 
                
    }
}