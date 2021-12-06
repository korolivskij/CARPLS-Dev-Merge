global with sharing class ctrlCarplsHome_NewDesign  extends ctrlCarplesGeneric{
/*RJN TABX made global for remote method */

   // public List<Selectoption>		taskAssignmentOptions		{ get; set; }
   // public String					selectedTaskAssignmentOption { get; set;}

    public List<Search_Log__c>      userSearchLogs              { get; set; }
    public List<Contact>            allPendingContacts          { get; set; }
    public List<Task>               userTasks                   { get; set; }
    public List<EventRelation>		userEvents					{ get; set; }
    public List<Event>				myEvents					{ get; set; }
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
    public Boolean                  displayNewNewsBtn           { get; set; }
    public Map<id,String>           postedStartTimeMap          { get; set; }
    public Integer                  numNewsOptions              { get; set; }
    public Integer 					numHomePageRefreshLoCasesMilliSeconds {get;set;}




    public static final Integer     LEFT_OPEN_CASES_SUBTRACT_MINS  = 0;
    public List<User>				allActiveUsers				{ get; set; }
    
    // Sergii addded 
    public List<User>				usersList				{ get; set; }
    public String				    chosenUserId		{ get; set; }
    public String                   chosenCalendarType  { get; set;}
    public String				    chosenUserName		{ get; set; }
    public List<Event>	 chosenEvents    {get;set;}
    public Boolean       showChosenEvents {get;set;}
    public List<leadItemsToApproveWrapper> leadItemsToApprove {get;set;} 
    public User currentUser {get;set;}

    public Case							caseSearch					{ get; set; }
    public String						jsCaseSearchOnComplete		{ get; set; }
    public String						caseNotFoundMessage			{ get; set; }
    public Boolean						displayQsCustomPageMessage  { get; set; }
    public DateTime        				dummyDateTime				{ get; set; }


	public Boolean						isRjnDebugMessages			{ get; set; }

	public String						rjnDebugMessages			{ get; set; }
	public List<MyService>				myServices					{get; Set;}
    public String                       selectedIntakeType          { get; set; }
    public Boolean                      isVeteranGroupMember        {get;set;}
    // Keith Snider added 12/24/2020
    public List<Group>                  taskQueues                  {get; set; }
    public String                       chosenTaskQueue             {get; set; }
    public Boolean						displayTaskResults			{get; set; }

  public Id selectedId {get;set;}

    public Pagereference doSetIntakeType() {
        if(selectedIntakeType != null && selectedIntakeType != '') {
            User u = [select id, intake_type__c from user where id = :UserInfo.getUserId()];
            u.intake_type__c = selectedIntakeType;
            update u;
        }
        return null;
    }

    public ctrlCarplsHome_NewDesign () {

        super();
        this.isVeteranGroupMember = GroupUtils.isGroupMember('IL-AFLAN');//@TODO Custom setting for name?


        this.myServices = new List<MyService>();
        //this.selectedTaskAssignmentOption = '';
        //this.retrieveTaskAssignmentOptions();

        this.isRjnDebugMessages = true;
        this.rjnDebugMessages = '   Starting rjn debug..</br>';
        this.displayQsCustomPageMessage = false;
        this.numHomePageRefreshLoCasesMilliSeconds = 30000; //default to 30 seconds
        this.displayNewNewsBtn = this.canUserAddNews();


        try {
         	Object o =  CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(),'Home_Page_Refresh_Left_Open_Cases__c');
       		Decimal d = (Decimal)o;
            numHomePageRefreshLoCasesMilliSeconds = d.intValue() * 1000;

        } catch (Exception e) {
         	System.debug(logginglevel.error,e);
        }
         ////debugLog('<font color=green> PERF CHECK-- before starting class constructor '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        ////debugLog('in ctrlCarplesHome contructor after calling super');
        dummyCaseForStatus = new Case();
        caseRts = Utilities.retrieveSObjectRecordTypes('Case',null);
        this.caseUtils                  = new CaseUtils();
        this.setDoesUserHaveOpenCases(false);

        this.selectedTaskStatus     = 'In Progress';
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
        //this.selectedCaseLastServicedUser = UserUtils.retrieveUserById(selectedCaseLastServicedById);
        //this.selectedClientOwnerUser = this.selectedCaseLastServicedUser;

        this.userTasks              = this.refreshUserTasks();
        getDisplayTaskResult();

        this.refreshUserEvents();

        this.numNewsOptions = 3;
        //this.allActiveUsers = UserUtils.retrieveAllUsers(UserInfo.getUserId());
    //  this.userPolyTasks          = this.refreshUserPolyTasks(); //@TODO for future use.. see method in UserUtils.


        //this.userTouchedContacts    = this.refreshUserTouchedContacts();
        this.myServices	= this.refreshUserServicedClients();
        this.userCases              = this.refreshUserCases();
        this.userNewsItems          = this.refreshUserNewsItems();
        this.leftOpenCases          = this.refreshLeftOpenCases();
        //this.allPendingContacts     = this.refreshPendingContacts();
        this.displayQuickSearchPanel = false;
        //this.userSmallPhotoUrl      = this.retrieveUserSmallPhotoUrl(UserInfo.getUserId());
        ////debugLog('leftOpenCasesCall='+caseUtils.debugMessages);

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

        ////debugLog('<font color=green> PERF CHECK-- END of class constructor '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
    
        //added by Sergii at 09/22/2020
       // this.usersList = [SELECT Id, Name FROM User WHERE isActive = true AND Calendly_User__c = true ORDER BY Name Asc]; 
        this.usersList = [SELECT Id,Name, Schedule_Map__c FROM User WHERE isActive = true AND Calendly_User__c = true AND Schedule_Map__c != null ORDER BY Schedule_Map__c Asc]; 
        this.showChosenEvents = false;
        this.chosenEvents = new List<Event>();
        
        List<User> currentUsers = [SELECT Id, Name FROM User WHERE isActive = true AND NewLeaf__c = true AND Id = :UserInfo.getUserId()];
        this.currentUser = currentUsers.isEmpty() ? null : currentUsers.get(0);
        this.leadItemsToApprove = retriveItemsToBeApproved();

        // added by Keith Snider 12/24/2020
        this.taskQueues = this.getUserAssignedTaskQueues();
    }
    public PageReference doCloseTask() {
        Task t = [select id, status from task where id = :selectedId];
        t.status = 'Completed';
        update t;
        this.doRefreshTasks();
        return null;
    }    


    /**
     * Triggered on vfCarplesHome.page via event listener delIncompleteServiceListener.
     * Event listener is listening for event = evtDelIncompleteService.
     * This is currently fired from vfCase.page used then the primary case tab is closed
     * because that closes the vfResourceLibraryTab so we can't use that.
     */
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
        ////debugLog('--- in doNothing ---');
        return null;
    }
    public PageReference doCheckForOpenCases() {
        this.leftOpenCases          = this.refreshLeftOpenCases();
       //--- rjn didn't matter this.setDoesUserHaveOpenCases(leftOpenCases == null || leftOpenCases.isEmpty());
        doRefreshUserServicedClients();
        //---- pound this with a hammer as i'm sick of the complaining about it.
        //something is getting stuck in viewstate just simulate F5 / flush the viewstate and reload.
        //there is something inherently wrong with vf / actionfunctions and many refreshes.
        //this page wont' show much data anyway so better safe then sorry.
        //sigh can't do this as sfdc will pound us with replay messages from the pushtopic as it's a new client id
        //if we flush the viewstate.
        //we can use with replay turned off
        //PageReference pr = Page.vfCarplsHome;
        //pr.setRedirect(true);
        //return pr;
        return null;
    }


    public Pagereference doIntakeSearch() {
        //PageReference pageRef = ApexPages.currentPage();
        //pageRef.getParameters().put('fromHome',true);
        return null;
    }
    public Pagereference doRefreshTasks() {
        this.userTasks =   ctrlCarplsHome_NewDesign.retrieveUserTasks(UserInfo.getUserId(),100);
        return null;
    }
    public Pagereference doRefreshNews() {
      //debugLog('do RefreshNews called');
      system.debug('in doRefreshNews');
    	this.userNewsItems          = this.refreshUserNewsItems();
      system.debug('returning from doRefreshNews');
    	return null;
    }
    public Pagereference doRefreshCases() {
        this.userCases =  this.refreshUserCases();
        return null;
    }




    public Pagereference doRefreshUserServicedClients() {

        this.myServices = this.refreshUserServicedClients();

        return null;
    }

    public List<Case> refreshLeftOpenCases() {
        String caseStatus = 'Open';


        ////debugLog('<font color=green> PERF CHECK-- before refresh of left open cases: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        this.leftOpenCases = retrieveCasesLeftOpenLocal(caseStatus,LEFT_OPEN_CASES_SUBTRACT_MINS);
         ////debugLog('<font color=green> PERF CHECK-- AFTER refresh of left open cases: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        ////debugLog('in refgreshLeftOpenCases.. leftOpenCases='+leftOpenCases);
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
        ////debugLog(' refreshUserTask--- selectedTaskStatus:'+selectedTaskStatus);
        ////debugLog('<font color=green> PERF CHECK-- before TASK retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        List<Task> ts = ctrlCarplsHome_NewDesign.retrieveUserTasks(UserInfo.getUserId(), 150);
        ////debugLog('<font color=green> PERF CHECK-- AFTER TASK retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return ts;
    }
    public void refreshUserEvents() {
    	//this.userEvents = Activity.retrieveUserTodaysEvents(UserInfo.getUserId());
    	this.myEvents = Activity.retrieveUserTodaysOwnedEventsAndInvitedEvents(UserInfo.getUserId());
    }
    /* @TODO For future use.. see method in UserUtils.
    public List<PolyTask> refreshUserPolyTasks() {
        //debugLog(' refreshUserPolyTasks--- selectedTaskStatus:'+selectedTaskStatus);
        return UserUtils.getUsersPolyTasks(UserInfo.getUserId(), selectedTaskStatus,999);
    }
    */
    public List<Case> refreshUserCases() {
        ////debugLog(' refreshUserCases--- selectedCaseStatus:'+selectedCaseStatus);
        ////debugLog(' refreshUserCases--- selectedCaseRt:'+selectedCaseRt);
        //debugLog(' refreshUserCases--- selectedCaseLastServicedById:'+selectedCaseLastServicedById);
        //debugLog('<font color=green> PERF CHECK-- before case retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        List<Case> cases = UserUtils.retrieveCases(selectedCaseLastServicedById, selectedCaseStatus,selectedCaseRt,50);
        //debugLog('<font color=green> PERF CHECK-- AFTER case retrieval: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return cases;
    }
    public List<News_Item__c> refreshUserNewsItems() {
        //debugLog(' refreshUserNewsItems -- ');
         //debugLog('<font color=green> PERF CHECK-- before refresh of news items: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');

        List<News_Item__c> lNewsItems =  UserUtils.retrieveNewsItems(7);
        //debugLog('<font color=green> PERF CHECK-- after refresh of news items: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        if(lNewsItems != null && !lNewsItems.isEmpty()) {
            for(News_Item__c ni : lNewsItems){
                //TimeZone tz = UserInfo.getTimeZone();
                //DateTime localTime = ni.start_date__c.AddSeconds(tz.getOffset(ni.start_date__c)/1000);


                //String sTime = localTime.format('h:mm a');
                String sTime = ni.start_date__c.format('h:mm a');
              //  //debugLog('Time--'+ sTime);
                String t = sTime;

                //t=t.substring(0,5);
                postedStartTimeMap.put(ni.id,t);
            }
        }
        return lNewsItems;
    }
    public List<Contact> refreshUserOwnedContacts() {
    	//debugLog('<font color=green> PERF CHECK-- before refresh of owned contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');

    	List<Contact> cs = UserUtils.retrieveUserOwnedContacts(UserInfo.getUserId());
    	//debugLog('<font color=green> PERF CHECK-- after refresh of owned contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        return cs;
    }
    public List<MyService> refreshUserServicedClients() {
                List<MyService> mysvcs = retrieveMyServices(UserInfo.getUserId());
				return mysvcs;
	}

    public List<Contact> refreshPendingContacts() {
        //debugLog(' refreshPendingContacts with selectedProject = '+selectedProject+'---');
        Boolean bShowTempContacts = false;
        //debugLog('<font color=green> PERF CHECK-- before refresh of pending contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        //List<Contact> pendingContacts = ContactUtils.retrieveAllContactsByStatusAndProject(null, selectedProject, 999,bShowTempContacts);

       // List<Contact> pendingContacts = ContactUtils.retrieveAllContactsByStatusAndProject(this.selectedClientOwnerId, null, selectedProject, 100,bShowTempContacts);
       List<Contact> pendingContacts = ContactUtils.retrieveAllContactsByStatusAndProject(getNumDaysPendingClients(), null, selectedProject, 100,bShowTempContacts);
       	if(ContactUtils.debugMessages != null && !ContactUtils.debugMessages.isEmpty()) {
       		//debugLog('--- messages from ContactUtils ----');
       		for(DebugMessage dm : ContactUtils.debugMessages) {
       			//debugLog(dm.message);
       		}
       		ContactUtils.debugMessages.clear();
       	}
        //debugLog('<font color=green> PERF CHECK-- after refresh of pending contacts: '+DateTime.now().format('h:mm :ss.SSS a') +'</font>');
        if(pendingContacts!=null) {

            //debugLog('---- number of pending contacts retrieved:'+pendingContacts.size());
        } else {
            //debugLog('---- number of pending contacts retrieved is ZERO -- ');
        }
        return pendingContacts;
    }
    public Pagereference doViewSearch() {
        return null;
    }

	
    public void getDisplayTaskResult() {
        system.debug('userTasks: ' + (userTasks!=null && !userTasks.isEmpty()));
        displayTaskResults = userTasks!=null && !userTasks.isEmpty();
        system.debug('displayTaskResults: '+displayTaskResults);
    }
    public Boolean getDisplayEventResults() {
    	return myEvents!=null && !myEvents.isEmpty();
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
	public Boolean getDisplayMyServices() {
		return this.myServices != null && !this.myServices.isEmpty();
	}
    public Boolean getDisplayUserServicedClients() {
        return this.userServicedClients !=null && !this.userServicedClients.isEmpty();
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


    public boolean canUserAddNews() {
        Boolean canIt = true;
        try {
            Set<String> goodProfs = new Set<String>{
                    'System Administrator', 'Carpls System Administrator'
            };
            Id uId = UserInfo.getUserId();
            List<User> users = [select id, type__c from user where id = :uId and (profile.name in :goodProfs)];
            User u;
            if (users != null && !users.isEmpty()) {
                u = users[0];
            }
            canIt = u != null;
        } catch (Exception e) {
            system.debug(e);
        }
        return canIt;
    }


    public static List<Task> retrieveUserTasks(Id uId,  Integer limitNum) {
        List<Task> tasks;
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('OwnerId').equals( uId ));
		String status = 'Close';
        whereC.add(new al.FieldCondition('Status').Notequals(status));
		system.debug('uId ' + uId);
        whereC.add(new al.FieldCondition('ActivityDAte').equals( Date.today()));
		String soql = '';
		soql += 'SELECT ' + soqlUtils.getAllFields('Task',false);
		soql +=			  +',what.name,what.id,what.type,who.name,who.id ';
		soql +=	'FROM 		Task ';
		soql += 'WHERE    OwnerId = :uId ';
		soql += 'and      Status  != \'Close\' ';
        soql += 'and      Status  != \'Completed\' ';
		soql += 'and      ActivityDate <= TODAY ';
		soql += 'Order by ActivityDate ASC, LastModifiedDate ASC ';
		soql += 'limit :limitNum ';

        /*
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Task', false ))
                    .selectx(new Set<String> {'what.name','what.id','what.type','who.name','who.id'})
                    .fromx  ('Task')
                    .wherex( whereC )
                    .orderByx(new al.OrderBy('ActivityDate').descending().nullsLast())
                    .limitx(limitNum)
                    .toSoql();
        */

    //  try {
            tasks = Database.query(soql);
        system.debug('tasks ' + tasks);
    //  } catch (Dmlexception e) {
    //      System.debug(logginglevel.error, e);
    //  }
        return tasks;

    }


        

	public class MyService{
		public Consultation__c svc {get;Set;}
		public String caseId  {get; Set; }
		public String caseNumber {get;Set;}
		public String clientName {get;Set;}
		public STring createdBy {get; Set; }
		public String clientId {get; Set; }
		public STring pcDisplay{get;set;}
        public String pcDisplayShort{ get; set;}
        public Decimal svcTime { get;set;}



		public MyService(Consultation__c svc) {
			this.svc = svc;
			this.caseId = svc.case__R.id;
			this.caseNumber = svc.case__r.casenumber;
			this.clientName = svc.case__r.contact.name;
			this.createdBy = formatCreatedBy(svc);
			this.clientId = svc.case__r.contact.id;
			this.pcDisplay = formatProblemCode(svc);
            if(svc.Service_Time__c != null) {
                svcTime = svc.Service_Time__c;
            } else {
                svcTime = 0;
            }
		}
	public String formatProblemCode(Consultation__c svc) {
			String pcDisplay = '';

			pcDisplay += svc.case__r.practice_area__c;
            //this.pcDisplayShort = pcDisplay;
			if(svc.case__r.problem_category__c != null) {
				pcDisplay += ' | ' + svc.case__r.problem_category__c;
			}
            if(pcDisplay != null && pcDisplay.length() > 31) {
                pcDisplay = pcDisplay.substring(0,30);
            } else {
                if(svc.case__r.problem_code__c != null) {
                    pcDisplay += ' | ' + svc.case__r.problem_code__c;
                }
                if(pcDisplay != null && pcDisplay.length() > 31) {
                    pcDisplay = pcDisplay.substring(0,30);
                }
            }
             this.pcDisplayShort = pcDisplay;
			if(svc.case__r.problem_code__c != null) {
				pcDisplay += ' | ' + svc.case__r.problem_code__c;
			}


			return pcDisplay;
	}
	public String formatCreatedBy(Consultation__c svc) {
			String cName = '';
			if(svc.createdby.firstName!=null) {
				//cName = svc.createdby.firstname.subString(0,1)+ svc.createdby.lastName;
			} else {
				//cName = svc.createdby.lastname;
			}
			cName += '  ' + svc.createdDate.format('hh:mm a');

			return cName;
	}

	}

    /*@TODO Move to UserUtils */
    public List<MyService> retrieveMyServices(Id uId) {

	List<MyService> mysvcs = new List<MySErvice>();

	List<Consultation__C> services = [
								select
										id, name,
                                        Service_Time__c,
										case__r.id,
										case__r.casenumber,
										case__r.contact.name,
										case__r.contact.id,
										case__r.Practice_Area__c,
										case__r.Problem_Category__c,
										case__r.Problem_Code__c,
										case__r.Jurisdiction__c,
										createddate,
										createdby.name,
										createdby.firstname,
										createdby.lastname,
										lastmodifieddate,
										lastmodifiedby.name,
										lastmodifiedby.firstname,
										lastmodifiedby.lastname
								from
											consultation__c
								where
										/*lastmodifieddate = TODAY and*/
										createdDate = TODAY
                                        //RJN Prod hack for now.
								and		createdById = :UserInfo.getUserId()
                                        //case__r.Last_Service_By__c = :UserInfo.getUserId()
                                //and last_serviced_by__c = :UserInfo.getUserId()
								order by
                  createddate desc,
										case__r.contact.name desc,
										case__r.casenumber desc


								];

        if(services != null) {
			for (Consultation__c svc : services)
			{
				mySvcs.add(new MyService(svc));
			}
		}
		//debugLog('----- mysvcs = services query list res='+mysvcs);
        return  mysvcs;

    }

    /**
     * rjn had to rewrite as api v 41 seems to have issuew with getting fields via describe calls
     * which have no visibility to anyone!!!!
     *
     * @param status`
     * @param minutesBeforeNow
     *
     * @return
     */
    public List<Case> retrieveCasesLeftOpenLocal(String status, Integer minutesBeforeNow) {
        //rjn 5/2 added filter to make sure the contact is not incomplete.
        List<Case>cases = new List<Case>();
        try {
            cases =
            [   select  id, casenumber, contact.name,  subject, status, lastmodifieddate
                from    case
                where   ownerId = :UserInfo.getUserId()
                and     status  = :status
                and     ( ( left_open__c = true and  start_it__c = true )
                        or     (ownerId = :UserInfo.getUserId() and status = :status) )
                and     ( contact.status__c != 'Incomplete' )
               and recordtype.developername = 'Carpls_Cases'

            ];
        } catch (exception e) {
            system.debug(e);
        }

        if(cases.isEmpty()) {
            cases = [
                    select id, casenumber, contact.name, subject, status, lastmodifieddate
                    from case
                    where ownerId = :UserInfo.getUserId()
                    and status = :status
                     and     ( lastmodifieddate >= LAST_N_DAYS:1
                    or createddate = TODAY )
                    and     ( contact.status__c != 'Incomplete' )
                    and recordtype.developername = 'Carpls_Cases'

            ];
        }

        return cases;
        //SELECT ID FROM Case WHERE OwnerId = :userInfo.getUserId() AND status = 'Open' AND lastModifiedDate <= :datetime.now().addMinutes(-5) AND Left_Open__c = true ORDER BY LastModifiedDate DESC];
    }

    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}



    //added by Sergii at 09/22/2020

    public Pagereference retriveEventsByOwnerId(){
        String queryOne = '';
        String queryTwo = '';
        if(chosenUserId == 'All'){
           queryOne ='';
        }
        else{
            queryTwo ='AND (New_Leaf_Schedule__c =: chosenUserId OR Owner.Name =:chosenUserId ) ';
        }
        String queryText = 'SELECT Id, Subject, owner.name, Description, StartDateTime, EndDateTime, Status__c ' 
                            + 'FROM Event WHERE StartDateTime = TODAY  AND New_Leaf_Appointment__c = TRUE '
                            +  queryOne+
                            +  queryTwo+
                            + ' ORDER BY StartDateTime ASC';
        this.chosenEvents = Database.query(queryText);
                                
        if(chosenEvents.size() > 0 ){
            this.showChosenEvents = true;
        } else{
            this.showChosenEvents = false;
        }
        System.debug('size is '+  chosenEvents.size());

        return null;
    }
    
    
    //added by Sergii at 10/05/2020
    public List<leadItemsToApproveWrapper> retriveItemsToBeApproved(){
        if(currentUser == null ){return new List<leadItemsToApproveWrapper>();}

        Set<Id> setTargets = new Set<Id>();
        Set<Id> setUserAndQueueIds = new Set<Id>();
        setUserAndQueueIds.add(currentUser.Id);
        for(GroupMember groupMember: [SELECT Id, Group.Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :currentUser.Id AND Group.Type = 'Queue']){
            setUserAndQueueIds.add(groupMember.Group.Id);
        }
        
        Map<String, leadItemsToApproveWrapper> mapLeadWrapperMap = new Map<String, leadItemsToApproveWrapper>();
        for (ProcessInstanceWorkItem workItem : [ SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem 
                                                  WHERE ProcessInstance.Status = 'Pending' 
                                                  AND ActorId IN :setUserAndQueueIds  ]) {          
                setTargets.add(workItem.ProcessInstance.TargetObjectId);
                mapLeadWrapperMap.put( workitem.ProcessInstance.TargetObjectId, new leadItemsToApproveWrapper(new Lead(), workItem.Id) );
        }

        system.debug('Approve ' + setTargets);
        System.debug('leadWrapperMap '+  mapLeadWrapperMap);
      
        for (Lead variable : [   SELECT Id, Name 
                                 FROM Lead 
                                 WHERE Id IN :setTargets ORDER BY Birthdate__c]) {
            if(mapLeadWrapperMap.containsKey(variable.Id)){
                mapLeadWrapperMap.get(variable.Id).leadName = variable.Name;
                mapLeadWrapperMap.get(variable.Id).leadId = variable.Id;
            }
        }
       

        System.debug('leadWrapperMap '+  mapLeadWrapperMap);
        System.debug('Approve size is '+   mapLeadWrapperMap.values().size());

        return  mapLeadWrapperMap.values();
    }

    // added by Keith Snider 12/24/2020
    public List<Group> getUserAssignedTaskQueues() {
        List<Group> currentUserTaskQueues = new List<Group>();
        List<QueueSobject> queueObjects = [SELECT QueueId, SobjectType FROM QueueSobject];
        //List<QueueSobject> taskQueues = [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Task';

        Set<Id> queueIds = new Set<Id>();
        if (!queueObjects.isEmpty()) {
            for (QueueSobject qo : queueObjects) {
                //system.debug('queue object type: '+qo.SobjectType);
                if (qo.SobjectType == 'Task') {
                    queueIds.add(qo.QueueId);
                } 
            }
        }
        List<Group> queues = [SELECT Id, Name, (SELECT Id, UserOrGroupId FROM GroupMembers WHERE UserOrGroupId = :UserInfo.getUserId()) FROM Group WHERE Id IN :queueIds];
        // iterate over queues and get all queues user is assigned
        System.debug('Danylo ' + queues);
        for (Group g : queues) {
            if (g.GroupMembers != null && !g.GroupMembers.isEmpty()) {
                currentUserTaskQueues.add(g);
            }
        }
        return currentUserTaskQueues;
    }

    // added by Keith Snider 12/24/2020
    public PageReference retrieveTasksFromChosenQueue() {
        System.debug('chosen task queue: '+chosenTaskQueue);
        
        if (chosenTaskQueue == 'My Tasks') {
            this.userTasks = retrieveUserTasks(UserInfo.getUserId(), 150);
        } else {
            system.debug('here');
            this.userTasks = retrieveUserTasks(chosenTaskQueue, 150);
            
        }
    	getDisplayTaskResult();
        return null;
    }

    public class leadItemsToApproveWrapper {
        public String leadId {get; set;}
        public String leadName {get; set;}
        public String instanceWorkItemId {get; set;}

        public leadItemsToApproveWrapper() {}

        public leadItemsToApproveWrapper(Lead l, String iwID ) {
            leadId =  l.Id;
            leadName = l.Name;
            instanceWorkItemId = iwID;
        }
    }

}