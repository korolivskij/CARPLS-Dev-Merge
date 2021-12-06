public with sharing class ctrlDefectLauncher extends ctrlCarplesGeneric {
    
    public          Case                c                       { get; set; }
    public          String              sPrimaryEntityId        { get; set; }
    public          String              sPrimaryEntityName      { get; Set; }
    public          String              sSubEntityId            { get; set; }
    public          String              sSubEntityName          { get; Set; }
    public          String              sSubTabPageInfo         { get; set; }
    public          String              sPrimaryTabPageInfo     { get; set; }
    
    public ctrlDefectLauncher() {
        
        debugLog('in constructor()');
        //construtor
    }
    public PageReference doInit() {
        debugLog('in doInit()');
        if(c == null) {
            this.buildNewCase();
        } 
        return null;
    }
    public Pagereference doOnFocusedSubTabEvent() {
        debugLog('in doOnFocusedSubTabEvent..   (Sub Entity Id) ='+sSubEntityId);
        debugLog('in doOnFocusedSubTabEvent..   (sSubTabPageInfo) ='+sSubTabPageInfo);
        if(sSubEntityId != null) {
            this.sSubEntityName =  Utilities.findObjectNameById(sSubEntityId);
            debugLog('in doOnFocusedSubTabEvent..   (Sub Entity Name) ='+sSubEntityName);
        }
        
        return null;
    }
    public Pagereference doOnFocusedPrimaryTabEvent() {
        debugLog('in doOnFocusedPrimaryTabEvent..   (Primary Entity Id) ='+sPrimaryEntityId);
        debugLog('in doOnFocusedPrimaryTabEvent..   (sPrimaryTabPageInfo) ='+sPrimaryTabPageInfo);
        if(sPrimaryEntityId != null) {
            this.sPrimaryEntityName =  Utilities.findObjectNameById(sPrimaryEntityId);
            debugLog('in doOnFocusedSubTabEvent..   (Primary Entity Name) ='+sPrimaryEntityName);
        }       
        return null;
    }
    public Pagereference doSaveCase() {
        Boolean success = false;
        Id caseIdInserted;
        if(c != null) {
            c.defect_object_id__c = sSubEntityId;
            c.defect_object_name__c = sSubEntityName;
            debugLog('<font color=blue> Case being inserted='+c + '</font>');
            this.setCaseDMLOptions();
            try {
                caseIdInserted = DmlUtils.DBInsert(c);
            } catch (Exception e) {
                debugLog(e.getMessage());
            }               
        }
        PageReference pr;
        if(caseIdInserted != null) {
            pr = new PageReference('/apex/vfDefectSaveResults?id='+caseIdInserted);
            pr.setRedirect(true);
        } else { 
            pr = null;
        }
        return pr;
    }
    public Pagereference doCancelCase() {
        buildNewCase();
        return null;
    }
    private void buildNewCase() {
        c = new Case();
        RecordType rtDefect = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Unit_Testing_Defects') ;
        if(rtDefect != null) {
            c.RecordTypeId = rtDefect.id;
        }
        
        c.Priority = 'Low';
        c.Status = 'Open';
        c.Origin = 'Web';
        
        
        Contact contact = ContactUtils.retrieveAllUserContactInfo(UserInfo.getUserId());
        if(contact != null) {
            c.ContactId = contact.id;
        } else {
            debugLog('No contact found for user:'+UserInfo.getLastName());
        }
        debugLog('in buildNewCase() cse='+c);
        

        
    }
    public ctrlDefectLauncher getTheController() {
        return this;
    }   
    private void setCaseDMLOptions() {
        AssignmentRule AR = new AssignmentRule();
        try {
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        } catch (Exception e) {
            debugLog(e.getMessage());           
        }
        if(AR != null) {
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            c.setOptions(dmlOpts);
        }       
    }
}