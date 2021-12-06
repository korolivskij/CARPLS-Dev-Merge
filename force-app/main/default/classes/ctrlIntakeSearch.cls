/**
 *  
 * @TODO ViewState try to lower this! this can get touchy with transient vars and stuff so need some time on this.
 *   
 * @see the apex lang managed class http://richardvanhook.com/2010/04/11/soql-builder/
 * @see ctrlCarplesGeneric (ancestor class)  
 */
public with sharing class ctrlIntakeSearch extends ctrlCarplesGeneric {
           
    public Boolean                      yesClientMatchExists        { get; set; }
    public Boolean                      yesPartyMatchExists         { get; set; }
    public Boolean                      isContactSearchResultsFound { get; set; }
    public Boolean                      isNoPartiesClicked          { get; set; }
    public Boolean                      isPartySearchResultsFound   { get; set; }
    public Boolean                      isCpSearchResultsFound      { get; set; }
    public Boolean                      showNewContactSearchInputs  { get; set; }
    public Boolean                      showOrgPartySearchInputs    { get; set; }
    public Boolean                      hasSearched                 { get; set; }   
    public Boolean                      hasPartySearched            { get; set; }
    public Boolean                      hasClientSearched        { get; set; }
    public Boolean                      isCollapseClientData        { get; set; }
    public Boolean                      isCollapsePartyData         { get; set; }
    public boolean                      showAllIntakeResults        { get; set; }
    public boolean                      showAllPartyResults         { get; set; }
    public Boolean                      showPartySearchLogs         { get; set; }
    public Boolean                      renderJsOpenNewParty        { get; set; }
    public Boolean                      hasSavedClient              { get; set; }
    public Boolean                      isNoPartieMatchesClicked    { get; set; }
    public Boolean                      isNoClientMatchesClicked    { get; set; }
    public Boolean                      wasRemovePartyLinkClicked   { get; set; }
    public Boolean                      wasRapidCreateCaseClicked   { get; Set; }
    public Boolean                      redirectToCase              { get; Set; }
    public Boolean                      isSoslQuickSearch           { get; set; }
    public Boolean                      refinedSearch               { get; set; }
    public Boolean                      refinedPartySearch          { get; set; }
    
    public String                       selectedContactNewOrExisting{ get; set; }
    public String                       selectedIndOrOrg            { get; set; }
    
    public transient List<Contact>      allContactResults           { get; set; }
    public List<ContactResult>          allContactSearchResults     { get; set; }
    public List<ContactResult>          matchedContactSearchResults { get; set; }
    
    public transient List<Contact>      allPartyResults             { get; set; }
    public List<ContactResult>          allPartySearchResults       { get; set; }
    public List<ContactResult>          matchedPartySearchResults   { get; set; }   
        
    public Contact                      tempSearchedClientContact   { get; set; }
    public Contact                      tempSearchedPartyContact    { get; set; }
    
    public SearchMatcher                clientSearchMatcher         { get; set; }
    public PartySearchMatcher           partySearchMatcher          { get; set; } 
    public PartySearchWrapper           partySw                     { get; set; }
    public Search_Log__c                clientSearchLog             { get; set; }
    public Boolean                      doOnLoadClientSearch        { get; set; }
    public Boolean                      doOnLoadSearchParties       { get; set; }
    public Boolean                      searchBtnClicked            { get; set; }
    public Boolean                      partySearchBtnClicked       { get; set; }
    public Boolean                      partySearchBtnClickedArtificallySet {get; set;}
    public Boolean                      addPartySearchBtnClicked    { get; set; }
    public Boolean                      isClientMatched             { get; set; }
    List<PartySearchWrapper>            partySearchWrappers         { get; set; }
    public Search_Log__c                slClientParent              { get; set; }
    public List<Search_Log_Children__c> partySearchLogs             { get; set; } 
    public String                       selectedClientSearchLogId   { get; set; }
    public String                       selectedPartySearchLogId    { get; set; }
    // below will be 1 row only
    public List<Contact>                tempSavedSearchedClients    { get; set; }
    public String                       partySectionHeaderTitle     { get; set; }
    public List<SearchLogWrapper>       slWraps                     { get; set; }
    public Id                           fromCaseId                  { get; set; }
    public Id                           currentPartySlId            { get; set; }
    public Case                         caseInserted                { get; set; }
    public Case                         fromCase                    { get; set; }
    public String                       fromPage                    { get; set; }
    public String                       clientReviewType            { get; set; }
    public String                       jsCreateCaseOnComplete      { get; Set; }
    public CaseUtils                    CaseUtils                   { get; Set; }
    public Boolean                      isAddingParty               { get; set; }
    public Boolean                      wasPartyAdded               { get; set; }
    public Id                           leadId                      { get; set; } // Added by S.Korolivskyi 26.08.2020 for storing Lead Id
    
    public Static Final Integer         MAX_DEBUG_MESSAGES = 500; // set value higher here b/c of match builder messages    
    
        
    public ctrlIntakeSearch() {
        super();

        debugLog('in <b>ctrlIntakeSearch contructor</b> after calling super');
        debugLog('<b>Constructor ctrlIntakeSearch..</b>.');
        
        this.getObjects();
        this.pageTrafficCop();
        this.initSettings();
    }
    
    public override void getObjects() {
        super.getObjects();
        debugLog('client orphan search categories = '+super.getClientOrphanSearchCategories());
        debugLog('client other search categories = '+super.getClientOtherSearchCategories());
        debugLog('existing client search categories = '+super.getExistingClientSearchCategories());
        debugLog('party orphan search categories = '+super.getPartyOrphanSearchCategories());
        debugLog('party other search categories = '+super.getPartyOtherSearchCategories());

        this.caseUtils = new CaseUtils();
        this.yesClientMatchExists = false;
        this.yesPartyMatchExists = false;
        this.redirectToCase = false;
        this.isAddingParty = false;
        this.wasPartyAdded = false;
        this.jsCreateCaseOnComplete = '';
        this.isContactSearchResultsFound = false;
        this.showPartySearchLogs = false;
        this.wasRapidCreateCaseClicked = false;
        this.tempSavedSearchedClients = new List<Contact>();
        this.selectedIndOrOrg = 'Individual';
        //------this.selectedContactNewOrExisting = 'Existing';
        this.selectedContactNewOrExisting = 'New';
        this.partySearchWrappers = new List<PartySearchWrapper>();
        //------this.showNewContactSearchInputs = false;
        this.showNewContactSearchInputs = true;
        this.isCollapseClientData = false;
        this.hasSearched = false;
        this.hasPartySearched = false;
        this.hasClientSearched = false;
        this.isNoPartiesClicked = false;
        this.renderJsOpenNewParty = false;
        this.doOnLoadClientSearch = false;
        this.isNoClientMatchesClicked = false;
        this.isClientMatched = false;
        this.doOnLoadSearchParties = false;
        this.isNoPartieMatchesClicked = false;
        this.isCollapsePartyData = true;
        this.isSoslQuickSearch = false;
        //this.selectedIndOrOrg = "Individual";
        this.searchBtnClicked = false;
        this.partySearchBtnClicked  = false;
        this.addPartySearchBtnClicked = false;
        this.hasSavedClient = false;
        this.wasRemovePartyLinkClicked = false;
        this.refinedSearch = false;
        this.refinedPartySearch = false;
        this.fromPage = '';
        this.clientReviewType = '';
        
        this.clientSearchMatcher = new SearchMatcher();
        this.partySearchMatcher = new PartySearchMatcher();
        this.partySw = new PartySearchWrapper();
        partySw.selectedAssociation = 'Adverse Party';
        this.partySearchLogs = new List<Search_Log_Children__c>();
        this.showAllIntakeResults = false; 
        this.showAllPartyResults = false;
        this.partySectionHeaderTitle = 'Party Search';  
        this.fromCaseId =    ApexPages.currentPage().getParameters().get('fromCaseId');
        this.partySearchBtnClickedArtificallySet = false;
        if(fromCaseId != null) {
            this.fromCase = caseUtils.retrieveCaseSummaryData(fromCaseId);
        } 
        
    }
    
    private void pageTrafficCop() {
        
        String sClientSlId =  ApexPages.currentPage().getParameters().get('clientSlId');
        debugLog('<font color="green">sClientSid passed in request='+sClientSlId + '</font>'); 
        
                        
        if( !Utilities.isBLANK(sClientSlid) ) {
            this.clientSearchLog = SearchWrapper.retrieveSearchLog(sClientSlId);
            debugLog('getObjects -- clientSearchLog='+clientSearchLog); 
            this.fromPage = clientSearchLog.fromPage__c;
            debugLog('getObjects fromPage='+fromPage); 
            
            if(Utilities.isNotNullObject(clientSearchLog) && (fromPage != 'vfClient' && fromPage != 'vfCarplsHome' 
                                                            && fromPage != 'vfCaseDetail' && fromPage != 'vfCaseDetail_AddParty')) {
                
                if('Yes'.equalsIgnoreCase(this.clientSearchLog.marked_as_match__c)) {
                    debugLog('not from client or carpls home.. marking onloadsearch parties to true. fromPAge='+fromPage);
                    // ELC 2/6/2015 - support for Contact Created 
                    slClient = clientSearchLog;
                    doOnLoadSearchParties    = true;
                } else {
                    this.copyExistingClientSearch(clientSearchLog);
                    debugLog('copying existing client search and setting boolean to fire client search');                   
                    this.selectedContactNewOrExisting = 'New';
                    this.showNewContactSearchInputs = true;
                    this.doOnLoadClientSearch = true;                       
                    //----- not allowed in constructor in apex this.doClientSearch() so set onload bool to be called by vf init action;
                }
            } else if (fromPage == 'vfCarplsHome' || fromPage =='vfCarplsHome2') {
                //from home / ie. quick search
                this.showNewContactSearchInputs = false;
                debugLog('showNewContactSearchInputs='+this.showNewContactSearchInputs);
                this.selectedContactNewOrExisting = 'New';
                this.copyExistingClientSearch(clientSearchLog);
                this.doOnLoadClientSearch = true;          
                
            }  else {
                //from vfClient or vfCaseDetail or vfCaseDetail_AddParty
                this.clientReviewType = ApexPages.currentPage().getParameters().get('clientReviewType');

                
                debugLog('client review type='+clientReviewType);
                try {
                    if('Yes'.equalsIgnoreCase(this.clientSearchLog.marked_as_match__c) 
                        && (fromPage == 'vfClient' || fromPage == 'vfCaseDetail' || fromPage == 'vfCaseDetail_AddParty')) {
                        List<Search_Log_Children__c> slcs = clientSearchLog.search_log_children__r;
                        debugLog('slcs ie. parties is:'+slcs);
                        if(Utilities.doesListHaveValue(slcs)) {
                            doOnLoadSearchParties    = true;
                            debugLog('marking doOnLoadSearchParties to true');                              
                        }
                        debugLog('searchWrapper='+sw);
                    
                        this.isClientMatched = true;
                        this.isCollapseClientData = true;
                    
                        if('Client'.equalsIgnoreCase(this.clientReviewType)) {
                            // ELC 2/6/2015 Adding support for ContactCreated
                            // If a new contact was created, use that.  Otherwise use the 
                            // one that was reviewed and matched.
                            id reviewedClientId;
                            if (clientSearchLog.Contact_Created__c != null) {
                                reviewedClientId = clientSearchLog.Contact_Created__c;
                            } else {
                                reviewedClientId = clientSearchLog.Contact_Reviewed__c;                             
                            }       
                            //sw.contact = ContactUtils.retrieveAllContactInfo(reviewedClientId);
                            //@todo rjn api versioning issues
                            Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                            sw.contact = retrieveAllContactInfo(reviewedClientId, excludeFields);
                            this.tempSearchedClientContact = sw.contact;    
                            hasSavedClient = true;
                            if(Utilities.doesListHaveValue(slcs)) {
                                String msg = 'Client: '+sw.contact.firstname + ' ' + sw.contact.Lastname + ' added as a match.';
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
                            }
                            isCollapsePartyData = false;    
                            this.refreshSearchLogWraps();
                        } else if ('Party'.equalsIgnoreCase(this.clientReviewType)) {
                            debugLog('in client review type of party in pageTrafficCop.. but doing nothing');
                            if(clientSearchLog.current_sl_party__c != null) {
                                if(fromPage == 'vfCaseDetail_AddParty') {
                                    
                                    debugLog('special use case of from page is vfCaseDetail_AddParty.. coming back after conflict log process. ie we kinda looped through different cases.');
                                    this.wasPartyAdded = true;
                                    Id xFromCaseId = clientSearchLog.addPartyFromCase__c;
                                    if(xFromCaseId != null) {
                                        this.fromCase = caseUtils.retrieveCaseSummaryData(xFromCaseId);                                 
                                    }
                                                                        
                                }
                            }
                            this.refreshSearchLogWraps();
                        }                       
                    
                        //this.copyExistingPartysearch(slChild);
                    } //else 
                    
                } catch (Exception e) {
                    errorLog(e,'Exception caught in doInit...clientSearchLog='+clientSearchLog + ' fromPage='+fromPage);
                }
            }     
        } else {
            //----------------------- no slClientId in Request
            fromPage = ApexPages.currentPage().getParameters().get('fromPage');
            if (fromPage == 'vfCaseDetail_AddParty') {    
                //Adding a party to a case.. autosearch client 
                
                debugLog('---- from vfCaseDetail_AddParty');
                debugLog('fromCaseId='+fromCaseId);
                CaseUtils caseUtils = new CaseUtils();
                Case cse = caseUtils.retrieveCaseSummaryData(fromCaseId);
                debuglog('rickcse='+cse);
                List<Case_Party__c> caseParties = caseUtils.retrieveCaseParties(cse);
                debugLog('--- caseParties='+caseParties);
                
                String msg = 'You have chosen to add a party to Case: '+cse.caseNumber +' . Please search for your party below.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
                
                this.isAddingParty = true;                
                this.isClientMatched = true;
                this.isCollapseClientData = true;
                this.isCollapsePartyData = false;
                this.hasSavedClient = true;

                //@todo rjn api versioning issues
                Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                sw.contact = retrieveAllContactInfo(cse.contactId, excludeFields);

                debuglog('rickswcontact='+sw.contact);
                
                debugLog('searchWrapper='+sw);
                this.tempSearchedClientContact = sw.contact;  
                //this.refreshSearchLogWraps(); 
                 
                //hasSavedClient = true;
            
            } 
            // todo
            else 
                fromPage = ApexPages.currentPage().getParameters().get('fromPage');
                system.debug('fromPage==== ' + fromPage);
				if(fromPage == 'lead'){
					system.debug('cls->'+clientSearchLog);
					//this.fromPageReferral = true;
					String firstName =  Apexpages.currentPage().getParameters().get('firstName');
					String lastName =  Apexpages.currentPage().getParameters().get('lastName');
                    String phone =  Apexpages.currentPage().getParameters().get('phone');
                    Date birthDate = date.parse(Apexpages.currentPage().getParameters().get('birthdate'));
                    Id leadId = Apexpages.currentPage().getParameters().get('referralId'); // S. Korolivskyi Updated 25.08.2020
                    this.leadId = leadId;
                    sw.contact.Lead__c = leadId; // S. Korolivskyi Updated 25.08.2020
					if(firstName != null){
						sw.contact.firstname = firstName;
					}
					if(lastName != null){
						sw.contact.lastname = lastname;
					}
					if(phone != null){
						sw.contact.phone = phone;
                    }
                    if(birthDate != null){
                        sw.contact.Birthdate = birthDate;
                    }


			}



            else {
                Boolean newSearch = false;
                String sNewSearch = Apexpages.currentPage().getParameters().get('newSearch');
                if(sNewSearch != null) {
                    try {
                        newSearch = Boolean.valueOf(sNewSearch);
                    } catch (Exception e) {
                    
                    }
                }
                if(!newSearch) {
                    /*
                    * User selected that the client is a match on the view client screen but there
                    * are no parties yet.
                    */
                    Search_Log__c sl = SearchWrapper.getLatestSearchLog(UserInfo.getUserId());
                    debugLog('getting latest user search log... sl='+sl);
                    if(sl!=null) {
                        if('Yes'.equalsIgnoreCase(sl.marked_as_match__c)) {
                            this.isClientMatched = true;
                            debugLog('in constructor setting doOnLoadSearchParties.. ie. came from vfClient and selected yes for match'); 
                            this.clientSearchLog = sl;     
                            // ELC 2/6/2015 Adding support for ContactCreated             
                            id reviewedClientId;
                            if (clientSearchLog.Contact_Created__c != null) {
                                reviewedClientId = clientSearchLog.Contact_Created__c;
                            } else {
                                reviewedClientId = clientSearchLog.Contact_Reviewed__c;                             
                            }
                            //sw.contact = ContactUtils.retrieveAllContactInfo(reviewedClientId);
                            //@todo rjn api versioning issues
                            Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                            sw.contact = retrieveAllContactInfo(reviewedClientId, excludeFields);
                            String msg = 'Client: '+sw.contact.firstname + ' ' + sw.contact.Lastname + ' added as a match.';
                            if(!wasRapidCreateCaseClicked) {
                                doOnLoadSearchParties    = true;
                                msg += ' Please search for parties.';
                            }
                        
                        
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));   
                            this.refreshSearchLogWraps();                       
                        }
                    }
                } else {
                    String msg = 'Please initiate your client intake by searching for the client.';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));   
                        
                }
            }
        }
         
 
        if(clientSearchLog != null) {
            this.showAllIntakeResults = clientSearchLog.client_result_state__c == 'All';
            this.showAllPartyResults = clientSearchLog.party_result_state__c == 'All';
        }           
    }
    public Pagereference doInitActions() {
        
        if(this.slClient == null && fromPage == 'vfCaseDetail_AddParty') {
            debugLog('there was no slClient found and fromPage is vfCaseDetail_AddParty.. creating a new mock slClient as we cannot assume the search log will exist for an old case');
            if(sw != null && sw.contact != null && sw.contact.id != null) {
                this.clientSearchLog = this.createMockSlClient(sw.contact.id); 
                this.slClient = clientSearchLog;
                debugLog('client search log created='+clientSearchLog);
                this.refreshSearchLogWraps();
            } else {
                //rjn patch fix / add party to existing case.. no value seems to exist in sw

            }
        } 
        //if(!super.getCustomSettingsGood()) {
        //  return null;
        //}     
            //@TODO huh? must be an error below
            if(slClient == null && (doOnLoadClientSearch || doOnLoadSearchParties)) {
                debugLog('in doInitActions retrieveing latest client search log'); 
                slClient = SearchWrapper.getLatestSearchLog(UserInfo.getUserId());
                //The below gets the latest search log and all search log children.
                slClient = SearchWrapper.retrieveSearchLog(slClient.Id);                
            }   
                
        if(this.doOnLoadClientSearch) {
            
            this.doClientSearch();
            
        }
        if(this.doOnLoadSearchParties) {
            debugLog('in doInitActions doing onLoadSearchParties'); 
            try {
            //doContinueClientSearch();

            
            
            this.isCollapseClientData = true;
            this.isCollapsePartyData =  false;
            this.hasSavedClient = true;
            /* Retrieve Client  Data again for display in blue bar */
            if(clientSearchLog != null) {
                // ELC 2/6/2015 Added support for ContactCreated
                id reviewedClientId;
                if (clientSearchLog.Contact_Created__c != null) {
                    reviewedClientId = clientSearchLog.Contact_Created__c;
                } else {
                    reviewedClientId = clientSearchLog.Contact_Reviewed__c;
                }
                //sw.contact = ContactUtils.retrieveAllContactInfo(reviewedClientId);
                //@todo rjn api versioning issues
                Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                sw.contact = retrieveAllContactInfo(reviewedClientId, excludeFields);

                this.tempSearchedClientContact = sw.contact;    
                String sPartyResultType = clientSearchLog.party_result_type__c;
                    if(sPartyResultType != null) {
                        this.selectedIndOrOrg = sPartyResultType;
                        if(selectedIndOrOrg == 'Organization') {
                            this.showOrgPartySearchInputs = true; 
                        } 
                    }                
            }
        
            Id reviewedPartySlId = this.slClient.current_sl_party__c;
            if(reviewedPartySlId != null) {
                debugLog('partyReviewedId='+reviewedPartySlId);
                Search_Log_Children__c SlChild = SearchWrapper.retrieveSearchLogChild(reviewedPartySlId);
                debugLog('slChild Record='+slChild);
                if(slChild != null) {
                    //Contact partyReviewed = ContactUTils.retrieveAllContactInfo(slChild.party_reviewed__c);
                    //@todo rjn api versioning issues
                    Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                    Contact partyReviewed = retrieveAllContactInfo(slChild.party_reviewed__c, excludeFields);
                    debugLog('partyReviewed FULL RECORD='+partyReviewed);

                if(slChild!=null) {
                    //if('Yes'.equalsIgnoreCase(sl.marked_as_match__c)) 
                    
                    if(partyReviewed != null && slChild.marked_as_match__c == 'Yes') {
                        String fullName = '';
                        String msg = 'Party: ';
                        if(partyReviewed.firstName != null) {
                            msg += partyReviewed.firstname + ' ';
                        }
                        msg += partyReviewed.Lastname + ' has been added as a match';
                      
                        String lFromPage = '';
                        
                        if(this.fromPage == null || this.fromPage =='') {
                            if(clientSearchLog != null) {
                                lfromPage = clientSearchLog.fromPage__c;
                                if(lfromPage == 'vfCaseDetail_AddParty') {
                                    String caseId = clientSearchLog.addPartyFromCase__c;
                                    fromCase = caseUtils.retrieveCaseSummaryData(caseId);
                                }
                            }
                        }
                        if(fromCase != null) {
                            msg += ' to case: '+fromCase.CaseNumber + '.';
                        } else {
                            msg += '.';
                        }

                        this.wasPartyAdded = true;  
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
                        this.refreshSearchLogWraps();
                        //this.doClearPartySearch();    
                        this.isCollapsePartyData = true;
                        if(this.clientSearchLog != null) {
                            debugLog('client search log='+clientSearchLog);
                            // ELC 2/6/2015 added support for ContactCreated
                            Id clientId;
                            if (clientSearchLog.Contact_Created__c != null) {
                                clientId = clientSearchLog.Contact_Created__c;
                            } else {
                                clientId = clientSearchLog.Contact_Reviewed__c;
                            }
                            //this.tempSearchedClientContact = ContactUtils.retrieveAllContactInfo(clientId);
                            //@todo rjn api versioning issues
                            excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                            this.tempSearchedClientContact = retrieveAllContactInfo(clientId, excludeFields);
                            if(sw == null) {
                                sw = new SearchWrapper();
                            }
                            sw.contact = tempSearchedClientContact;
                            this.partySectionHeaderTitle = 'Party - <font color=yellow><b>  (  '+this.calcTotalPartySlWraps()+ ' Added  )</b></font>';
                            
                        }           
                    } else if (partyReviewed !=null && slChild.Marked_as_Match__c == 'No') {
                        Search_Log_Children__c slc = PartySearchWrapper.retrievePartySearchLog(slClient.Current_SL_Party__c);
                        if(slc != null) {
                            this.currentPartySlId = slChild.id;
                            debugLog('<font color=blue>currentPartySlId='+currentPartySlId+'</font>'); 
                            this.partySearchBtnClicked = true;
                            this.partySearchBtnClickedArtificallySet = true;
                            debugLog('<font color=red>Artifically setting party searched button click to true for now</font>');                          
                            
                        } else {
                            this.partySearchBtnClickedArtificallySet = false;
                        }
                        
                        this.copyExistingPartysearch(slc);
                        if(!wasRapidCreateCaseClicked) {
                            this.doPartySearch();           
                        }
                        
                    }
                }
                }
                

                
            } else  {
            
            // ELC 2/6/2015 Added support for ContactCreated
            Id reviewedContactId;
            if (this.slClient.contact_created__c != null) {
                reviewedContactId = this.slClient.contact_created__c;
            } else {
                reviewedContactId = this.slClient.contact_reviewed__c;              
            }
            debugLog('contactReviewed='+reviewedContactId); 
            //sw.contact = ContactUtils.retrieveAllContactInfo(reviewedContactId);
                //@todo rjn api versioning issues
                Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
                sw.contact = retrieveAllContactInfo(reviewedContactId, excludeFields);
            this.tempSearchedClientContact = sw.contact;
            this.refreshSearchLogWraps();
            String msg = 'Client: '+sw.contact.firstname + ' ' + sw.contact.Lastname + ' has been added as a match.';
            
                Search_Log_Children__c slc = PartySearchWrapper.retrievePartySearchLog(slClient.Current_SL_Party__c);
                this.copyExistingPartysearch(slc);
                if(!wasRapidCreateCaseClicked) {
                    msg += 'Please search for parties.';
                    this.doPartySearch();
                }
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
            }
            
            
            
            } catch (Exception e) {
                debugLog('exception in doOnLoadSearchParties e=:'+e.getMessage() + ' line #:'+e.getLineNumber() + ' stackTrace='+e.getStackTraceString());  
            }   
            
        }
        return null;
    }
    public Boolean getAnyPartySearchLogs() {
        Boolean hasLogs = false;
        hasLogs = this.partySearchLogs != null && !this.partySearchLogs.isEmpty();
        if(hasLogs) {
            this.partySectionHeaderTitle = 'Party - <font color=yellow><b>  ( '+partySearchLogs.size()+'  Added  )</b></font>';
        }
        return hasLogs;
    }
    
    
     
    public override void initSettings() {
        super.initSettings();
        //System.debug('overriding ancestor');
    }
    
    private al.NestableCondition buildClientSearchWhere() {
        
        
        if(sw == null || sw.contact == null) {
            debugLog('cant build where clause.. sw='+sw);
            return null;
        }
        String lastName     = sw.contact.lastName; 
        String firstName    = sw.contact.FirstName;
        String phone        = sw.contact.Phone;
        
        // was causing no match - ELC   
        //if(phone!=null) {phone  = ContactUtils.stripPhone(phone); }
                
        String mi           = sw.contact.Middle_Initial_Suffix__c;
        String streetAddy   = sw.contact.MailingStreet;
        String ssn          = sw.contact.last_four_ssn__c;  //added ELC
        Date   dDob         = sw.contact.Birthdate;
        String contactId    = sw.contactIdentifier;
        
        al.NestableCondition whereC = new al.OrCondition();
        al.NestableCondition whereCand = new al.AndCondition();
        
        // we only want to look at Individuals, not Orgs
        whereCand.add(new al.FieldCondition('contact_type__c').equals('Individual'));
        
        if(phone!=null)         { whereC.add(new al.FieldCondition('c.phone').equals(phone.trim()));}
        if(dDob!=null)          { whereC.add(new al.FieldCondition('c.birthdate').equals(dDob));} 
        if(ssn != null && !ssn.equals('0') && !ssn.equals('0000'))         
                                { whereC.add(new al.FieldCondition('c.last_four_ssn__c').equals(ssn));}  // added ELC
        
        if(!Utilities.isBLANK(contactId))     { whereC.add(new al.FieldCondition('c.contact_identifier__c').likex(contactId.trim()));}
        if(!Utilities.isBLANK(contactId))     { whereC.add(new al.FieldCondition('c.legacy_Id__c').likex(contactId.trim()));}
        
        if(lastName!=null)      { 
            // made these equals rather than likex to make result set more meaningful @ELC
            whereC.add(new al.FieldCondition('c.lastname').equals(lastName.trim()));
            whereC.add(new al.FieldCondition('c.aliases__c').equals(lastName.trim()));
        }
        
        // If an exiting client search make sure there are case party records
        // commented out because this is already done every time for clients
        //if(!showNewContactSearchInputs) { whereC.add(new al.FieldCondition('of_Case_Party_Records__c',al.Operator.GREATER_THAN,0)); }
        

        clientSearchMatcher.processSearchTerms(sw);
        
        // ELC - got rid of the name equivalence because it isn't really appropriate for last name        

        al.NestableCondition whereAliases = ContactUtils.processAliases(sw.contact);
        
        if(whereAliases!=null) {
            debugLog('Adding Aliases to where:');
            whereC.add(whereAliases);
        } else {
            debugLog('No aliases being added');
        }

        whereCand.add(whereC);
        return whereCand;       
    }
    /*
    *   This method will build a where clause that looks for individual Contact records
    *   in which the LastName (w/ Alias handling) AND (DOB OR Phone OR FirstName) match
    */
    private al.NestableCondition buildClientSearchWhereAnd() {
        
        
        if(sw == null || sw.contact == null) {
            debugLog('cant build where clause.. sw='+sw);
            return null;
        }
        String lastName     = sw.contact.lastName; 
        String firstName    = sw.contact.firstName;
        String phone        = sw.contact.Phone;
        Date   dDob         = sw.contact.Birthdate;
        String contactId    = sw.contactIdentifier;

        al.NestableCondition whereC = new al.AndCondition();
        al.NestableCondition whereCor = new al.OrCondition();
        al.NestableCondition whereCor2 = new al.OrCondition();
        
        // we only want to look at Individuals, not Orgs
        whereC.add(new al.FieldCondition('contact_type__c').equals('Individual'));

        // in case it's a Quick Search and they only entered the last name
        if (phone==null && firstname==null) {
            whereC.add(new al.FieldCondition('extra_id_info__c').equals(True));
        } else {        
            if(phone!=null)         { whereCor2.add(new al.FieldCondition('c.phone').equals(phone.trim()));}
            if(dDob!=null)          { whereCor2.add(new al.FieldCondition('c.birthdate').equals(dDob));}
            if(firstName!=null)     { whereCor2.add(new al.FieldCondition('c.firstName').equals(firstName));}
            whereC.add(whereCor2);
        }

// Already do this for category = client.  If this changes overall we would want to include this again 
        // If an exiting client search make sure there are case party records
//        if(!showNewContactSearchInputs) { whereC.add(new al.FieldCondition('of_Case_Party_Records__c',al.Operator.GREATER_THAN,0)); }
        
        if(lastName!=null)      { 
            // made these equals rather than likex to make result set more meaningful @ELC
            whereCor.add(new al.FieldCondition('c.lastname').equals(lastName.trim()));
            whereCor.add(new al.FieldCondition('c.aliases__c').equals(lastName.trim()));
        }
        
        clientSearchMatcher.processSearchTerms(sw);
        
        al.NestableCondition whereAliases = ContactUtils.processAliases(sw.contact);
        
        if(whereAliases!=null) {
            debugLog('Adding Aliases to where:');
            whereCor.add(whereAliases);
        } else {
            debugLog('No aliases being added');
        }

        whereC.add(whereCor);
        return whereC;       
    }    
    private al.NestableCondition buildPartySearchWhere() {
        // We don't want to perform this search without a name.  It was getting by the first
        // two checks - partySw.contact must be instantiated somewhere.
        if(partySw == null || partySw.contact == null || 
            (partySw.contact.lastName == null && partySw.contact.Org_Name__c == null)) {
            debugLog('cant build where clause.. sw='+partySw);
            return null;
        }
        String lastName     = partySw.contact.lastName; 
        String firstName    = partySw.contact.FirstName;
        String orgName      = partySw.contact.Org_Name__c;
        String phone        = partySw.contact.Phone;
        
        //if(phone!=null) {phone  = ContactUtils.stripPhone(phone); }
                
        String mi           = partySw.contact.Middle_Initial_Suffix__c;
        String streetAddy   = partySw.contact.MailingStreet;
        Date   dDob         = partySw.contact.Birthdate;
        String ssn          = partySw.contact.Last_Four_SSN__c;
        String contactId    = partySw.contactIdentifier;
        String selAssoc     = partySw.selectedAssociation;
        
        al.NestableCondition whereC = new al.OrCondition();     
        al.NestableCondition whereCand = new al.AndCondition();
        // ELC 2/16/15 - changed to equals from like
        if(phone!=null)         { whereC.add(new al.FieldCondition('c.phone').equals(phone.trim()));}
       //----------- if(mi!=null)            { whereC.add(new al.FieldCondition('c.middle_initial_suffix__c').likex(mi.trim()));}
        if(streetAddy!=null)    { whereC.add(new al.FieldCondition('c.mailingstreet').likex(streetAddy.trim()));}
        if(dDob!=null)          { whereC.add(new al.FieldCondition('c.birthdate').equals(dDob));}
        if(ssn != null && !ssn.equals('0') && !ssn.equals('0000'))         { whereC.add(new al.FieldCondition('c.last_four_ssn__c').equals(ssn));} 
        if(!Utilities.isBLANK(contactId))     { whereC.add(new al.FieldCondition('c.contact_identifier__c').likex(contactId.trim()));}
        if(!Utilities.isBLANK(contactId))     { whereC.add(new al.FieldCondition('c.legacy_Id__c').likex(contactId.trim()));}
        
        // ELC - 3/12/2015 - changed the field condition for alias below to equals from like
        if(lastName!=null)              { 
            whereC.add(new al.FieldCondition('c.lastname').equals(lastName.trim()));
            whereC.add(new al.FieldCondition('c.aliases__c').equals(lastName.trim()));
        }
        if(orgName!=null)               { 
            whereC.add(new al.FieldCondition('c.org_name__c').likex(orgName.trim()));
            whereC.add(new al.FieldCondition('c.aliases__c').likex(orgName.trim()));
        }

         // added ELC - we only want records of the same contact type returned
        whereCand.add(new al.FieldCondition('c.contact_type__c').equals(this.selectedIndOrOrg));
        partySearchMatcher.processSearchTerms(PartySw);

        
        al.NestableCondition whereAliases = ContactUtils.processAliases(partySw.contact);
        if(whereAliases!=null) {           
            whereC.add(whereAliases);
        }   
        whereCand.add(whereC);  
        return whereCand;       
    }
    /*
    *   This method will build a where clause that looks for individual Contact records
    *   in which the LastName (w/ Alias handling) AND (DOB OR Phone OR FirstName) match
    */
    private al.NestableCondition buildPartySearchWhereAnd() {
        
        
        if(PartySw == null || PartySw.contact == null) {
            debugLog('cant build where clause.. sw='+sw);
            return null;
        }
        String lastName     = PartySw.contact.lastName; 
        String orgName      = PartySw.contact.org_name__c;
        String firstName    = PartySw.contact.firstName;
        String phone        = PartySw.contact.Phone;
        Date   dDob         = PartySw.contact.Birthdate;
        
        al.NestableCondition whereC = new al.AndCondition();
        al.NestableCondition whereCor = new al.OrCondition();
        al.NestableCondition whereCor2 = new al.OrCondition();
        al.NestableCondition whereCand = new al.AndCondition();
        
        if (phone==null && dDob == null) {
            whereC.add(new al.FieldCondition('extra_id_info__c').equals(True));
        } else {
            if(phone!=null)         { whereCor2.add(new al.FieldCondition('c.phone').equals(phone.trim()));}
            if(dDob!=null)          { whereCor2.add(new al.FieldCondition('c.birthdate').equals(dDob));}
            if(firstName!=null)     { whereCor2.add(new al.FieldCondition('c.firstName').equals(firstName));}
        
            whereC.add(whereCor2);
        }
        
        if(lastName!=null)              { 
            whereCor.add(new al.FieldCondition('c.lastname').equals(lastName.trim()));
            whereCor.add(new al.FieldCondition('c.aliases__c').equals(lastName.trim()));
        }
        if(orgName!=null)               { 
            whereCor.add(new al.FieldCondition('c.org_name__c').likex(orgName.trim()));
            whereCor.add(new al.FieldCondition('c.aliases__c').likex(orgName.trim()));
        }

         // added ELC - we only want records of the same contact type returned
        whereCand.add(new al.FieldCondition('c.contact_type__c').equals(this.selectedIndOrOrg));
        partySearchMatcher.processSearchTerms(PartySw);

        
        al.NestableCondition whereAliases = ContactUtils.processAliases(partySw.contact);
        if(whereAliases!=null) {           
            whereCor.add(whereAliases);
        }   

        whereC.add(whereCor);
        return whereC;       
    }        
    public PageReference doContinueClientSearch() {
        this.hasSavedClient = true;
        this.tempSearchedClientContact = sw.contact;
        this.tempSavedSearchedClients.add(this.tempSearchedClientContact);
        this.isCollapseClientData = true;
        this.isCollapsePartyData =  false;
        debugLog('in action doContinueClientSearch.. setting tempSearchedClientContact to:'+tempSearchedClientContact);
        return null;
    }
    public PageReference doNoClientMatches() {
        this.hasSavedClient = true;
        sw.contact.Contact_Type__c = this.selectedIndOrOrg;
        this.tempSearchedClientContact = sw.contact;
        // ELC 2/6/2015
        //sw.contact.sessionId__c = UserInfo.getSessionId();
        this.tempSearchedClientContact.status__c = 'Pending';
        // NPSP Addition - changed the default to Donor, so need to set to Client here
        this.tempSearchedClientContact.category__c = 'Client';
        this.tempSearchedClientContact.preferred_address_type__c = 'Home';
        //sw.contact.status__c = 'Pending';
        try {
            upsert this.tempSearchedClientContact;
            updateLeadStatus(leadId);
            //upsert sw.contact;
        } catch (Exception e) {
            debugLog(e.getStackTraceString());
            System.debug(logginglevel.error,e);
            Utilities.sendEmail('rnendza@gmail.com','error in doClientMatched '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());
        }
        this.tempSavedSearchedClients.add(this.tempSearchedClientContact);
        // ELC 2/6/2015 - added next line
        sw.contact = tempSearchedClientContact;
        this.isCollapseClientData = true;
        this.isCollapsePartyData =  false;
        //this.clientSearchLog = this.writeSearchLog('Client', sw);

        //this is essentially a match since we are creating on the fly because
        //no match was found when searching
        // ELC 2/6/2015 - set the ContactReviewed field on the SearchLog to null
        // and set ContactCreated to the new ContactId
        this.clientSearchLog.contact_reviewed__c = null;
        this.clientSearchLog.contact_created__c = tempSearchedClientContact.id;
        update this.clientSearchLog;
        // moved the following line below the update
        /*super*/slClient = this.clientSearchLog;        
        System.debug(logginglevel.warn,'clientSearchLog='+clientSearchLog + ' sw.contact='+sw.contact);
        super.updateSearchLogMatchStatus('Yes',this.clientSearchLog.id,sw.Contact.id,'Client');
        //-----super.updateSearchLogMatchStatus('Yes',this.clientSearchLog.id,null,'Client');
                                                        
        this.refreshSearchLogWraps();
        this.isNoClientMatchesClicked = true;
        
        debugLog('in action doNoClientMatches.. setting tempSearchedClientContact to:'+tempSearchedClientContact);
        String msg = 'Client: '+sw.contact.firstname + ' ' + sw.contact.Lastname + ' stored. Please enter Party search criteria.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));       
        return null;
    }


    public PageReference doNoPartyMatches() {
        this.isNoPartieMatchesClicked = true;
        this.tempSearchedPartyContact = partysW.contact;
        if (!(this.tempSearchedPartyContact == null)){
            debugLog('in doNoPartyMatches, tempSearchedPartyContact = '+ this.tempSearchedPartyContact.name);
        }
        this.tempSearchedPartyContact.sessionId__c = UserInfo.getSessionId();
        tempSearchedPartyContact.Contact_Type__c = this.selectedIndOrOrg;
        // ELC - added 10/9/15
        if(slClient != null && slClient.AddPartyFromCase__c != null) {
            tempSearchedPartyContact.Status__c = 'Current';
        } else {
            tempSearchedPartyContact.Status__c = 'Pending';
        }
        // NPSP - If this is an Organiation, create an account for it first and tie the contact to it.
        // Then a Household Account won't be created for it.
        if (this.selectedIndOrOrg.equals('Organization')) {
            Account orgAcct = AccountUtils.buildNewOrgAccount(this.tempSearchedPartyContact);
            try {
                insert orgAcct;
            } catch (Exception e) {
                debugLog(e.getStackTraceString());
                System.debug(logginglevel.error,e);         
                Utilities.sendEmail('rnendza@gmail.com','error in doNoPartyMatches '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Error in doNoPartyMatched='+e.getStackTraceString()));          
                return null;        
            }               
            tempSearchedPartyContact.accountId = orgAcct.id;
        }
        // NPSP End Insert
        // NPSP - set a few fields to indicate that this is a force4J record rather than donor record
        if (tempSearchedPartyContact.MailingStreet != null && tempSearchedPartyContact.MailingStreet != '') {
            tempSearchedPartyContact.Preferred_Address_Type__c = 'Home';
        } 
        String assoc = partySw.selectedAssociation;
        if (assoc == 'Attorney') {
            tempSearchedPartyContact.category__c = 'Attorney';
        } else {
            tempSearchedPartyContact.category__c = 'Party'; 
        }
        try {
            upsert tempSearchedPartyContact;        
        } catch (Exception e) {
            debugLog(e.getStackTraceString());
            System.debug(logginglevel.error,e);         
            Utilities.sendEmail('rnendza@gmail.com','error in doNoPartyMatches '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Error in doNoPartyMatched='+e.getStackTraceString()));          
            return null;        
        }        
        debugLog('upserted tempSearchedPartyContact='+tempSearchedPartyContact);
        
       
        
        partySw.contact = tempSearchedPartyContact;
        debugLog('in action doNoPartyMatches.. setting tempSearchedClientContact to:'+tempSearchedPartyContact);
        // NPSP : added support for Org name.  Not really NPSP fix but noticed at that time
        String msg = '';
        if (this.selectedIndOrOrg.equals('Organization')) {
            msg = 'Party: ' + tempSearchedPartyContact.org_name__c;
        } else {
            msg = 'Party: ' + tempSearchedPartyContact.firstname + ' ' + tempSearchedPartyContact.Lastname;
        }
        msg += ' stored. Please search for another party ';
        if(slClient != null && slClient.AddPartyFromCase__c != null) {
            msg += ' or click Save & Continue to add the party to your case.';
        } else {
            msg += ' or click Save & Continue.';
        }   
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));       

        this.isCollapseClientData = true;
        //this.isCollapsePartyData =  true;
        debugLog('in action doNoPartyMatches.. setting tempSearchedPartyContact to:'+tempSearchedPartyContact);
       
        Search_Log_Children__c currentSlParty = PartySearchWrapper.retrievePartySearchLog(currentPartySlId);
        debugLog('about to update SearchLogParty for child party log:'+currentSlParty);
        //this is essentially a match since we are creating on the fly
        //since no match was found during searching.
      
        // ELC - added because I was getting null pointer error
        if (currentSlParty != null) {
            debugLog('nulling out party reviewed on current sl party because we are creating one on the fly');
            currentSlParty.Party_Reviewed__c = null;
            debugLog('setting slc.party_created__c to:'+tempSearchedPartyContact.id);
            currentSlParty.Party_Created__c = tempSearchedPartyContact.id; 
            update currentSlParty;
        }
        
        super.updatePartySearchLogMatchStatus(  'Yes',currentSlParty);
        if(slClient != null) {
            if(currentSlParty != null) {
                debugLog('updating current sl party on sl client record to:'+currentSlParty.id);
                slClient.Current_SL_Party__c = currentSlParty.id;               
            } else { //was going boom boom.. still not sure why..
                String msg1 = 'currentSlParty = null  so we can not update slClient.current_sl_party__c.....slClient='+slClient;
                debugLog(msg1);
                System.debug(logginglevel.warn,msg);
                msg1 += ' UserName ='+ User.Username;   
                Utilities.sendEmail('rnendza@gmail.com','bypass of error in doNoPartyMatches: '+Datetime.now() + ' for User ' + UserInfo.getUserId(),msg1,msg1);                        
            }               
        }
                
        this.refreshSearchLogWraps();       
        this.renderJsOpenNewParty = false;
        this.isCollapsePartyData =  true;       
        this.wasPartyAdded = true;
        this.partySectionHeaderTitle = 'Party - <font color=yellow><b>  (  '+this.calcTotalPartySlWraps()+ ' Added  )</b></font>';
       
        return null;       
    }
    /* This seems to be a deprecated class.  The only call is in test class 
        TEST_vfIntakeClientSearch. The other call in vfIntakeSearchPage is commented out.
    */
    public PageReference doContinuePartySearch() {
        this.tempSearchedPartyContact = partysW.contact;
        this.isCollapseClientData = true;
        this.isCollapsePartyData =  true;
        debugLog('in action doContinuePartySearch.. setting tempSearchedPartyContact to:'+tempSearchedPartyContact);
        //insert contact.. open new tab with client (ie.. lay down some js)
        //insert this.tempSearchedPartyContact;
        
        this.tempSearchedClientContact.sessionId__c = UserInfo.getSessionId();
        debugLog('in action doContinuePartySearch.. tempSearchedClientContact.Org_Name__c = '+tempSearchedClientContact.Org_Name__c);
        try {      
            upsert this.tempSearchedClientContact;
        } catch (Exception e) {
            debugLog(e.getStackTraceString());
            System.debug(logginglevel.error,e);         
            Utilities.sendEmail('rnendza@gmail.com','error in doContinue PartySearch upserting tempSearchedClientContact '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());    
        }    
        tempSearchedPartyContact.Related_Party__c = tempSearchedClientContact.id;
        tempSearchedPartyContact.type__c = 'Interested Party';
        tempSearchedPartyContact.Contact_Type__c = this.selectedIndOrOrg;
        tempSearchedPartyContact.sessionId__c = UserInfo.getSessionId();
        try {      
            upsert this.tempSearchedPartyContact;
        } catch (Exception e) {
            debugLog(e.getStackTraceString());
            System.debug(logginglevel.error,e);         
            Utilities.sendEmail('rnendza@gmail.com','error in doContinue PartySearch upserting tempSearchedPartyContact '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());     
        }    
        this.renderJsOpenNewParty = true;
        
        return null;
    }

    public PageReference doAddPartySearch() {   
        
        showPartySearchLogs = true;
        if(this.partySearchBtnClicked) {
            //debugLog('about to writeSearchLogParty for parent client log:'+this.clientSearchLog);
            //System.debug(logginglevel.info,'about to writeSearchLogParty for parent client log:'+this.clientSearchLog);
            //this.writeSearchLogParty('Adverse Party', 'No',partySw, this.clientSearchLog);
            debugLog('in doAddPartySearch');
            debugLog('cleintSearchLog='+this.clientSearchLog);  
        }
        this.refreshSearchLogWraps();
             
        this.partySw = new PartySearchWrapper();
       // this.allPartyResults = null;
       // this.allPartySearchResults = null;
       // this.matchedPartySearchResults = null;
        this.isPartySearchResultsFound = false;
        this.isCollapsePartyData = false;    
        this.yesPartyMatchExists = false;
               

        return null;       
    }
    // This method will build an SOQL query, for either an Or'd search, or a more refined
    // AND search.
    private String buildPartySoql(Boolean pIsAndSearch){
        
        this.partySearchMatcher = new PartySearchMatcher();
        al.NestableCondition whereCor = this.buildPartySearchWhereAnd();
    
        if(whereCor == null) {
            return null;
        }   
        al.NestableCondition whereCand = new al.AndCondition();
                
        /** ELC 10/17/16 - simplified category to just look for nbull or blank
        al.NestableCondition whereCandCats = new al.AndCondition();
 
        al.NestableCondition whereCorCats = new al.OrCondition();

        whereCandCats.add(new al.SetCondition('category__c',al.Operator.INCLUDES,getPartyOrphanSearchCategories()));
        whereCandCats.add(new al.FieldCondition('of_Case_Party_records__c').greaterthan(0));
        whereCorCats.add(whereCandCats);
        whereCorCats.add(new al.SetCondition('category__c',al.Operator.INCLUDES,getPartyOtherSearchCategories()));
            
        whereCand.add(whereCorCats);
        **/
        whereCand.add(whereCor);
        whereCand.add(new al.FieldCondition('category__c').notequals(null));
        whereCand.add(new al.FieldCondition('category__c').notequals(''));         
        //ELC - 10/12/15 whereCand.add(new al.NotCondition(new al.AndCondition().add(new al.FieldCondition('status__c','Pending'))));
        //ELC - 10/12/15 debugLog('<font color=red>Note! excluding parties with a status of Pending</font>');
        if(slClient != null) {
            debugLog('In buildPartySoql.. found parent sl.');
        } else {
            debugLog('In buildPartySoql.. did NOT found parent sl.');
        }
        
        String tsoql = '';
                   
        tsoql = new al.SoqlBuilder()
                .selectx(new Set<String> {'id','name','phone', 'contact_identifier__c','MailingStreet','Email','MailingCity' })
                .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c', 'MailingPostalCode' })
                .selectx(new Set<String> {'LastModifiedDate','firstname','lastname', 'last_four_SSN__c','Aliases__c' })
                .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c', 'Org_Name__c' })             
                .selectx(new Set<String> {'last_service_date__c','type__c' })   
                .selectx(new Set<String> {'category__c','Category_Icon__c'})
                //-- case party children needed for findContactAssociation in searchmatcher
                .selectx(
                   new al.SoqlBuilder()
                    .selectx(new Set<String> {'id','name','type__c','case__r.id','case__r.subject' })
                    .selectx(new Set<String> {'case__r.contact.id','case__r.contact.name' })
                    .fromx('Case_Parties__r'))
                    
                .fromx  ('Contact c ')
                .wherex (whereCand)
// Don't need an order by clause for the AND search.  May need to add back in if this function
// is used for the OR SOQL search as well
//                .orderByx(new List<al.OrderBy>{
//                    new al.OrderBy('phone').ascending().nullsLast()
//                    ,new al.OrderBy('last_four_SSN__c').ascending().nullsLast()
//                    ,new al.OrderBy('aliases__c').ascending().nullsLast()
//                    ,new al.OrderBy('lastname').ascending()
//                    ,new al.OrderBy('firstname').ascending().nullsLast()
//                })
                .limitx( contactSearchResultsLimit )                    
                .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators()); 
                
            return tSoql;        
        
    }    
    public PageReference doPartySearch() {
        debugLog('doing party search');
        String soql = '';

        // If there is no party data on which to search, return null        
        if(partySw == null || partySw.contact == null || 
            (partySw.contact.lastName == null && partySw.contact.Org_Name__c == null)) {
            debugLog('in doPartySearch with empty or incomplete sw.. sw='+partySw);
            return null;
        }
        if(!getIsSoslPartySearch() || showDebugMessages) { //don't waste time doing this block if we are doing sosl search and debugging is off.
        
            this.partySearchMatcher = new PartySearchMatcher();
            al.NestableCondition whereCor = this.buildPartySearchWhere();
    
            if(whereCor == null) {
             return null;
            }   
        
            al.NestableCondition whereCandCats = new al.AndCondition();
            al.NestableCondition whereCand = new al.AndCondition(); 
            al.NestableCondition whereCorCats = new al.OrCondition();

            // ELC 10/17/2016 Removed category from consideration in the search
            //whereCandCats.add(new al.SetCondition('category__c',al.Operator.INCLUDES,getPartyOrphanSearchCategories()));
            //whereCandCats.add(new al.FieldCondition('of_Case_Party_records__c').greaterthan(0));
            //whereCorCats.add(whereCandCats);
            //whereCorCats.add(new al.SetCondition('category__c',al.Operator.INCLUDES,getPartyOtherSearchCategories()));
            whereCand.add(new al.FieldCondition('category__c').notequals(null));
            whereCand.add(new al.FieldCondition('category__c').notequals(''));          
            //whereCand.add(whereCorCats);
            whereCand.add(whereCor);
            //ELC - 10/12/15
            //whereCand.add(new al.NotCondition(new al.AndCondition().add(new al.FieldCondition('status__c','Pending'))));
            //debugLog('<font color=red>Note! excluding parties with a status of Pending</font>');
            if(slClient != null) {
                debugLog('In doPartySearch.. found parent sl.');
 
            } else {
                debugLog('In doPartySearch.. did NOT found parent sl.');
            }
            //---whereCand.add(whereCor);
                    
                 soql = new al.SoqlBuilder()
                    .selectx(new Set<String> {'id','name','phone', 'contact_identifier__c','MailingStreet','Email','MailingCity' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c', 'MailingPostalCode' })
                    .selectx(new Set<String> {'LastModifiedDate','firstname','lastname', 'last_four_SSN__c','Aliases__c' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c', 'Org_Name__c' })             
                    .selectx(new Set<String> {'last_service_date__c','type__c' })   
                    .selectx(new Set<String> {'category__c','Category_Icon__c'})
                    //-- case party children needed for findContactAssociation in searchmatcher
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'id','name','type__c','case__r.id','case__r.subject' })
                        .selectx(new Set<String> {'case__r.contact.id','case__r.contact.name' })
                        .fromx('Case_Parties__r'))
                    
                    .fromx  ('Contact c ')
                    .wherex (whereCand)
                    .orderByx(new List<al.OrderBy>{
                        // TODO - ELC check this.  commented out becaue it was affecting results.
                        //  May want to add back in, but as category__c rather than type__c
                        //new al.OrderBy('type__c').descending().nullsLast(),
                        new al.OrderBy('phone').ascending().nullsLast()
                        ,new al.OrderBy('last_four_SSN__c').ascending().nullsLast()
                        ,new al.OrderBy('aliases__c').ascending().nullsLast()
                        ,new al.OrderBy('lastname').ascending()
                        ,new al.OrderBy('firstname').ascending().nullsLast()
                    })
                    .limitx( contactSearchResultsLimit )                    
                    .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators()); 
        }               
        
        try {   
            if( !getIsSoslPartySearch() )  {
                debuglog('<b>PARTY SOQL=</b>'+soql);    
                this.allPartyResults = Database.query (soql);
                this.hasPartySearched = true;
            } else {
                //experimental sosl...
                // added the replace here so that names with hyphens will be found by the
                // sosl if they are in the system with a space instead
                String lastname = partySw.contact.lastName;
                if(lastName != null) {
                    lastName = lastName.replace('-',' '); 
                    lastName = String.escapeSingleQuotes(lastName);
                }           

                    
                String firstName    = partySw.contact.FirstName;
                if(firstname != null) {
                    firstName = String.escapeSingleQuotes(firstName);
                }               
                String orgName      = partySw.contact.Org_Name__c;
                if(orgName != null) {
                    orgName = String.escapeSingleQuotes(orgName);
                }               
                String phone        = partySw.contact.Phone;
                String alias        = partySw.contact.aliases__c;
                if(alias != null) {
                    alias = String.escapeSingleQuotes(alias);
                }               
            
                String mi           = partySw.contact.Middle_Initial_Suffix__c;
                String streetAddy   = partySw.contact.MailingStreet;
                Date   dDob         = partySw.contact.Birthdate;
                // ELC 2/16/15 added text birthdate
                String tempDate     = String.valueOf(partySw.contact.Birthdate);
                String dob = null;
                if (tempDate != null) {
                    dob             = tempDate.replace('-','');
                } 
                String ssn          = partySw.contact.Last_Four_SSN__c;
                String contactId    = partySw.contactIdentifier;
                String selAssoc     = partySw.selectedAssociation;
                String sContactType = this.selectedIndOrOrg;
                
                String sosl = ''; 
                sosl += ' FIND ';
                if('Individual' == this.selectedIndOrOrg) {             
                    sosl += '       \''+lastName;
                    // ELC 2/16/2015
                    if(dob != null) {                   
                        sosl += '   OR   '+dob; 
                    }
                } else { // org search
                    sosl += '       \''+orgName;
                                    
                }
                if(phone != null && phone != '') {
                    sosl += '   OR  '   +phone;
                }
                if(streetAddy != null && streetAddy != '') {
                    sosl += '   OR  '   +streetAddy;
                }   

                
                if(alias != null && alias != '') {          
                    sosl += '   OR  '   +alias +'\'';
                } else {
                    sosl += '\'';
                }           
                
                List<String> partyOrphanSearchCategories = getPartyOrphanSearchCategories();
                List<String> partyOtherSearchCategories = getPartyOtherSearchCategories();
                String sPartyOrphanCategories = '';
                String sPartyOtherCategories = '';
                
                if(partyOrphanSearchCategories != null && !partyOrphanSearchCategories.isEmpty()) {
                    for(String sOrphanCat : partyOrphanSearchCategories) {
                        sPartyOrphanCategories +=  '\''+sOrphanCat+'\','; 
                    }
                }
                if(sPartyOrphanCategories != '') {
                    sPartyOrphanCategories = al.StringUtils.chomp(sPartyOrphanCategories,',');
                }
                    
                debugLog('---sPartyOrphanCategories='+sPartyOrphanCategories);
                
                if(partyOtherSearchCategories != null && !partyOtherSearchCategories.isEmpty()) {
                    for(String sOtherCat : partyOtherSearchCategories) {
                        sPartyOtherCategories +=  '\''+sOtherCat+'\','; 
                    }
                }
                if(sPartyOtherCategories != '') {
                    sPartyOtherCategories = al.StringUtils.chomp(sPartyOtherCategories,',');
                }
                    
                debugLog('---sPartyOtherCategories='+sPartyOtherCategories);
                
                sosl += ' IN ALL FIELDS '; //-- cant really tighten this unfortunately.
                
                sosl += ' RETURNING Contact ';
                
                sosl += '(  id,firstname,lastname,phone,birthdate,last_four_ssn__c,mailingstreet, ';
                sosl += ' Middle_Initial_Suffix__c, Aliases__c, Category__c, Category_Icon__c, ';
                sosl += ' last_service_date__c,LastModifiedDate,email,org_name__c, text_birthdate__c ';
                
                sosl += ' WHERE '; 
                /** ELC 10/17/2016  removed category from consideration in search **/
                // Added back in - was causing issues until we can keep users from doing TabX
                if(sPartyOrphanCategories != null && sPartyOrphanCategories != '') {
                    sosl += '       ((category__C  INCLUDES ( '+sPartyOrphanCategories+')  and ';
                    sosl += '        of_Case_Party_records__c > 0 and status__c != \'Pending\') ';
                }
                if(sPartyOtherCategories != null && sPartyOtherCategories != '') {
                    sosl += '       OR category__c INCLUDES ( '+sPartyOtherCategories+')) and ';
                } else {
                    sosl += '       ) and ';
                }

                
                sosl += '   (contact_type__c = \''+sContactType+'\' ';  
                //sosl += ' and category__c != null ';     // ELC - not needed with category logic added back in above         
                sosl += ' ) ';
/** ELC 9/4/15 I am going to try this without this portion of the where clause.  The risk is that it will
**  too often return the max number of rows, but will allow for the 'fuzzy' logic of SOSL
                if('Individual' == this.selectedIndOrOrg) {
                        sosl += '   and (lastname = \''+lastname +'\'';
                        if(phone!= null && phone != '') {
                            sosl += '           or phone = \'' +phone+'\'';
                        }                       
                        sosl += '           or aliases__c = \''+lastName +'\'';
                        if(dDob !=null) {
                            sosl += '           or birthdate = :dDob ';
                        }
                        if(alias != null && alias != '') {          
                            sosl += '           or ( aliases__c = \''+alias+'\'';
                            sosl += '                   or lastname = \''+alias+'\'';
                            sosl += '               ) ';
                        } 
                        sosl += '       )';



                                                
                } else {
                    //org search
                    sosl += '    and ( org_name__c like \''+orgName +'%\'';
                    sosl += '           or aliases__c = \''+orgname +'\'';                  
                    if(alias != null) {
                        sosl += '           or aliases__c = \''+alias +'\'';                        
                    }
                    if(phone != null) {
                        sosl += '           or phone = \''+phone +'\'';
                    }
                    sosl += ' ) ';        
                }        
 **/            
// ELC the order by won't prioritize rows returned in SOSL search.  And we are reordering anyway                                        
//              sosl += ' ORDER BY  phone ASC NULLS LAST ';
//              sosl += '           ,aliases__c ASC NULLS LAST ';
//              sosl += '           ,lastname  ASC ';
//              sosl += '           ,firstname ASC NULLS LAST ';
                sosl += '   )   '; 
                //--- note. if not specific a limit of 2000 is the default (and max) specified by sfdc.
                                
                debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE  PARTY SOSL CALL:'+sosl+'</b></font>');  
                debugLog('SOQL would be:'+soql);
                List<List<SObject>> searchList = search.query(sosl);
                debugLog('<font color=green><b>'+ DateTime.now() +' AFTER PARTY SOSL CALL</b></font>'); 
                this.allPartyResults = ((List<Contact>)searchList[0]);                      
                this.hasPartySearched = true;
            }

        } catch (Exception e)  {
            //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
            super.errorLog(e,'<b>ERROR IN party SEARCH SOQL');
        }
            // ELC 2/18/2015 - extend intake search when max rows returned
            // Note that since the WHERE clause is applied after the limit of 2000 is imposed,
            // I made the limit here a little lower to account for records that were excluded.
            // This number was chosen randomly and may need to be adjusted.
            if (allPartyResults !=null && !allPartyResults.isEmpty() && allPartyResults.size() >= 1900) {
                /*   If 2000 rows are returned, that means that we are going to be missing
                    some records that will not be compared.  This method uses a tighter
                    search as a follow up.
                */ 
                soql = buildPartySoql(true);
                try {
                    refinedPartySearch = true; 
                    debugLog(DateTime.now()+'<b>REFINING party search SOQL=</b>' +soql);  
                    this.allPartyResults = database.query(soql);                    
                    debugLog(DateTime.now()+'<b>DONE EXECUTING SOQL</b>' +soql);    
                } catch (Exception e){
                    super.errorLog(e,'<b>ERROR IN REFINING PARTY SOQL ' + e.getMessage() + ' SOQL='+ soql + '</b>');
                }
                String msg = 'Maximum Number of Records Returned - a more granular search was performed.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
            }        
        if(allPartyResults !=null && !allPartyResults.isEmpty()) {
            
            this.isPartySearchResultsFound = true;
        
            super.debugLog('# of rows found='+allPartyResults.size());
            //--rjn check here
            partySearchMatcher.processSearchTerms(partySw); 
            if (this.selectedIndOrOrg == 'Organization') {
                partySearchMatcher.buildOrgMatches(allPartyResults, partySw  );
            } else {
                partySearchMatcher.buildMatches(allPartyResults, partySw  );
            }
             //-- @TODO eval this. 
            allPartyResults = null;           
            if(this.partySearchMatcher != null) {
            if (this.partySearchMatcher.debugMessages != null) {
                if (this.partySearchMatcher.debugMessages.size() + debugMessages.size() < MAX_DEBUG_MESSAGES) {
                    debugMessages.addAll(partySearchMatcher.debugMessages);
                }
            }
            }
            
            this.allPartySearchResults = partySearchMatcher.allContactResults;
            this.allPartySearchResults = partySearchMatcher.buildSlMatches(allPartySearchResults,slClient);
            this.matchedPartySearchResults = partySearchMatcher.someContactResults; 
            this.matchedPartySearchResults = partySearchMatcher.buildSlMatches(matchedPartySearchResults,slClient);
            
            super.debugLog('All results size='+allPartySearchResults.size());
            //rjn moved to below super.debugLog('Matched results size='+matchedPartySearchResults.size());

            if (this.matchedPartySearchResults != null) {
                super.debugLog('Matched results size='+matchedPartySearchResults.size());
            
                matchedPartySearchResults.sort();
                super.debugLog('Just sorted matched results'+matchedPartySearchResults);
                if(allPartySearchResults != null && allPartySearchResults.size() > contactSearchDisplayLimit) {
                 allPartySearchResults = subsetContactResults(allPartySearchResults, contactSearchDisplayLimit);                
                 debugMessages.add(new DebugMessage('xxxnew size of allPartySearchResults='+allPartySearchResults.size()));
                }            
                if(matchedPartySearchResults != null && matchedPartySearchResults.size() > contactSearchDisplayLimit) {
                 matchedPartySearchResults = subsetContactResults(matchedPartySearchResults, contactSearchDisplayLimit);                
                 debugMessages.add(new DebugMessage('xxxnew size of matchedPartySearchResults='+matchedPartySearchResults.size()));
                }                  
            }
        } else {
            this.isPartySearchResultsFound = false;
            this.allPartyResults = null;
            this.matchedPartySearchResults = null;
        
            super.debugLog(' NO ROWS FOUND ');
        }
        debugLog('checking if search btn was clicked (party)='+partySearchBtnClicked);
        debugLog('value of addPartySearchBtnClicked:'+addPartySearchBtnClicked);
        if(this.partySearchBtnClicked && !this.partySearchBtnClickedArtificallySet) {
            debugLog('writing sl for Party');
            this.currentPartySlId = this.writeSearchLogParty(partySw.selectedAssociation,'No',partySw,this.clientSearchLog);
            //this.clientSearchLog = this.writeSearchLog('Client', sw);
        }       
            // ELC - added to try to force looking at Yes matches
            String msg = '';
            if(matchedPartySearchResults != null && matchedPartySearchResults.size() > 0) {
                ContactResult pcr = matchedPartySearchResults[0];
                yesPartyMatchExists = pcr.autoMatch == 'Yes' && !(pcr.markedAsMatch == 'No');
                debugMessages.add(new DebugMessage('yesPartyMatchExists = '+yesPartyMatchExists));
                msg = 'Please review your results.';
            } else {
                msg = 'Please review your results or click [Save & Continue] at bottom of search results to create a new Party.';
            }     
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        this.partySearchBtnClickedArtificallySet = false;
        return null;
    }
    public PageReference doClearClientSearch() {
        super.debugLog(' In do clear client search ');
        Boolean success = false;
        if(this.clientSearchLog != null) {
            super.debugLog(' deleting this.clientSearchL<og ');
            try {
                success = DmlUtils.DBDelete(clientSearchLog);                       
            } catch (Dmlexception dmlEx) {
                debugLog(dmlEx.getMessage());
            } catch (Exception e) {
                debugLog(e.getMessage());
            }
        }  else {
            debugLog('No client search log currently in scope.. just fake like clear search worked');
            success = true;
        }
        
        if(success) {
            String msg = 'Search successfully cleared!';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        } else {
            String msg = 'Clearing search failed!';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,msg));                      
        }   
        this.clientSearchLog = null;
        this.isNoClientMatchesClicked = false;
        this.isClientMatched = false;
        this.slWraps = null;
        this.tempSearchedClientContact = null;
        
        
        sw = new SearchWrapper();
        this.allContactResults = null;
        this.matchedContactSearchResults = null;
        this.isContactSearchResultsFound = false;
        this.hasClientSearched = false;
        this.hasSearched = false;
        this.yesClientMatchExists = false;
        
        this.doClearPartySearch();
        return null;
            
    }   
    public PageReference doClearPartySearch() {
        this.partySw = new PartySearchWrapper();
        this.tempSearchedClientContact = null;
        this.allPartyResults = null;
        this.allPartySearchResults = null;
        this.matchedPartySearchResults = null;
        this.isPartySearchResultsFound = false;
        this.partySearchBtnClicked = false;
        //this.hasSearched = false;
        this.hasPartySearched = false;
        this.yesPartyMatchExists = false;
        return null;    
    }
    private String buildClientSoql(Boolean pIsAndSearch){
        
        al.NestableCondition whereCor;
        if (pIsAndSearch) {
            whereCor = this.buildClientSearchWhereAnd();
        } else {
            whereCor = this.buildClientSearchWhere();
        }
        if(whereCor == null) {
            return null;
        }

        //al.NestableCondition whereCandCats = new al.AndCondition();
        al.NestableCondition whereCand = new al.AndCondition(); 
        //al.NestableCondition whereCorCats = new al.OrCondition();

        /** ELC 10/17/16 simplified cateogry criteria to just exclude those with null or blank category
        List<String> sCats = new List<String>();
        List<String> sOtherCats = new List<String>();
        if(showNewContactSearchInputs) {
            sCats = getClientOrphanSearchCategories();
            sOtherCats = getClientOtherSearchCategories();
        } else {
            // An existing client search will always exclude all orphans
            sCats = getExistingClientSearchCategories();
        }

        if(sCats != null && !sCats.isEmpty() ) {
            whereCandCats.add(new al.SetCondition('c.category__c',al.Operator.INCLUDES,sCats));
            whereCandCats.add(new al.FieldCondition('c.of_case_Party_records__c').greaterthan(0));
            whereCorCats.add(whereCandCats);
        } 
        if(sOtherCats != null && !sOtherCats.isEmpty()) {
            whereCorCats.add(new al.SetCondition('c.category__c',al.Operator.INCLUDES,sOtherCats));
        }
        if(whereCorCats != null) {
            whereCand.add(whereCorCats);
        }
        al.NestableCondition whereCStatus = new al.OrCondition();
        // ELC - changed to exclude pending rather than include others - added statuses
        //ELC - 10/12/15 whereCStatus.add(new al.NotCondition(new al.FieldCondition('status__c','Pending')));
        whereCand.add(whereCStatus);
        **/
        
        whereCand.add(whereCor);
        whereCand.add(new al.FieldCondition('category__c').notequals(null));
        whereCand.add(new al.FieldCondition('category__c').notequals(''));        
        String tsoql = '';
        
        tsoql = new al.SoqlBuilder()
                    .selectx(new Set<String> {'id','name','phone', 'contact_identifier__c','MailingStreet','Email' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c' })
                    .selectx(new Set<String> {'LastModifiedDate','firstname','lastname', 'last_four_SSN__c','Aliases__c' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c' })                
                    .selectx(new Set<String> {'last_service_date__c' }) 
                    .selectx(new Set<String> {'category__c','category_icon__c'})
                    //-- case party children needed for findContactAssociation in searchmatcher
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'id','name','type__c','case__r.id','case__r.subject' })
                        .selectx(new Set<String> {'case__r.contact.id','case__r.contact.name' })
                        .fromx('Case_Parties__r'))
 
                    .fromx  ('Contact c ')
                    .wherex (whereCand)
                    .limitx (3000)
 // don't need an order by clause for the AND search.  May need to add back in conditionally
 // if this function is used for the OR SOQL search also                   
 //                   .orderByx(new List<al.OrderBy>{
 //                       new al.OrderBy('birthdate').ascending().nullsLast()
 //                       ,new al.OrderBy('last_four_SSN__c').ascending().nullsLast()
 //                       ,new al.OrderBy('aliases__c').ascending().nullsLast()
 //                       ,new al.OrderBy('lastname').ascending()
 //                       ,new al.OrderBy('firstname').ascending().nullsLast()
 //                   })
                    .toSoql ();

        return tSoql;                    
    }
    public PageReference doClientSearch() {
         
        this.clientSearchMatcher = new SearchMatcher();
        String soql='';
        
        if(!getIsSoslClientSearch() || showDebugMessages) { //don't waste time doing this block if we are doing sosl search and debugging is off.
            al.NestableCondition whereCor = this.buildClientSearchWhere();
            if(whereCor == null) {
                return null;
            }
            al.NestableCondition whereCand = new al.AndCondition();   
            whereCand.add(whereCor);        
            /* ELC 10/17/2016 removed category from the queries 
            al.NestableCondition whereCandCats = new al.AndCondition();
            al.NestableCondition whereCand = new al.AndCondition(); 
            al.NestableCondition whereCorCats = new al.OrCondition();

            List<String> sCats = new List<String>();
            List<String> sOtherCats = new List<String>();
            if(showNewContactSearchInputs) {
                debugLog('We are doing a new contact search');
                
                debugLog('categories to search are:'+getClientOrphanSearchCategories());
                sCats = getClientOrphanSearchCategories();
                debugLog('other categories to search are:'+getClientOtherSearchCategories());
                sOtherCats = getClientOtherSearchCategories();
            } else {
                debugLog('We are doing an existing contact search');
                // An existing client search will always exclude all orphans
                sCats = getExistingClientSearchCategories();
                debugLog('categories to search are:'+getExistingClientSearchCategories());
            }

            if(sCats != null && !sCats.isEmpty() ) {
                whereCandCats.add(new al.SetCondition('c.category__c',al.Operator.INCLUDES,sCats));
                whereCandCats.add(new al.FieldCondition('c.of_case_Party_records__c').greaterthan(0));
                whereCorCats.add(whereCandCats);
            } 
            if(sOtherCats != null && !sOtherCats.isEmpty()) {
                whereCorCats.add(new al.SetCondition('c.category__c',al.Operator.INCLUDES,sOtherCats));
            }
            if(whereCorCats != null) {
                whereCand.add(whereCorCats);
            }
            al.NestableCondition whereCStatus = new al.OrCondition();
            // ELC - changed to exclude Pending rather than include others
            //ELC - 10/12/15 whereCStatus.add(new al.NotCondition(new al.FieldCondition('status__c','Pending')));
            whereCand.add(whereCStatus);
        
            //ELC - 10/12/15 debugLog('<font color=red>Note! excluding clients with a status of Pending</font>');            

             */
            whereCand.add(new al.FieldCondition('c.category__c').notequals(null));
        
                   
                soql = new al.SoqlBuilder()
                    .selectx(new Set<String> {'id','name','phone', 'contact_identifier__c','MailingStreet','Email' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c' })
                    .selectx(new Set<String> {'LastModifiedDate','firstname','lastname', 'last_four_SSN__c','Aliases__c' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c' })                
                    .selectx(new Set<String> {'last_service_date__c' }) 
                    .selectx(new Set<String> {'category__c','category_icon__c'})
                    //-- case party children needed for findContactAssociation in searchmatcher
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'id','name','type__c','case__r.id','case__r.subject' })
                        .selectx(new Set<String> {'case__r.contact.id','case__r.contact.name' })
                        .fromx('Case_Parties__r'))
                        
                
                    .fromx  ('Contact c ')
                    //.wherex   (whereCor)
                   
                    .wherex (whereCand)
                    
                    .orderByx(new List<al.OrderBy>{
                        new al.OrderBy('phone').ascending().nullsLast()
                        ,new al.OrderBy('last_four_SSN__c').ascending().nullsLast()
                        ,new al.OrderBy('aliases__c').ascending().nullsLast()
                        ,new al.OrderBy('lastname').ascending()
                        ,new al.OrderBy('firstname').ascending().nullsLast()
                    })
                    
                    
                    .limitx( contactSearchResultsLimit )                    
                    .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators());    
        }
        String sosl = '';
            try {   
                
                if( !getIsSoslClientSearch() )  {
                    debugLog(DateTime.now()+'<b>client SOQL=</b>' +soql);  
                    this.allContactResults = Database.query (soql);
                    debugLog(DateTime.now()+'<b>DONE EXECUTING SOQL</b>' +soql);                
                } else {                
                    //--- SOSL Version
                    String lastName     = sw.contact.lastName; 
                    if(lastName != null) {
                        lastname = lastname.replace('-',' ');
                        lastName = String.escapeSingleQuotes(lastName);
                    }
                    String firstName    = sw.contact.FirstName;
                    if(firstname != null) {
                        firstName = String.escapeSingleQuotes(firstName);
                    }
                    String phone        = sw.contact.Phone;
                    String mi           = sw.contact.Middle_Initial_Suffix__c;
                    String streetAddy   = sw.contact.MailingStreet;
                    String ssn          = sw.contact.last_four_ssn__c; 
                    Date   dDob         = sw.contact.Birthdate;
                    // ELC 2/16/15 added text birthdate
                    String tempDate     = String.valueOf(sw.contact.Birthdate);
                    String dob          = null;
                    if (tempDate != null) {
                        dob = tempDate.replace('-','');
                    }
                    String alias        = sw.contact.aliases__c;
                    
                    if(alias != null) {
                        alias = String.escapeSingleQuotes(alias);
                    }                   
                    String contactId    = sw.contactIdentifier;
                    String sContactType = 'Individual';
                
                    
                    
                    if(showNewContactSearchInputs) {    //--- NORMAL (NON QUICK SEARCH)
                        debugLog('--- normal client search (non quick search)');                
                        sosl += ' FIND ';
                        sosl += '       \' '+lastName;
                        sosl += '   OR  '   +phone;
                        if(streetAddy != null && streetAddy != '') {
                            sosl += '   OR  '   +streetAddy;
                        }
                        debugLog('ssn = '+ssn);
                        if(ssn != null && !ssn.equals('0') && !ssn.equals('0000')) {
                            debugLog('adding SSN to client search');
                            sosl += '   OR  '   +ssn;
                        }
                        sosl += '   OR  '   +dob;
                        if(alias != null && alias != '') {          
                            sosl += '   OR  '   +alias +'\'';
                        } else {
                            sosl += '\'';
                        }
                        /* ELC 10/17/2016 Removed category from search criteria */
                        // ELC 11/23/16 added back in until we can keep users from closing the tab
                        List<String> clientOrphanSearchCategories = getClientOrphanSearchCategories(); 
                        List<String> clientOtherSearchCategories = getClientOtherSearchCategories(); 
                
                
                        String sClientOrphanCategories = '';
                        if(clientOrphanSearchCategories != null && !clientOrphanSearchCategories.isEmpty()) {
                            for(String sCat : clientOrphanSearchCategories) {
                                sClientOrphanCategories +=  '\''+sCat+'\','; 
                            }
                        }
                        if(sClientOrphanCategories != '') {
                            sClientOrphanCategories = al.StringUtils.chomp(sClientOrphanCategories,',');
                        }
                    
                        debugLog('---sClientCategories='+sClientOrphanCategories);
                        
                        String sClientOtherCategories = '';
                        if(clientOtherSearchCategories != null && !clientOtherSearchCategories.isEmpty()) {
                            for(String sCat : clientOtherSearchCategories) {
                                sClientOtherCategories +=  '\''+sCat+'\','; 
                            }
                        }
                        if(sClientOtherCategories != '') {
                            sClientOtherCategories = al.StringUtils.chomp(sClientOtherCategories,',');
                        }
                    
                        debugLog('---sClientCategories='+sClientOtherCategories);
                                      
                        sosl += ' IN ALL FIELDS '; //-- cant really tighten this unfortunately.
                
                        sosl += ' RETURNING Contact ';
                
                        sosl += '(  id,firstname,lastname,phone,birthdate,last_four_ssn__c,mailingstreet, ';
                        sosl += ' Middle_Initial_Suffix__c, Aliases__c, Category__c, Category_Icon__c, ';
                        sosl += ' last_service_date__c,LastModifiedDate,email, text_birthdate__c ';
// Changed this so that the 'orphans' are ignored only if the category includes Client or Party                 
                        sosl += ' WHERE '; 
                        /* ELC 10/17/2016 removed category from search criteria */
                        // ELC 11/23/16 added back in until we can keep users from closing tab
                        if(sClientOrphanCategories != null && sClientOrphanCategories != '') {
                            sosl += '       ((category__C  INCLUDES ( '+sClientOrphanCategories+')  and ';
                            sosl += '         of_Case_Party_Records__c > 0 and status__c != \'Pending\')';
                        }
                        if(sClientOtherCategories != null && sClientOtherCategories != '') {
                            sosl += '         OR category__c INCLUDES ( '+sClientOtherCategories+')) and ';
                        } else {
                            sosl += '           ) and ';
                        }
                        
                        // ELC - changed to exclude Pending rather than include others
                        //sosl += '   (status__c != \'Pending\') and ';
                        sosl += '   contact_type__c = \''+sContactType+'\'  ';
                        //sosl += ' and category__c != null )';
/** ELC 9/4/15 removing this portion of the where clause to tak full advantage of SOSL capabilities             
                        sosl += '   and (phone = \'' +phone+'\'';
                        if (ssn != null && !ssn.equals('0000') && !ssn.equals('0')) {
                            sosl += '           or last_four_ssn__c = \''+ssn +'\'';
                        }
                        sosl += '           or aliases__c = \''+lastName +'\'';
                        sosl += '           or birthdate = '+String.valueOf(dDob) + '';
                        if(alias != null && alias != '') {          
                            sosl += '           or ( aliases__c = \''+alias+'\'';
                            sosl += '                   or lastname = \''+alias+'\'';
                            sosl += '               ) ';
                        } 
                        sosl += '           or lastname = \''+lastName+'\')';
 **/                    
// The ordering isn't help prioritize the SOSL search, but may be slowing it down               
//                      sosl += ' ORDER BY  phone ASC NULLS LAST ';
//                      sosl += '           ,last_four_SSN__c ASC NULLS LAST ';
//                      sosl += '           ,aliases__c ASC NULLS LAST ';
//                      sosl += '           ,lastname  ASC ';
//                      sosl += '           ,firstname ASC NULLS LAST ';
                        sosl += '   )   '; 
                        //--- note. if not specific a limit of 2000 is the default (and max) specified by sfdc.
                    } else { 
                        //- Quick search.. we can probably borrow much above and combine but readiblity sucks either way.
                        debugLog('--- QUICK SEARCH ----');
                
                        sosl += ' FIND ';
                        if(lastName != null && lastName != '') {    
                            //lastName = String.escapeSingleQuotes(lastName);                   
                            sosl += '       \''+lastName;
                        }
                        //if(firstName != null && firstName != '') {
                            //firstName = String.escapeSingleQuotes(firstName); 
                        //  sosl += '   OR  '   +firstName;
                        //}
                        if(phone != null && phone != '') {
                            sosl += '   OR  '   +phone;
                        }
                        
                        if(alias != null && alias != '') {  
                            //alias = String.escapeSingleQuotes(alias);         
                            sosl += '   OR  '   +alias +'\'';
                        } else {
                            sosl += '\'';
                        }
                    

                        List<String> clientSearchCategories = getExistingClientSearchCategories(); 
                
                        String sClientCategories = '';
                        if(clientSearchCategories != null && !clientSearchCategories.isEmpty()) {
                            for(String sCat : clientSearchCategories) {
                                sClientCategories +=  '\''+sCat+'\','; 
                            }
                        }
                        if(sClientCategories != '') {
                            sClientCategories = al.StringUtils.chomp(sClientCategories,',');
                        }
                    
                        debugLog('---sClientCategories='+sClientCategories);

                        sosl += ' IN ALL FIELDS '; //-- cant really tighten this unfortunately.
                
                        sosl += ' RETURNING Contact ';
                
                        sosl += '(  id,firstname,lastname,phone,birthdate,last_four_ssn__c,mailingstreet, ';
                        sosl += ' Middle_Initial_Suffix__c, Aliases__c, Category__c, Category_Icon__c, ';
                        sosl += ' last_service_date__c,LastModifiedDate,email, text_birthdate__c ';
                
                        sosl += ' WHERE ';
                        
                        if(sClientCategories != null && sClientCategories != '') {
                            sosl += '       (category__C  INCLUDES ( '+sClientCategories+') ) and ';
                        }
                        // ELC - changed to exclude pending rather than include others
                        //ELC - 10/12/15 sosl += '   (status__c != \'Pending\') and ';
                        sosl += '   (contact_type__c = \''+sContactType+'\' ';
                
                        //sosl += '     and of_Case_Party_Records__c > 0) ';
/** ELC 9/4/15 removing this portion of where clause to take full advantage of SOSL             
                        sosl += '   and (  lastname = \''+lastName+'\'';  
                        if(phone != null && phone != '') {
                            sosl += '       or phone = \'' +phone+'\'';
                        }
                        sosl += '           or aliases__c = \''+lastName +'\'';                     
                        
**/                     
                        sosl += '  )  ';                        
                

                        sosl += '   )   ';  
                    }   
                            
                    debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE SOSL CALL:'+sosl+'</b></font>');
                    system.debug('***SOSL Call = '+sosl);  
                    debugLog('SOQL would be:'+soql);
                    List<List<SObject>> searchList = search.query(sosl);
                    debugLog('<font color=green><b>'+ DateTime.now() +' AFTER SOSL CALL</b></font>'); 
                    this.allContactResults = ((List<Contact>)searchList[0]);
                }           
            

                    this.hasSearched = true;
                //if(this.showNewContactSearchInputs) {
                this.hasClientSearched = true;
                //}
    
            } catch (Exception e)  {
                //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
                super.errorLog(e,'<b>ERROR IN CLIENT SEARCH SOSQL ' + e.getMessage() + ' SOQL='+ sosl + '</b>');
            }       
        super.debugLog('# of rows found='+allContactResults.size());
        if(allContactResults !=null && !allContactResults.isEmpty()) {
            // ELC 2/18/2015 - extend intake search when max rows returned
            // Note that since the WHERE clause is applied after the limit of 2000 is imposed,
            // I made the limit here a little lower to account for records that were excluded.
            // This number was chosen randomly and may need to be adjusted.
            if (allContactResults.size() > 1900) {
                /*   If 2000 rows are returned, that means that we are going to be missing
                    some records that will not be compared.  This method uses a tighter
                    search as a follow up.
                */ 
                soql = buildClientSoql(true);
                try {
                    refinedSearch = true;
                    debugLog(DateTime.now()+'<b>REFINING client search SOQL=</b>' +soql);  
                    this.allContactResults = Database.query (soql);
                    debugLog(DateTime.now()+'<b>DONE EXECUTING SOQL</b>' +soql);    
                } catch (Exception e){
                    super.errorLog(e,'<b>ERROR IN REFINING CLIENT SOQL ' + e.getMessage() + ' SOQL='+ sosl + '</b>');
                }
                String msg = 'Maximum Number of Records Returned - a more granular search was performed.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
            }
            if(allContactResults !=null && !allContactResults.isEmpty()) {
            
                this.isContactSearchResultsFound = true;
        
                super.debugLog('# of rows found='+allContactResults.size());
                //--rjn check here
                debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE process search terms</b></font>');  
                this.clientSearchMatcher.processSearchTerms(sw);
                debugLog('<font color=green><b>'+ DateTime.now() +' AFTER process search terms</b></font>');
                debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE BUILD OF MATCHES</b></font>');
                this.clientSearchMatcher.buildMatches(allContactResults, sw, !this.showNewContactSearchInputs );
                 debugLog('<font color=green><b>'+ DateTime.now() +' after BUILD OF MATCHES</b></font>');
            
                //-- @TODO eval this. 
                allContactResults = null;
                //debugMessages.addAll(this.clientSearchMatcher.debugMessages);
                this.allContactSearchResults = this.clientSearchMatcher.allContactResults;
                debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE BUILD OF search log MATCHES FOR ALL RESULTS</b></font>');
                this.allContactSearchResults = this.clientSearchMatcher.buildSlMatches(allContactSearchResults,slClient);
                debugLog('<font color=green><b>'+ DateTime.now() +' AFTER BUILD OF search log MATCHES FOR ALL RESULTS</b></font>');
            
                this.matchedContactSearchResults = this.clientSearchMatcher.someContactResults; 
                debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE BUILD OF search log MATCHES FOR MATCHED RESULTS</b></font>');
              
                this.matchedContactSearchResults = this.clientSearchMatcher.buildSlMatches(matchedContactSearchResults,slClient);
                debugLog('<font color=green><b>'+ DateTime.now() +' after BUILD OF search log MATCHES FOR MATCHED RESULTS</b></font>');
                if(matchedContactSearchResults!= null) {
                    debugLog('In doClientSearch.. matchedContactResults != null');
                    debugLog('<font color=green><b>'+ DateTime.now() +' BEFORE sort of matched results</b></font>');
                    matchedContactSearchResults.sort();
                    debugLog('<font color=green><b>'+ DateTime.now() +' AFTER SORT OF MATCHED RESULTS</b></font>');
                } 

            //---
                if(allContactSearchResults != null && allContactSearchResults.size() > contactSearchDisplayLimit) {
                    allContactSearchResults = subsetContactResults(allContactSearchResults, contactSearchDisplayLimit);                 
                    debugMessages.add(new DebugMessage('xxxnew size of allContactSearchResults='+allContactSearchResults.size()));
                }            
                if(matchedContactSearchResults != null && matchedContactSearchResults.size() > contactSearchDisplayLimit) {
                    matchedContactSearchResults = subsetContactResults(matchedContactSearchResults, contactSearchDisplayLimit);                 
                    debugMessages.add(new DebugMessage('xxxnew size of matchedContactSearchResults='+matchedContactSearchResults.size()));
                }             
            //---
                // ELC - added to try to force looking at Yes matches
                String msg = '';
                if(matchedContactSearchResults != null && matchedContactSearchResults.size() > 0) {
                    ContactResult cr = matchedContactSearchResults[0];
                    yesClientMatchExists = cr.autoMatch == 'Yes' && !(cr.markedAsMatch == 'No');
                    debugMessages.add(new DebugMessage('yesClientMatchExists = '+yesClientMatchExists));
                    msg = 'Please review your results.';
                } else {
                    msg = 'Please review your results or click [Save & Continue] at bottom of search results to create a new client and add a Party search.';
                }           
                super.debugLog('All contacts results size='+allContactSearchResults.size());
                super.debugLog('Matched contacts results size='+matchedContactSearchResults.size());

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
            
                super.debugLog('<font color=red> Removing allContactResults from memory for All</font>');   
                allContactResults = null;  //@TODO Performance
            
            }
            
        } else {
            this.isContactSearchResultsFound = false;
            this.allContactResults = null;
            this.matchedContactSearchResults = null;
        
            super.debugLog(' NO CLIENT ROWS FOUND ');
            String msg = 'No results found. Please change criteria and execute search again or select [Save & Continue] to create a new client.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));           
        }
        if(this.clientSearchMatcher != null) {
            if(this.clientSearchMatcher.debugMessages != null) {
                if (this.clientSearchMatcher.debugMessages.size() + debugMessages.size() < MAX_DEBUG_MESSAGES) {
                    debugMessages.addAll(this.clientSearchMatcher.debugMessages);
                }       
            }   

        }
        
        debugLog('checking if search btn was clicked='+searchBtnClicked);
        if(this.searchBtnClicked) {
            debugLog('writing sl for client');
            this.clientSearchLog = this.writeSearchLog('Client', sw);
        }
        
        
        return null;
    }
    
    public Pagereference doSelectContact() {
        Pagereference pr = new PageReference('/'+selectedId);
        return pr;
    }
    public Pagereference doSelectParty() {
        Pagereference pr = new PageReference('/'+selectedId);
        return pr;      
    }
    public Pagereference doRemoveParty() {
        id slChildId = this.selectedPartySearchLogId;
        // moved the select inside the try statement so that if it's already deleted an exception won't be thrown
        try {
            Search_Log_Children__c slChild = [select id from Search_Log_Children__c where id =:slChildId];
            delete slChild;
        } catch (Exception e) {
            debugLog(e.getStackTraceString());
            System.debug(logginglevel.error,e);         
            Utilities.sendEmail('rnendza@gmail.com','error in doRemoveParty deleting slChild '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());    
        }
        refreshSearchLogWraps();
        this.wasRemovePartyLinkClicked = true;
        Integer totalParties = this.calcTotalPartySlWraps();
        if(totalParties == 0) {
            this.partySectionHeaderTitle = 'Party Search';
        } else  {
            this.partySectionHeaderTitle = 'Party - <font color=yellow><b>  (  '+this.calcTotalPartySlWraps()+ ' Added  )</b></font>';
        }
        
        return null;
    }
    public Pagereference doRemoveClientSl() {
        id slParentId = this.selectedClientSearchLogId;
        if(slParentId == null ) {
            debugLog('no search log client to remove!');
            return null;
        }
        try {
            Search_Log__c slParent = [select id from Search_Log__c where id =:slParentId];        
            delete slParent;
        } catch (Exception e) {
            debugLog('Nothing to delete!');
            System.debug(logginglevel.error,e);
        }
        refreshSearchLogWraps();
        String url = '/apex/vfIntakeSearch?isdtp=vw&newSearch=true';
        Pagereference pr = new Pagereference(url);
        pr.setRedirect(true);
        String msg = 'Search successfully canceled.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));    
                            
        return pr;
        
    }
    
    public Pagereference doSelectCase() {
        Pagereference pr = new PageReference('/'+selectedId);
        return pr;
    }
    public Pagereference doNoPartyToEnter() {
        debugLog('in doNoPartyToEnter');
        this.isCollapsePartyData = true;
        this.isNoPartieMatchesClicked = true;
        this.isNoPartiesClicked = true;
        
        this.partySectionHeaderTitle = 'Party - <font color=yellow><b>(  No Party Data Selected  )<b></font>';
        return null;
    }
    public Pagereference doRadioSelect() {
        super.debugLog('in doRadioSelect..selectedContactNewOrExist='+this.selectedContactNewOrExisting);
        if('New'.equalsIgnoreCase(this.selectedContactNewOrExisting) ) {
            this.showNewContactSearchInputs = true;
        } else {
            this.showNewContactSearchInputs = false;
        }
        // ELC changed 9/29/16 - toggle between New and Existing for 2.0  
        // Pulled these from doClearClientSearch but don't want to clear the search wrapper and wipe out the name, etc       
        //this.allContactResults = null;
        //this.allContactSearchResults = null;
        //this.matchedContactSearchResults = null;
        //this.isContactSearchResultsFound = false;
        this.isNoClientMatchesClicked = false;
        this.isClientMatched = false;
        this.slWraps = null;
        this.tempSearchedClientContact = null;
        
        this.allContactResults = null;
        this.matchedContactSearchResults = null;
        this.isContactSearchResultsFound = false;
        this.hasClientSearched = false;
        this.hasSearched = false;
        this.yesClientMatchExists = false;
        return null;
    }
    public Pagereference doIndOrOrgRadioSelect() {
        super.debugLog('in doIndOrOrgRadioSelect..selectedIndOrOrg='+this.selectedIndOrOrg);
        if('Organization'.equalsIgnoreCase(this.selectedIndOrOrg) ) {
            this.showOrgPartySearchInputs = true;
        } else {
            this.showOrgPartySearchInputs = false;
        }
        this.allPartyResults = null;
        this.allPArtySearchResults = null;
        this.matchedPartySearchResults = null;
        this.isPartySearchResultsFound = false;

        return null;
        
    }
    public PageReference doCreateCase() {
        
        boolean startit = true;
        Case cse = new Case();
        if(slWraps == null || slWraps.isEmpty()) {
            debugLog('could not find sl wrapper object');
            return null;
        }
        if(sw == null  || sw.contact == null) {
            debugLog('cound long find searchwrapper or contact prop in search wrapper');
            return null;
        }           
        cse.contactId = sw.contact.id;     
        cse.status = 'Open';
        cse.origin = 'Web';
        cse.No_Parties_Clicked__c = this.isNoPartiesClicked;
    
        try {      
            insert cse;
        } catch (Exception e) {
            debugLog(e.getStackTraceString());
            System.debug(logginglevel.error,e);         
            Utilities.sendEmail('rnendza@gmail.com','error in doCreateCase inserting case '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());
            return null;    
        }       
        
        this.caseInserted = cse;

        if(sw.contact.Lead__c != null){
            ContentDocumentLink[] conDocList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: sw.contact.Lead__c];
            if(!conDocList.isEmpty()){
                ContentDocumentLink[] insertconDocList = new ContentDocumentLink[]{};
                for(ContentDocumentLink conDoc : conDocList) {
                    ContentDocumentLink conDocNew = new ContentDocumentLink(LinkedEntityId = this.caseInserted.Id, ContentDocumentId = conDoc.ContentDocumentId);
                    insertconDocList.add(conDocNew);
                }

                insert insertconDocList;
            }
        }
        
        Case_Party__c  clientCp = caseUtils.retrieveCaseParty(cse.id, sw.Contact.id);
        if(clientCp != null) {
           if(clientCp.Required_Fields_Completed__c || wasRapidCreateCaseClicked) {
               this.redirectToCase = true;
           }
        }
        
        Search_Log__c slParent = SearchWrapper.retrieveSearchLog(clientSearchLog.id);
    
        if(slParent != null) {
            List<Search_Log_Children__c> slChildren = slParent.Search_Log_Children__r;
            if(slChildren != null && !slChildren.isEmpty()) {
                debugLog('evaluating search log children for case party insert');
                List<Case_Party__c> toinsertCaseParties = new List<Case_Party__c>();
                for(Search_Log_Children__c slc : slChildren) {
                    if(slc.marked_as_match__c == 'Yes') {
                        Case_Party__c cp = new Case_Party__c();
                        cp.case__c = cse.id;
                        debugLog('<font color=orange>search log child record about to insert:'+slc+'</font>');
                        // ELC 2/6/2015 - changed this to check for non-null party_created - if one was created
                        // we always should use it, even if party_reviewed wasn't cleared
                        //if(slc.party_reviewed__c == null) {
                        if (slc.party_created__c != null) {
                            cp.contact__c = slc.party_created__c;
                        } else  {
                            cp.contact__c = slc.Party_Reviewed__c;
                        }
                        cp.class__c = slc.Contact_Type__c;
                        cp.primacy__c = 'Primary';
                        cp.type__c = slc.Association__c;
                        cp.relationship__c = slc.relationship__c;
                        toinsertCaseParties.add(cp);
                    }
                }
                if(!toinsertCaseParties.isEmpty()) {
                    debugLog('inserting case parties'+toInsertCaseParties);
                        try {
                            insert toinsertCaseParties;
                        } catch (DmlException d) {
                            debugLog(d.getMessage());
                        } catch (Exception e) {
                            debugLog(e.getMessage());
                        }
                }               
            }
            
        }       
        
        
        String url = '/apex/vfCaseDetail?id='+cse.id+'&newcase=true';
        Pagereference pr = new Pagereference(url);
        String js = '';
        if(this.redirectToCase) {           
            js+= 'fConsoleTabLockToggle(false);newCaseExistingClient(\''+caseInserted.id+'\');return false;';
        } else {
            js+= 'fConsoleTabLockToggle(false);newCaseNewClient(\''+sw.Contact.id+'\',\''+caseInserted.Id+'\');return false;';
        }
        this.jsCreateCaseOnComplete = js;
        return null;
        
        
    }
    public List<SelectOption> getNewOrExistingItems() { 
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('New','New'));           
        options.add(new SelectOption('Existing','Existing')); 
        return options; 
    }
    public List<SelectOption> getIndOrOrgItems() {  
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Individual','Individual')); 
        options.add(new SelectOption('Organization','Organization'));         
        return options; 
    } 
    public pageReference toggleIntakeResults() {
        showAllIntakeResults = !showAllIntakeResults ;
        if(showAllIntakeResults) {
            if(slClient != null) {
                slClient.client_Result_State__c = 'All';
                update slClient;
            }
        } else {
            if(slClient != null) {
                slClient.client_Result_State__c = 'Matches';
                update slClient;
            }           
        }
        return null;
    }
    public PageReference togglePartyResults() {
        this.showAllPartyResults = !this.showAllPartyResults;
        if(showAllPartyResults) {
            if(slClient != null){
                slClient.party_Result_State__c = 'All';
                update slClient; 
            }
        } else {
            if(slClient != null) {
                slClient.party_Result_State__c = 'Matches';              
                update slClient;
            }           
        }
        return null;
    }
    
    public Search_Log__c writeSearchLog(String association, SearchWrapper aSw) {
        debugLog('writing search log for assocation='+association + ' sw='+aSw);
        Search_Log__c sl = new Search_Log__c();
        sl.association__c = association;
        sl.user__c = UserInfo.getUserId();
        sl.first_name__c = aSw.contact.firstName;
        sl.last_name__c  = aSw.contact.lastName;    
        sl.Phone__c = aSw.contact.phone;
        sl.Aliases__c = aSw.contact.Aliases__c;
        sl.Last_Four_SSN__c = aSw.contact.Last_Four_SSN__c;
        sl.Birthdate__c = aSw.contact.Birthdate;
        sl.SessionId__c = UserInfo.getSessionId();
        if(showAllIntakeResults) {
            //if(slClient != null) {
                sl.client_Result_State__c = 'Matches';
                debugLog('updating sl client to result state all');
                //update slClient;
            //}
        } else {
        //  if(slClient != null) {
                sl.client_Result_State__c = 'All';
                debugLog('updating sl client to result state matches');
            //  update slClient;
            //}         
        }           
        if(selectedIndOrOrg == 'Organization') {
            sl.party_result_type__c = 'Organization';
        } else {
            sl.party_result_type__c = 'Individual';
        }
        insert sl;  

        return sl;
    }
    /**
     * @TODO this is updating slClient which is occassionaly throwing an unknown error.
     * but it's passing in the var sl which is clientSearchLog.. which one is correct
     * to update in this situation??
     *
     */
    public Id writeSearchLogParty(String association, String matchStatus,PartySearchWrapper aPartySw, Search_Log__c sl) {
        Id parentId = sl.id;
        Search_Log_Children__c slc = new Search_Log_Children__c();
        slc.Association__c = aPartySw.selectedAssociation;
        slc.user__c = UserInfo.getUserId();
        slc.first_name__c = aPartySw.contact.firstName;
        slc.last_name__c  = aPartySw.contact.lastName;
        slc.org_name__c = aPartySw.contact.org_name__c;
        slc.contact_type__c = aPartySw.contact.contact_type__c;
        slc.Client_Search_Log__c = parentId;
        slc.Relationship__c = aPartySw.relationship;
        slc.Aliases__c = aPartySw.contact.Aliases__c;
        slc.Phone__c = aPartySw.contact.Phone;
        slc.Birthdate__c = aPartySw.contact.Birthdate;
        slc.Marked_as_Match__c = matchStatus;
        slc.party_reviewed__c = aPartysw.contact.id;
        try {
            insert slc; 
        } catch (Exception e) {
            Utilities.sendEmail('rnendza@gmail.com','error in writePartySearchLog when attempting to insert slc: '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString());            
        } 
        String sPartyResultState = '';
        String sPartyResultType = '';
        
        if(showAllPartyResults) {
            sPartyResultState = 'All';
        } else {
            sPartyResultState = 'Matches';        
        }
        if(this.selectedIndOrOrg == 'Individual') {
            sPartyResultType = 'Individual';
        } else {
            sPartyResultType = 'Organization';
        }
        

        if(slClient != null) {
            if(sPartyResultState != null && sPartyResultState != '') {
                slClient.party_result_state__c = sPartyResultState;
            }
            if(sPartyResultType != null) {
                slClient.party_result_type__c = sPartyResultType;
            }
            try {
                if(slClient.id != null) {
                    //assuming sometimes this id is null??
                    update slClient;
                }
                if(clientSearchLog != null) {
                    if(clientSearchLog.id != null)  {
                        update clientSearchLog;
                    }
                }
            } catch (Exception e ) {
                debugLog(e.getStackTraceString());
                System.debug(logginglevel.error,e); 
                Utilities.sendEmail('rnendza@gmail.com','error in writeSearchLogClient when attempting to update slClient: '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString() + '' + e.getMessage() + ' ' +e.getCause() + 'slClient='+slClient + ' clientSearchLog='+clientSearchLog);                   
            }           
        }
        
        
        //rjn..check ind/org radio button and update client again.....    (party_result_type__c)   
        try {
            this.partySearchLogs.add(slc);
        } catch (Exception e) {
            System.debug(logginglevel.error,e);         
            Utilities.sendEmail('rnendza@gmail.com','error in writeSearchLogParty '+Datetime.now(), e.getStackTraceString(),e.getStackTraceString() + '' + e.getMessage() + ' ' +e.getCause());
        }
        return slc.id;
    }
    private void copyExistingClientSearch(Search_Log__c sl) {
        sw.contact.LastName = sl.Last_Name__c;
        sw.contact.FirstName = sl.First_Name__c;
        sw.contact.Phone = sl.phone__c;
        sw.contact.Last_Four_SSN__c = sl.last_four_SSN__c;
        sw.contact.Aliases__c = sl.aliases__c;
        sw.contact.Birthdate = sl.birthdate__c;
        
    }
    private void copyExistingPartysearch(Search_Log_children__c slChild) {
        if(partySw == null || slChild == null) {
            return;
        }
        partySw.contact.LastName = slChild.Last_Name__c;
        partySw.contact.FirstName = slChild.First_Name__c;
        partySw.contact.Org_Name__c = slChild.Org_Name__c;
        partySw.contact.phone = slChild.phone__c;
        partySw.contact.last_four_SSN__c = slChild.Last_Four_SSN__c;
        partySw.contact.aliases__c = slChild.aliases__c;
        partySw.contact.birthdate = slChild.birthDate__c;
        partySw.relationship = slChild.Relationship__c;
        partySw.contact.contact_type__c = slChild.Contact_Type__c;
        
    }
    public PageReference doSelectPartySearchLog() {
        String sPartySlId = '';
        if(selectedPartySearchLogId != null && selectedPartySearchLogId != '') {
            sPartySlId = selectedPartySearchLogId;
        } else {
            sPartySlId = ApexPages.currentPage().getParameters().get('sPartySlId');
        }
        debugLog('in doSelectPartySearchLog selected partySl='+sPartySlId); 
        if(sPartySlId != null && sPartySlId.length() > 0) {
            Search_Log_Children__c slChild = PartySearchWrapper.retrievePartySearchLog(sPartySlId);
            
            debugLog('in doSelectPartySearchLog slChild='+slChild); 
            if(slChild != null) {
                if(!wasRapidCreateCaseClicked) {
                    this.copyExistingPartysearch(slChild);
                    this.doPartySearch();
                }
            }       
        }       
        return null;
    }
    public PageReference doTogglePartySearchLogs() {  
        //If the showContent variable is true, set it to false, else, set it to true  
        debugLog('in doTogglePartySearchLogs  showPartySearchLogs='+showPartySearchLogs);
        if(showPartySearchLogs){  
            showPartySearchLogs = false;  
        }  
        else{  
            showPartySearchLogs = true;  
        }  
        return null;  
    }  
    public void refreshSearchLogWraps() {
        if(clientSearchLog!=null) {
            this.slWraps = SearchWrapper.retrieveSearchLogWrappers(clientSearchLog.id);
            //debugLog('Refreshing SL WRAPS... slWraps='+slWraps);
        }
    }
    public Integer calcTotalPartySlWraps() {
        Integer total = 0;
        if(slWraps != null && !slWraps.isEmpty()) {
            for(SearchLogWrapper slw : slWraps) {
                if( slw.isPartySlWrap() ) {
                    total ++;
                }
            }
        }
        return total;
    }
    
    
    public Boolean getShowAddPartyButton() {
        Boolean showit = false;
        if(this.clientSearchLog != null) {
            List<Search_Log_Children__c> slChildren = clientSearchLog.search_log_children__r;
            if(slChildren != null && !slChildren.isEmpty()) {
                showIt = true;
            } else {
                if(wasRemovePartyLinkClicked || isNoPartieMatchesClicked) {
                    showIt = true;
                }   
            }
        }
        return showIt;
    }
