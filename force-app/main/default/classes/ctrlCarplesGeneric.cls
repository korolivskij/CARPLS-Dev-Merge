public virtual class ctrlCarplesGeneric {

    public Boolean                      showDebugMessages           { get; set; }
    public Boolean                      showChatter                 { get; set; }
    
    public String                       debugMsgBtnText             { get; set; }
    public String                       selectedId                  { get; set; }
     
    public List<DebugMessage>           debugMessages               { get; set; }
    public Integer                      contactSearchResultsLimit   { get; set; }
    public Integer						contactSearchDisplayLimit	{ get; set; }
    public List<SelectOption>           ssCategories                { get; set; }
     
    public Map<String,String>           qsParms                     { get; set; }
    
    public SearchWrapper                sw                          { get; set; }
    public Map<String,String>           keyPrefixMap                { get; set; }       
    
    private ctrlComponentBase           myComponentController;
    public  Search_Log__c               slClient                    { get; set; }
    public  Search_Log__c               slParty                     { get; set; }
    public  Boolean                     fromSearch                  { get; set; }
    public  Boolean                     reviewCurrent               { get; set; }
    public  Boolean                     showLeftNav                 { get; set; }
    public  String                      sessionId                   { get; set; }   
    public  static Boolean              staticShowChatterPanel      { get; set; }
    public  static Boolean				staticIsSoslClientSearch	{ get; set; }
    public  static Boolean				staticIsSoslPartySearch		{ get; set; }
    public  static Boolean				staticIsNewCaseFlow			{ get; set; }
    public  static Boolean				staticIsNewClientPage		{ get; set; }    
    public  static Boolean				staticShowPageNavigator		{ get; set; }
    public  static String               staticResourceHeaderColor   { get; Set; }
    public  static String               staticAppAccentColor   { get; Set; }
    public  static Integer				staticNumDaysPendingClients { get; set; }
    public  static List<String>         staticPartyOrphanSearchCategories { get; Set; }
    public  static List<String>         staticPartyOtherSearchCategories { get; Set; }
    public  static List<String>         staticClientOrphanSearchCategories{ get; Set; }   
    public  static List<String>         staticClientOtherSearchCategories{ get; Set; }   
    public  static List<String>         staticExistingClientSearchCategories{ get; Set; }
    
    public  static Map<Id,Profile>      static_mprofileId_profile   { get; set; }
     
    public  Boolean getIsSoslClientSearch() {
    	return ctrlCarplesGeneric.staticIsSoslClientSearch;
    }
    public  Boolean getIsSoslPartySearch() {
    	return ctrlCarplesGeneric.staticIsSoslPartySearch;
    } 
    public  Boolean getIsNewCaseFlow() {
    	return ctrlCarplesGeneric.staticIsNewCaseFlow;
    }   
    public  Boolean getIsNewClientPage() {
    	return ctrlCarplesGeneric.staticIsNewClientPage;
    }     
    public  Boolean getShowChatterPanel() {
        return ctrlCarplesGeneric.staticShowChatterPanel;   
    }
    public  Boolean getShowPageNavigator() {
        return ctrlCarplesGeneric.staticShowPageNavigator;   
    }
    public  String getResourceHeaderColor() {
        return ctrlCarplesGeneric.staticResourceHeaderColor;    
    }   
    public  String getAppAccentColor() {
        return ctrlCarplesGeneric.staticAppAccentColor;    
    }       
    public  Boolean getCustomSettingsGood() {
        return ctrlCarplesGeneric.staticCustomSettingsGood; 
    }
    public  List<String> getPartyOrphanSearchCategories() {
        return ctrlCarplesGeneric.staticPartyOrphanSearchCategories;  
    }
    public  List<String> getPartyOtherSearchCategories() {
        return ctrlCarplesGeneric.staticPartyOtherSearchCategories;  
    }
    public  List<String> getClientOrphanSearchCategories() {
        return ctrlCarplesGeneric.staticClientOrphanSearchCategories; 
    }
    public  List<String> getClientOtherSearchCategories() {
        return ctrlCarplesGeneric.staticClientOtherSearchCategories; 
    }
    public  List<String> getExistingClientSearchCategories() {
        return ctrlCarplesGeneric.staticExistingClientSearchCategories; 
    }
    public Integer getNumDaysPendingClients() {
    	return ctrlCarplesGeneric.staticNumDaysPendingClients;
    }
    
    public  Map<String,SectionStateBean>    mSectionState
                            { get; set; }
    /*                      
    public transient Boolean                displayCustomPageMessage            { get; set; }           
    public transient String                 customPageMessageSeverityStyleClass { get; set; }   
    public transient        String          customPageMessage;
    public virtual String   getCustomPageMessage()              { return this.customPageMessage; }  
    public virtual void     setCustomPageMessage(String msg )   { this.customPageMessage = msg; } 
    */
    public Boolean displayCustomPageMessage {get; set; }
    public static Boolean staticCustomSettingsGood {get; set; }
    public String  customPageMessageSeverityStyleClass {get;set;}
    public String  customPageMessage {get; set; }
    
    static  {   
    	   
        try {
            staticCustomSettingsGood = true;
            
            String fieldName = 'showChatterPanel__c';
            Object oChatter = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);        
            if(oChatter != null) {
                Boolean b = (Boolean)oChatter;
                staticShowChatterPanel = b;
            } else {
                String msg = 'There was a problem locating Carplsv20Settings__c (specifically:'+fieldName+')';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,msg));
                staticCustomSettingsGood = false;
                
            } 
            fieldName = 'IsSoslClientSearch__c';
            Object oClientSearch =  CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName); 
            if(oClientSearch != null) {
            	Boolean b = (Boolean)oClientSearch;
            	staticIsSoslClientSearch = b;
            }  
            fieldName = 'IsSoslPartySearch__c';
            Object oPartySearch =  CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName); 
            if(oPartySearch != null) {
            	Boolean b = (Boolean)oPartySearch;
            	staticIsSoslPartySearch = b;
            }  
            fieldName = 'IsNewCaseFlow__c'; 
            Object oIsNewCaseFlow = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);                
            if(oIsNewCaseFlow != null) {
            	Boolean b = (Boolean)oIsNewCaseFlow;
            	staticIsNewCaseFlow = b;
            } else {
            	staticIsNewCaseFlow = false;
            }
            fieldName = 'IsNewClientPage__c'; 
            Object oIsNewClientPage = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);                
            if(oIsNewClientPage != null) {
            	Boolean b = (Boolean)oIsNewClientPage;
            	staticIsNewClientPage = b;
            } else {
            	staticIsNewClientPage = false;
            }            
            fieldName = 'ResourceHeaderColor__c';
            Object oColor = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);      
            if(oColor != null) {
                String s = (String)oColor;
                staticResourceHeaderColor = s;
            }
            fieldName = 'AppAccentColor__c';
            Object oColor2 = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);      
            if(oColor2 != null) {
                String s = (String)oColor2;
                staticAppAccentColor = s;
            }
            fieldName = 'partyOrphanSearchCategories__c';
            Object oPartyOrphanCats = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);      
            if(oPartyOrphanCats != null) {
                String s = (String)oPartyOrphanCats;
                List<String> lPartyOrphanCats = Utilities.detokenizeString(s, ';');
                staticPartyOrphanSearchCategories = lPartyOrphanCats;
            }  
            fieldName = 'partyOtherSearchCategories__c';
            Object oPartyOtherCats = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);      
            if(oPartyOtherCats != null) {
                String s = (String)oPartyOtherCats;
                List<String> lPartyOtherCats = Utilities.detokenizeString(s, ';');
                staticPartyOtherSearchCategories = lPartyOtherCats;
            }                    
            fieldName = 'clientOrphanSearchCategories__c';
            Object oClientOrphanCats = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);     
            if(oClientOrphanCats != null) {
                String s = (String)oClientOrphanCats;
                List<String> lClientOrphanCats = Utilities.detokenizeString(s, ';');
                staticClientOrphanSearchCategories = lClientOrphanCats;
            }    
            fieldName = 'clientOtherSearchCategories__c';
            Object oClientOtherCats = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);     
            if(oClientOtherCats != null) {
                String s = (String)oClientOtherCats;
                List<String> lClientOtherCats = Utilities.detokenizeString(s, ';');
                staticClientOtherSearchCategories = lClientOtherCats;
            }                  
            fieldName = 'existingClientSearchCategories__c';
            Object oExistingClientCats = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);     
            if(oExistingClientCats != null) {
                String s = (String)oExistingClientCats;
                List<String> lExistingClientCats = Utilities.detokenizeString(s, ';');
                staticExistingClientSearchCategories = lExistingClientCats;
            }
            fieldName = 'NumDaysPendingClients__c';
            Object oNumDaysPendingClients = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);     
            if(oNumDaysPendingClients != null) {
            	Decimal d = (Decimal)oNumDaysPendingClients;
                Integer i = Integer.valueOf(d);
                staticNumDaysPendingClients = i;             
            } else {
            	staticNumDaysPendingClients = 30;
            }
            
           fieldName = 'ShowPageNavigator__c';
           staticShowPageNavigator = false;
           try {
  				Object oShowIt = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);                
           		if(oShowIt != null) {
            		staticShowPageNavigator = (Boolean)oShowIt;
           		}
           } catch (Exception e) {
           		System.debug(logginglevel.error, 'error attempting to obtain custom setting'+e);
           }
           
           
            List<Profile> allOrgProfiles = UserUtils.retrieveAllOrgProfiles();
            static_mprofileId_profile = new Map<Id,Profile>();
            for(Profile p : allOrgProfiles) {
                static_mprofileId_profile.put(p.id,p);
            }
            
                    
        } catch (Exception e) {
            String msg = 'There was a problem locating Carplsv20Settings__c';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,msg + ': '+ e.getStackTraceString()));
            System.debug(LoggingLevel.error,e);
            staticCustomSettingsGood = false;
        }           
    }
                        

    public ctrlCarplesGeneric() {
        
        
        this.showChatter = false;
        this.showDebugMessages = false;
       
        this.fromSearch = false;
        this.reviewCurrent = false;
        this.displayCustomPageMessage = false;
        this.customPageMessage = ' ';
        this.showLeftNav = false;
        initCustomSettings();
        mSectionState = new Map<String,SectionStateBean>();
        debugMessages = new List<DebugMessage>(); 
        debugLog('<b>Constructor CtrlCarplesGeneric..</b>.');
        
        if(showDebugMessages) {
            //debugLog('Current Url='+ApexPages.currentPage().getUrl());
            debugLog('Request Parms='+ApexPages.currentPage().getParameters());
            debugLog('<font color=purple>URL='+ApexPages.currentPage() +'</font>');
        } 
        String s =  ApexPages.currentPage().getParameters().get('fromSearch');
        if(s != null && s.length() > 0) {
            debugLog('in generic constructor.. YES from search');
            this.fromSearch = Boolean.valueOf(s);
            String s1 = ApexPages.currentPage().getParameters().get('view');
            if(s1 != null && s1.length() > 0) {
                this.reviewCurrent = Boolean.valueOf(s1);
            }
            if(fromSearch) {
                this.slClient = SearchWrapper.getLatestSearchLog(UserInfo.getUserId());
                //The below gets the latest search log and all search log children.
                if(slClient != null) {
                    this.slClient = SearchWrapper.retrieveSearchLog(slClient.Id);
                }
                debugLog('Latest search log='+slClient);
            }
            
        } else {
            debugLog('in generic constructor.. NOT from search');
        }   
        initKeySetMap();        
    }
    public virtual Boolean updateSearchLogMatchStatus(  String status,Id slId, 
                                                        Id contactReviewedId,String slType) {
        if(status == null) {
            debugLog('invalid null status passed to slupdate');
            return false;
        }
        if(this.slClient == null) {
            debugLog('generic constructor search log client object was not set..');
            return false;
        }
        debugLog('slType to be updated ='+ slType);
        if('Client'.equalsIgnoreCase(slType)) {
        try {
            this.slClient.Marked_as_Match__c = status;
            Search_Log__c sl = [    select  id, marked_as_match__c,Result_Contact_Ids_No_Match__c
                                    from    search_log__c 
                                    where id = :slId];
            sl.Marked_as_Match__c = status;
            if('No'.equalsIgnoreCase(status)) {
                String resultContactIdsNoMatch = sl.result_contact_ids_no_match__c;
                if(resultContactIdsNoMatch == null || resultContactIdsNoMatch == '') {
                    sl.Result_Contact_Ids_No_Match__c = contactReviewedId;
                } else {
                    String sDelim = ',';
                    
                    sl.Result_Contact_Ids_No_Match__c = Utilities.tokenizeString(sl.result_contact_ids_no_match__c, contactReviewedId, sDelim);
                }
                sl.client_result_state__c = 'Matches';
            } else {
            	// ELC 2/6/2015 - adding support for contactCreated
            	// I'm not sure what this was doing but I think it is what is screwing everything up
                //if(sl.Contact_Reviewed__c == null && sl.contact_created__c == null) {
                //    sl.Contact_Reviewed__c = contactReviewedId; 
                //}
                sl.client_result_state__c = 'All';
            }
            update sl;
            debugLog('sl match status updated to:'+status);
        } catch (Exception e) {
            system.debug(logginglevel.error, e) ;
            debugLog(e.getMessage());
        }
        }
        return true;
    }   
    public virtual Boolean updatePartySearchLogMatchStatus( String status,Search_Log_Children__c slc) {
        if(status == null) {
            debugLog('invalid null status passed to party slupdate');
            return false;
        }
        if(slc == null) {
            debugLog('search log child is null');
            return false;
        }
        Search_Log__c slParent = SearchWrapper.retrieveSearchLog(slc.Client_Search_Log__c);
        try {
            slc.Marked_as_Match__c = status;

            String resultContactIdsNoMatch = slParent.Result_Party_Ids_No_Match__c;
            if(resultContactIdsNoMatch == null || resultContactIdsNoMatch == '') {
                slParent.Result_Party_Ids_No_Match__c = slc.Party_Reviewed__c;
            } else {
                String sDelim = ',';
                
                slParent.Result_Party_Ids_No_Match__c = Utilities.tokenizeString(slParent.result_party_ids_no_match__c, slc.Party_Reviewed__c, sDelim);
            }
            update slParent;
            update slc;
            debugLog('sl party match status updated to:'+status);
        } catch (DmlException e) {
            system.debug(logginglevel.error, e) ;
            debugLog(e.getMessage());
        }
        
        return true;
    }       
    public virtual ctrlComponentBase getMyComponentController() {
        return myComponentController;
    }
    public virtual void setComponentController(ctrlComponentBase compController) {
        myComponentController = compController;
    }
    public ctrlCarplesGeneric getThis() {
        return this;
    }
    
    public virtual String generateSessionId() {
        String sessionID = utilities.generateRandomString(64);      
        return sessionId;
    }
    
    
    private void initKeySetMap() {
        if(keyPrefixMap != null) {
            return;
        }
        debugLog('loading keysetmap</br>');
                
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        this.keyPrefixMap = new Map<String,String>{};
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();           
            keyPrefixMap.put(tempPrefix,tempName);
            //debugLog('prefix='+tempPrefix + ' name='+tempName);
        }
        
    }
    public String findObjectNameForId( String pId ) {
        if(pId == null) {
            debugLog('findObjectForId passed pId=null returning null');
            return null;
        }
        String first3 = pId.subString(0,3);
        String name = keyPrefixMap.get(first3);
        debugLog('id passed='+pId+ ' name='+name);
        return name;
    }
    public Schema.Describesobjectresult findSObjectResForApiName(String apiName) {
        Map <String, Schema.SObjectType > m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get(apiName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        return r;
    }
    
    private void initCustomSettings() {
        String fieldName = 'showDebugMessages__c';
        this.contactSearchResultsLimit = 200;
        this.contactSearchDisplayLimit = 50;
        

        try {       
            Object o = CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(),fieldName);
            this.showDebugMessages = Boolean.valueOf(o);
            
            Object oLimit = CustomSettingsUtls.getCarplsv20Settings(UserInfo.getProfileId(),'Contact_Search_Limit__c');
    // TODO-ELC get rid of comment - using for debug        
           this.contactSearchResultsLimit = Integer.valueOf(oLimit);
           oLimit = CustomSettingsUtls.getCarplsv20Settings(UserInfo.getProfileId(),'Contact_Search_Display_Limit__c');
    		this.contactSearchDisplayLimit = Integer.valueOf(oLimit);

            
        } catch (Exception e) {
            System.debug(logginglevel.warn, e);
        }
        
        //if(UserInfo.getLastName().contains('Nendza') || UserInfo.getLastName().contains('Cox')) {
        //  this.showDebugMessages = true;
        //}     
            debugLog('Parent Class showDebugMessages='+this.showDebugMessages);
            debugLog('Parent Class Contact Search Limit='+this.contactSearchResultsLimit);      
    }
    //Method called when the Toggle Content button is clicked  
    public virtual PageReference toggleChatter() {  
        //If the showContent variable is true, set it to false, else, set it to true  
        if(showChatter){  
            showChatter = false;  
        } else {  
            showChatter = true;  
        }  
        return null;  
    }  
    
    public virtual void getObjects() {
        sw = new SearchWrapper();
        this.ssCategories = new List<SelectOption>();           
    }
    public virtual void initSettings() {
        this.qsParms = ApexPages.CurrentPage().getParameters();
        if(qsParms == null) {
            qsParms = new Map<String,String>();
        }   
    }   
    
    public virtual void debugLog(String msg) {
        if (debugMessages == null) {
            debugMessages = new List<DebugMessage>();
        }
        if((showDebugMessages) && (debugMessages.size() < 999)) { //@Performance
            debugMessages.add(new DebugMessage(msg));
        }
    }
    public virtual void errorLog(string message, string stackTrace){
        errorLog(message,stackTrace,'');
    }
    public virtual void errorLog(string message, string stackTrace,string strOther){
        if(debugMessages == null) {
            debugMessages = new List<DebugMessage>();
        }
        if(showDebugMessages && (debugMessages.size() < 999)) { //@Performance
            debugMessages.add(new DebugMessage(message, stackTrace, strOther));
        }
    }
    
    public virtual void errorLog(exception e, string strOther){
        errorLog(e.getMessage(),e.getStackTraceString(),strOther);
    }
    
    public virtual void errorLog(exception e){
        errorLog(e,'');
    }  
     
    public virtual List<SelectOption> getssCategories() {
        return UiUtils.retrievePlValues(New Account(), 'Social_Service__c');
    } 
    public virtual void SetssCategories(List<SelectOption> lSelectOptions ) {
        this.ssCategories = lSelectOptions;
    } 
    public virtual boolean getIsSysAdmin() {
        Boolean isIt = false;
        Profile p = static_mprofileId_profile.get(UserInfo.getProfileId());
        String pName = p.name;
        //@TODO find better way to do this.. ie. .custom setting or profile value
        if(pName.contains('System Administrator') || pName.contains('Breakeven SA')) {
            isIt = true;
        }
        return isIt;
    }   
    public virtual boolean getIsReviewer() {
        Boolean isIt = false;
        Profile p = static_mprofileId_profile.get(UserInfo.getProfileId());
        String pName = p.name;
        //@TODO find better way to do this.. ie. .custom setting or profile value
        if(pName.contains('System Administrator') || pName.contains('Supervising Attorney')) {
            isIt = true;
        }
        return isIt;
    }
    /* @RJN FOR FUTURE USE!
    @RemoteAction  
    public static String networkPing(String callingPage) {
    	System.debug(logginglevel.debug, 'Network ping reached.. callingpage='+callingPage);
    	return 'You reached me!';
    }
    */
      
}