public with sharing class ctrlAlerts extends ctrlCarplesGeneric {

	public 			List<Alert__c> 		alerts					{ get; set; }
	public          Alert__c            singleAlert             { get; Set; }
	public          Id                  selectedAlertId         { get; set; }
	public          Contact 			contact					{ get; Set; }
	public          Case	 			cse						{ get; Set; }
	public			Alert__c			newAlert				{ get; set;	}

	public    		String				sPrimaryEntityId		{ get; set; }
	public          String              sPrimaryEntityName      { get; Set; }
	public    		String				sSubEntityId			{ get; set; }
	public          String              sSubEntityName          { get; Set; }
	public 			String				sSubTabPageInfo			{ get; set; }
	public 			String				sPrimaryTabPageInfo		{ get; set; }
	public			String				entityName				{ get; set; }

	public          Boolean             bPopAlerts				{ get; Set; }
	public          Boolean             showAlertsTable         { get; Set; }
	public          Boolean             showSingleAlert         { get; Set; }
	public          Boolean             showBackToListBtn       { get; Set; }
	public			Boolean				showNewAlert			{ get; set; }

	public          String              sSectionTitle           { get; Set; }
	public			String				sNewAlertMsg			{ get; set; }

	public          Boolean             getShowNoDataFound() {
		boolean showIt = false;
		showIt =  !this.showSingleAlert && !this.showAlertsTable;
		if(showIt && !showNewAlert) {
			clearAlertsView();
		}
		return showIt;
	}

	public ctrlAlerts getTheController() {
		return this;
	}

	public ctrlAlerts() {
		debugLog('in constructor()');
		bPopAlerts 			= false;
		showAlertsTable 	= false;
		showSingleAlert 	= false;
		showBackToListBtn 	= false;
		showNewAlert 		= false;
		sNewAlertMsg 	= '';
		entityName 			= '';

	}
	public PageReference doInit() {
		//debugLog('in doInit()');
		bPopAlerts = false;
		return null;
	}
	public PageReference doSelectAlert() {
		//debugLog('in doSelectSingleAlert.. <font color=blue>Selected Alert Id='+selectedAlertId+'</font>');
		if(selectedAlertId != null) {
			al.NestableCondition whereC = new al.AndCondition();
			whereC.add(new al.FieldCondition('id').equals(selectedAlertId));
			List<Alert__c> tmpAlerts = Utilities.retrieveAlerts(whereC);
			if(tmpAlerts!=null && !tmpAlerts.isEmpty()) {
				this.singleAlert = tmpAlerts[0];
				//debugLog('in doSelectSingleAlert.. <font color=blue>Single Alert found for clicked link='+singleAlert+'</font>');
				this.showSingleAlert = true;
				this.showAlertsTable = false;
				this.sSectionTitle = singleAlert.Name +' Detail';
				this.showBackToListBtn = true;
				//debugLog('in doSelectSingleAlert.. sSectionTitle='+sSectionTitle);
				tmpAlerts.clear();
				tmpAlerts = null;
			}
		}
		return null;
	}
	public PageReference doBackToList() {
		//debugLog('in doOnBackToList ');
		this.showBackToListBtn = false;
		this.selectedAlertId = null;
		this.singleAlert = null;
		return doOnFocusedSubTabEvent();
	}
	public Pagereference doOnFocusedSubTabEvent() {
		//debugLog('in doOnFocusedSubTabEvent..   (Sub Entity Id) ='+sSubEntityId);
		//debugLog('in doOnFocusedSubTabEvent..   (sSubTabPageInfo) ='+sSubTabPageInfo);
		if(sSubEntityId != null) {
			this.sSubEntityName =  Utilities.findObjectNameById(sSubEntityId);
			//debugLog('in doOnFocusedSubTabEvent..   (Sub Entity Name) ='+sSubEntityName);
			if('Contact'.equalsIgnoreCase(sSubEntityName) || 'Case'.equalsIgnoreCase(sSubEntityName)) {
				this.refreshAlerts(sSubEntityId,sSubEntityName);
			} else {
				this.clearAlertsView();
			}
		}

		return null;
	}
	public Pagereference doOnFocusedPrimaryTabEvent() {
		//debugLog('in doOnFocusedPrimaryTabEvent..   (Primary Entity Id) ='+sPrimaryEntityId);
		//debugLog('in doOnFocusedPrimaryTabEvent..   (sPrimaryTabPageInfo) ='+sPrimaryTabPageInfo);
		if(sPrimaryEntityId != null) {
			this.sPrimaryEntityName =  Utilities.findObjectNameById(sPrimaryEntityId);
			//debugLog('in doOnFocusedSubTabEvent..   (Primary Entity Name) ='+sPrimaryEntityName);
			if('Contact'.equalsIgnoreCase(sPrimaryEntityName) || 'Case'.equalsIgnoreCase(sPrimaryEntityName)) {
				//		sNewAlertMsg = '';
				this.refreshAlerts(sPrimaryEntityId,sPrimaryEntityName);
			} else {
				this.clearAlertsView();
			}
		}
		return null;
	}

	private void refreshAlerts(Id sEntityId, String sEntityName) {
		if(sEntityName == 'Contact') {
			entityName = sEntityName;
			this.refreshContactAlertS(sEntityId);
		}
		if(sEntityName == 'Case') {
			entityName = sEntityName;
			this.refreshCaseAlerts(sEntityId);
		}
	}

	private void refreshContactAlerts(Id contactId) {

		//debugLog('<font color=purple> (Contact Refresh) Attempting to refresh alerts with using contactId:'+contactId);
		this.alerts = Utilities.retrieveAllAlertsForContact(contactId, 'Open');
		// moved this out of if stmt so it's available to create new alert
		Set<String> excludeFields = new Set<String> {'OtherAddress'};
		contact = this.retrieveAllContactInfo(contactId); // rjn do not call contactUtils.. see method at bottom this has version issues.
		//contact = ContactUtils.retrieveAllContactInfo(contactId);


		if(alerts!=null && !alerts.isEmpty()) {
			debugLog('<font color=blue>Retrieved :'+alerts.size()+' for contactId:'+contactId);
			bPopAlerts = true;
			if(alerts.size() == 1) {
				singleAlert = alerts[0];
				this.showSingleAlert = true;
				this.showAlertsTable = false;
				this.sSectionTitle = '1 Alert found for '+ Utilities.findObjectLabelById(contactId) + ' '+contact.name;
			} else {
				this.showSingleAlert = false;
				this.showAlertsTable = true;
				//rjn was throwing NPE in test class
				try {
					this.sSectionTitle = alerts.size() + ' Alerts found for ' + Utilities.findObjectLabelById(contactId) + ' ' + contact.name ;
				} catch (Exception e) {
					system.debug(e);
					this.sSectionTitle = ' Alerts found ';
				}
			}
		} else {
			//debugLog('No Open Alerts found for contact id:'+contactId);
			clearAlertsView();
		}
	}
	private void refreshCaseAlerts(Id caseId) {

		//debugLog('<font color=purple> (Case Refresh) Attempting to refresh alerts with using caseId:'+caseId);
		this.alerts = Utilities.retrieveAllAlertsForCase(caseId, 'Open');
		// moved this out of if stmt so that it's available to new alert
		CaseUtils caseUtils = new CaseUtils();
		this.cse = caseUtils.retrieveCaseSummaryData(caseId);

		if(alerts!=null && !alerts.isEmpty()) {
			//debugLog('<font color=blue>Retrieved :'+alerts.size()+' for caseId:'+caseId);
			bPopAlerts = true;
//			CaseUtils caseUtils = new CaseUtils();
//			this.cse = caseUtils.retrieveCaseSummaryData(caseId);
			if(alerts.size() == 1) {
				singleAlert = alerts[0];
				this.showSingleAlert = true;
				this.showAlertsTable = false;
				this.sSectionTitle = '1 Alert found for Case: '+cse.casenumber;
			} else {
				this.showSingleAlert = false;
				this.showAlertsTable = true;
				this.sSectionTitle = alerts.size() +' Alerts found for Case: '+cse.casenumber;
			}
		} else {
			//debugLog('No Open Alerts found for case id:'+caseId);
			clearAlertsView();
		}
	}
	private void clearAlertsView() {
		debugLog('clearing alerts view');

		this.bPopAlerts = false;
		this.showSingleAlert = false;
		this.showAlertsTable = false;
		this.showNewAlert = false;
		this.sSectionTitle = 'No alerts found';
		if(this.sSubEntityId != null) {
			this.sSectionTitle += ' for '+Utilities.findObjectLabelById(sSubEntityId);
		} else  {
			if(this.sPrimaryEntityId != null) {
				this.sSectionTitle += ' for '+Utilities.findObjectLabelById(sPrimaryEntityId);
			}
		}
		this.sSectionTitle += '!';
		//this.

		this.singleAlert = null;
		this.alerts = null;

	}
	public PageReference doCreateNewAlert() {
		debugLog('in doCreateNewAlert()');
		if (cse == null && contact == null) {
			sNewAlertMsg = 'You must be in a Case or Contact to create an alert!';
		} else {
			newAlert = new Alert__c();
			bPopAlerts 			= false;
			showAlertsTable 	= false;
			showSingleAlert 	= false;
			showBackToListBtn 	= false;
			showNewAlert 		= true;
		}
		return null;
	}

	public PageReference doTestNewAlert() {
		system.Assert(false, 'In doTestNewAlert');
		return null;
	}
	public PageReference doSaveNewAlert() {
		debugLog('In doSaveNewAlert - newAlert = '+newAlert);
		debugLog('In doSaveNewAlert - entity = '+entityName);
		showNewAlert = false;
		if (entityName == 'Case') {
			newAlert.case__c = this.cse.id;
		} else if (entityName == 'Contact') {
			newAlert.contact__c = this.contact.id;
		} else {
			debugLog('in doSaveNewAlert - missing valid case or contact');
			return null;
		}
		try {
			insert newAlert;
		} catch (Exception e) {
			debugLog('Error in doSaveNewAlert - '+e.getMessage());
		}
		//      alerts.add(newAlert);
		//      if (alerts.size() > 1) {
		//      	showAlertsTable = true;
		//      } else {
		//      	showSingleAlert = true;
		//		}
		if (entityName == 'Case') {
			refreshAlerts( this.cse.id, 'Case');
		} else if (entityName == 'Contact') {
			refreshAlerts(this.contact.id, 'Contact');
		} else {
			debugLog('in doSaveNewAlert - missing valid case or contact');
			return null;
		}

		return null;

	}
/**
    * rjn added this to stop bs versioning errors such as otheraddress as well as i need the military field but did not want
    *  we really don't need all that other stuff in here anyway......
    */
	public  Contact retrieveAllContactInfo(Id contactId) {
		Contact c;
		try {

			c = [select id, name, firstname, lastname, email from contact where id = :contactId];
		} catch (Dmlexception dEx) {
			System.debug(logginglevel.error, dEx);
		} catch (Exception e) {
			System.debug(logginglevel.error, e);
		}
		return c;
	}
}