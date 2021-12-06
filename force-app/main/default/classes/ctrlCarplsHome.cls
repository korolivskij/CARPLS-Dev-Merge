global with sharing class ctrlCarplsHome  extends ctrlCarplesGeneric{
/*
@TODO make obsolete
/*
      
    public List<Search_Log__c>      userSearchLogs              { get; set; }
    public List<Contact>            allPendingContacts          { get; set; }
    public List<Task>               userTasks                   { get; set; }
   // public List<PolyTask>           userPolyTasks               { get; Set; } //polymorphic tasks
   
    public List<ServicedClientWrapper> userServicedClients		{ get; set; }
    public List<Case>               userCases                   { get; set; }
    public List<News_Item__c>       userNewsItems               { get; set; }
    public List<Case>               leftOpenCases               { get; set; }
    public List<RecordType>         caseRts                     { get; Set; }
        
    public String                   selectedTaskStatus          { get; set; }
    public String                   selectedCaseStatus          { get; set; } 
    public String                   selectedCaseRt              { get; Set; }
    public Case                     dummyCaseForStatus          { get; Set; }
    public String					selectedClientOwnerId	{ get; set; }
    public User						selectedClientOwnerUser	{ get; set; }
    public String                   selectedCaseLastServicedById  { get; Set; }
    public User                     selectedCaseLastServicedUser     { get; Set; }
    public String                   selectedProject             { get; set; }
    public Search_Log__c            quickSearchSl               { get; set; }
    public Search_Log__c            selectedSearchLog           { get; set; }
    public caseUtils                caseUtils                   { get; set; }   
    public String                   userSmallPhotoUrl           { get; set; }
    public Id                       closedCaseId                { get; set; }
    
    
    public Boolean                  doesUserHaveOpenCases;  
    public Boolean                  doPendingContactsExist;
    public Boolean					displayQuickSearchPanel		{ get; set; }
    public Map<id,String>           postedStartTimeMap          { get; set; }
    public Integer                  numNewsOptions              { get; set; }
    public Integer 					numHomePageRefreshLoCasesMilliSeconds {get;set;}
    
    
    
     
    public static final Integer     LEFT_OPEN_CASES_SUBTRACT_MINS  = 0; 
    public List<User>				allActiveUsers				{ get; set; }
    
    public Case							caseSearch					{ get; set; }
    public String						jsCaseSearchOnComplete		{ get; set; }
    public String						caseNotFoundMessage			{ get; set; }
    public Boolean						displayQsCustomPageMessage  { get; set; }
    public DateTime        				dummyDateTime				{ get; set; }
    
         
	public Boolean						isRjnDebugMessages			{ get; set; }
	public String						rjnDebugMessages			{ get; set; }  
 

    public ctrlCarplsHome () {
        super();
        this.isRjnDebugMessages = true;
        this.rjnDebugMessages = '   Starting rjn debug..</br>';
        this.displayQsCustomPageMessage = false;
        this.numHomePageRefreshLoCasesMilliSeconds = 30000; //default to 30 seconds

        
        try {
         	Object o =  CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(),'Home_Page_Refresh_Left_Open_Cases__c');   
       		Decimal d = (Decimal)o;
            numHomePageRefreshLoCasesMilliSeconds = d.intValue() * 1000;
            
        } catch (Exception e) {
         	System.debug(logginglevel.error,e);   
        }
         debugLog('<font color=green> PERF CHECK-- before starting class constructor '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        debugLog('in ctrlCarplesHome contructor after calling super');
        dummyCaseForStatus = new Case();
        caseRts = Utilities.retrieveSObjectRecordTypes('Case',null);
        this.caseUtils                  = new CaseUtils();
        this.setDoesUserHaveOpenCases(false);
        
        this.selectedTaskStatus     = 'Not Started';
        this.selectedCaseStatus     = 'Closed';
        this.selectedCaseRt         = 'Carpls_Cases';
        this.selectedProject        = 'All';
        this.postedStartTimeMap     = new Map<Id,String>();

        //RJN Hack... don't require ANY NEWS ITEMS TO EXIST!
        Id bogusId = [select id from user limit 1].id;
        postedStartTimeMap.put(bogusId,'BOOOO');
 		this.caseSearch = new Case();
        this.jsCaseSearchOnComplete = '';       	
               
        this.selectedCaseLastServicedById  = UserInfo.getUserId();
        this.selectedClientOwnerId = UserInfo.getUserId();
        this.selectedCaseLastServicedUser = UserUtils.retrieveUserById(selectedCaseLastServicedById);
        this.selectedClientOwnerUser = this.selectedCaseLastServicedUser;
        this.userSearchLogs         = this.refreshUserSearchLogs(); 
        this.userTasks              = this.refreshUserTasks();  
        this.numNewsOptions = 3;
        this.allActiveUsers = UserUtils.retrieveAllUsers(UserInfo.getUserId());
    //  this.userPolyTasks          = this.refreshUserPolyTasks(); //@TODO for future use.. see method in UserUtils.

        
        //this.userTouchedContacts    = this.refreshUserTouchedContacts();
        this.userServicedClients	= this.refreshUserServicedClients();
        this.userCases              = this.refreshUserCases();
        this.userNewsItems          = this.refreshUserNewsItems();
        this.leftOpenCases          = this.refreshLeftOpenCases();
        this.allPendingContacts     = this.refreshPendingContacts();
        this.displayQuickSearchPanel = false;
        this.userSmallPhotoUrl      = this.retrieveUserSmallPhotoUrl(UserInfo.getUserId());
        debugLog('leftOpenCasesCall='+caseUtils.debugMessages);
        
        this.setDoPendingContactsExist(allPendingContacts != null && !allPendingContacts.isEmpty());
        this.setDoesUserHaveOpenCases(leftOpenCases != null && !leftOpenCases.isEmpty());
        
        sw = new SearchWrapper();
        String msg = 'Hello ' + Userinfo.getFirstName() + '.  Welcome to the Carpls Service Cloud!<br/>';
        
        if(this.getDoesUserHaveOpenCases()) {
            msg += 'You have <font color=\'red\'><b>'+leftOpenCases.size();
            if(leftOpenCases.size() == 1) {
                msg+= ' case left open.</b></font> Please take action on this case.';
            }  else {
                msg+= ' cases left open.</b></font> Please take action on these cases.';
            }
                    
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,msg));
        } else {
            msg += 'Please click the New Intake Search button to start a new intake.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        }
        //this.showDebugMessages = UserInfo.getLastName() == 'Nendza';
            this.getcaseLastServicedOptions();    
        debugLog('<font color=green> PERF CHECK-- END of class constructor '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');      
    }   


	@RemoteAction
    global static boolean remoteDeleteIncompleteService(String serviceId) {
        
        boolean deleted = false;
		try  {
        	Id svcId = serviceId;
          	Id parentCaseId;
          	Consultation__c svc = [select id,Case__c from Consultation__c where id = :svcId];
          	parentCaseId = svc.case__c;
          	delete svc;
          	deleted = true;
        	if(parentCaseId != null) {
        		Case c = [select id, status from case where id = :parentCaseId];
        		if(c != null) {
					System.debug(logginglevel.debug, 'In remoteDeleteIncompleteService: setting case closed');
            		c.status = 'Closed';
            		update c;           			
        		}
        	}  	
         } catch (Exception e) {
          	  System.debug(logginglevel.error,e);
         }
         //@TODO Return object as opposed to simple boolean.
         return deleted;
    } 
    public PageReference doNothing() {
        debugLog('--- in doNothing ---');
        return null;    
    }
    public PageReference doCheckForOpenCases() {
        this.leftOpenCases          = this.refreshLeftOpenCases();
        return null;
    }  
    public Pagereference doInitPage() {
    	debugLog('<font color=green> PERF CHECK-- before doInitPage '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        if(this.getDoesUserHaveOpenCases()) {
        	// commented this out because it was creating confusion and serving no real purpose
        	// I think that it's functionality was served by the Resume Case on the home page
            //caseUtils.addLeftOpenCasesPosts(this.leftOpenCases);
        }
        debugLog('<font color=green> PERF CHECK-- after doInitPage '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return null;    
    }
    public PageReference doCloseCase() {
        this.setDoesUserHaveOpenCases(false);       
        debugLog('.... case closed Id='+closedCaseId);
        this.userCases              = this.refreshUserCases();
        this.leftOpenCases          = this.refreshLeftOpenCases();     
        this.userServicedClients = this.refreshUserServicedClients();
        this.allPendingContacts  = this.refreshPendingContacts();
        
        return null;
    }
    public Pagereference doIntakeSearch() {
        //PageReference pageRef = ApexPages.currentPage();
        //pageRef.getParameters().put('fromHome',true);
        return null;    
    }
    public Pagereference doRefreshTasks() {
        this.userTasks =  this.refreshUserTasks();
        return null;
    }   
    public Pagereference doRefreshCases() {
        this.userCases =  this.refreshUserCases();
        return null;
    }
    public PageReference doTaskStatusSelect() {
        debugLog(' doTaskStatusSelected--- selectedTaskStatus:'+selectedTaskStatus);
        this.userTasks =  this.refreshUserTasks();
        return null;
    }
    public PageReference doCaseFilterSelect() {
        debugLog(' doCaseStatusSelected--- selectedCaseStatus:'+selectedCaseStatus);
        debugLog(' doCaseStatusSelected--- selectedCaseRt:'+selectedCaseRt);
        debugLog(' doCaseLastModIdSelect--- selectedCaseLostModId:'+selectedCaseLastServicedById);
        this.userCases =  this.refreshUserCases();
        if(selectedCaseLastServicedById != null && selectedCaseLastServicedById != '-1') {
            this.selectedCaseLastServicedUser = UserUtils.retrieveUserById(selectedCaseLastServicedById);
        } else {
            this.selectedCaseLastServicedUser = null;
        }
        return null;
    }
    public PageReference doCaseStatusSelect() {
        debugLog(' doCaseStatusSelected--- selectedCaseStatus:'+selectedCaseStatus);
        this.userCases =  this.refreshUserCases();
        return null;
    }
    public PageReference doCaseLastModIdSelect() {
        debugLog(' doCaseLastModIdSelect--- selectedCaseLostModId:'+selectedCaseLastServicedById);
        this.userCases =  this.refreshUserCases();
        return null;
    }
    public PageReference doProjectSelect() {
        debugLog(' doProjectSelect--- selectedProject:'+selectedProject);
        this.allPendingContacts = this.refreshPendingContacts();
        return null;        
    }
    public PageReference doClientOwnerSelect() {
		if(selectedClientOwnerId != null && selectedClientOwnerId != '') {
    		this.selectedClientOwnerUser = UserUtils.retrieveUserById(selectedClientOwnerId);
			debugLog(' doClientOwnerSelect--- selectedClientOwnerUser:'+selectedClientOwnerUser);
		} else {
			debugLog(' doClientOwnerSelect--- selectedClientOwnerUser: ALL Active Users');
		}
    	
    	this.allPendingContacts = this.refreshPendingContacts();
    	return null;
    }
    public Pagereference doRefreshSearchLogs() {
        debugLog(' doRefreshSearchLogs');
        this.userSearchLogs = this.refreshUserSearchLogs();
        return null;
    }
    public Pagereference doExistingSearchSelect() {
        selectedId = ApexPages.currentPage().getParameters().get('paramSelectedSearchId');
        debugLog('existing search id selected = '+selectedId);
        if(selectedId!=null && selectedId != '') {
            this.selectedSearchLog = SearchWrapper.retrieveSearchLog(selectedId);
            if(selectedSearchLog != null) {
                debugLog('updating fromPage on searchLog to vfCarplsHome');
                this.selectedSearchLog.fromPage__c = 'vfCarplsHome';
                this.selectedSearchLog.marked_as_match__c = null;
                this.selectedSearchLog.contact_reviewed__c = null;
                // ELC 2/6/2014
                this.selectedSearchLog.contact_created__c = null;
                update this.selectedSearchLog;
            } else {
                debugLog('No search log found for selected sl id='+selectedId);
            }
        }
        
        return null;
    }
    public Pagereference doRefreshUserServicedClients() {
        debugLog(' doRefreshUserServicedClients');
        this.userServicedClients = this.refreshUserServicedClients();
        //this.userTouchedContacts = this.refreshUserTouchedContacts();
        return null;
    }
    public List<Search_Log__c> refreshUserSearchLogs() {
    	// ELC changed this from 999 to help with view state error on home page
        Integer limitRows = 25;
         debugLog('<font color=green> PERF CHECK-- before refresh of search logs: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        List<Search_Log__c> sls = SearchWrapper.retrieveUserSearchLogs(UserInfo.getUserId(), limitRows);
         debugLog('<font color=green> PERF CHECK-- after refresh of search logs: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return sls;
    }
    public List<Case> refreshLeftOpenCases() {
        String caseStatus = 'Open';
       
    
        debugLog('<font color=green> PERF CHECK-- before refresh of left open cases: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        this.leftOpenCases = caseUtils.retrieveCasesLeftOpen(caseStatus,LEFT_OPEN_CASES_SUBTRACT_MINS);
         debugLog('<font color=green> PERF CHECK-- AFTER refresh of left open cases: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        debugLog('in refgreshLeftOpenCases.. leftOpenCases='+leftOpenCases);
        return leftOpenCases;
    }
    public Pagereference doRefreshLeftOpenCases() {
        this.leftOpenCases = this.refreshLeftOpenCases();
        return null;
    }
    public Pagereference doRefreshAllPendingContacts() {
        this.allPendingContacts = this.refreshPendingContacts();
        return null;
    }
    public List<Task> refreshUserTasks() {
        debugLog(' refreshUserTask--- selectedTaskStatus:'+selectedTaskStatus);
        debugLog('<font color=green> PERF CHECK-- before TASK retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        List<Task> ts = UserUtils.getUsersTasks(UserInfo.getUserId(), selectedTaskStatus,250);
        debugLog('<font color=green> PERF CHECK-- AFTER TASK retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return ts;
    }

    public List<Case> refreshUserCases() { 
        debugLog(' refreshUserCases--- selectedCaseStatus:'+selectedCaseStatus);
        debugLog(' refreshUserCases--- selectedCaseRt:'+selectedCaseRt);
        debugLog(' refreshUserCases--- selectedCaseLastServicedById:'+selectedCaseLastServicedById);
        debugLog('<font color=green> PERF CHECK-- before case retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        List<Case> cases = UserUtils.retrieveCases(selectedCaseLastServicedById, selectedCaseStatus,selectedCaseRt,50);
        debugLog('<font color=green> PERF CHECK-- AFTER case retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return cases;
    }
    public List<News_Item__c> refreshUserNewsItems() { 
        debugLog(' refreshUserNewsItems -- ');
         debugLog('<font color=green> PERF CHECK-- before refresh of news items: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
         
        List<News_Item__c> lNewsItems =  UserUtils.retrieveNewsItems(100);
        debugLog('<font color=green> PERF CHECK-- after refresh of news items: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        if(lNewsItems != null && !lNewsItems.isEmpty()) {
            for(News_Item__c ni : lNewsItems){
                //TimeZone tz = UserInfo.getTimeZone();
                //DateTime localTime = ni.start_date__c.AddSeconds(tz.getOffset(ni.start_date__c)/1000);                
                
                
                //String sTime = localTime.format('h:mm a');
                String sTime = ni.start_date__c.format('h:mm a');
              //  debugLog('Time--'+ sTime);
                String t = sTime;
                
                //t=t.substring(0,5);
                postedStartTimeMap.put(ni.id,t);
            }       
        } 
        return lNewsItems;
    }
    public List<Contact> refreshUserOwnedContacts() {
    	debugLog('<font color=green> PERF CHECK-- before refresh of owned contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
    	
    	List<Contact> cs = UserUtils.retrieveUserOwnedContacts(UserInfo.getUserId()); 
    	debugLog('<font color=green> PERF CHECK-- after refresh of owned contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return cs;      
    }
    public List<ServicedClientWrapper> refreshUserServicedClients() {
        debugLog(' refreshUserServicedClients---'); 
        debugLog('<font color=green> PERF CHECK-- before refresh of serviced clients: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        List<ServicedClientWrapper> scwraps = UserUtils.retrieveTodaysServicedClients(UserInfo.getUserId());
         debugLog('<font color=green> PERF CHECK-- after refresh of serviced clients: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');  
        return scwraps; 
    }
    
    public List<Contact> refreshPendingContacts() {
        debugLog(' refreshPendingContacts with selectedProject = '+selectedProject+'---'); 
        Boolean bShowTempContacts = false; 
        debugLog('<font color=green> PERF CHECK-- before refresh of pending contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        //List<Contact> pendingContacts = ContactUtils.retrieveAllContactsByStatusAndProject(null, selectedProject, 999,bShowTempContacts);  

       // List<Contact> pendingContacts = ContactUtils.retrieveAllContactsByStatusAndProject(this.selectedClientOwnerId, null, selectedProject, 100,bShowTempContacts); 
       List<Contact> pendingContacts = ContactUtils.retrieveAllContactsByStatusAndProject(getNumDaysPendingClients(), null, selectedProject, 100,bShowTempContacts); 
       	if(ContactUtils.debugMessages != null && !ContactUtils.debugMessages.isEmpty()) {
       		debugLog('--- messages from ContactUtils ----');
       		for(DebugMessage dm : ContactUtils.debugMessages) {
       			debugLog(dm.message);
       		}
       		ContactUtils.debugMessages.clear();
       	}
        debugLog('<font color=green> PERF CHECK-- after refresh of pending contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        if(pendingContacts!=null) {
        	
            debugLog('---- number of pending contacts retrieved:'+pendingContacts.size());
        } else {
            debugLog('---- number of pending contacts retrieved is ZERO -- ');
        }
        return pendingContacts;
    }
    public Pagereference doViewSearch() {
        return null;
    }   
    public List<Selectoption> getTaskStatusOptions() {
        List<SelectOption> options = UiUtils.retrievePlValues(new Task(), 'Status');
        List<SelectOption> trimmedOptions = new List<SelectOption>();
        for(SelectOption so : options) {
            if(so != null) {
                String label = so.getLabel();
                if(label != null) {
                    if(label.length() >= 12) {
                        label = label.substring(0, 12);
                        so.setLabel(label);
                    }
                }
                trimmedOptions.add(so);
            }
        }
        return trimmedOptions;
    }
    public List<Selectoption> getContactsProjectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Selectoption so = new Selectoption('','-- All Projects --');
        options.add(so);
        options.addAll( UiUtils.retrievePlValues(new Contact(), 'project__c') );
        
        return options;
    }


    public List<Selectoption> getCaseStatusOptions() {
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');
        
        //List<SelectOption> options = UiUtils.retrievePlValues(new Case(), 'Status');
        
        List<SelectOption> options = UiUtils.retrievePlValues(new Case(), 'Status',rt); 
        List<SelectOption> displayOptions = new List<SelectOption>();
        for(SelectOption so : options) {
            if(so.getValue() != 'Referred Externally (Auto)' 
            && so.getValue() != 'Design' && so.getValue() != 'Fix Applied'
            && so.getValue() != 'Fix Tested' && so.getValue() != 'On Hold' && so.getValue() != 'In Progress' ) {
                    //if(selectedCaseRt = 'Carpls_Cases') {
                        
                        displayOptions.add(so);
                        
                    //}
            }
            
        }
        return displayOptions;
    }
    public List<Selectoption> getCaseRtsOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if(this.caseRts != null) {
            for(RecordType rt : caseRts) {
                Boolean bDisabled = false;
                SelectOption so = new SelectOption(rt.developername, rt.developername,bDisabled);
                options.add(so);    
            }
        }
        return options;

        //return null;
    }   
    public List<SelectOption> getCaseLastServicedOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Id currentUserId = UserInfo.getUserId();
        
        options.add(new selectOption( currentUserId, UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
       // options.add(new selectOption( '-1', ' -- All Active Users --'));
        if(allActiveUsers != null) {
            for(User u : allActiveUsers) {
                options.add(new selectOption( u.id, u.lastname));
            }
        }
        debugLog('--- getcaseLastServicedOptions.. options='+options);
        return options;
         
    }
    public List<SelectOption> getClientOwnerOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Id currentUserId = UserInfo.getUserId();
        
        options.add(new selectOption( currentUserId, UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
        options.add(new selectOption( '', ' -- All Active Users --'));
        if(allActiveUsers != null) {
            for(User u : allActiveUsers) {
                options.add(new selectOption( u.id, u.lastname));
            }
        }
        debugLog('--- getClientOwnerOptions.. options='+options);
        return options;
        
    }
    public Boolean getDisplayTaskResults() {
        return userTasks!=null && !userTasks.isEmpty();
    } 
    public Boolean getDisplayCaseResults() {
        return userCases!=null && !userCases.isEmpty();
    }
    public Boolean getDisplayPendingContactsResults() {
        return allPendingContacts!=null && !allPendingContacts.isEmpty();
    }
    public Boolean getDisplaySearchLogResults() {
        return  this.userSearchLogs !=null && !this.userSearchLogs.isEmpty();
    }   
    public Integer getCountSearchLogResults() {
        Integer count = 0;
        if(this.userSearchLogs == null || this.userSearchLogs.isEmpty()) {
            return 0;
        } else {
            return userSearchLogs.size();   
        }
    }
    public Boolean getDisplayUserServicedClients() {
        return this.userServicedClients !=null && !this.userServicedClients.isEmpty();
    } 
    public PageReference doQuickSearch() {
        slClient = this.writeSearchLog('Client',sw);
        return null;
    }
    public PageReference doShowQuickSearch() {
    	this.displayQuickSearchPanel = true;
    	return null;
    }
    public PageReference doHideQuickSearch() {
    	this.displayQuickSearchPanel = false;
    	return null;
    }
    public PageReference doClearQuickSearch() {
        slClient = null;
        sw = new SearchWrapper();
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
        //sl.case_nbr__c = aSw.caseNumber;
        sl.sessionId__c = UserInfo.getSessionId();
        
        insert sl;      
        return sl;      
    }
    public Boolean getDoPendingContactsExist() {
        return (this.allPendingContacts != null && !this.allPendingContacts.isEmpty());
    }
    public void setDoPendingContactsExist(Boolean b) {
        this.doPendingContactsExist = b;
    }
    public Boolean getDoesUserHaveOpenCases() {
        return (this.leftOpenCases !=null && !this.leftOpenCases.isEmpty());
    }
    public void setDoesUserHaveOpenCases(Boolean b) {
        this.doesUserHaveOpenCases = b;
    }
    public String  retrieveUserSmallPhotoUrl(Id uid) {
        User u = [select id,smallPhotoUrl from user where id = :uid];
        return u.smallPhotoUrl;
    }
  public String getCurrentDateTime() {
            User currentUser = [Select TimeZoneSidKey from User where id =: USerInfo.getUserId()];
            return DateTime.now().format('EEEE MMMM d, yyyy  HH:mm:ss a',currentUser.TimeZoneSidKey);
        
    }

    public Integer getNumDaysPendingClientDisplay() {
    	return super.getNumDaysPendingClients();
    }
    public String getSlClientLastNameSanitized() {
    	String clean = '';
    	if(slClient != null) {
    		String rawLn = slClient.last_Name__c;
    		if(rawLn != null) {
    			clean = String.escapeSingleQuotes(rawLn);
    		} 
    	}
    	return clean; 
    }
	public PageReference doCaseNbrSearch() {
		debugLog('--- in doCaseNbrSearch ---');
		if(caseSearch.CaseNumber != null) {
			String caseNumber = caseSearch.casenumber;
			List<Case> cases = [select id, casenumber from case where casenumber = :casenumber];
			if(cases != null && cases.size() == 1) {
				caseSearch.id = cases[0].id;
				this.caseNotFoundMessage = null;
				
				this.jsCaseSearchOnComplete = 'newSubActivity(\'/apex/vfCaseDetail?id='+caseSearch.id+'&review=true&fromSearch=false&tempCase=false\',\'View: '+caseSearch.caseNumber+ '\');return false;'; 				
			}else {
				this.customPageMessageSeverityStyleClass = 'warningM3';
				displayQsCustomPageMessage = true;
				this.caseNotFoundMessage = 'No records located for case #: '+caseSearch.caseNumber + '. Please enter a different case number or search by other criteria.';
				this.customPageMessage = caseNotFoundMessage;
				jsCaseSearchOnComplete = '';
			} 
			
		} else {
			
			this.caseNotFoundMessage = 'No Cases located for case #: '+caseSearch.caseNumber;	
			jsCaseSearchOnComplete = '';		
		}
		return null;		
	} 
    public PageReference doClearCustomPageMessages() {
      	debugLog('--- clearning custom page messages -----');
        this.customPageMessage = null;
        this.displayQsCustomPageMessage = false;
       
        return null;
    }
    public PageReference doCheckForPageRefresh() {
        this.leftOpenCases = refreshLeftOpenCases();
        Boolean doIt = this.getDoesUserHaveOpenCases();
     
        debugLog('--- in doCheckForPageRefresh() ----- doIt='+doIt);
        return null;
    }

	public class MyServices {
		
	}
*/
}