/*    
    public PageReference doClearAllSearches() {
        debugLog('<font color=blue> at top of doClearAllSearchers</font>');
        PageReference pr = null;
        if(slClientParent != null) {
            debugLog('<font color=red> Deleting searchlog (from slClientParent):'+slClientParent.Id+'</font>');
            this.selectedClientSearchLogId = slClientParent.Id;
            pr = this.doRemoveClientSl();
        } else {
            if(clientSearchLog  != null) {
                debugLog('<font color=red> Deleting searchlog (from clientSearchLog):'+clientSearchLog.Id+'</font>');
                this.selectedClientSearchLogId = clientSearchLog.Id;
                pr = this.doRemoveClientSl();
            }
        }
        doOnLoadClientSearch  = false;
        doOnLoadSearchParties = false;
        return pr;

    }
    */
    /* ELC 11/9/16 -- In this version, I am going to try deleting the underlying contact records that were
        created in the intake search.  If, of course, they were newly created.  And have no case party
        associations... */
    public PageReference doClearAllSearches() {
    	
    	Datetime oneHourAgo = Datetime.now().addHours(-1);
    	
        debugLog('<font color=blue> at top of doClearAllSearchers</font>');
        PageReference pr = null;
        if(slClientParent != null) {
            debugLog('<font color=red> Deleting searchlog (from slClientParent):'+slClientParent.Id+'</font>');
            this.selectedClientSearchLogId = slClientParent.Id;
            pr = this.doRemoveClientSl();
        } else {
            if(clientSearchLog  != null) {
                debugLog('<font color=red> Deleting searchlog (from clientSearchLog):'+clientSearchLog.Id+'</font>');
                this.selectedClientSearchLogId = clientSearchLog.Id;
                pr = this.doRemoveClientSl();
            }
        }
        try {
		    delete [select id, contact.name, category__c  
		    					from contact 
		    					where ((category__c = 'Client' AND nbr_of_case_client_associations__c = 0) 
		    					OR (category__c = 'Party' AND nbr_of_case_party_associations__c = 0)) AND 
		    					createdbyid = :UserInfo.getUserId() 
		    					and createddate > :oneHourAgo];
        } catch (Exception e){
        	System.debug('Exception deleting contacts in doClearAllSearches: '+e);
        }
        					
        doOnLoadClientSearch  = false;
        doOnLoadSearchParties = false;
        return pr;

    }
    public Boolean getDisplayCreateCaseBtn() {
        return hasSavedClient && (isNoPartieMatchesClicked || calcTotalPartySlWraps() > 0 );    
    }
    public pageReference doCancelAddPartyToCase() {
        //this.displayCreateCaseButton = false;
        return null;
    }
    public pagereference doSaveAndContinueAddPartyToCase() {
        Search_Log__c slParent = SearchWrapper.retrieveSearchLog(clientSearchLog.id);
    
        if(slParent != null) {
            List<Search_Log_Children__c> slChildren = slParent.Search_Log_Children__r;
            if(slChildren != null && !slChildren.isEmpty()) {
                debugLog('evaluating search log children for case party insert');
                List<Case_Party__c> toinsertCaseParties = new List<Case_Party__c>();
                for(Search_Log_Children__c slc : slChildren) {
                     debugLog('evaluating search log children - slc.marked as match='+slc.marked_as_match__c);
                     
                    if(slc.marked_as_match__c == 'Yes') {
                        
                        Case_Party__c cp = new Case_Party__c();
                        if(fromCaseId == null) {
                            fromCaseId = slParent.addPartyFromCase__c;
                            if(fromCaseId != null) {
                                fromCase = caseUtils.retrieveCaseSummaryData(fromCaseId);
                                debugLog('evaluating search log children - slc.fromCase='+fromCaseId);
                            } else {
                                
                                debugLog('evaluating search log children - could not set fromCase...');
                            }
                        }
                        cp.case__c = fromCaseId;
                        if(slc.party_reviewed__c == null) {
                            cp.contact__c = slc.party_created__c;
                        } else  {
                            cp.contact__c = slc.Party_Reviewed__c;
                        }
                        cp.class__c = slc.Contact_Type__c;
                        cp.primacy__c = 'Primary';
                        cp.type__c = slc.Association__c;
                        cp.relationship__c = slc.relationship__c;
                        toinsertCaseParties.add(cp);
                    }
                    
                }
                if(!toinsertCaseParties.isEmpty()) {
                    debugLog('inserting case parties'+toInsertCaseParties);
                        try {
                            insert toinsertCaseParties;
                        } catch (DmlException d) {
                            debugLog(d.getMessage());
                        } catch (Exception e) {
                            debugLog(e.getMessage());
                        }
                }               
            }
        }
 
        return null;
    }
    
    private List<ContactResult> subsetContactResults(List<ContactResult> list1, Integer count) {
        Integer startIndex = 0;
        List<ContactResult> returnList = null;
        if(list1 != null && list1.size() > 0 && startIndex <= list1.size()-1 && count > 0){
            returnList = new List<ContactResult>();
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }   
    private Search_Log__c createMockSlClient( Id contactId) {
        //Contact c = ContactUtils.retrieveAllContactInfo(contactId);
        //@todo rjn api versioning issues
        Set<String> excludeFields = new Set<String> {'OtherAddress','MailingAddress'};
        Contact c  = retrieveAllContactInfo(contactId, excludeFields);

        Search_Log__c   sl = new Search_Log__c();
        sl.Association__c = 'Client';
        sl.Client_Result_State__c = 'All';
        sl.First_Name__c = c.FirstName;
        sl.Last_Name__c = c.LastName;
        sl.fromPage__c = 'vfCaseDetail_AddParty';
        sl.Phone__c = c.Phone;
        sl.Last_Four_SSN__c = c.Last_Four_SSN__c;
        sl.Birthdate__c =  c.Birthdate;
        sl.Marked_as_Match__c = 'Yes';
        sl.contact_reviewed__c = c.id;
        sl.sessionId__c =  UserInfo.getSessionId();
        sl.Party_Result_State__c = 'Matches';
        sl.User__c = UserInfo.getUserId();
        if(fromCaseId != null) {
            sl.AddPartyFromCase__c = fromCaseId;
        }
        insert sl;
        return sl;      
    }
 /**
     * rjn added this to stop bs versioning errors such as otheraddress as well as i need the military field but did not want
     * to mess with the above.
     */
    public  Contact retrieveAllContactInfo(Id contactId, Set<STring> excludeFields) {
        Contact c;
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('id').equals( contactId ));

        // This field was not being included no matter what I did. Added it manually but am excluding here to
        // prevent another error in the future. ELC IF-LAN changes
        //Set<String> excludeFields = new Set<String>();
        //excludeFields.add('Is_Military__c');

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Contact', false , excludeFields))
                //      .selectx(new Set<String> {'Is_Military__c'})
                .fromx  ('Contact')
                .wherex( whereC )
                .toSoql();
        try {

            c = Database.query(soql);
        } catch (Dmlexception dEx) {
            System.debug(logginglevel.error, dEx);
        } catch (Exception e) {
            debuglog('ex='+e.getMessage());
            System.debug(logginglevel.error, e);
        }
        return c;
    }
    private static void updateLeadStatus(Id leadId) {
        if (leadId != null) {
            Lead lead = [SELECT Id, Status FROM Lead WHERE id = :leadId]; 
            lead.Status = 'Closed - Converted';
            update lead;
        }
    }

}