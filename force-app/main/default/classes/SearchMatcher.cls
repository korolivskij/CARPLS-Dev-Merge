/***
	This class first builds a list of search terms for the first name using the 
	NameEquivalence object.	It then cycles through the rows returned from the query and compares each element to 
	the input supplied by the user.  If there is a match on an element, a term is added to 
	a string.  This string is then parsed to create a match score.  
	
	ELC 9/4/15 - made changes to remove name equivalence for last names - it wasn't being used 
	and don't see us ever using it for that purpose.
***/	
public with sharing class SearchMatcher {
 
    
    Set<String>             sFirstTerms         { get; set; }
    
    public transient List<ContactResult>  allContactResults   { get; set; }
    public transient  List<ContactResult>  someContactResults  { get; set; }
    public transient List<DebugMessage>   debugMessages       { get; set; }
    
    public Static Final Integer  MAX_DEBUG_MESSAGES = 50; //any more then 100 is probably worthless
    
    

    
    public SearchMatcher() {
        sFirstTerms = new Set<String>();    

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
    public void processSearchTerms(SearchWrapper sw) {
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
     
    
    }
    /**
     * @TODO Get rid of unneeded logging on every row.

    public void buildMatchesObsolete(List<Contact> contacts, SearchWrapper sw, Boolean isExistingClientSearch) {
          
          if(contacts != null && contacts.size() > 0) {
              Integer iContactsAdded = 0;
              Integer iDebugMessages = 0;
                for (Contact c : contacts) {
                    
                    ContactResult contactResult = new ContactResult();
                    contactResult.c = c;
                    contactResult.caseParties = c.case_parties__r;
                    
                    
                    contactResult = this.findContactAssoc(contactResult);

                    string m = '';
                                       
                    if(sw.contact.FirstName != null && sFirstTerms != null && c.firstName != null){
                        if(sFirstTerms.contains(c.FirstName.trim().toLowerCase())){
                            m +=  ' FirstName,';
                        }
                    }
                    if(sw.contact.LastName != null && slastTerms != null && sLastTerms.size()>0 && c.lastName != null){
                    	//* ELC 9/4/15 changed below to ignore hyphens and spaces 
                        if(sLastTerms.contains(c.Lastname.toLowerCase().replace(' ','').replace('-',''))){
                            m +=  ' LastName,';
                        }
                    }                    
                    // in the next 2,the user entered an alias, so we compare it to this record's name fields                
                    if (sw.contact.FirstName != null && c.FirstName != null
                        && // (c.FirstName.toLowerCase() == sw.contact.FirstName.toLowerCase() ||
                        (sw.contact.Aliases__c != null && c.FirstName != null && c.FirstName.toLowerCase() == sw.contact.Aliases__c.toLowerCase()) ){
                        m +=  ' AliasF,';
                    }
                    if (sw.contact.LastName != null 
                        && /*(c.LastName.toLowerCase() == sw.contact.LastName.toLowerCase()   redundant - this was caught above and has nothing to do with alias
                        ||*/ /* ELC 9/4/15 changed below to ignore hyphens and spaces  
                        (sw.contact.Aliases__c != null && c.lastName != null && c.LastName.toLowerCase().replace(' ','').replace('-','') == sw.contact.Aliases__c.toLowerCase().replace(' ','').replace('-',''))){
                        m +=  ' AliasL,';
                    }
                    // Check if Alias entered matches alias in record
                    if (sw.contact.Aliases__c != null && c.Aliases__c != null
                        &&  (c.Aliases__c.toLowerCase().replace(' ','').replace('-','') == sw.contact.Aliases__c.toLowerCase().replace(' ','').replace('-',''))){
                        m +=  ' AliasA,';
                    }
                    // if the next 2 ifs, the user did not enter an alias, but we will compare the name entered to this record's aliases
                    if (c.Aliases__c != null && sw.contact.FirstName != null 
                            && c.Aliases__c.toLowerCase().contains(sw.contact.FirstName.toLowerCase())){
                        m += ' AliasF,';
                    }
                    if (sw.contact.LastName != null  && c.Aliases__c != null
                            && c.Aliases__c.toLowerCase().replace(' ','').replace('-','').contains(sw.contact.LastName.toLowerCase().replace(' ','').replace('-',''))){
                        m += ' AliasL,';
                    }
                    if (
                    		sw.contact.Middle_Initial_Suffix__c  != null 
                            && c.middle_Initial_Suffix__c != null 
                            && c.Middle_Initial_Suffix__c.toLowerCase() == sw.contact.Middle_Initial_Suffix__c.toLowerCase()
                            
                        ){m += ' MI,';}
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
                    if (sw.contact.Last_Four_SSN__c  != null && c.Last_Four_SSN__c != null 
                        && c.Last_Four_SSN__c == sw.contact.Last_Four_SSN__c){
                        m += ' SSN,';
                    }
                    
                    if (sw.contact.Birthdate!= null && c.Birthdate != null 
                        && c.Birthdate == sw.contact.Birthdate){
                        m += ' DOB,';
                    }
                            
                    contactResult.matches = m;    
                    if(iDebugMessages < MAX_DEBUG_MESSAGES) {   
                        debugMessages.add(new DebugMessage('buildMessages: contactResult.matches:'+m));
                        iDebugMessages ++;
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
                            } else if (m.contains('Phone') || m.contains('Street') || m.contains('Phone')) {
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
                           // intakeSearchResults.add(sc);
                            //somecontacts.add(sc);
                            someContactResults.add(contactResult);
                        }
                    } else {
                        if(matches >= 9) {
                            //complete match
                            contactResult.autoMatch= 'Exact';
                            contactResult.confidence = confidence;
                            contactResult.matchScore = 100;
                            //inxxtakeSearchResults.add(sc);
                           // somecontacts.add(sc);
                           someContactResults.add(contactResult);
                        } else {
                            //no match
                            contactResult.autoMatch= 'No';
                            contactResult.confidence = confidence;
                            contactResult.matchScore = 0;
                        }
                    }
                     

                        // --- Adding to all contact results....
                        allContactResults.add(contactResult);                    
                        iContactsAdded++;
                    
                }
              try {               
                allContactResults.sort();
                //@todo after sort possibly only take max contacts in list value (to be displayed on client)
                debugMessages.add(new DebugMessage('AFter sort.. size of allContactResults='+allContactResults.size()));
                
                // if(allContactResults != null && allContactResults.size() > MAX_CONTACTS_IN_LIST) {
              //  		allContactResults = (List<ContactResult>)al.ArrayUtils.subset(allContactResults, MAX_CONTACTS_IN_LIST);
               //
                //	 	debugMessages.add(new DebugMessage('new size of allContactResults='+allContactResults.size()));
                 //}
                 
                 if(debugMessages != null && debugMessages.size() > MAX_DEBUG_MESSAGES)  {
                 	debugMessages = (List<DebugMessage>)al.ArrayUtils.subset(debugMessages, MAX_DEBUG_MESSAGES);
                 }
               } catch (Exception e) {
                    System.debug(logginglevel.error,e);
               }
             
        }
    }
    **/
    public void buildMatches(List<Contact> contacts, SearchWrapper sw, Boolean isExistingClientSearch) {
          
          if(contacts != null && contacts.size() > 0) {
              Integer iContactsAdded = 0;
              Integer iDebugMessages = 0;
              	Set<String> sMatches = new Set<String>();
              	Set<String> sConfidence = new Set<String>();
              	
              	String swStrippedLastName;
              	if (sw.contact.lastname != null) {
              		 swStrippedLastName = sw.contact.lastname.toLowerCase().replace('-','').replace(' ','').replace('\'','');
              	}
              	String swStrippedAlias;
              	if (sw.contact.aliases__c != null) {
              		swStrippedAlias = sw.contact.aliases__c.toLowerCase().replace('-','').replace(' ','').replace('\'','');
              	}
              	
                for (Contact c : contacts) {
                    sMatches.clear();
                    ContactResult contactResult = new ContactResult();
                    contactResult.c = c;
                    contactResult.caseParties = c.case_parties__r;
                    String cStrippedLastName;
                    if (c.lastName != null ) {
                    	cStrippedLastName = c.lastName.toLowerCase().replace('-','').replace(' ','').replace('\'','');
                    }                    
                    String cStrippedAlias;
                    if (c.aliases__c != null) {
                    	cStrippedAlias = c.aliases__c.toLowerCase().replace('-','').replace(' ','').replace('\'','');
                    }                    
                    
                    contactResult = this.findContactAssoc(contactResult);
                                    
                    if(sw.contact.FirstName != null && sFirstTerms != null && c.firstName != null){
                        if(sFirstTerms.contains(c.FirstName.trim().toLowerCase())){
                            sMatches.add('FirstName');
                        }
                    }
                    if(sw.contact.LastName != null && c.lastName != null){
                        // ELC 9/4/2015 if(sLastTerms.contains(c.Lastname.trim().toLowerCase())){
                  		if(cStrippedLastName.equals(swStrippedLastName)) {
                            sMatches.add('LastName');
                        }
                    }                    
                    // in the next 2,the user entered an alias, so we compare it to this record's name fields                
                    if (sw.contact.FirstName != null && c.FirstName != null
                        &&  (sw.contact.Aliases__c != null && c.FirstName != null && c.FirstName.toLowerCase() == sw.contact.Aliases__c.toLowerCase()) ){
                        sMatches.add('AliasF');
                    }
                    if (sw.contact.LastName != null && sw.contact.Aliases__c != null 
                    		&& c.lastName != null && !String.isEmpty(swStrippedAlias)) {
                    	if (cStrippedLastName.equals(swStrippedAlias)){
                        	sMatches.add('AliasL');
                    	}
                    }
                    // Check if Alias entered matches alias in record
                    if (swStrippedAlias != null && cStrippedAlias != null
                        &&  (cStrippedAlias == swStrippedAlias)){
                        sMatches.add('AliasA');
                    }
                    // if the next 2 ifs, the user did not enter an alias, but we will compare the name entered to this record's aliases
                    if (c.Aliases__c != null && sw.contact.FirstName != null 
                            && c.Aliases__c.toLowerCase().contains(sw.contact.FirstName.toLowerCase())){
                        sMatches.add('AliasF');
                    }
                    if (swStrippedLastName != null  && c.Aliases__c != null && !String.isEmpty(cStrippedAlias)
                            && cStrippedAlias.contains(swStrippedLastName)){
                        sMatches.add('AliasL');
                    }
                    if (
                    		sw.contact.Middle_Initial_Suffix__c  != null 
                            && c.middle_Initial_Suffix__c != null 
                            && c.Middle_Initial_Suffix__c.toLowerCase() == sw.contact.Middle_Initial_Suffix__c.toLowerCase()
                            
                        ){
                        	sMatches.add('MI');
                        }
                    if (sw.contact.Phone != null && c.Phone !=null && c.phone == sw.contact.Phone){
                        sMatches.add('Phone');
                        }
                    if (sw.contact.MailingStreet != null && c.MailingStreet != null 
                        && c.MailingStreet.toLowerCase().contains(Utilities.shortenText(sw.contact.MailingStreet,10).toLowerCase())){
                        sMatches.add('Street');
                    }
                    
                    if (sw.contact.MailingCity != null && c.MailingCity!= null 
                        && c.MailingCity.toLowerCase() == sw.contact.MailingCity.toLowerCase()){
                        sMatches.add('Add1');
                    }
                    if (sw.contact.MailingPostalCode != null && c.MailingPostalCode != null 
                    	&& c.MailingPostalCode == sw.contact.MailingPostalCode) {
                        sMatches.add('Add2');
                    }
                    // Don't want to match on an invalid SSN
                    if (sw.contact.Last_Four_SSN__c  != null && c.Last_Four_SSN__c != null 
                        && sw.contact.Last_Four_SSN__c != '0000'
                        && c.Last_Four_SSN__c == sw.contact.Last_Four_SSN__c){
                        sMatches.add('SSN');
                    }
                    
                    if (sw.contact.Birthdate!= null && c.Birthdate != null 
                        && c.Birthdate == sw.contact.Birthdate){
                        sMatches.add('DOB');
                    }
                            
                    if(sMatches.size() > 0) {
                    	contactResult.matches = al.StringUtils.joinSet(sMatches,',');
                    }
                        
                    if(iDebugMessages < MAX_DEBUG_MESSAGES) {   
                        debugMessages.add(new DebugMessage('buildMessages: contactResult.matches:'+sMatches));
                        iDebugMessages ++;
                    }
                    sConfidence.clear();
                    Integer matches = 0;
                    matches = sMatches.size();
                    //including both the name and alias in the match count is messing with the score
                    
                    if ((sMatches.contains('FirstName')) && (sMatches.contains('AliasF'))) {
                        matches = matches - 1;
                    }
                    if ((sMatches.contains('LastName')) && (sMatches.contains('AliasL'))) {
                        matches = matches - 1;
                    }
                    
                    if(matches  < 9 && matches > 0) {
                          
 
                            if ((sMatches.contains('LastName') || sMatches.contains('AliasL') || sMatches.contains('AliasA')) 
                                && (sMatches.contains('SSN') || sMatches.contains('Phone')
                                        || sMatches.contains('DOB') || sMatches.contains('Street')))   {
                                sConfidence.add('primary');
                            } else if (sMatches.contains('DOB') && (sMatches.contains('SSN') || sMatches.contains('Street') ||
                                        sMatches.contains('Phone'))) {
                                 sConfidence.add('primary');
                            } else if (sMatches.contains('SSN') && (sMatches.contains('Street') || sMatches.contains('Phone'))) {  
                                 sConfidence.add('primary');
                            } else if (sMatches.contains('Street') && sMatches.contains('Phone')) {
                                 sConfidence.add('primary');
                            }  else if (((sMatches.contains('LastName') || sMatches.contains('AliasL')) 
                                            && (sMatches.contains('FirstName') || sMatches.contains('AliasF'))) ||
                                        ((sMatches.contains('LastName') || sMatches.contains('AliasL')) && sMatches.contains('AliasA')) ||
                                        ((sMatches.contains('FirstName') || sMatches.contains('AliasF')) && sMatches.contains('AliasA'))) {
                                 sConfidence.add('secondary');
                            } else if (sMatches.contains('Phone') || sMatches.contains('Street')) {
                                 sConfidence.add('secondary');
                            }                       
                        
                            if (sConfidence.contains('primary')) {
                                contactResult.autoMatch = 'Yes';
                                contactResult.confidence = al.StringUtils.joinSet(sConfidence,',');
                                contactResult.matchScore = matches + 20;
                            } else if (sConfidence.contains('secondary')) {
                                contactResult.autoMatch = 'Maybe';
                                contactResult.confidence = al.StringUtils.joinSet(sConfidence,',');
                                contactResult.matchScore = matches;
                            } else {
                                contactResult.autoMatch = 'No';
                                contactResult.confidence = al.StringUtils.joinSet(sConfidence,',');
                                contactResult.matchScore = 0;
                            }                   

                        if (contactResult.autoMatch != 'No') {
                            someContactResults.add(contactResult);
                        }
                    } else {
                        if(matches >= 9) {
                            //complete match
                            contactResult.autoMatch= 'Exact';
                            contactResult.confidence = al.StringUtils.joinSet(sConfidence,',');
                            contactResult.matchScore = 100;
                           someContactResults.add(contactResult);
                        } else {
                            //no match
                            contactResult.autoMatch= 'No';
                            contactResult.confidence = al.StringUtils.joinSet(sConfidence,',');
                            contactResult.matchScore = 0;
                        }
                    }
                     

                        // --- Adding to all contact results....
                        allContactResults.add(contactResult);                    
                        iContactsAdded++;
                    
                }
              try {               
                allContactResults.sort();
                //@todo after sort possibly only take max contacts in list value (to be displayed on client)
                debugMessages.add(new DebugMessage('AFter sort.. size of allContactResults='+allContactResults.size()));
                /*
                 if(allContactResults != null && allContactResults.size() > MAX_CONTACTS_IN_LIST) {
                		allContactResults = (List<ContactResult>)al.ArrayUtils.subset(allContactResults, MAX_CONTACTS_IN_LIST);
               
                	 	debugMessages.add(new DebugMessage('new size of allContactResults='+allContactResults.size()));
                 }
                 */
                 if(debugMessages != null && debugMessages.size() > MAX_DEBUG_MESSAGES)  {
                 	debugMessages = (List<DebugMessage>)al.ArrayUtils.subset(debugMessages, MAX_DEBUG_MESSAGES);
                 }
               } catch (Exception e) {
                    System.debug(logginglevel.error,e);
               }
             
        }
    }    
    public List<ContactResult> buildSlMatches (List<ContactResult> contactResults, Search_Log__c sl) {
        
        Integer iDebugMessages = 0;
         
        if(sl == null) {
            if(iDebugMessages < MAX_DEBUG_MESSAGES) {   
                debugMessages.add(new DebugMessage('buildSlMatches sl = null returning'));
                iDebugMessages ++;
            }
            System.debug(logginglevel.warn, 'Search log record passed is null.. returning');
            return contactResults;
        }
        
        List<ContactResult> returnedResults = new List<ContactResult>();
        
        Integer i = 0;
        for(ContactResult cr : contactResults) {
            if(cr.c == null) {
                System.debug(logginglevel.warn, 'In contactresult loop. contact attached to cr is null.. looping to next');
                continue;
            }
            //if(cr.c.id == sl.Contact_Reviewed__c) {
                System.debug(logginglevel.info, 'contact id matched with search log.. CONTACT ID='+cr.c.id + ' sl.marked_as_match__c = '+sl.Marked_as_Match__c);
                String slMarkedAsNoMatchIds = '';
                slMarkedAsNoMatchIds = sl.Result_Contact_Ids_No_Match__c;
                if(slMarkedAsNoMatchIds != null) {
                    if(slMarkedAsNoMatchIds.contains(cr.c.id)) {
                        cr.markedAsMatch = 'No';
                    }
                }
            //if(sl.Client_Result_State__c == 'Matches' && cr.markedAsMatch != 'No') {
                returnedResults.add(cr);
            //}

        }
        if(iDebugMessages < MAX_DEBUG_MESSAGES) {   
            debugMessages.add(new DebugMessage('buildSlMatches Search_Log__c='+sl));
            iDebugMessages ++;
        }
        /*
        if(returnedResults != null && returnedResults.size() > MAX_CONTACTS_IN_LIST) {
        	returnedResults = (List<ContactResult>)al.ArrayUtils.subset(allContactResults, MAX_CONTACTS_IN_LIST); 
        }
        */ 
        		/* the below doesn't appear to be working due to conversions of type any to debugMessage.. @todo rjn check this out.
                 if(debugMessages != null && debugMessages.size() > MAX_DEBUG_MESSAGES)  {
                 	debugMessages = (List<DebugMessage>)al.ArrayUtils.subset(debugMessages, MAX_DEBUG_MESSAGES);
                 }
                 */        
        return returnedResults;
    }
}