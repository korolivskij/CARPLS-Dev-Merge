public with sharing class ctrlCarplsConnectHome {

	public static FINAL String		REFERRED_STATUS = 'Applied';
	public List<Case>               pendingCases                { get; set; }
	public List<Case>				actedUponCases				{ get; set; }
	public Account					referralAcct				{ get; set; }
	public Boolean					hasReferral					{ get; set; }
	public Boolean					displayPendingCasesResults	{ get; set; }
	public Boolean					displayActedUponCasesResults { get; set; }
	public caseUtils                caseUtils                   { get; set; } 
	// for the picklist - will be translated into values for status and distribution
	public String					plStatus					{ get; set; } 
	public String					arStatus					{ get; set; } 
	//public String					arDistribution				{ get; set; }
	public String					arClosingCode				{ get; set; }
    
    
    public ctrlCarplsConnectHome() {
    	
    	displayPendingCasesResults = false;
    	displayActedUponCasesResults = false;
    	plStatus = 'Referral Accepted';
    	caseUtils = new CaseUtils();
    	hasReferral = this.retrieveAccount();
    	if (!hasReferral) {
    		//debugLog('Invalid User for referral page');
    		return;
    	}
    	//this.pendingCases = this.refreshPendingCases();
    	
    }
     public String getCurrentDateTime() {
            User currentUser = [Select TimeZoneSidKey from User where id =: USerInfo.getUserId()];
            return DateTime.now().format('EEEE MMMM d, yyyy  HH:mm:ss a',currentUser.TimeZoneSidKey);
        
    }
    /*
    	 Need to figure out from the user name what account they are connected with.  So we will get
    	 the Contact record with this name, then get the account associated with that contact.
    	 NOTE: Contacts are created for each user via trigger, but an admin will need to connect the
    	 contact with the correct account.
    */
    public Boolean retrieveAccount() {
    	String name = UserInfo.getName();
    	this.referralAcct = null;
    	
    	List<Contact> cs = ContactUtils.retrieveContactInfoByName(name);
    	System.debug('in retrieveAccount - cs = '+cs);
    	if (cs == null || cs.size() > 1) {
    		return false;
    	}
    	for (Contact c: cs) {
    		Account a = AccountUtils.retrieveAccountWoLongText(c.AccountId);
    		if (a != null && a.CARPLS_Connect__c == TRUE) {
    			this.referralAcct = a;
    			return true;
    		}
    	}
        if (this.referralAcct == null) {
            return false;
        }
    	System.debug('In RetrieveAccount with account = '+referralAcct);
    	return true;
    }
    public Pagereference doInitPage() {
    	//debugLog('<font color=green> In ctrlCarplsConnectHome.doInitPage </font>');
        this.pendingCases = this.refreshPendingCases();
        this.actedUponCases = this.refreshActedUponCases();
        
        return null;    
    }
    public List<Case> refreshPendingCases() {
    	System.debug('in refreshPendingCases, referralAcct = '+referralAcct);
    	List<Case> cs = caseUtils.retrieveCasesByReferral(this.referralAcct, REFERRED_STATUS,'None');
    	System.debug('In refreshPendingCases');
    	if ((cs != null) && (cs.size() > 0)) {
        	displayPendingCasesResults = true;
        } else {
        	displayPendingCasesResults = false;
        }
    	return cs;
    }
    public Pagereference doRefreshPendingCases() {
        this.pendingCases = this.refreshPendingCases();
        return null;
    }
    public List<Case> refreshActedUponCases() {
    	if (plStatus == 'Closed') {
    		arStatus = plStatus; 
    		//arDistribution = 'Referral Accepted';
    		arClosingCode = 'None';
    	} else if (plStatus == 'Referral Accepted') {
    		// ELC 2/17: changed from Applied to Accepted for IL-AFLAN changes
    		arStatus = 'Accepted';
    		arClosingCode = 'None';
    		//arDistribution = plStatus;
    	} else if (plStatus == 'Referral Rejected') {
    		arStatus = 'Closed';
    		arClosingCode = 'Denied Service';
    		//arDistribution = plStatus;
    	}
    	System.debug('in refreshActedUponCases, referralAcct = '+referralAcct+' arStatus = '+arStatus+' arClosingCode = '+arClosingCode);
    	List<Case> cs = caseUtils.retrieveCasesByReferral(this.referralAcct, this.arStatus, this.arClosingCode);
    	//System.debug('In refreshActedUponCases, with cse = '+cs);
    	if ((cs != null) && (cs.size() > 0)) {
        	displayActedUponCasesResults = true;
        } else {
        	displayActedUponCasesResults = false;
        }
    	return cs;
    }
    public Pagereference doRefreshActedUponCases() {
        this.actedUponCases = this.refreshActedUponCases();
        return null;
    }
    public List<Selectoption> getApplResStatusOptions() {

        List<SelectOption> options = new List<SelectOption>();
        Selectoption so = new Selectoption('Referral Accepted','Referral Accepted');
        options.add(so);
        so = new Selectoption('Referral Rejected','Referral Rejected');
        options.add(so);
        so = new Selectoption('Closed','Closed');
        options.add(so);
        
        return options;
    }
    public pageReference doStatusSelect() {
    	System.debug(' doStatusSelect--- arStatus:'+arStatus);
        this.actedUponCases = this.refreshActedUponCases();
        return null;        
    }
}