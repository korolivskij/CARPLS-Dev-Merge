public with sharing class ctrlClient extends ctrlCarplesGeneric {
     
    public Contact                      client              {get; set;}
    private List<Contact>               spContacts;
    
    //rjn 12/05/14  passed as urlparm from vfCaseDetail
    public Boolean                      fromDirtyTab            {get; set;}

    public Boolean                      tempContact         {get; set;} 
    public Boolean                      isViewOnly          {get; set;}
    public Boolean                      isNewEditMode       {get; set;}
    public Boolean                      isEditMode          {get; set;}
    public Boolean                      isFromCase          {get; set;}
                        
    public Boolean                      isPartyReview       {get; set;}
    public Boolean                      displayAddNewIncomeForm {get;set;}
    public Boolean                      doSearchPartiesExist {get; set; }
    public Boolean                      isNewClient         { get; set; }
    public Boolean                      showMatchActionBar {get; set; }
    public Boolean                      isScreenPop     {get; set;}

     
    public Boolean                      displayHhIncomeEdit {get; set;}
    public Boolean                      displayCaseHistory  {get; set;}
    public Boolean                      displayHHIncomeViewOnlyPanel  {get; set;}
    public Boolean                      displayHHMembersNewEdit  {get; set;}
    public Boolean                      displaySaveAndPostForm  {get; set; }
    

    
    public Boolean                      displaySaveAndPostBtn   {get; set;}
    // when this is ready for production, delete displayIneligibleBtn and replace render on 
    // page with rendered="{!  (!isViewOnly || isNewEditMode || isEditMode)}"
    public Boolean                      displayIneligibleBtn        {get; set;}
    public Boolean                      displayIncompleteBtn        { get; set; }
    public Boolean                      renderIneligibleClientComponent { get; set; }
    public Boolean                      renderIncompleteIntakeComponent { get; set; }
    public Boolean                      allInputRequired    { get; set; }
    public Boolean                      displaySaveAndContinueCurrentPage {get; set; }
    public Boolean                      displaySaveAndContinueToCase    {get; set; }
    public Boolean                      displayConflictAlert  {get; set; }
    public Boolean                      displayAddParties   {get; set; }
    public Boolean                      displayMatchReloadJs {get;set; }
    public Boolean                      displayAddNewIncomeSource   { get; set; }
    public Boolean                      displaySaveNewIncomeSource  { get; set; }
    public Boolean                      validationErrors            { get; set; }
    public Boolean                      emailRequired               { set; }
    //rjn 12/05/14
    public String                       sIsOpenServiceTab           { get; set; } //set from Action Function
        
    public transient Boolean                        addNewIncomeSourceBtnClicked { get; set; }
    public transient Boolean                        calcIncomeSourceBtnClicked   { get; set; }
    
    public Boolean                      matchAndContinuePressed {get; set;}
    public Boolean                      matchButNoCaseParties ;
    public Boolean getMatchButNoCaseParties() {
        debugLog('in getter...returning matchButNoCaseParties '+matchButNoCaseParties);
        return this.matchButNoCaseParties;
    }
    public Boolean                      matchYes            {get; set;}
    public Boolean                      potentialConflict   {get; set;}
    public Boolean                      partyIsClientConflict {get; set;}
    public Boolean                      servicedClient {get; set; }
    public Boolean                      pendingClient {get; set; }
    public Boolean                      incompleteClient { get; set; }
    public Boolean                      isConflictSearchComplete { get; set; }
    public Boolean                      isNewMode {get; set;}
    
    public Case                         newCase             {get; set;}
    public Case                         fromCase            {get; set;}
    public Case_Party__c                caseHistory         {get; set;}
    public PovertyBean                  pb                  {get; set;}
    public PovertyBean                  pbAmi               {get; set;}
    public CaseUtils                    caseUtils           {get; set;}
    public transient ContactUtils       cUtils              {get; set;}
    public Search_Log_Children__c       currentPartySl      {get; set;}
    public Case_Party__c                currentCaseParty    {get; set;}
    public List<Conflict_Log__c>        conflictLogs        {get; set;}
    public String                       saveAndPostJsMethod {get; set;}
    public String                       saveAndContinueJsMethod {get; set;}
    public String                       matchButNoCasePartiesJsMethod {get; set;}
    public String                       doCancelJsMethod    {get; set;}
    public String                       fromCaseId          {get; set;}
    public String                       searchType          {get; set;}
    public String                       saveAndPostProjectJsMethod  {get; set; }
    public String                       closedCaseId                {get; set; }
    public String                       originalClientEmail         {get; set; }
    public  Boolean            onLoadAddNewIncomeSource    {get; set; }
    public transient Boolean            isDeletingIncome            {get; set; }
    public transient Boolean            isCancelingIncome           {get; set; }
    
    public Income_Detail__c             newIncomeSource     {get; set;}
    
    // for rejection popup
    public String                       selectedIneligibleReason    {get; set;}
    public String                       userIntakeType          { get; set; }

    //veteran project rjn.
    public Integer                      entryDate { get; set;}
    public Integer                      exitDate { get; set;}

    public Id                           leadId { get; set;} // Updated 26.08.2020 by S.Korolivskyi
    
    
    //public List<Income_Detail__c>     clientIncomeDetails {get; set;}
    public List<Income_Detail__c>       clientIncomeDetails;
    public List<Income_Detail__c>       getClientIncomeDetails() {
        //debugLog('in getter.. returning clientIncomeDetails:'+this.clientIncomeDetails);
        return clientIncomeDetails;
    }

    public void setClientIncomeDetails(List<Income_Detail__c> ids) {
        this.clientIncomeDetails = ids;
        //debugLog('in setter. setting clientIncomeDetails:'+this.clientIncomeDetails);
    }
  
    public /*override*/ String getCustomPageMessage() {
        String msg = customPageMessage;
        if(msg!=null) {
            if(msg.contains('null')) {
                msg = msg.replace('null', '');
            }
        }   
        return msg;     
    }
    public Boolean getEmailRequired() {
        Boolean required = false;
        if(client != null) { 
            if(client.has_email__c != null) {
                debugLog('in getEmailRequired... has_email = ..'+client.has_email__c);
        
                if(client.has_email__c == 'Yes') {
                    required = true;
                } 
            }       
        }
        debugLog('in getEmailRequired... returning..'+required);
        return required;
    }
    /**
     *
     */
    public Boolean getEmailModified() {
        Boolean modified = false;
        if(client != null) {
            if(client.email != originalClientEmail) {
               modified = true;
            }
        }
        return modified;
    }
    public List<Selectoption> getIneligibleReasonOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(' - Income', 'Over Income') );
        options.add(new SelectOption(' - Geography', 'Out of Service Area'));
        options.add(new SelectOption(' - Abusive', 'Abusive/Threatening'));
        options.add(new SelectOption(' - Represented', 'Currently Represented'));
        //rjn add wanted this changed to Unqualified IL-AFLAN
        //options.add(new SelectOption(' - Unqualified Military', 'Unqualified Military'));
        options.add(new SelectOption(' - Unqualified IL-AFLAN', 'Unqualified IL-AFLAN'));
        return options;
    }     
    
    public ctrlClient(ApexPages.StandardController stdController) {
        super();

        String leadIdString = Apexpages.currentPage().getParameters().get('leadId');
        this.leadId = String.isBlank(leadIdString) ? null : (Id)leadIdString; // S. Korolivskyi Updated 26.08.2020
        
        this.isFromCase = false; 
        this.isScreenPop = false;
        //rjn 12/05/14
        this.sIsOpenServiceTab = '';  //set via actionfunction  
        this.fromDirtyTab = false;    //set via url param
        
        debugLog('<b>in ctrlClient (stdController) contructor</b> after calling super');
        this.client = (Contact)stdController.getRecord();
        
        //this.originalClientEmail = client.email;
        //elc inContact integration
        String sSoftPhoneQuery = ApexPages.currentPage().getParameters().get('sfdcquery0');
        String ani = ApexPages.currentPage().getParameters().get('ani');
        System.debug(loggingLevel.debug, 'ani param = '+ani);

        //User u = [select id, intake_type__c from user where id = :UserInfo.getUserId()];
        //if(u.intake_type__c != null) {
        //    this.userIntakeType =u.intake_type__c;
        //}
        //--- RJN Esstentially we took away the button in intake and merrged the display for this stuff.
        //--- so just hardcode this flag for now
        this.userIntakeType = 'IL-AFLAN';
        /*
         String intakeType = '';

        User u = [select id, intake_type__c from user where id = :UserInfo.getUserId()];
        if(u.intake_type__c != null) {
            intakeType =u.intake_type__c;
            if(c.Is_Military__c && intakeType == 'IL-AFLAN') {
        return retrieveAMIPoverty(c);
    }
}



*/


        if(ani != null && ani.length() > 0) {
            String spPhone = '';
            String spPhone2 = '';
            // check to see if this is an outbound call - ani is CARPLS #
            if (ani.equals('3127389200')) {
                String dnis = ApexPages.currentPage().getParameters().get('dnis');
                System.debug(loggingLevel.debug, 'dnis param = '+dnis); 
                if(dnis != null && dnis.length() > 0) {
                    spPhone = dnis;
                } else {
                    System.debug(loggingLevel.debug, 'Error - outbound call with no dnis parameter!!');
                } 
            } else {  
                spPhone = ani;
            }       
            try {
                //spContacts = (List<Contact>) Database.Query(sSoftPhoneQuery);
                spPhone2 = '('+spPhone.substring(0,3)+') '+spPhone.substring(3,6)+'-'+spPhone.substring(6);             
                List<Contact> spContacts = [select id from contact where category__c includes ('Client') and phone in (:spPhone,:spPhone2)];
                if (spContacts != null && spContacts.size() > 0) {
                    if (spContacts[0] != null) {
                        this.client = spContacts[0];
                        this.isScreenPop = true;
                        debugLog('set isScreenPop to true');
                    } else {
                        System.debug('Error in phone params - no row returned.');
                    }
                }
            } catch (Dmlexception d) {
                System.debug(d.getMessage());
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }                
                   
        this.client = this.retrieveAllClientData();
        this.originalClientEmail = client.email;
        this.cUtils = new ContactUtils();
        this.caseUtils = new CaseUtils();
        this.searchType = 'Client';
        this.showMatchActionBar = false;
        

        this.pb = cUtils.retrievePoverty(client);
        this.pbAmi = cUtils.retrieveAMIPoverty(client);

        debugLog(' in constructor = pb='+pb);
      //  if(pb != null) {
     //     String msg = '<b>'+pb.povertyPct+'%</b> - ' + pb.povertyLevelDesc;
        //  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
       // }
        super.debugLog(pb.toString());
        
        this.isViewOnly = false;
        this.isNewClient = false;
        this.isNewEditMode = false;
        this.isEditMode = false;
        this.tempContact = false;
        this.displayHhIncomeEdit = false;
        this.displayCaseHistory = false;
        this.displayHHIncomeViewOnlyPanel = false;
        this.displayHHMembersNewEdit = false;
        this.displaySaveAndPostBtn = true;
        this.displayIneligibleBtn = false;
        this.displayIncompleteBtn= false;
        this.displaySaveAndContinueCurrentPage = false;
        this.displayMatchReloadJs = false;
        this.displayAddNewIncomeSource = true;
        this.displayAddNewIncomeForm = false;
        this.displaySaveNewIncomeSource = false;
        this.renderIneligibleClientComponent = false;
        this.renderIncompleteIntakeComponent = false;
        this.allInputRequired = true;
        this.addNewIncomeSourceBtnClicked = false;
        this.isCancelingIncome = false;
        
        this.calcIncomeSourceBtnClicked = false;
        this.showLeftNav = false;
        
        this.displaySaveAndContinueToCase = false;
        this.displayAddParties = false;
        this.displayConflictAlert = false;
        this.matchAndContinuePressed = false;
        this.matchButNoCaseParties = false;
        this.partyIsClientConflict = false;
        this.doSearchPartiesExist = false;
        this.isPartyReview = false;
        this.potentialConflict = false;
        this.displaySaveAndPostForm = false;
        this.matchYes = false;
        this.saveAndPostJsMethod = '';
        this.saveAndContinueJsMethod = '';
        this.matchButNoCasePartiesJsMethod = '';
        this.doCancelJsMethod = 'fConsoleTabLockToggle(false); closeTab();return false;';
        this.customPageMessageSeverityStyleClass = 'warningM4';
        this.onLoadAddNewIncomeSource = false;
        this.isConflictSearchComplete = false;
        this.servicedClient = false;
        this.pendingClient = false;
        this.incompleteClient = (client.status__c == 'Incomplete');
        debugLog('Incomplete Client = '+ incompleteClient);
        this.saveAndPostProjectJsMethod = '';
        


        //@TODO RJN Probably obsolete code!
        /*   
        String s =  ApexPages.currentPage().getParameters().get('tempContact');
        if(s != null && s.length() > 0) {
            tempContact = Boolean.valueOf(s);
        }
        */

        //rjn 12/05/14
        String sfromDirtyTab = ApexPages.currentPage().getParameters().get('fromDirtyTab');
        if(sfromDirtyTab != null && sfromDirtyTab.length() > 0) {
            try {
                this.fromDirtyTab = Boolean.valueOf(sfromDirtyTab);
                debugLog('fromDirtyTab='+fromDirtyTab);
            }  catch (Exception e) {
                debugLog(e.getMessage());
            }           
        }
        
        if(this.isScreenPop) {
            debugLog('setting flags for screen pop');
            // view parameter
            this.isViewOnly = true;
            this.displayCaseHistory = true;
            this.displayHHINcomeViewOnlyPanel = true;
            this.displayAddNewIncomeSource = false;
            // showAddCaseBtn parameter
            this.displayAddParties = true;
            // servicedClient parameter
            this.servicedClient = true;

            List<Case_Party__c> cps = client.Case_Parties__r;
            if(cps != null && !cps.isEmpty()) {
                String tmsg = 'To add further service, please scroll down to the cases list and click View';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,tmsg));      
            }           
        }
        String sviewOnly =  ApexPages.currentPage().getParameters().get('view');
        if(sViewOnly != null && sViewOnly.length() > 0) {
            
            this.isViewOnly = Boolean.valueOf(sViewOnly);
            debugLog('isViewOnly ='+isViewOnly);
            this.displayCaseHistory = true;
            this.displayHHIncomeViewOnlyPanel = true;
            if(isViewOnly) {
                this.displayAddNewIncomeSource = false;
            }
        }
        String sNewCaseId = ApexPages.currentPage().getParameters().get('newCaseId');
        if(sNewCaseId != null && sNewCaseId.length() > 0) {
            Id caseId = sNewCaseId;
            initCase(caseId);
        }
        
        String sReviewParty = ApexPages.currentPage().getParameters().get('reviewParty');
        if(sReviewParty != null && sReviewParty.length() > 0) {
            this.isPartyReview = Boolean.valueOf(sReviewParty);
            
        }
        
        String sSearchType = ApexPages.currentPage().getParameters().get('searchType');
        if(sSearchType != null && sSearchType != '') {
            if(sSearchType == 'Client') {
                this.searchType = 'Client';
                debugLog('SEARCHTYPE IS CLIENT');
            } else {
                this.searchType = 'Party';
                List<String> sCategories = Utilities.getPlValues(client.category__c);
                //@TODO Client Type Mod
                //if(client.RecordType.name == 'Client') {
                if(Utilities.doesListHaveValue(sCategories, 'Client')) {
                    this.isPartyReview = false; 
                    debugLog('User searched in party search. resulting link client was a client however.. display as client');
                }
            }
        }
        
        String sNewClient =  ApexPages.currentPage().getParameters().get('newclient');
        if(sNewClient != null && sNewClient.length() > 0) {
            this.isNewEditMode = Boolean.valueOf(sNewClient);
            this.displayHhIncomeEdit = false;
            this.displayCaseHistory = false;
            this.displayHHIncomeViewOnlyPanel = false;
            this.displaySaveAndContinueCurrentPage = true;
            this.isNewClient = Boolean.valueOf(sNewClient);
        } 
        String sServicedClient = ApexPages.currentPage().getParameters().get('servicedClient');
        if(sServicedClient != null && sServicedClient.length() > 0) {
            this.servicedClient = Boolean.valueOf(sServicedClient);
             
        } 
               
        String sPendingClient = ApexPages.currentPage().getParameters().get('pendingClient');
        debugLog('getting parameter pendingClient = '+sPendingClient);
        if(sPendingClient != null && sPendingClient.length() > 0) {
            this.PendingClient = Boolean.valueOf(sPendingClient) && 'Pending'.equalsIgnoreCase(client.status__c);
                       
        }
 

        String sConflictSearchComplete =  ApexPages.currentPage().getParameters().get('conflictSearchComplete');
        if(sConflictSearchComplete != null && sConflictSearchComplete.length() > 0) {
            this.isConflictSearchComplete = Boolean.valueOf(sConflictSearchComplete);
        }

        String sAddCaseBtnOverride =  ApexPages.currentPage().getParameters().get('showAddCaseBtn');
        if(sAddCaseBtnOverride != null && sAddCaseBtnOverride.length() > 0) {
            this.displayAddParties = Boolean.valueOf(sAddCaseBtnOverride);
        }
        String sClientSlId  = ApexPages.currentPage().getParameters().get('clientSlId');
        if(sClientSlId != null && sClientSlId != '') {
            id clientSlId = sClientSlId;
            this.slClient = SearchWrapper.retrieveSearchLog(clientSlId);
            debugLog('<font color=purple>slClientId:'+clientSlId + ' found in request.. overriding slClient to slClient='+slClient + '</font>');
        }
             
        //if(!this.isViewOnly && !isNewEditMode) {
        //    String msg = 'Double click editable fields to edit field data.';
        //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        //}   
        String sFromCase =  ApexPages.currentPage().getParameters().get('fromCase');
        String sFromCaseId = ApexPages.currentPage().getParameters().get('fromCaseId');
        if(sFromCase != null && sFromCase.length() > 0 && sFromCaseID !=null && sFromCase.length() > 0) {
            
            this.isFromCase = Boolean.valueOf(sFromCase);
            
            debugLog('value of isFromCase='+isFromCase);
            if(this.isFromCase) {
                this.fromCaseId = sFromCaseId;
                //this.displaySaveAndContinueCurrentPage = true; RJn defect
                this.displaySaveAndContinueCurrentPage = false;
                this.fromCase = caseUtils.retrieveCaseSummaryData(fromCaseId);
                String methodCall ='fConsoleTabLockToggle(false);replacePrimaryAndCloseSubs(';
                // ELC 11/15/16 - changed to vfCase
                String  url = '/apex/vfCase?id='+fromCaseId;
                url += '&tempCase=false&newCase=false&fromSearch=false&resumeCase=true&review=false';
            
            
                String tabLabel = 'Edit Case: ' + fromCase.casenumber;
                String tabName = 'case'+fromCase.id;
            
                methodCall += '\'' + url + '\',';
                methodCall += '\'' + tabLabel + '\',';
                methodCall += '\'' + tabName + '\');';
                        
                //oncomplete="replacePrimaryAndCloseSubs('/apex/vfCaseDetail?id={!newCase.id}&tempCase=false&newcase=true','New Case: {!newCase.casenumber}','case{!newCase.id}')"
                    
                //RJN 12/05/14 if coming from a tab that is dirt.. ie. has unsaved changes ie an *
                //we cannot simply start closing and refreshing tabs we must just close this tab
                //just focus being placed on tab we came back from.  do the same thing if one is simply open and not dirty as well
                // ELC 11/16/16 - Changed to always just close tab                                  
                //if(!fromDirtyTab || 'true' != sIsOpenServiceTab) {
                //    this.saveAndContinueJsMethod = methodCall;
                //} else {
                    this.saveAndContinueJsMethod = 'fConsoleTabLockToggle(false);closeTab();';
                //}
                
                debugLog('save and continue js='+saveAndContinueJsMethod);
            }
        }     
        debugLog('is party review='+isPartyReview);
        this.conflictLogs = this.refreshConflictLogs();   
        // this.showDebugMessages = UserInfo.getLastName() == 'Nendza';  
        if (this.client.Lead__c != null) {
            Lead ld = [SELECT Id, Email FROM Lead WHERE Id = :this.client.Lead__c LIMIT 1];
            this.client.Email =  ld.Email;
        }
        
    }
    public Pagereference doInit() {
        
        if(fromSearch && reviewCurrent) {
            this.showMatchActionBar = true;
            if(searchType == 'Client') {
                if(slClient != null) {
                    slClient.Contact_Reviewed__c = this.client.id;
                    debugLog('searchtype is client. slClient = '+slClient);     
                    update slClient;
                } else {
                    System.debug(logginglevel.error,'sl client is null and should not be!.. check url params');                 
                }
            }
            if(searchType == 'Party') {
                String s =  ApexPages.currentPage().getParameters().get('currentPartySl');
                if(s != null && s.length() > 0) {
                    this.currentPartySl = PartySearchWrapper.retrievePartySearchLog(s);
                    if(currentPartySl != null ) {
                        currentPartySl.Party_Reviewed__c = this.client.id;                  
                        update currentPartySl;
                        if(slClient != null) {
                            slClient.Current_SL_Party__c = currentPartySl.id;
                            update slClient;
                        }
                    }
                    debugLog('searchtype is party...currentPartySl = '+this.currentPartySl);                    
                } else {
                    debugLog('<font color=red><b>NOTE!</b> searchType is party but there is no currentPartySl (ID) in the request</font>');    
                }  
            }
        }

        //-- note newClient is not necessarily a new client but looks like it was hacked to income details and stuff would show. @RJN Fix this.
        this.displaySaveAndPostBtn = ( this.isNewClient && (client.Status__c == 'Pending' ) );
        this.displayIneligibleBtn = true;       //( this.isNewClient );
        this.displayIncompleteBtn = ( !servicedClient && this.isNewClient && (client.Status__c == 'Pending' || client.Status__c == 'Incomplete' || client.Status__c.contains('Ineligible')) );
        System.debug('hclient detail>>> '+ this.clientIncomeDetails);

        if(this.isNewClient && ( this.clientIncomeDetails == null || this.clientIncomeDetails.isEmpty()) ) {
            System.debug('here here>>> '+ this.isNewClient);
            debugLog('<font color=green>Setting onload AddNewIncomeSource=true</font>');
            this.onLoadAddNewIncomeSource = true;
            this.doAddNewIncomeSource();
        }
        if(servicedClient) {
                        List<Case_Party__c> cps = client.Case_Parties__r;
                        if(cps != null && !cps.isEmpty()) {
                            String tmsg = 'To add further service, please scroll down to the cases list and click View';
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,tmsg));      
                        }   
        } 
        if(pendingClient) {
            List<Case_Party__c> cps = client.Case_Parties__r;
            if(cps != null && !cps.isEmpty()) {         
                String tmsg = 'Client is Pending with an incomplete case. Please scroll down to the cases section and click resume.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,tmsg));  
            } else {
                this.displayAddParties = true; 
                //String tmsg = 'Client is Pending with no cases. Please add a case for the client.';
                String tmsg = 'Client is Incomplete. Please complete any necessary information and click Save & Continue to add a case.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,tmsg)); 
                
            }       
        }   
          
       
        return null;
    }
    public void initCase(Id pCaseId) {
            CaseUtils caseUtils = new CaseUtils();
            this.newCase = caseUtils.retrieveCaseSummaryData(pCaseId);
            this.currentCaseParty = caseUtils.retrieveCaseParty(pCaseId,client.id);
            debugLog('New Case Just created ='+newCase);
            debugLog('currentCaseParty ='+currentCaseParty);
            //replacePrimaryAndCloseSubs(url,tabLabel,tabName)
            // ELC - added this to catch the situation where no case is returned
            if (newCase != null) {
                String msg = 'Please complete the necessary';
                if(!isPartyReview){
                    msg += ' client fields.';
                } else {
                    msg += ' fields';
                }
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));               
                
                String pageName = 'vfCaseDetail';
                if(super.getIsNewCaseFlow()) {
                    pageName = 'vfCase';
                }
                
                String methodCall ='fConsoleTabLockToggle(false);replacePrimaryAndCloseSubs(';
                String  url = '/apex/'+pageName+'?id='+newCase.id;
                        url += '&tempCase=false&newCase=true';
            
                String tabLabel = 'New Case: ' + newCase.casenumber;
                String tabName = 'case'+newCase.id;
            
                methodCall += '\'' + url + '\',';
                methodCall += '\'' + tabLabel + '\',';
                methodCall += '\'' + tabName + '\');';
                        
                //oncomplete="replacePrimaryAndCloseSubs('/apex/vfCaseDetail?id={!newCase.id}&tempCase=false&newcase=true','New Case: {!newCase.casenumber}','case{!newCase.id}')"
                    
                //RJN 12/05/14 if coming from a tab that is dirt.. ie. has unsaved changes ie an *
                //we cannot simply start closing and refreshing tabs we must just close this tab
                //just focus being placed on tab we came back from.  do the same thing if one is simply open and not dirty as well    
                // ELC 11/16/16 - Changed from && condition to ||                    
                if(!fromDirtyTab || 'true' != sIsOpenServiceTab) {
                    this.saveAndContinueJsMethod = methodCall;
                } else {
                    this.saveAndContinueJsMethod = 'fConsoleTabLockToggle(false);closeTab();';
                }
                
                debugLog('save and continue js='+saveAndContinueJsMethod);
                
            } else {
                debugLog('no case returned from retrieveCaseSummaryData for CaseId:'+pCaseId);
            }       
    }
    public PageReference doCloseCase() {
        debugLog('.... case closed Id='+closedCaseId);
        String tmsg = 'Client has been modified from pending to current.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,tmsg));  
        this.doInit();     
        return null;
    }  
    // For the conditionally required email field.  i'm not sure if this is needed or if it was just for the date
    public PageReference doEmailSelect() {
        debuglog('--- in doEmailSelect..client:'+client);
        
        if(!this.getEmailRequired()) {
            debuglog('--- in doEmailnSelect. setting email to null since its not required');
            //client.email = null;
        } else {
            debuglog('--- in doEmailSelect. Email is required');            
        }
        return null;
    }  
    /* RJN 12/05/14
     * Needed for ActionFunction to set isOpenServiceTab;
     * If there is an open service tab.. overwrite saveAndContinueJsMethod (do not call refreshPrimaryAndCloseSub)
     */
    public PageReference doSetOpenServiceTab() {
        debugLog('in doSetOpenServiceTab isOpenServiceTab='+this.sIsOpenServiceTab);
        if('true' == this.sIsOpenServiceTab) {
            this.saveAndContinueJsMethod = 'fConsoleTabLockToggle(false);closeTab();';
        }   
        return null;
    }
    public Boolean doEditMode() {
        this.isEditMode = true;
        this.isViewOnly = false;
        this.displayIneligibleBtn = true;
        this.displaySaveAndContinueCurrentPage = true;
        if(!this.isFromCase) { // rjn defect
            this.saveAndContinueJsMethod = '';
            //this.displayIncompleteBtn = true;
        }
        this.doCancelJsMethod = 'fConsoleTabLockToggle(false);';
        return null;
    }
    public PageReference doUpdateMilitary() {
        debuglog('in doUpdateMilitary... updating client='+client);
       /*
        if(entryDate != null) {
            if (entryDate == 0) {
                client.Entry_Date_yyyy__c = 0000;
            } else {
                client.Entry_Date_yyyy__c = entryDate;
            }

        }

        if(exitDate != null) {
            client.Exit_Date_yyyy__c = this.exitDate;
        }
        */
        update client;
        this.client = this.retrieveAllClientData(); // refresh so formula field calcs correctly

        return null;
    }
    public PageReference doDisplayIneligible() {
        debugLog('In doDisplayIneligible');
        renderIneligibleClientComponent = true;
        allInputRequired = false;
        return null;
    }
    public PageReference doCancelIneligibleClient() {
        System.debug(loggingLevel.debug, 'In doCancelIneligibleClient, newCase = '+newCase+' Client = '+client);
        
        renderIneligibleClientComponent = false;
        allInputRequired = true;
        if (client != null) {
            this.client.rejection_reason__c = null;
        }
        return null;
    }
   
    // This is called if the client is ineligible.  There will be a pop-up that prompts the user to specify
    // a reason for the rejection.  
    public PageReference doIneligibleNewCase() {
        
        String newCategory = '';
        
        System.debug(loggingLevel.debug, 'In doIneligibleNewCase, newCase = '+newCase+' Client = '+client);
        
        try {
            delete newCase;
            debugLog('<font color=orange>deleted case:</font>');
            updateLeadStatus(leadId, client,'Ineligible');
        } catch (Exception e) {
            debugLog('<font color=red>EXCEPTION DELETING CASE:'+e+'</font>');
        }
        // Need to add Inquiry to the client category and change the status to ineligible
        
        if (client != null) {
            refreshClientCategories();
            if (client.category__c != null && !client.category__c.contains('Inquiry') && !client.category__c.contains('Client')) {
                newCategory = client.category__c + ';' + 'Inquiry';
            } else if (client.category__c != null && client.category__c.contains('Client')) {
                newCategory = client.category__c;
            } else {
                newCategory = 'Inquiry';
            }
            client.category__c = newCategory;
            client.status__c = 'Ineligible' + selectedIneligibleReason;
            //RJN Looks like this was missing. added 9/26/2017
            try {
                update client;
                debugLog('adding Ineligible to client Category');
            } catch (Exception e) {
                debugLog('exception updating client');
            }

            doSaveIncomeSource();
        }
        return null;
    }
    public PageReference doDisplayIncomplete() {
        System.debug(LoggingLevel.DEBUG, 'In doDisplayIncomplete, city = '+ client.mailingcity);
        update client;
        renderIncompleteIntakeComponent = true;
        allInputRequired = false;
        return null;
    }    
    // This is called if the intake is incomplete.  There will be a pop-up that prompts the user to confirm
    public PageReference doIncompleteIntake() {

        client.status__c = 'Incomplete';
        incompleteClient = true;

        if(incompleteClient){
            updateLeadStatus(leadId, client, 'Force4J Closed');
        }
        
        System.debug(loggingLevel.debug, 'In doIncompleteIntake, Client = '+client);
        // save non-zero income information
        doSaveIncomeSource();
        // If there is a blank income detail entry, clear it
        //List<Income_Detail__c> incDets = ContactUtils.retrieveContactIncomeDetails(client.id);
        //if (incDets != null && incDets.size() == 1) {
        //  Income_Detail__c incDet = incDets[0];
        //  if ((incDet.amount__c == 0) || (incDet.amount__c == null)) {
        //      ContactUtils.DeleteIncome(incDet);
        //  }
        //}

        /**
        * We need to inform the UI.. ie. the home page. that something happened where it should be refreshed in the case
        * it's in resume case mode.. even though the status isn't really changing this should trick it into refreshing.
        *
        * This will fire the listener on vfCarplsHome. ie  var vfPe_casesstatuschanged_listener = function(event) {}
        *
        * This is done in uiUtils as I didn't want to change the api version of ctrlClient (ie. we need a later api
        * version to deal with platform events.
        */
        try {
            Boolean allSuccess = UiUtils.firePlatformCaseEvent(newCase);
            system.debug(logginglevel.debug,'Success on fire of SFDC Platform Event='+allSuccess);
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
        }
        return null;
    }

    public PageReference doCancelIncompleteIntake() {
        System.debug(loggingLevel.debug, 'In doCancelIncompleteIntake, newCase = '+newCase+' Client = '+client);
        
        renderIncompleteIntakeComponent = false;
        allInputRequired = true;
        incompleteClient = false;
        return null;
    }     
    public Contact retrieveAllClientData() {
        
        id cId = client.id;
        debugLog('firing retrieveAllClientData with id='+cId);
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact',false))
                    .selectx(new Set<String> {'Annual_Income_Realtime__c'})
                    .selectx(new Set<String> {'CreatedBy.communitynickname', 'LastModifiedBy.communitynickname'})                    
                             
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'conflict_status__c','contact__c','id','Type__c','case__r.jurisdiction__c','Role__c','case__r.id','case__r.last_contact__c','case__r.closedDate','case__r.reason','case__r.caseNumber','case__r.subject','case__r.problem_category__c','case__r.practice_area__c','case__r.Problem_Code__c','case__r.status','case__r.project__c'})
                        .selectx(new Set<String> {'case__c','case__r.last_service_by__r.communitynickname','case__r.last_service_date__c'})
                        .fromx('Case_Parties__r')
                        .wherex(new al.FieldCondition('contact__c').equals(cId))
                        .limitx(20)
                        )
                       
                    .fromx  ('Contact c ')
                    .wherex (new al.FieldCondition('id').equals(cId))   
                    .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators());
        
        Contact c;                                  
        try {
            debugLog('main contact query='+soql);
            c = Database.query(soql);
            debugLog('contact retrieved= id='+c.id + ' name='+c.name );
            String soqlId = new al.soqlBuilder()    
                        .selectx( SoqlUtils.getAllFieldsSet('Income_Detail__c',false))
                        .selectx( new Set<String> { 'lastmodifiedby.name','lastmodifiedby.communitynickname','lastmodifieddate'})
                        .fromx('Income_Detail__c')
                        .wherex(new al.FieldCondition('contact__c').equals(cId))
                        .orderByx(new al.OrderBy('LastModifiedDate').ascending().nullsLast())
                        .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators());
                        
            this.clientIncomeDetails = Database.query(soqlId);
            System.debug('soqlBuilder>>>' +this.clientIncomeDetails  );
            debugLog('contact income details retrieved='+clientIncomeDetails);
        } catch (Dmlexception e) {
            debugLog('contact retrieval error='+e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        if(c!= null) {

        }
        return c;       
    }
    public Pagereference doCancel() {
        if(this.isNewEditMode && newCase == null) {
            try {
                debugLog('deleting client' + this.client);
                delete this.client;
                updateLeadStatus(leadId, client,'Force4J Closed');
            } catch (Exception e) {
                debugLog('client delete failed with exception '+e);
                System.debug(e);
            }
        }  
        // ELC 10/14/16 newCase was apparently populated in the event of an existing case as well. Adding check for isNewEditMode as well. 
        if(newCase !=null && isNewEditMode) {
            CaseUtils caseUtils = new CaseUtils();
           //-------- not needed.. probably switched over to trigger List<Case_Party__c> cps = caseUtils.retrieveCaseParties(newCase);
            try {
                debugLog('deleteing case');
                //System.debug('deleting case and case parties'); 
                delete newCase;
                updateLeadStatus(leadId, client,'Force4J Closed');
                //debugLog('deleteing case parties');
                //delete cps;
            } catch (Dmlexception d) {
                System.debug(d);
            } catch (Exception e) {
                System.debug(e);                
            }
            
        } 
        if (this.isNewEditMode) {
            this.doCancelJsMethod = 'fConsoleTabLockToggle(false); closePrimaryAndSubs();';
            // ELC - Not sure that this is needed if we are closing the window
            this.displayIneligibleBtn = false;
        }
        if (this.isViewOnly) {
            this.doCancelJsMethod = 'fConsoleTabLockToggle(false);closeTab();return false;';
        }
        this.isViewOnly = true;
        this.isNewEditMode = false;
        this.isEditMode = false;
        this.displayIneligibleBtn = false;
        this.incompleteClient = false;
        debugLog('-- bottom of doCancel') ;      
        return null;
    } 
    public Pagereference doNoMatch() {
        //delete this.client;   
        debugLog('in doNoMatch searchType being evaluated = '+searchType) ;
        if(searchType == 'Client') {
            debugLog('updating sl match status for client:'+slClient) ;
            if(slClient != null) {
                updateSearchLogMatchStatus('No',this.slClient.id,this.slClient.Contact_Reviewed__c,'Client');
            }
        }    
        if(searchType == 'Party') {
            debugLog('<font color=blue><b>searchType var is Party...updating sl match status for party:'+currentPartySl+'</b></font>') ;
            if(slClient != null) {
                if(slClient.fromPage__c != 'vfCaseDetail_AddParty') {
                    slClient.fromPage__c = 'vfClient';
                }
                debugLog('<font color=blue><b>updating slclient from page to vfClient slClient='+slClient+'</b></font>') ;
                
                update slClient;
            }
            updatePartySearchLogMatchStatus('No',this.currentPartySl);
            //------------delete currentPartySl;
        }
        return null;
    } 
    /**
     * This method which will roll through the Case_Party__c
     * records associated to the passed contact and insert Possible_Conflict__c records if applicable.
     *
     * @param cps               A List of Case_Party__c objects to be evaluated.
     * @param searchType        Either 'Client' or 'Party'. The search that was executed.
     * @param Contact           The Contact record selected in the Search Results.
     * @param searchLogClient   The Parent Search Log saved after performing the search. (Client).
     *                          This is derived from search_log__c. This is the record written after the user performs a client search to save state.
     * @param searchLogParty    The Child Search Log saved after performing the search. (Party).
     *                          This is derived form search_log_children__c (I know bad API Name).
     *
     * @returns Set<Id>         If records are inserted.. the set of ids of the records. 
     *
     * @TODO.. RJN this can't be right but i'm afraid to change at the moment.. Validate business rules!
     * @TODO.. RJN What about interested parties? 
     */
    public Set<Id> evalAndMaybeCreatePossibleConflicts(    List<Case_Party__c> cps, 
                                                            String searchType, Contact c,
                                                            Search_Log__c searchLogClient, Search_Log_Children__c searchLogParty){
        Set<Id> pcIdsInserted = new Set<Id>();
        Boolean bAnyPossibleConflict = false;
                                                                    
        //-- Simple arg validation ---
        debugLog('--- createPossibleConflictings... entering method..');
        if(cps == null || cps.isEmpty()) { debugLog('-No case parties to eval. .Peace out'); return null;}
        if(searchType == null || searchType == '' || (searchType != 'Client' && searchType != 'Party' ) ){debugLog('- invalid search type:'+searchType+' Peace out');return null;}
        if(c == null) {debugLog('-What the heck! contact should not be null!.....Peace out');return null; }
        if(searchLogClient == null && searchLogParty == null) {debugLog('-BOTH searchLogClient and searchLogParty cannot be null either!.....Peace out');return null; }
        //----------------------------
        debugLog('- contact.id='+c.id + ' contact.name='+c.name);
        debugLog('- searchType='+searchType);
        debugLog('- # of cp records:'+cps.size());      
        if(searchLogClient != null) {
            debugLog('- searchLogClient id:'+searchLogClient.id + ' searchLogClient.name:'+searchLogClient.name);                   
        }
        if(searchLogParty != null) {
            debugLog('- searchLogParty id:'+searchLogParty.id + ' searchLogParty.name:'+searchLogParty.name);                   
        }               
        List<Possible_Conflict__c> pcs = new List<Possible_Conflict__c>(); 
        /**
         * Roll through Case Party Records..
         */
       
        for(Case_Party__c cp : cps) {
            debugLog('case party record being evaluated ='+cp);
            if(cp.case__C == null) {
                debugLog('----- cp='+cp + ' was dissociated to its case somehow so skipping');
                continue; 
            }
            if(searchType == 'Client') { /* We initiated a Client Search on the Intake Page */
                // ELC - added IP here in response to defect #00993965 - added Other as request from Al
                if(('Adverse party'.equalsIgnoreCase(cp.type__c) || 'Interested Party'.equalsIgnoreCase(cp.type__c) || 'Other'.equalsIgnoreCase(cp.type__c))
                    && cp.contact__c == client.id 
                    && c.Contact_Type__c != 'Organization') {                   
                
                    Possible_Conflict__c pc = new Possible_Conflict__c();
                    pc.Search_Log_Client__c = searchLogClient.id;
                    pc.case__c = cp.case__c;
                    pc.contact_being_reviewed__c = searchLogClient.Contact_Reviewed__c;
                    pc.possible_reason__c = 'Client - Adverse Party';
                    pcs.add(pc);
                    bAnyPossibleConflict = true;                                    
                }                   
            } else if (searchType == 'Party') { /* We initiated a Party Search on the Intake Page */
                /* Is this really correct? .. doesn't seem right but who knows....*/
                if(cp.contact__c == c.id && c.Contact_Type__c != 'Organization') {
                    
                    Possible_Conflict__c pc = new Possible_Conflict__c();
                    pc.contact_being_reviewed__c = searchLogParty.Party_Reviewed__c;
                    pc.search_log_party__c = searchLogParty.id;
                    pc.case__c = cp.case__c;
                    if('Client'.equalsIgnoreCase(cp.type__c)) {
                        pc.possible_reason__c = 'Adverse Party - Client';
                    } else {
                        pc.possible_reason__c = 'Adverse Party - Party';
                    }   
                    pcs.add(pc);
                    bAnyPossibleConflict = true;                    
                }
            }
        }  
        if(bAnyPossibleConflict && pcs != null && !pcs.isEmpty()) {
            try {
                debugLog('<font color=\'blue\'>Inserting INSERTING Possible Conflict Records!:'+pcs); 
                pcIdsInserted = DmlUtils.DBInsert(pcs, true);
            }  catch (Exception ex) {
                debugLog('<font color=\'red\'>Inserting INSERTING Possible Conflict Records!:'+ex);
            }                       
        }                   
        return pcIdsInserted;   
    }   
    /**
     * Action method handeling the click of the 'Yes' Button in the yellow match bar.
     *
     *
     * @returns a Pagereference
     */  
    public Pagereference doMatchYes() {
        debugLog('<font color=\'blue\'><b>In doMatchYes:</b></font> id:' + client.id + ' name='+client.name);
        
        if (leadId != null) { // S. Korolivskyi Updated 26.08.2020
            client.Lead__c = leadId;  // S. Korolivskyi Updated 26.08.2020
        } // S. Korolivskyi Updated 26.08.2020
                        
        update client;
        updateLeadStatus(leadId, client, null);

        List<Case_Party__c> caseParties = client.case_parties__r;
        this.displayAddNewIncomeSource = true;
            
        try {
            if(searchType == 'Client') {
                /*
                 * The Search Button pressed was for a Client
                 */
                if( client.Contact_Type__c != 'Organization') { 
                    if (client.status__c == 'Incomplete' && client.category__c.contains('Client')) {
                        String url = '/apex/vfClient?id='+client.id;
                        url += '&newclient=true';
                        List<Case_Party__c> tempCps = client.Case_Parties__r;
                        if(tempCps != null && !tempCps.isEmpty()) {     
                            Id newCseId = tempCps[0].case__c;
                            url += '&newCaseId='+newCseId;
                        } 
                        PageReference pageRef = new PageReference(url).setRedirect(true);
                        debugLog('url='+url);
                        return pageRef;                     
                    }
                    if(caseParties != null && caseParties.size() > 0) {
                        debugLog('<font color=\'blue\'><b>Running Conflict Check for contact:</b></font> id:' + client.id + ' name='+client.name);                                          
                        //-- Pull Any Existing PC records and Nuke.
                        List<Possible_Conflict__c> existingPcs = [select id from possible_conflict__c where search_log_client__c  = :slClient.id];          
                        if(existingPcs != null) {
                            delete existingPcs;
                        }
                        Set<Id> potentialConflictIds = evalAndMaybeCreatePossibleConflicts(caseParties,
                                                                            this.searchType, this.client,
                                                                            this.slClient,null);
                        this.potentialConflict = potentialConflictIds!=null && potentialConflictIds.size() > 0;
                                                                
                        if(!this.potentialConflict) {
                            this.isConflictSearchComplete = true;
                            debugLog('<font color=\'green\'>NO Potential Conflict Found.. </font> (Looking for a case party that is a type of Adverse Party and the client='+client.name);              
                        } else {
                            debugLog('<font color=\'green\'>Possible Conflict(s) Found. Possible_Conflict__c records inserted:'+potentialConflictIds+'</font>');                                            
                        }
                    } else {
                        // There are no case party records for this contact.  Since the user said it's
                        // a match, we need to add code here to go back to intake search
                        
                        // setting this to false - was undefined before causing erratic results - no case parties, no potential conflict
                        this.potentialConflict = false;
                        doAddParties();
                        matchButNoCaseParties = true;
                        this.matchButNoCasePartiesJsMethod = 'refreshPrimaryAndCloseSub();';
                                
                        debugLog('<font color=\'orange\'>NO case parties found that were attached to the client.. client</font>='+client+' slid = '+slClient.id+' searchType = '+searchType);
                    }           
                    if(!this.potentialConflict) {
                    
                        if(searchType == 'Client') {
                            updateSearchLogMatchStatus('Yes',this.slClient.id,this.slClient.Contact_Reviewed__c,'Client');
                        }
                        //@TODO RJN how is the below ever being called? should it be?? is search type being faked somewhere?
                        if(searchType == 'Party') {
                            updatePartySearchLogMatchStatus('Yes', this.currentPartySl);
                        }
                        this.displayAddNewIncomeSource = true;
                    }
                } else {
                    debugLog('<font color=purple> contact type is Organization so skipping conflicts check. (searchtype = party)</font>');  
                }               
            } else if(searchType == 'Party') {
                    //Added back party per AL @TODO Client Type Mod
                    List<String> sCategories = Utilities.getPlValues(client.category__c);
                    Set<Id> potentialConflictIds;
                    if( client.Contact_Type__c != 'Organization') { 
                        // removing this check - want conflict check for all types of contacts 
                        //if(Utilities.doesListHaveValue(sCategories,'Client') || Utilities.doesListHaveValue(sCategories,'Party') ) {                    
                            debugLog('<font color=\'blue\'><b>Running Conflict Check for contact category: ' +client.category__c + ' party search:</b></font> ' + client); 
                            List<Possible_Conflict__c> pcsToClear = [select id from possible_conflict__c where search_log_party__c = :this.currentPartySl.id];
                            if(pcsToClear != null && !pcsToClear.isEmpty()) {
                                delete pcsToClear;
                            }
                            List<Possible_Conflict__c> pcs = new List<Possible_Conflict__c>();
    
                            potentialConflictIds = evalAndMaybeCreatePossibleConflicts(caseParties,
                                                                                this.searchType, this.client,
                                                                                null,this.currentPartySl);
                            this.potentialConflict = potentialConflictIds!=null && potentialConflictIds.size() > 0;                     
                            partyIsClientConflict = potentialConflict; //@TODO is this needed.                      
                        //}               
                        if(!this.potentialConflict) {
                            debugLog('<font color=\'green\'>NO Potential Conflict Found.. </font> (the party is not a client or cp record already reviewed party='+client.name);            
                            this.displayAddNewIncomeSource = true;
                        } else {
                            debugLog('<font color=\'green\'>Possible Conflict(s) Found. Possible_Conflict__c records inserted:'+potentialConflictIds+'</font>');                            
                        }
                    } else {
                        debugLog('<font color=purple> contact type is Organization so skipping conflicts check. (searchtype = party)</font>');
                    }
            } else { 
                debugLog('<font color=\'yellow\'><b>Bypassing conflict check</b> because we fell through search type check</font>');                    
            }
        } catch (Exception e) {
            debugLog(e.getMessage());
        }
        debugLog('In doMatchYes.. matchAndContinuePressed1='+this.matchAndContinuePressed); 
        if(this.matchAndContinuePressed && this.potentialConflict) {
            this.displayConflictAlert = true;
        } 
//      potentialConflict = false;   
        /**
         * Some of this crap is obsolete. ie the highlighting of the row in the CP related list.
         * Thats how we started it but reqs changed to autopop to case screen and roll through 
         * as opposed to clicking view in the link.
         */
        if(potentialConflict) {
            String msg = '';
            if(!partyIsClientConflict) {
                msg = '<b>Conflict Alert!</b> Please review the case highlighted in yellow via clicking the view case link.';
            } else {
                List<String> sCategories = Utilities.getPlValues(client.category__c);
                //@TODO Client Type Mod
                if(Utilities.doesListHaveValue(sCategories,'Party')){
                //if(client.recordtype.name == 'Party') {
                //  msg = '<b>Conflict Alert!</b> Please review the case highlighted in yellow via clicking the view case link.';                       
                } else {
                //  msg = '<b>Conflict Alert!</b> Party being reviewed is a client. Please review the case below via clicking the view case link.'; 
                }
            }       
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,msg)); 
            
            /* bounce to  the case page  */
            List<Possible_Conflict__c> pcs = new List<Possible_Conflict__c>();
            Id slId;
            if(this.searchType == 'Client') {
                slId = slClient.id;
            } else {
                slId = currentPartySl.id;
            }
            pcs = caseUtils.retrievePossibleCaseConflicts(slId,searchType);
            if(pcs == null || pcs.isEmpty()) {
                    msg = 'No Possible Conflict Records Found!';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));               
                return null;
            }
            Possible_Conflict__c pc = pcs[0]; // <--- PULL FIRST POSSIBLE CONFLICT RECORD!!!!
            Id caseId = pc.case__c;

            String url = '/apex/vfCaseDetail?id='+caseId;
            url+='&tempCase=false&review=true';
            url+='&potentialConflict=true';
            url+='&contactBeingReviewed='+this.client.id;
            if(searchType == 'Client') {
                url+='&slId='+slClient.id;
            } else {
                url+='&slId='+this.currentPartySl.id;
            }
            url+='&searchType='+this.searchType;
            
            PageReference pageRef = new PageReference(url);
            
            debugLog('url='+url);
            return pageRef;
            /* ----- end bounce */                  
        } else {
            Boolean partiesExist = this.getDoSearchPartiesExist();
            String msg = '';
            if(searchType == 'Client') {
                List<String> lCategories = Utilities.getPlValues(client.category__c);
                //@TODO Contact Type Mod
                if(Utilities.doesListHaveValue(lCategories,'Party')) {
                //if(client.recordType.name == 'Party') {
                    msg = 'No Conflict Found!';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg)); 
                    this.displayAddParties = true;
                    this.isPartyReview = false;
                    debugLog('displayAddParties='+displayAddParties);
                    debugLog('isPartyReview='+isPartyReview);
                } 
                try {
                    update client;
                    //--- RJN POST DEMO MOD this.displaySaveAndContinueCurrentPage = true;
                    debugLog('just updated the client.. setting viewOnly true.. setting show match bar = false');
                    this.isViewOnly = true;
                    this.showMatchActionBar = false;
                    //this.isNewEditMode = true;
                } catch (DmlException e) {
                    //if(e.getDmlType(0) == StatusCode.REQUIRED_FIELD_MISSING) {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Required Fields Missing'));  
                    //}
                    
                }
                
            
            } else  {
                //msg = 'You may double click next to any field or click save and continue to add the party to the new case.';
            }
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));  
        
            if(this.matchAndContinuePressed) {
                /// post demo mod this.isViewOnly = false;
                if(partiesExist) {
                    this.displaySaveAndContinueToCase = true;
                    CaseUtils caseUtils = new CaseUtils();
                    //Case_Party__c cpClient = caseUtils.retrieveCaseParty(, Id contactId)
                } else {
                    if(searchType =='Client') {
                        //RJN post demo mod this.displaySaveAndContinueToCase = false;
                        debugLog('in.. doMatchYes... matchAndCont was pressed.. search type = client.');
                        debugLog('setting displaySaveAndContinueToCase to true');
                        
                        this.displaySaveAndContinueToCase = true;
                        List<Case_Party__c> cps = client.Case_Parties__r;
                        if(cps != null && !cps.isEmpty()) {
                            String tmsg = 'To add further service, please scroll down to the cases list and click View';
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,tmsg));      
                        }
                        
                        
                    }
                    this.displayAddParties = true;
                    if(searchType == 'Party') {
                        this.displaySaveAndContinueCurrentPage = true;
                        this.displayMatchReloadJs = true;
                        if(slClient != null) {
                            //return doAddParties();
                            currentPartySl.Marked_as_Match__c = 'Yes';
                            update currentPartySl;
                        }
                    }
                    //rjn rjn drop this down is script on vf page (ensure button rerender shows this)
                    
                    //RJN 12/05/14 if coming from a tab that is dirt.. ie. has unsaved changes ie an *
                    //we cannot simply start closing and refreshing tabs we must just close this tab
                    //just focus being placed on tab we came back from.  do the same thing if one is simply open and not dirty as well
                    if(!this.fromDirtyTab && 'true' != sIsOpenServiceTab) { 
                        this.saveAndContinueJsMethod = 'fConsoleTabLockToggle(false);refreshPrimaryAndCloseSub();';
                    } else {
                        this.saveAndContinueJsMethod = 'fConsoleTabLockToggle(false);closeTab();';
                    }
                    debugLog('saveAndContinueJsMethod'+saveAndContinueJsMethod);
                    
                }
            } 
            this.displayAddNewIncomeSource = true;
            //this.isViewOnly = false;
            
            debugLog('doMatchYes= isViewOnly='+isViewOnly);
            //debugLog('setting isViewOnlyTo TRUE!!!!');
            //this.isViewOnly = true;
        }
        
        return null;
        
    }
    public Pagereference doSaveAndPostProject() {
        client.Status__c = 'Pending';
        client.Temp_Record__c = false;
        
        update client;
        return null;
    }
    public PageReference doCancelSaveAndPost() {
        client.Temp_Record__c = true;

        update client;
        this.displaySaveAndPostForm = false;
        ApexPages.currentPage().getParameters().put('newClient','true');
        //URL=System.PageReference[/apex/vfClient?id=003L000000L3RwHIAV&isdtp=vw&newCaseId=500L0000002doWlIAI&newclient=true&nonce=7ab9fce9015174a89e92a84b3ab7d0fb7d0ef8c5ab6ae57c66b140f020ff334c&sfdcIFrameOrigin=https%3A%2F%2Fcs8.salesforce.com]
        this.doInit();
        return null;
    }
    public Pagereference doAddParties() {
        
        if(this.client.Status__c == 'Pending' || servicedClient) {
            debugLog('<font color=red> PENDING Client or SERVICED Client.. faking a search log </font>');    
            this.slClient = new Search_Log__c();
            SearchWrapper sw = new SearchWrapper();
            sw.Contact.firstname = client.firstname;
            sw.Contact.lastname = client.LastName;
            sw.Contact.phone = client.Phone;
            sw.contact.aliases__c = client.Aliases__c;
            //@TODO Client Type Mod
            //String association = client.RecordType.name;
            String association = client.Category__c;
            this.slClient = writeSearchLog(association,sw);
        }
        
        
        slClient.Contact_Reviewed__c = this.client.id;
        slClient.Marked_as_Match__c = 'Yes';
        slClient.fromPage__c = 'vfClient';
        //slClient.fromPage__c = Apexpages.currentPage().getUrl();
        update slClient;
        
        //Apexpages.currentPage().getParameters().put('newSearch','false');  //overrides value set in home page. if it was set
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
        sl.fromPage__c = 'vfCarplsHome';
        sl.sessionId__c = UserInfo.getSessionId();
        
        insert sl;      
        return sl;      
    }   
    public Pagereference doAddIncomeDetails() {
        update client;
        return null;
    }
    public Pagereference doSaveAndContinueCurrentPage() {
        debugLog('In doSaveAndContinueCurrentPage.. updating contact record') ; 
        if (isPartyReview) {
        	validationErrors = false;
        } else {
        	validationErrors = missingRequiredFields();
        }
        System.debug('in doSaveAndContinueCurrentPage, ValidationErrors = '+validationErrors);
        if (validationErrors) {
            return null;
        }        
        try {

            System.debug('Danylo client '+client);
            update client;
            updateLeadStatus(leadId, client, null);
            doSaveIncomeSource();
            /*
            if(this.newIncomeSource != null) {
                doSaveNewIncomeSource();
            } 
            */          
            if(cUtils == null) {cUtils = new ContactUtils(); }
            this.pb = cUtils.retrievePoverty(client);
            this.pbAmi = cUtils.retrieveAMIPoverty(client);
            debugLog(' in doSaveAndContinueCurrentPage = pb='+pb);
            if (!client.is_Military__c && pb.containerStyleClass == 'povertyNotEligible') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Client is over income! Please click Ineligible.'));
                validationErrors = true;
                return null;
            } else if (client.is_military__c) {
                //if(pb.containerStyleClass == 'povertyNotEligible') {
                //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Client is over income! Please click Ineligible.'));
                //    validationErrors = true;
                // }
                //rjn don't stop them per all
            }
        } catch (Dmlexception dmlEx) {
            ApexPages.addMessages(dmlEx);
            saveAndContinueJsMethod = '';
            return null;
        }
        if(!this.isViewOnly) {
            this.displayHhIncomeEdit = true;
            this.isNewEditMode = false;
            this.isEditMode = false;
            this.displayHHIncomeViewOnlyPanel = true;
            
            this.displayHHMembersNewEdit = true;
        }
        if(client.Nbr_of_Adults__c != null && client.Nbr_of_Adults__c > 0) {
            this.displaySaveAndContinueToCase = true;
            this.displaySaveAndContinueCurrentPage = false;
            this.displayHHMembersNewEdit = true;
            this.displayHHIncomeViewOnlyPanel = true;
            this.isViewOnly = false;
            //String msg = 'All Client Information is now editable. Please double click any field to edit or click [New Case].';
           // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
            if(currentCaseParty != null) {
                currentCaseParty.Required_Fields_Completed__c = true;
                debugLog('updating currentCaseParty:'+currentCasePArty.id + ' to set req fields completed = true');
                update currentCaseParty;
            }
            
            
        }
        debugLog('In doSaveAndContinueCurrentPage.. matchAndContinuePressed2='+this.matchAndContinuePressed);   
        if(this.matchAndContinuePressed) {
            this.displayConflictAlert = true;
            debugLog('matchAndContinue IS STILL TRUE.. isViewOnly='+isViewOnly);
        }
        this.isViewOnly = true;
        return null;        
    }
    public Pagereference doSaveAndContinueToCase() {
    	
        if (isPartyReview) {
        	validationErrors = false;
        } else {
        	validationErrors = missingRequiredFields();
        }
        System.debug('in doSaveAndContinueToCase, ValidationErrors = '+validationErrors);       
        if (validationErrors) {
            return null;
        }       
        if(this.cUtils == null) {
            this.cUtils = new ContactUtils();
        }

        update client;
        this.pb = cUtils.retrievePoverty(client);
        this.pbAmi = cUtils.retrieveAMIPoverty(client);
        debugLog(' in doSaveAndContinueToCase = pb='+pb);
        /*
        Case cse = new Case();
        cse.ContactId = this.client.id;
        insert cse;
        this.newCase = cse;
        Case_Party__c cp = new Case_Party__c();
        cp.Case__c = cse.id;
        cp.Contact__c = this.client.id;
        */
        
        return null;
    }
    public Pagereference doSaveAndPost() {
        
        try {
            this.doSaveIncomeSource();          
            /*
            if(this.newIncomeSource != null) {
                doSaveNewIncomeSource();
            }
            */

            update client;
            if(cUtils == null) {cUtils = new ContactUtils(); }
            this.pb = cUtils.retrievePoverty(client);
            this.pbAmi = cUtils.retrieveAMIPoverty(client);
            debugLog(' in doSaveAndPost pb='+pb);
        } catch (DmlException dml) {
          //    if(e.getDmlType(0) == StatusCode.REQUIRED_FIELD_MISSING) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,dml.getMessage() ));
                return null;  
        //  }           
        }
        catch (Exception e) {
          //    if(e.getDmlType(0) == StatusCode.REQUIRED_FIELD_MISSING) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '  line#' + e.getLineNumber() ));
                return null;  
        //  }           
        }       
        
        this.isViewOnly = false;
        this.displayHhIncomeEdit = true;
        this.isNewEditMode = false;
        this.isEditMode = false;
        this.displayHHIncomeViewOnlyPanel = true;
        this.displayHhMembersNewEdit = true;
        String msg = 'Contact successfully saved! Please enter the project name.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        if(searchType == 'Client') {
            this.displaySaveAndContinueCurrentPage = true;
        }
        this.client = this.retrieveAllClientData();
        this.displaySaveAndPostForm = true;
        client.project__c  = null;
        //this.saveAndPostJsMethod = 'refreshPrimaryAndCloseSub();';
        
        return null;
    }
    public Pagereference doEditHhIncome() {
        Id IncomeDetailId = selectedId;
        debugLog('<font color=orange>doEditHhIncome selectedId='+selectedId + '</font>');
        // There are instances in which the update is attempted on a deleted row.  I think it's when the 
        // user is clicking in rapid succession, or there is a bad network connection that causes
        // multiple clicks.  This will get rid of the exception that was occurring.
        Income_Detail__c incDet = new Income_Detail__c();
        List<Income_Detail__c> incDets = [select id from income_detail__c where id = :incomeDetailId];
        if (incDets.size() > 0) {
            // swallow an invalid id error because it may mean that the row was deleted.
            // This has been happening when the network is slow.
            try {
                incDet = incDets[0];
                update incDet;
            } catch (DmlException dml) {
                if(dml.getDmlType(0) == StatusCode.INVALID_ID_FIELD) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,dml.getMessage() ));
                }           
            }
            catch (Exception e) {
                if(e.getDmlType(0) == StatusCode.INVALID_ID_FIELD) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '  line#' + e.getLineNumber() ));
                }           
            }       
        }
        this.retrieveAllClientData();           
        
        return null;
    }
    public Pagereference doCancelHhIncome() {
        this.isCancelingIncome = true;
        super.debugLog('<b>doCancelHhIncome. selectedId=</b>' + selectedId+ '<br/>');
        PageReference pr = doRemoveHhIncome();
        return pr;
    }
    public Pagereference doRemoveHhIncome() {
        Boolean success = false;
        super.debugLog('<b>doRemoveHhIncome. selectedId=</b>' + selectedId+ '<br/>');
        // selectedId is a parameter set in vfClient when this method or doCancelHhIncome are called
        Id incomeDet = selectedId;
        // There are instances in which the delete is attempted on an already deleted row.  I think it's when the 
        // user is clicking in rapid succession, or there is a bad network connection that causes
        // multiple clicks.  This will get rid of the exception that was occurring.
        Income_Detail__c incDet = new Income_Detail__c();
        List<Income_Detail__c> incDets = [select id from income_detail__c where id = :incomeDet];
        if (incDets.size() > 0) {
            // swallow an invalid id error because it may mean that the row was deleted.
            // This has been happening when the network is slow.
            incDet = incDets[0];      
            success = ContactUtils.DeleteIncome(incDet);
        }    
            
        this.isDeletingIncome = true;
        
        if(success) {
            customPageMessageSeverityStyleClass = 'confirmM4';
            if(true == isCancelingIncome) {
                customPageMessage = 'Successfully canceled adding an income record.';
            } else  {
                customPageMessage = 'Income record deleted successfully!';
            }   
            displayCustomPageMessage = true;
            this.client = this.retrieveAllClientData(); 
            return this.doSaveIncomeSource();
        } else {
            customPageMessageSeverityStyleClass = 'errorM4';
            customPageMessage += 'Deletion of income record failed!';   
            displayCustomPageMessage = true;
        }
        return null;
    }
    public Pagereference doViewCase() {
        return null;
    }
    public PageReference doAddNewIncomeSource() {
        addNewIncomeSourceBtnClicked = true;
        debugLog('<font color=brown>in doAddNewIncomeSource</font>');
        if ( (client.Nbr_of_Adults__c == null || client.Nbr_of_Adults__c == 0)
            && (client.Nbr_of_Minors__c == null || client.Nbr_of_Minors__c == 0) 
            && !onLoadAddNewIncomeSource) {
                System.debug('here'+client.Nbr_of_Minors__c );
                displayCustomPageMessage = true;    
                customPageMessageSeverityStyleClass = 'warningM4';
                customPageMessage += 'You must not have 0 for both adults and minors';  
                this.displayCustomPageMessage = true;
                if(!true == onLoadAddNewIncomeSource) {
                    debugLog('<font color=brown>existing doAddNewIncomeSource</font>');
                    return null;
                } else {
                    debugLog('<font color=brown>continuing in doAddNewIncomeSource</font>');
                }
        }

        this.doSaveIncomeSource();
        this.newIncomeSource = new Income_Detail__c();
        newIncomeSource.Active__c = true;
        
        newIncomeSource.Contact__c = client.id;
        insert newIncomeSource;
        this.selectedId = newIncomeSource.id;
        debuglog('<font color=blue> Inserting new income source:'+newIncomeSource+'</font>');
        this.client = this.retrieveAllClientData();
        debugLog('-- in doAddNewIncomeSource');
        //insert income detail record here
        this.displayAddNewIncomeForm = true;
        this.displayAddNewIncomeSource = false;
        this.displaySaveNewIncomeSource = true;
        return null;
    }    
    public Pagereference doCalcIncome() {
        calcIncomeSourceBtnClicked = true;
        if(clientIncomeDetails == null || clientIncomeDetails.size() == 0) {
            displayCustomPageMessage = true;        
            customPageMessageSeverityStyleClass = 'warningM4';
            customPageMessage += ' No calculation can be executed as there are no income records added.';
        }
        
        this.selectedId = null;
        
        Pagereference pr = this.doSaveIncomeSource();
        if(!true == displayCustomPageMessage) {
                
            customPageMessageSeverityStyleClass = 'warningM4';
            customPageMessage += ' No calculation can be executed as there are no income records added.';
        } else {
            selectedId = null;
        }   
        return pr;
        
    }

    public Pagereference doSaveIncomeSource() {
        Boolean success = false;
        if(! (true == onLoadAddNewIncomeSource) && !(true == isDeletingIncome) && !(true == incompleteClient) && !this.client.status__c.contains('Ineligible')) {
        if ( (client.Nbr_of_Adults__c == null || client.Nbr_of_Adults__c == 0)
            && (client.Nbr_of_Minors__c == null || client.Nbr_of_Minors__c == 0) ) {
            displayCustomPageMessage = true;        
            customPageMessageSeverityStyleClass = 'warningM4';
            customPageMessage = ' No update to income occurred. You must not have 0 for both adults and minors';    
            return null;
        }
        }
        
        
        debuglog('<font color=blue> Updating Client:'+this.client+'</font>');
        success = ContactUtils.updateContact(this.client);

        if(success) {   
            if(this.clientIncomeDetails!=null && !this.clientIncomeDetails.isEmpty()) {
                if (this.client.status__c == 'Incomplete' || this.client.status__c.contains('Ineligible')) {
                    List<Income_Detail__c> newIncDetails = new List<Income_Detail__c>();    
                    for (Income_Detail__c id: clientIncomeDetails) {
                        if (id.income_type__c != null && id.amount__c != null && id.frequency__c != null) {
                            newIncDetails.add(id);
                        }
                    }
                    clientIncomeDetails = newIncDetails;
                }
                success = ContactUtils.updateIncome(this.clientIncomeDetails); 
                debuglog('<font color=blue> Updating income Details:'+this.clientIncomeDetails+'</font>');
                if(success) {
                    displayCustomPageMessage = true;    
                    customPageMessageSeverityStyleClass = 'confirmM4';
                    if(true == addNewIncomeSourceBtnClicked) {
                        customPageMessageSeverityStyleClass = 'infoM4';
                        customPageMessage=' Please enter income data and click Calculate to save, or Add Income to save and add another row.';  
                    } else {
                        customPageMessage=' Successfully updated client Income!';
                    } 
                }
                this.client = this.retrieveAllClientData();
            } else {
                //nothing
            }
        } else {
            displayCustomPageMessage = true;    
            customPageMessage=' Update of Client Income Failed!';                           
        }
        if(cUtils == null) { cUtils = new ContactUtils(); }
        this.pb =  cUtils.retrievePoverty(client);
        this.pbAmi = cUtils.retrieveAMIPoverty(client);
        debugLog(' in doSaveIncomeSource = pb='+pb);
        debugLog(' in doSaveIncomeSource = pbAmi='+pbAmi);
        return null;
    }
    
 
    public boolean getDoSearchPartiesExist() {
        boolean exists = false;
        if(searchType=='Client') {
            if(this.slClient == null) {
                exists = false;
            } else {
                List<Search_Log_Children__c> slChildren = slClient.search_log_children__r;
                if(slChildren == null || slChildren.isEmpty()) {
                    exists = false;
                }
            }
        }
        return exists;
    }
    public Boolean getDisplayIncomeElgibility() {
        Boolean showIt = false;
        if(client != null && searchType == 'Client') {
            if(client.Income_Details__r != null) {
                if(pb!=null && pb.povertyPct != null) {
                    showIt = true;
                }
            }
        }
        return showIt;
    }
    
    public ctrlClient getTheController() {
        return this;
    }
    public List<Conflict_Log__c> refreshConflictLogs() {
        List<Conflict_Log__c> conflictLogs = caseUtils.retrieveContlictLogs(this.client);
        return conflictLogs;
    }
    public Boolean getDisplayConflictLogs() {
        Boolean showIt = false;
        //if(searchType == 'Client') {
            if(conflictLogs != null && !conflictLogs.isEmpty()) {
                showIt = true;
            }
        //}
        return showIt;
    }
    public void refreshIncomeDetails() {
        //this.client.income_details__r = ContactUtils.retrieveContactIncomeDetails(client.id);     
        
    }
    public void refreshClientCategories() {
        Contact c = ContactUtils.retrieveAllContactInfo(this.client.id);
        this.client.category__c = c.category__c;
    }
    public Pagereference doDefaultClientProfile() {
        client.Referred_By__c = 'Court';
        client.Gender__c = 'Male';
        debugLog('-------in doDefaultClientProfile');
        return null;
        
    }

    public String getSectionCategoryHeader() {
        String sHeader = '';
        
        /*
         * Per Al, Dont show donor, volunteer section header.
         * @TODO RJN store exclusion info in custom settings.
         */
        Set<String> sExcludeCatHeaders = new Set<String>();
        sExcludeCatHeaders.add('Donor');
        sExcludeCatHeaders.add('Volunteer');
        
        List<String> lContactCats = Utilities.detokenizeString(client.category__c, ';');    
        if(lContactCats != null) {
            if(lContactCats.size() == 1) {
                if(!sExcludeCAtHeaders.contains(lContactCats[0])) {
                    sHeader = lContactCats[0];  
                }
            }
        }
        return sHeader;
    }
    public Boolean getShowSectionCategoryHeader() {
        String sHeader = getSectionCategoryHeader();
        return sHeader != null && sHeader != '';
    }
    /**
     * Per al.. We don't really want to see client category information, while within the
     * case process. We only want to see specific associations (Case_Party__c.type) with Cases.
     * So lets try to find that info, if not available, for lack of anything else to display,
     * display the contact category.. .but only display that if the contact is only one category.
     * ie. don't going showing like 5 different categories in the title.
     */
    public String getPageTitle() {
        String sTitle = '';
        
        Integer iCaseClientAssociations     = Integer.valueOf(client.Nbr_of_Case_Client_Associations__c);
        Integer iCasePartyAssociations      = Integer.valueOf(client.Nbr_of_Case_Party_Associations__c);
        Integer iCaseAttorneyAssociations   = Integer.valueOf(client.Nbr_of_Case_Attorney_Associations__c);
        
        if(iCaseClientAssociations > 0) {
            sTitle += 'Client';
        }
        if(iCasePartyAssociations > 0) {
            if(sTitle != '') { sTitle += ' | '; }
            sTitle += 'Party';
        }
        if(iCaseAttorneyAssociations > 0) {
            if(sTitle != '') { sTitle += ' | '; }
            sTitle += 'Attorney';
        }   
        if(sTitle == '') {
            List<String> lContactCats = Utilities.detokenizeString(client.category__c, ';');    
            if(lContactCats != null) {
                if(lContactCats.size() == 1) {
                    sTitle = /*'TEST NOTHING FOUND:'+*/lContactCats[0]; 
                }
            }
                    
        }
        return sTitle;  
    }
    public Boolean getShowPageTitleCategoryIcons() {
        return !getShowPageTitleCaseAssocIcons();
    }
    public Boolean getShowPageTitleCaseAssocIcons() {
        Integer iCaseClientAssociations     = Integer.valueOf(client.Nbr_of_Case_Client_Associations__c);
        Integer iCasePartyAssociations      = Integer.valueOf(client.Nbr_of_Case_Party_Associations__c);
        Integer iCaseAttorneyAssociations   = Integer.valueOf(client.Nbr_of_Case_Attorney_Associations__c);
        return iCaseClientAssociations > 0 || iCasePartyAssociations > 0 || iCaseAttorneyAssociations > 0;              
    }

    public Pagereference doSaveAndRemoveBounceAlert() {

        client.EmailBouncedDate = null;
        client.EmailBouncedReason = null;

        //client.EmailBounced = null;
        update client;
        this.retrieveAllClientData();
        return null;
    }

    // This is a huge pain, but required fields can't be conditional. So, had to make them look 
    // required and do the validation manually.
    public Boolean missingRequiredFields() {
        Boolean missingInput = false;
        debugLog('<b>in ctrlClient missingRequiredFielods </b> client.is_military__c = '+client.is_military__c + ' allInputRequired ='+allInputRequired + 'client.military_service__c='+client.military_service__c );
        debugLog('client ='+client);
        if (!allInputRequired) {
            debugLog('allInput is not required returning immediately');
            return missingInput;

        }

        if (client.mailingstreet == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mailing Street is Required'));
        }
        if (client.mailingcity == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mailing City is Required'));
        }       
        if (client.mailingstate == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mailing State is Required'));
        }   
        if (client.mailingpostalcode == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mailing Postal Code is Required'));
        }
        /*NOT IN PROD CURRENTLY wrong actually this is now in prod rjn */
        if (client.County__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mailing County is Required'));
        }
        

        if (client.birthdate == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Birthdate is Required'));
        }
        if (client.phone == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Phone is Required'));
        }       
        if (client.lastname == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Last Name is Required'));
        }   
        if (client.firstname == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'First Name Code is Required'));
        }
        if(!client.is_military__c) {
            if (client.referred_by__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Referred by is Required'));
            }
        }
        if (client.gender__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Gender is Required'));
        }       
        if (client.ethnicity__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Ethnicity is Required'));
        }   
        if (client.language__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Language is Required'));
        }

        if (client.military_service__c == null) {
            missingInput = true;
            debugLog('setting missingInput = true');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Military Service is Required'));
        }
        if (client.marital__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Marital is Required'));
        }
        if(!client.is_military__c) {
            if (client.minor_children__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Minor Children is Required'));
            }
        }
        if (client.housing__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Housing is Required'));
        }
        if(!client.is_military__c) {
            if (client.citizenship__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Citizenship is Required'));
            }
        }
        if (client.highest_degree__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Highest Degree is Required'));
        }
            debugLog('<font color=red>checking ms=</font>'+client.military_service__c);

        if(!client.is_military__c) {
            if (client.prior_attorney_use__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Prior Attorney Use is Required'));
            }
        }



        if(!client.is_military__c) {
            if (client.Housing_changes_past_5_years__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, '# Housing Changes Last 5 Years is Required'));
            }
        }
        if (client.employment_status__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Employment Status is Required'));
        }


        if(!client.is_military__c) {
            if (client.current_employment_status_years__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Length of Current Employment Status is Required'));
            }
        }
        if(!client.is_military__c) {
            if (client.disability__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Disability is Required'));
            }
            if (client.internet_skill_level__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Internet Skill Level is Required'));
            }

        }
        if (client.nbr_of_adults__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'# of Adults is Required'));
        }
        if (client.nbr_of_minors__c == null) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'# of Minors is Required'));
        }
        if (clientIncomeDetails == null || clientIncomeDetails.isEmpty()) {
            missingInput = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Income is Required. Please add income detail.'));          
        } else {
            for (Income_Detail__c id : clientIncomeDetails) {
                if (id.income_type__c == null || id.amount__c == null || id.frequency__c == null) {
                    missingInput = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'All income fields are Required.'));                                
                }
            }
        }

        if( client.is_military__c) {
            Boolean bValidEntryDate = false;

            if (client.military_association__c == null) {
                //missingInput = true;
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Association is Required'));
            }
            if (client.branch__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Branch is Required'));
            }
            if (client.rank__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Rank is Required'));
            }
            if (client.vdisablity__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'VDisability is Required'));
            }
            if (client.military_status__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Status is Required'));
            }
//            debuglog('in validation entryDate='+String.valueof(entryDate));
            if (client.entry_date_text_yyyy__c == null) {
                missingInput = true;
               // entryDate = null;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Entry Date is Required. If you do not know this please enter 0000 '));
            } else {
                if(client.entry_date_text_yyyy__c == '0' || client.entry_date_text_yyyy__c == '00' || client.entry_date_text_yyyy__c == '000') {
                    missingInput = true;
                    // entryDate = null;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Entry Date is Invalid. If you do not know this please enter 0000 '));
                }
                try {
                    Integer entryDate = Integer.valueOf(client.entry_date_text_yyyy__c);
                    if(entryDate != 0 && entryDate < 1940) {
                        missingInput = true;
                        // entryDate = null;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Entry Date is Invalid. Please enter a value >= 1940 '));

                    } else {
                        bValidEntryDate = true;
                    }

                } catch (Exception e) {
                    missingInput = true;
                    // entryDate = null;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Entry Date is Invalid. If you do not know this please enter 0000 '));
                    system.debug(e);
                }
            }
            if (client.exit_date_text_yyyy__c == null) {
                missingInput = true;
                // entryDate = null;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exit Date is Required. If you do not know this please enter 0000 '));
            } else {
                if(client.exit_date_text_yyyy__c == '0' || client.exit_date_text_yyyy__c == '00' || client.exit_date_text_yyyy__c == '000') {
                    missingInput = true;
                    // entryDate = null;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exit Date is Invalid. If you do not know this please enter 0000 '));
                }  
                try {
                    Integer exitDate = Integer.valueOf(client.exit_date_text_yyyy__c);


                        if(bValidEntryDate) {
                            Integer entryDate = Integer.valueOf(client.entry_date_text_yyyy__c);

                            if (exitDate != 0 && exitDate < entryDate) {
                                missingInput = true;
                                // entryDate = null;
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exit Date is Invalid. Exit Date must be greater then entry date '));
                              }
                        }
                    //if(exitDate > System.Today().year()) {
                     //RJN this doesn't seem right but Al insisted at the time.. i made him change his mind.
                     //+1 for me
                     //missingInput = true;
                       // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exit Date is Invalid. Exit Date must be <= today'));

                        
                    //}



                } catch (Exception e) {
                    missingInput = true;
                    // entryDate = null;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exit Date is Invalid. If you do not know this please enter 0000 '));
                    system.debug(e);
                }
            }
            /*
            if (exitDate == null)  {
                missingInput = true;
                exitDate = null;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exit Date is Required. If you do not know this please enter 0000 '));
            }
            */
            if (client.nbr_of_Deployments__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, '# of deployments is required'));
            }
            if (client.vreferral_source__c == null) {
                missingInput = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'VReferral Source is required'));
            }
        }


       /// if(client.is_currently_bounced__c /*&& !this.getEmailModified()*/) {
        //    missingInput = true;
        //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Email was bounced. Please modify the email address. Bounced reason: '+client.email_bounced_reason__c));
       // }
        //missingInput = true;
        debugLog('returning missingInput='+missingInput);

        return missingInput;

        
    }    
  
    private static void updateLeadStatus(Id leadId, Contact client, String closedReason ) {
        if (leadId == null) {
            if (client.Lead__c != null) {
                leadId = client.Lead__c;
            } else {
                return;
            }
        }
        Lead lead = [SELECT Id, Status, Closed_Reason__c FROM Lead WHERE id = :leadId]; 
        if (closedReason == null) {
            lead.Status = 'Closed - Converted';
        } else {
            lead.Status = 'Closed - Not Converted';
            switch on closedReason {
                when 'Force4J Closed' {
                    lead.Closed_Reason__c = closedReason;
                }
                when 'Ineligible' {
                    lead.Closed_Reason__c = closedReason;
                }
            }
        }
        update lead;
    }
    

}