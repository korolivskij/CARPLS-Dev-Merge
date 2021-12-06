public  class ctrlCaseDetail extends ctrlCarplesGeneric {
      
  
    public Case                                     cse                                 { get; set; }
    public Consultation__c                          userAddedConsulation                { get; set; }
    public List<Case_Party__c>                      caseParties                         { get; set; }   
    public List<Case_Review__c>                     caseReviews                         { get; set; }   
    public List<Attachment>                         caseAttachments                     { get; Set; }
    public List<Consultation__c>                    consultations                       { get; set; }  
    public List<Consultation__c>                    incompleteServices                  { get; set; }
    public Map<Id,Consultation__c>                  mIncompleteServiceId_Service        { get; Set; }
    public List<Conflict_Log__c>                    conflictLogs                        { get; set; } 
    public List<Subject__c>                         relatedSubjects                     { get; set; }
    public List<Applied_Resource__c>                appliedResources                    { get; set; }
    public List<NotesWrapper>                       caseConsultationNotes               { get; set; }
    public NotesWrapper                             newCaseConsultationNote             { get; set; }
     
    
    
    
    public Consultation__c                          currentConsultation                 { get; set; }
    public Note                                     newConsultationNote                 { get; set; }
    
    public list<Note>                               currentConsultationNotes            { get; set; }   
    
    public Boolean                                  isViewOnly                          { get; set; }
    public Boolean                                  isNewEditMode                       { get; set; }
    public Boolean                                  isRealEditMode                      { get; set; }
    public Boolean                                  isServiceComplete                   { get; Set; }
    public Boolean                                  isResumeCase                        { get; set; }
    public Boolean                                  isFromCase                          { get; set; }
    public Boolean                                  displaySaveAndContinueCurrentPage   { get; set; }
    public Boolean                                  displayConflictButtons              { get; set; }
    public Boolean                                  displayConflictLogs                 { get; set; }
    public Boolean                                  showCancelCloseTab                  { get; Set; }

    public Boolean                                  displayRelatedFaqs                  { get; set; }
    public Boolean                                  displayRelatedSubjects              { get; set; }
    public Boolean                                  displayCaseArticles                 { get; set; }
    public Boolean                                  displayCaseConsulationNotes         { get; set; }
    public Boolean                                  displayFaqs                         { get; set; }
    public Boolean                                  displayConsultations                { get; set; }
    public Boolean                                  displayCaseParties                  { get; set; }
    public Boolean                                  displayAddNewDisp                   { get; set; }
    public Boolean                                  displayAddNewReview                 { get; set; }
    public Boolean                                  showExpandedNote                    { get; set; }
    public Boolean                                  isConflict                          { get; set; }
    public Boolean                                  isCollapseFaqData                   { get; set; }
    public Boolean                                  displayAddNewServiceNote            { get; set; }
    public Boolean                                  isUserAddingService                 { get; set; }
    public Boolean                                  detailViewOnlyMode                  { get; set; }
    public Boolean                                  doQuestionsExist                    {  set; }
    public Boolean                                  showActiveSubjects                  { get; set; }
    public Boolean                                  wasEditProblemCodeBtnClicked        { get; set; }
    public Boolean                                  isUserEditingProblemCode            { get; set; }
    public transient Boolean                        actionCompleted                     { get; Set; }

    
    public CaseUtils                                caseUtils                           { get; set; }
    //public KnowledgeUtils                         kUtils                              { get; set; }
    public AppliedResourceUtils                     arUtils                             { get; set; }
    
    public String                                   selectedPublishingStatus            { get; set; }
    public String                                   selectedSubjectType                 { get; set; }
    public String                                   actionId                            { get; set; }
    public String                                   subjCseId                           { get; set; }
    
    public String                                   caseSubjectIdSelected               { get; Set; }
    public String                                   sourceCaseId                        { get; set; }
    public String                                   currentRelativeUrl                  { get; Set; }
    public String testRefresh {get; set;}

    public Id                                       cpIdClickedFromClient               { get; set; }
    public Id                                       selectedCpId                        { get; set; }
    public Id                                       selectedAppliedResourceId           { get; set; }
    //slId is search_log__c id or search_log_children__id pending on searchType
    public Id                                       slId                                { get; set; }
    
    public String                                   clickedNotesRowId                   { get; set; }
    public String                                   collapseNotesRowId                  { get; set; }
    public String                                   expandNotesRowId                    { get; set; }
    public Boolean                                  isCaseClosed                        { get; set; }
    public Boolean                                  renderArticleReviewComponent        { get; set; }
    public Boolean                                  renderArticleCreateComponent        { get; set; }
    public Boolean                                  renderSubjectCreateComponent        { get; set; }
    public Boolean                                  renderCaseReviewCreateComponent     { get; set; }
    //public String                                 caseFaqKavIdReviewed                { get; set; }
    
    public String                                   caseSubjectIdReviewed               { get; set; }
    public String                                   serviceIdForReview                  { get; set; }
    public Subject__c                               caseSubjectReviewed                 { get; set; }
    public Boolean                                  doesCaseActivityHistoryExist        { get; set; }
    
    /* -- Conflicts Check from client review stuff */
    public List<Possible_Conflict__c>               possibleCaseConflicts               { get; set; }
    public Possible_Conflict__c                     currentConflict                     { get; set; }
    public List<Conflict_Log__c>                    conflictLogsAdded                   { get; set; }
    public List<Case_Party__c>                      possibleConflictingCaseParties      { get; set; }
    public String                                   contactIdBeingReviewed              { get; set; }
    public String                                   searchType                          { get; set; }
    public Boolean                                  potentialConflict                   { get; set; }
    public Boolean                                  showConflictLogEntryPanel           { get; set; }
    public String                                   reloadUrl                           { get; set; }
    public Boolean                                  yesConflictClicked                  { get; set; }
    public Boolean                                  yesConflictCompleted                { get; set; }
    public Boolean                                  noConflictCompleted                 { get; set; }
    public Boolean                                  contactHasMultipleCpAssoc           { get; set; }
    public Boolean                                  noConflictClicked                   { get; set; }
    public Boolean                                  displayConflictLogsAdded            { get; set; }
    public Boolean                                  displayCaseCustomPageMessage        { get; set; }
    public Boolean                                  isNewCase                           { get; set; }
    public Boolean                                  isPreCase                           { get; set; }
    public Boolean                                  isServiceEdit                       { get; set; }
    public Boolean                                  isServiceEditNew                    { get; set; }
    public Boolean                                  isCaseDetailEdit                    { get; set; }
    public Boolean                                  showResourceAppliedMsgPanel         { get; set; }
    public Boolean                                  showServiceMsgPanel                 { get; set; }
    public Boolean                                  showPartyMsgPanel                   { get; set; }
    public Boolean                                  showSubjectSelectedMsgPanel         { get; set; }
    public Boolean                                  showIncompleteServiceMsgPanel       { get; set; }
    public Boolean                                  pendingClient                       { get; set; }
    public Boolean                                  isCloseTabCancelOverride            { get; set; }
    
    public transient Boolean                        renderSubjectViewComponent          { get; Set; }

    public String                                   selectedSubjectRecordType           { get; set; }
    public String                                   searchTabUrl                        { get; set; }
    public String                                   searchTabLabel                      { get; set; }
    
    public List<FeedItem>                           feedItems                           { get; set; }
    public List<FeedItemWrapper>                    feedItemWrappers                    { get; set; }   
    public List<ContentVersion>                     contentVersion                      { get; set; }
    public List<ContentVersionWrapper>              contentVersionWrappers              { get; set; }
    
    public List<Survey_Feedback__c>                 caseSurveys                         { get; set; }

    
    
    /*--- End conflicts check from client review stuff */
    /* --- Begin conflict log entry panel stuff **/

    public List<User>                               superAttorneys                      { get; set; }
    
    public  Conflict_Log__c                         conflictLog                         { get; set; }   
    public  Search_Log__C                           conflictSearchLog                   { get; set; }
    public  Case_Party__c                           casePartyClicked                    { get; set; }
        

    public  String                                  selectedReasonVal                   { get; set; }
    public  String                                  selectedApproverVal                 { get; set; }
    public  String                                  searchedClientName                  { get; set; }
    public  String                                  jsSaveOnCompleteMethod              { get; set; }
    public  String                                  jsAddNewService                     { get; set; }
    public  String                                  jsConflictProcess                   { get; set; }
    public  String                                  jsCloseNewSubjectMethod              { get; Set; }
    
    public  Boolean                                 isProblemCodeInfoPopulated;
//  public FAQ__kav                                 faqClicked                          { get; set; }
    public  Subject__c                                  subjectClicked                  { get; set; }
	
    public String                                       jsMainSaveOnCompleteMethod      { get; set; }
    public String                                       jsRefreshArOnComplete           { get; set; }
    public String                                       jsRemoveArOnComplete            { get; Set; }
    
    public Subject__c                                   newSubject                      { get; Set; }
    public String                                       newSubjectTitle                 { get; Set; }
    public String                                       resourceClickedId               { get; Set; }
    public Applied_Resource__c                          lastArApplied                   { get; set; }
    
    public Case_Review__c                               newCaseReview                   { get; set; }
    public ProblemCodeWrapper                           preCasePcWrap                   { get; set; }
    
    //--- The below might be set via event listener from service tab.
    public String                                       serviceSubTabObjectId           { get; set; }
    public String                                       serviceSubTabAction             { get; set; }
   
   	// For CaseQuestions  RJN we aren't really using this anyway.. this was causing an insufficient privs error upon viewstate desir.
    // made transient
   	public transient  List<DynaQaWrapper>              			cseQaWraps                  	{ get; set; }
   	public transient  Map<String, Schema.SObjectfield> 			sObjectFieldMap            	 	{ get; set; }
    /*
     * isPreviewOnly was null at times (even though it is set in the constructor).. guard against a null value.
     */
    public Boolean                                      isPreviewOnly                   
                                                            {   get {
                                                                    if(isPreviewOnly == null){isPreviewOnly = false;}
                                                                    return isPreviewOnly;
                                                                }   
                                                                set; 
                                                            }
	public Boolean getDoQuestionsExist() {
		return ( cseQaWraps != null && !cseQaWraps.isEmpty());
		
	}
    
    public ctrlCaseDetail(ApexPages.StandardController stdController) {
        this.caseUtils  = new CaseUtils();       
        this.cse = (Case)stdController.getRecord(); 
        this.wasEditProblemCodeBtnClicked = false;  
        this.isUserEditingProblemCode = false; 
        this.constructorInitCode();
        this.jsConflictProcess = 'return;';
        this.jsMainSaveOnCompleteMethod  = 'return;';
        this.jsRefreshArOnComplete  = 'return;';
         this.jsAddNewService = ''; 
        this.actionCompleted = false;
        this.preCasePcWrap = new ProblemCodeWrapper();
        this.isServiceComplete = false;
        this.isPreviewOnly = false;
        this.mIncompleteServiceId_Service = new Map<Id,Consultation__c>();
        
        // For Case Questions
        this.sObjectfieldMap = UiUtils.getSObjectFieldsMap(new Case());
        this.cseQaWraps = new List<DynaQaWrapper>();
        


       // debugLog('---isViewOnly='+this.isViewOnly);
       // this.showDebugMessages = UserInfo.getLastName() == 'Nendza';
        
    }
    /** 
     * Because DML Cannot be executed in the constructor.. do any dml init here.
     *
     */
    public PageReference doInitCase() {

		
       if(isPreCase && isNewCase) {
            debugLog('<font color=red>Setting case.start_it__c to true and left_open__c to true!!</font>');
            cse.start_it__c = true;
            cse.Left_Open__c = true; 
            update cse;             
        }   
        if(getIsIncompleteServices() && cse.status != 'Open' && !isViewOnly) {
            cse.status = 'Open';
            update cse;
            debugLog('in doInitCase since we found an incomplete service and the case status was closed, <font color=blue>changing the case status to open</font>');
        }
        
        if(getIsIncompleteServices() && !isViewOnly && !isPreviewOnly) {
            String msg = 'There are incomplete services associated with this case. Please scroll down and edit the services highlighted in red!';
            this.customPageMessage = msg;
            this.displayCaseCustomPageMessage = true;       
            this.customPageMessageSeverityStyleClass = 'errorM3';
            this.showIncompleteServiceMsgPanel = true;
        }
        //if this is a new case, the case questions will be retrieved in the subject selection
        if (!isNewCase) {
        	// ELC - needed to comment this out for now because it put the # of SQL queries over the edge
        	//this.InitCaseQuestions();
        }
        return null;    
    }
    public void constructorInitCode() {
        this.currentRelativeUrl = ApexPages.currentPage().getUrl();
        debugLog('--- in constructorInitCode.. current relative Url='+currentRelativeUrl);
        this.renderSubjectViewComponent = false;
        this.showCancelCloseTab = false;
        this.showActiveSubjects = true;
        this.refreshCaseSummaryData();
        this.displayAddNewReview = getIsReviewer();
        this.refreshCaseReviews();
        this.refreshCaseAttachments();
        this.refreshFeedItemWrappers();
        this.refreshContentVersionWrappers();
        this.refreshCaseSurveys();
        this.isCaseDetailEdit = false;
        this.doQuestionsExist = false;
        this.isViewOnly = false;   
        this.isNewEditMode = false;
        this.isUserAddingService = false;
        this.isResumeCase = false;
        this.doesCaseActivityHistoryExist = false;
        this.displaySaveAndContinueCurrentPage = false;
        this.showConflictLogEntryPanel = false;
        this.displayCaseCustomPageMessage = false;
        this.showResourceAppliedMsgPanel = false;
        this.showSubjectSelectedMsgPanel = false;
        this.showServiceMsgPanel = false;
        this.showPartyMsgPanel = false;
        this.showIncompleteServiceMsgPanel = false;
        this.displayConflictButtons = false;
        this.displayConflictLogs = false;
        this.displayConsultations = false;
        this.displayCaseCustomPageMessage = false;
        this.displayCaseParties = false;
        this.displayFaqs = false;
        this.displayRelatedSubjects = false;
        this.displayAddNewServiceNote = false;
        this.displayAddNewDisp  = false;
        this.displayConflictLogsAdded = false;
        this.isProblemCodeInfoPopulated = false;
        this.isCloseTabCancelOverride = false;
        this.isRealEditMode = false;
        this.isNewCase = false;
        this.isPreCase = false;
        this.isServiceEditNew = false;
      //      this.isSer
        this.isServiceEdit = false;
        this.detailViewOnlyMode = false;
        
        this.showExpandedNote = false;
        this.potentialConflict = false;
        this.isConflict = false;
        this.displayRelatedFaqs = false;
        this.selectedPublishingStatus = 'All';
        this.selectedSubjectType = 'All';
        this.isCollapseFaqData = false;
        this.yesConflictClicked = false;
        this.yesConflictCompleted = false;
        this.noConflictCompleted = false;
        this.contactHasMultipleCpAssoc = false;
        this.noConflictClicked = false;
        this.conflictLogsAdded = new List<Conflict_Log__c>();
        
        this.displayCaseConsulationNotes = false;
        this.isCaseClosed = false;
        this.renderArticleReviewComponent = false;  
        this.renderArticleCreateComponent = false;
        this.renderSubjectCreateComponent = false;
        
        this.pendingClient = false;
       
        this.jsCloseNewSubjectMethod = '';
        this.jsRefreshArOnComplete = '';
        this.jsRemoveArOnComplete   = '';
              
        String sNewCase =  ApexPages.currentPage().getParameters().get('newcase');
        if(sNewCase != null && sNewCase.length() > 0) {
            this.isNewEditMode = Boolean.valueOf(sNewCase);
            this.displaySaveAndContinueCurrentPage = true;
            displayConsultations = false;
            this.isNewCase = Boolean.valueOf(sNewCase);
            this.isPreCase = isNewCase;
            
            
        } 
       
        String sResume =  ApexPages.currentPage().getParameters().get('resumeCase');
        if(sResume != null && sResume.length() > 0) {
            this.isResumeCase = Boolean.valueOf(sResume);
            if(isResumeCase && cse.Problem_Code__c == null) {
                debugLog('in constructorinit()... we are in resumecase and case problem code is null.. Set isPreCase to true');
                this.isPreCase = true;
            }
        }
                       
 
        
        String sviewOnly =  ApexPages.currentPage().getParameters().get('review');
        if(sViewOnly != null && sViewOnly.length() > 0) {
            this.isViewOnly = Boolean.valueOf(sViewOnly);
            //this.refreshkArticles();
            //this.displayFaqs = true;
            //this.refreshConsultations();
            this.displayCaseParties = true;
            this.displayConsultations = true;
            this.displayFaqs = true;

        }
        String sPendingClient = ApexPages.currentPage().getParameters().get('pendingClient');
        if(sPendingClient != null && sPendingClient.length() > 0) {
            this.pendingClient = Boolean.valueOf(sPendingClient);
             
        } 
        debugLog('in constructorinit() .. pendingClient='+this.pendingClient);      
        if(this.isResumeCase) {
            this.displaySaveAndContinueCurrentPage = true;
            this.displayCaseParties = true;
            this.displayConsultations = true;
            this.displayFaqs = true;
            this.detailViewOnlyMode = true;
            this.isViewOnly = true;
            debugLog('is resumeCase setting viewOnly=true');    
            if(this.currentConsultation == null) {
                this.currentConsultation = caseUtils.retrieveCurrentCaseConsultation(cse);
                debugLog('in resumeCase... currentCons was null but is now='+this.currentConsultation);    
                if(currentConsultation == null) {
                    this.isServiceEditNew = true;
                    this.doEditDetail();
                    
                    
                }
            } 
        }
        /* obsolete ??
        String sSummaryEdit =  ApexPages.currentPage().getParameters().get('summaryEdit');
        if(sSummaryEdit != null && sSummaryEdit.length() > 0) {
            this.isViewOnly = false;
            this.isRealEditMode = true;
            this.isNewEditMode = true;
            if(this.currentConsultation == null) {
                
                this.currentConsultation = caseUtils.retrieveCurrentCaseConsultation(cse);
                debugLog('In summary Edit setting currentConsultation='+this.currentConsultation);
            }
        }        
        */
       
        String sPotentialConflict =  ApexPages.currentPage().getParameters().get('potentialConflict');
        if(sPotentialConflict != null && sPotentialConflict.length() > 0) {
            this.potentialConflict = Boolean.valueOf(sPotentialConflict);
            this.contactIdBeingReviewed = ApexPages.currentPage().getParameters().get('contactBeingReviewed');
            this.searchType = ApexPages.currentPage().getParameters().get('searchType'); 
            this.slId =   ApexPages.currentPage().getParameters().get('slId');  
            //this.refreshPotentialConflicts();  
            this.refreshPossibleCaseConflicts(); 
              

        }
        String sCpIdClicked =  ApexPages.currentPage().getParameters().get('cpIdClicked');
        if(sCpIdClicked != null && sCpIdClicked.length() > 0) {
            this.cpIdClickedFromClient = sCpIdClicked;
            this.isPreviewOnly = true;
            
        }
        String sPreviewOnly =  ApexPages.currentPage().getParameters().get('previewOnly');
        if(sPreviewOnly != null && sPreviewOnly != '') {
            try {
                this.isPreviewOnly = Boolean.valueOf(sPreviewOnly);
            } catch (Exception e) {
                debugLog('error setting isPreviewOnly with request value of '+sPreviewOnly);
            }
        }
        String sShowCloseTabCancelOverride =  ApexPages.currentPage().getParameters().get('showCloseTabCancelOverride');
        if(sShowCloseTabCancelOverride != null && sShowCloseTabCancelOverride != '') {
            try {
                this.isCloseTabCancelOverride = Boolean.valueOf(sShowCloseTabCancelOverride);
            } catch (Exception e) {
                debugLog('error setting isCloseTabCancelOverride with request value of '+sShowCloseTabCancelOverride);
            }
        }        
        
        this.refreshCaseParties();
        //this.consultations = caseUtils.retrieveConsultations( cse );
        this.refreshConsultations();
        
        this.refreshConflictLogs(); 
        
        this.arUtils = new AppliedResourceUtils();
        this.actionId = '';
      
        
       //   this.refreshkArticles();
        if(cse.Problem_Category__c != null && cse.problem_category__c != '') {
            this.refreshSubjects();
        }
        this.refreshAppliedResources();

        debugLog('in constructorinit() .. current consultation='+this.currentConsultation);
        if(this.currentConsultation == null) {
            debugLog('no current consultation found!');
            if(this.consultations != null && !this.consultations.isEmpty()) {
                debugLog('consultation records are attached to the case.. attempt to get the latest which will be the first');
                this.currentConsultation = consultations[0];
                debugLog('current consultation set to='+this.currentConsultation);              
            }
            
        }
       //GO HERE
        
        if(!this.isNewEditMode) {
            this.displayConflictLogs = true;
            
        }  
        if(!isViewOnly && !isNewEditMode) {
            /*
            String msg = 'Case is editable. Hover over fields and double click on those where a pencil appears to edit those fields.';
            if(!this.isRealEditMode) {
                msg+= '  You may also click the Edit Detail button.';
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg)); 
            */
            this.displayFaqs = true;    
                    
        }   
        /* future enhancement not ready
        if(cse.status == 'Open' && cse.last_service_by__c != null && cse.Last_Service_By__c != UserInfo.getUserId()) {
            String msg = ' This case is currently being worked on by ' + cse.last_service_by__r.name;
            msg += '. Please click cancel to return to your original page.';
            this.isPreviewOnly = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,msg)); 
        }       
        */
        this.initSectionState();
        if(slClient == null) {
            slClient = SearchWrapper.getLatestSearchLog(UserInfo.getUserId() );
        
        }
        
        this.caseConsultationNotes = caseUtils.retrieveCaseConsultationNotesWraps(this.cse);   
        this.setIsProblemCodeInfoPopulated(this.getIsProblemCodeInfoPopulated());       
        this.isNewCase = !this.getIsProblemCodeInfoPopulated();
       
    }
    public ctrlCaseDetail getTheController() {
        return this;
    }
    /**
     * Added Per Design Change Case.. 00006069
     * 
     */
    public PageReference doInitSubjectsForPcInfo()  {
        debugLog('----------> in doInitSubjectsForPcInfo at top....');
        //ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(cse);  
        debugLog('--- pcWrap='+this.preCasePcWrap);
        if(preCasePcWrap.practiceArea == null){
            preCasePcWrap = new ProblemCodeWrapper(cse);
        }
        this.displayFaqs = true;
        mSectionState.get('caseSubjectSection').showIt = true; 
        mSectionState.get('faqsPanel').showIt = true; 

        
        this.refreshSubjects();
        //this.initSectionState();
        return null;
    }
    
    public PageReference doSetResourceClickedId() {
        debugLog('----------> in doSetResourceClickedId().... id Set by actionfunction='+resourceClickedId);
        return null;    
    }
    
    private void initSectionState() {
        this.mSectionState = new Map<String,SectionStateBean>();
        
        this.detailViewOnlyMode     =  (!this.isRealEditMode &&  (cse.subject != null && cse.description != null && this.getIsProblemCodeInfoPopulated()) || isViewOnly);
        Boolean showCloseTabCancel = false;
        if(cpIdClickedFromClient != null || ( pendingClient && isPreCase) || isPreviewOnly) {
            showCloseTabCancel = true;  
        }
        if(isCloseTabCancelOverride) {
            showCloseTabCancel = true;
        }
        
        debugLog('---cpIdClickedFromClient='+cpIdClickedFromClient);
        debugLog('---isPreviewOnly='+isPreviewOnly);
        debugLog('---isUserAddingService='+isUserAddingService);
        debugLog('---isRealEditMode='+isRealEditMode);
        debugLog('---isServiceEditNew='+isServiceEditNew);
        debugLog('---isCaseDetailEdit='+isCaseDetailEdit);
        debugLog('---showCloseTabCancel='+showCloseTabCancel);
        debugLog('---isPreCase='+isPreCase);
        
        Boolean showEditDetailBtn   = this.detailViewOnlyMode && cse.Status != 'Closed' && currentConsultation != null && !isPreviewOnly;
        //Boolean showSaveAndContinueBtn = !showEditDetailBtn && !isViewOnly && !isServiceEditNew ;
        Boolean showSaveAndContinueBtn = !showEditDetailBtn && !isViewOnly && !isServiceEditNew 
                                            && currentConsultation !=null && !isPreviewOnly /*|| (cse.Selected_Subject__c == null || cse.description == null)*/;
        Boolean requireDescInput = cse.Selected_Subject__c != null && !isPreCase;
        
        
        
        //Boolean showSaveAndCloseBtn = isRealEditMode && !this.isServiceEditNew;
        
        Boolean showSaveAndCloseCaseBtn = cse.Status != 'Closed' &&  !isNewCase && currentConsultation != null && !this.isServiceEditNew && !isRealEditMode && !isPreviewOnly;
        Boolean showCancelEditButton = this.isRealEditMode && !isServiceEditNew;
        debugLog('show save and continue btn='+showSaveAndContinueBtn);
        Boolean showAddServiceBtn   = (   ( 
                                            (cse.Status == 'Closed' && !showSaveAndCloseCaseBtn && !isUserAddingService && !isNewCase && !showSaveAndContinueBtn) 
                                            || (currentConsultation == null && cse.Selected_Subject__c != null && cse.description != null  && !isServiceEditNew) 
                                          )
                                        &&  ( !isPreviewOnly )
            
                                      );
        debugLog('show add service btn='+showAddServiceBtn);                              
                                      
        //Boolean collapseSubject = ( (cse.subject != null && !showSaveAndContinueBtn && !this.isServiceEditNew) || detailViewOnlyMode);
        //collapseSubject = ( (cse.status == 'Closed') && (! (isRealEditMode || isServiceEditNew)) );
        Boolean collapseSubject = (cse.subject != null && !isRealEditMode) || isServiceEditNew;
        debugLog('---collapseSubject='+collapseSubject);
        debugLog('---detailViewOnlyMode='+detailViewOnlyMode);
        
        mSectionState.put( 'panelLeftNav', new SectionStateBean('panelLeftNav',false) );
        mSectionState.put( 'tempCloseCaseByPassBtn', new SectionStateBean('tempCloseCaseByPassBtn',cse.status != 'Closed') );
        mSectionState.put( 'cancelNewCaseBtn', new SectionStateBean('cancelNewCaseBtn',
                            (isNewCase || !this.getIsProblemCodeInfoPopulated()) && !pendingClient   && !this.isUserEditingProblemCode)
                        );
        //mSectionState.put( 'saveNewCaseBtn', new SectionStateBean('saveNewCaseBtn',this.getIsProblemCodeInfoPopulated() && cse.selected_subject__C != null) );
        mSectionState.put( 'saveNewCaseBtn', new SectionStateBean('saveNewCaseBtn',false) );
        mSectionState.put( 'saveEditProblemCodeBtn', new SectionStateBean('saveEditProblemCodeBtn',this.isUserEditingProblemCode) );
        mSectionState.put( 'cancelCloseTabBtn', new SectionStateBean('cancelCloseTabBtn',showCloseTabCancel) );
        debugLog('---initSectionState.. cancelCloseTabBtn='+mSectionState.get('cancelCloseTabBtn'));
        
        
        debugLog('---initSectionState.. isNEwCase='+isNewCase);
        Boolean showCaseDetailViewOnlySection = (isViewOnly || detailViewOnlyMode || isCaseDetailEdit);
        Boolean everClosed = cse.ever_closed__c;
        //Boolean everClosed = true;
        debugLog('---initSectionState.. closedDate='+cse.ClosedDate);
        debugLog('---initSectionState.. everClosed='+everClosed);
        
        mSectionState.put( 'caseDetailViewOnlySection', new SectionStateBean('caseDetailViewOnlySection',(showCaseDetailViewOnlySection)) );
        
        mSectionState.put( 'caseDetailEditSection', new SectionStateBean('caseDetailEditSection',(!showCaseDetailViewOnlySection)) );
        //mSectionState.put( 'caseDescViewOnlySection', new SectionStateBean('caseDescViewOnlySection', ( (detailViewOnlyMode) && !this.isCaseDetailEdit) || everClosed  ) );
        mSectionState.put( 'caseDescViewOnlySection', new SectionStateBean('caseDescViewOnlySection', ( !isPreCase & ( (detailViewOnlyMode) && !this.isCaseDetailEdit) || everClosed)   ));
        mSectionState.put( 'caseDescEditInputsSection', new SectionStateBean('caseDescEditInputsSection',!isPreCase & (!detailViewOnlyMode  && this.isCaseDetailEdit && !everClosed)));
        mSectionState.get('caseDescEditInputsSection').required = requireDescInput;
        
        
        Boolean showProfileSection = true;
        Boolean showProfileInputs = false;
        
        showProfileInputs = ( (!isViewOnly|| this.isServiceEditNew ) && !detailViewOnlyMode);
        //override.. make sure subject is populated before showing profile inpute section.
        if(this.cse.selected_subject__c == null || isPreCase ) {
            showProfileInputs = false;
            showProfileSection = false;
        }
        debugLog('---showProfileSection ie. show it at all?='+showProfileSection);
        debugLog('---showProfileInputs='+showProfileInputs);
        mSectionState.put( 'caseProfileSection', new SectionStateBean('caseProfileSection', showProfileSection ) );
        mSectionState.put( 'caseProfileSectionInputs', new SectionStateBean('caseProfileSectionInputs', showProfileInputs ) );  
        mSectionState.put( 'caseProfileSectionView', new SectionStateBean('caseProfileSectionView',( !showProfileInputs)));         
        mSectionState.put( 'pbButtons', new SectionStateBean('pbButtons',!this.potentialConflict) );
        
        mSectionState.put( 'backToClientBtn', new SectionStateBean('backToClientBtn',showCancelCloseTab) );
        debugLog('---isViewOnly='+isViewOnly);
        
        mSectionState.put( 'editDetailBtn', new SectionStateBean('editDetailBtn',showEditDetailBtn) );
        //Boolean showSaveAndContinueBtn = !detailViewOnlyMode && this.displaySaveAndContinueCurrentPage && !isNewCase;
         
        mSectionState.put( 'saveAndContinueBtn', new SectionStateBean('saveAndContinueBtn',showSaveAndContinueBtn) );
        mSectionState.put( 'saveAndContinueNewServiceBtn', new SectionStateBean('saveAndContinueNewServiceBtn',this.isServiceEditNew ));
        
        mSectionState.put( 'saveAndCloseBtn', new SectionStateBean('saveAndCloseBtn',showSaveAndCloseCaseBtn) );
        mSectionState.put( 'cancelEditBtn', new SectionStateBean('cancelEditBtn',showCancelEditButton) );
        
        Boolean doServicesExist = this.consultations != null && !this.consultations.isEmpty();
        mSectionState.put( 'cancelAddServiceEditBtn', new SectionStateBean('cancelAddServiceEditBtn',this.isServiceEditNew && doServicesExist) );
        mSectionState.put( 'editProblemCodeBtn', new SectionStateBean('editProblemCodeBtn',this.isServiceEditNew && !doServicesExist) );
        //debugLog()
        mSectionState.put( 'addActivityBtn', new SectionStateBean('addActivityBtn',!showSaveAndContinueBtn && !this.isServiceEditNew && !isRealEditMode && !isPreviewOnly) );
        mSectionState.put( 'addPartyBtn', new SectionStateBean('addPartyBtn',
                ( !showSaveAndContinueBtn && !this.isServiceEditNew && !isRealEditMode && !isPreviewOnly) /*main detail view*/
                || (this.isServiceEditNew && !doServicesExist))); /* or new case entering desc */
        
        
        mSectionState.put( 'caseSubjectCollapseJs', new SectionStateBean('caseSubjectCollapseJs',collapseSubject) );
        mSectionState.put( 'articleReviewSectionCollapseJs', new SectionStateBean('articleReviewSectionCollapseJs',collapseSubject) );
        mSectionState.put( 'caseSubjectSection', new SectionStateBean('caseSubjectSection',true) );
        
        mSectionState.put( 'faqsPanel', new SectionStateBean('faqsPanel',!isViewOnly) );    
        mSectionState.put( 'caseDetailEditOnlySection', new SectionStateBean('caseDetailEditOnlySection',isRealEditMode));
        
        
        mSectionState.put( 'closeCaseBtn', new SectionStateBean('closeCaseBtn',showSaveAndCloseCaseBtn) );
        mSectionState.put( 'addServiceBtn', new SectionStateBean('addServiceBtn',showAddServiceBtn) );
        mSectionState.put( 'articleReviewSection', new SectionStateBean('articleReviewSection',this.isViewOnly || this.renderArticleReviewComponent || isResumeCase || isNewCase || cse.subject != null) );
        mSectionState.put( 'articleCreate', new SectionStateBean('articleCreate',this.renderArticleCreateComponent) );
        mSectionState.put( 'subjectCreateComponent', new SectionStateBean('subjectCreateComponent',this.renderSubjectCreateComponent) );

        //---- related lists        
        
        mSectionState.put( 'conflictLogsSection', new SectionStateBean('conflictLogsSection',this.displayConflictLogs && !this.isRealEditMode) );
        Boolean showCasePartiesList = (( (displayCaseParties &&   cse.Description != null && cse.Subject != null) || isViewOnly) && !isRealEditMode)  ;
        Boolean partiesAccepted = (currentConsultation != null && currentConsultation.parties_Accepted__c);
        mSectionState.put( 'casePartiesSection', new SectionStateBean('casePartiesSection',showCasePartiesList,partiesAccepted) );
        Boolean arAccepted = (currentConsultation != null && currentConsultation.applied_resources_accepted__c);
        mSectionState.put( 'appliedResourcesSection', new SectionStateBean('appliedResourcesSection',showCasePartiesList,arAccepted) );
        mSectionState.put( 'serviceNotesSection', new SectionStateBean('serviceNotesSection',showCasePartiesList) );
        Boolean serviceDispAccepted = (currentConsultation != null && currentConsultation.service_disposition_accepted__c);
        mSectionState.put( 'caseDispositionsSection', new SectionStateBean('caseDispositionsSection',showCasePartiesList,serviceDispAccepted) );
        mSectionState.put( 'caseAttachmentsSection', new SectionStateBean('caseAttachmentsSection',showCasePartiesList) );
        mSectionState.put( 'caseActivityHistorySection', new SectionStateBean('caseActivityHistorySection',showCasePartiesList) );
        mSectionState.put( 'caseSurveySection', new SectionStateBean('caseSurveySection',showCasePartiesList) );
        mSectionState.put( 'caseReviewSection', new SectionStateBean('caseReviewSection',showCasePartiesList) );

        this.checkProblemCode();
        
        
  
    }
    private void checkProblemCode() {
        
        Boolean pcPopulated = this.getIsProblemCodeInfoPopulated();
        if(!pcPopulated) {
            mSectionState.get('caseDetailViewOnlySection').showIt = false;
            mSectionState.get('caseDetailEditSection').showIt = false;
            //--    mSectionState.get('caseProfileSection').showIt = false;
            mSectionState.get('caseSubjectSection').showIt = false;
            mSectionState.get('caseSubjectCollapseJs').showIt = false;
            mSectionState.get('articleReviewSectionCollapseJs').showIt = false;
            mSectionState.get('caseDescViewOnlySection').showIt = false;
            
            mSectionState.get('caseDescEditInputsSection').showIt = false;
            mSectionState.get('faqsPanel').showIt = false;
            mSectionState.get( 'editDetailBtn').showIt = false;
            mSectionState.get( 'closeCaseBtn').showIt = false;
            mSectionState.get( 'addActivityBtn').showIt = false;
            mSectionState.get( 'addPartyBtn').showIt = false;
            //mSectionState.get( 'cancelNewCaseBtn').showIt = false;
            mSectionState.get( 'addServiceBtn').showIt = false;
            mSectionState.get( 'saveAndContinueBtn').showIt = false;
            
            
            mSectionState.get( 'saveAndContinueNewServiceBtn').showIt = false;
            if(!pendingClient && isPreCase) {
                mSectionState.get( 'cancelCloseTabBtn').showIt = false;
            }
            
            mSectionState.get( 'saveAndCloseBtn').showIt = false;
            mSectionState.get( 'cancelEditBtn').showIt = false;
            mSectionState.get( 'cancelAddServiceEditBtn').showIt = false;
            mSectionState.get( 'editProblemCodeBtn').showIt = false;
           
            mSectionState.get( 'articleReviewSection').showIt = false;
            mSectionState.get( 'articleCreate').showIt = false;
            mSectionState.get( 'subjectCreateComponent').showIt = false;
            mSectionState.get( 'caseDispositionsSection').showIt = false;
            mSectionState.get( 'conflictLogsSection').showIt = false;
            mSectionState.get('caseProfileSection').showIt = false;
            mSectionState.get('caseProfileSectionInputs').showIt = false;
            mSectionState.get('caseProfileSectionView').showIt = false;
            mSectionState.get('casePartiesSection').showIt = false;
            mSectionState.get('appliedResourcesSection').showIt = false;
            mSectionState.get('serviceNotesSection').showIt = false;
            mSectionState.get('caseAttachmentsSection').showIt = false;
            mSectionState.get('caseActivityHistorySection').showIt = false;
            mSectionState.get('caseSurveySection').showIt = false;
            mSectionState.get('caseReviewSection').showIt = false;
            this.displaySaveAndContinueCurrentPage = true;
            //mSectionState.put( 'caseDetailViewOnlySection', new SectionStateBean('caseDetailViewOnlySection',false) );  
            //mSectionState.put( 'caseProfileSection', new SectionStateBean('caseProfileSection',isViewOnly) );         
        }
    }
    /* moved to it's own page>
    public PageReference doAddNewServiceNote() {
        newCaseConsultationNote = new NotesWrapper(new Note());
        if(this.currentConsultation != null) {
            newCaseConsultationNote.note.ParentId = this.currentConsultation.id;
        }
        this.displayAddNewServiceNote = true;
        return null;
    }
    */
    public Pagereference doEditDetail() {
        this.isNewEditMode = true;
        this.isRealEditMode = true;
        //this.is
        this.isViewOnly = false;
        this.isCaseDetailEdit = true;
    
        this.initSectionState();
        return null;
    }
    /*  Obsolete?  @ELC
    public Pagereference doAddNewDisp() {
        update this.cse;
        this.userAddedConsulation = new Consultation__c();  
        userAddedConsulation.Case__c = this.cse.id;
        userAddedConsulation.Subject__c = 'Service ' + string.valueOf(date.today());
        userAddedConsulation.Consultation_Category__c = cse.Practice_Area__c + '_' +
                                                        cse.Problem_Category__c + '_' + cse.Problem_Code__c;
        userAddedConsulation.last_contact__c = date.today();
        userAddedConsulation.contact_xx__c = cse.contactId; 
                 
        //rjn come back here
        this.displayAddNewDisp = true;
        return null;
    }
    */
    /* obsolete
    public Pagereference doAcceptParties() {
        currentConsultation.Parties_Accepted__c = true;
        update currentConsultation;
        this.initSectionState();
        debugLog('<font color=blue>In doAcceptPArties.. cons.parties_accepted__c='+currentConsultation.parties_accepted__c +' </font>');
        return null;
    }
    public Pagereference doAcceptAppliedResources() {
        currentConsultation.Applied_Resources_Accepted__c = true;
        update currentConsultation;
        this.initSectionState();
        debugLog('<font color=blue>In doAcceptAppliedResources.applied_resources_accepted__c='+currentConsultation.applied_resources_accepted__c +' </font>');
        return null;
    }
    public Pagereference doAcceptServiceDisp() {
        currentConsultation.Service_Disposition_Accepted__c = true;
        update currentConsultation;
        this.initSectionState();
        debugLog('<font color=blue>In doAcceptServiceDisp.service_disposition_accepted__c='+currentConsultation.service_disposition_accepted__c +' </font>');
        return null;
    }
    */
    /* moved to it's own page??
    public Pagereference doSaveNewDisp() {
        
        //userAddedConsulation.Case__c = this.cse.id;
        //userAddedConsulation.Subject__c = 'Service ' + string.valueOf(date.today());
        //userAddedConsulation.Consultation_Category__c = cse.Practice_Area__c + '_' +
                                                        cse.Problem_Category__c + '_' + cse.Problem_Code__c;
        //userAddedConsulation.last_contact__c = date.today();
        //userAddedConsulation.contact_xx__c = cse.contactId; 
                
        upsert userAddedConsulation;
        
        this.currentConsultation = userAddedConsulation;
        debugLog('in doSaveNewDisp.. currentConsultation='+this.currentConsultation);
        this.refreshCaseSummaryData();
        this.refreshConsultations();
        this.displayAddNewDisp = false;
        //this.isNewCase = false;
        return null;
    }
    */
    /* moved to it's own page?
    public Pagereference doSaveNewServiceNote() {
        
        Note n = this.newCaseConsultationNote.note;
        if(n.ParentId == null) {
            if(this.currentConsultation != null) {
                n.ParentId = currentConsultation.id;
            } else {                
                String msg = 'Add of new service note Failed.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,msg));   
                debugLog('unable to add new consulation note since no current consulation exists yet!'); 
                return null;            
            }
        }
        insert n;
        String msg = 'New Service Note Saved.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));   
            
        if(consultations != null && !consultations.isEmpty()) {
            this.caseConsultationNotes = caseUtils.retrieveCaseConsultationNotesWraps(this.cse);
            if(caseConsultationNotes != null && !caseConsultationNotes.isEmpty()) {
                this.displayCaseConsulationNotes = true;
                this.displayAddNewServiceNote = false;
            }
        }       
        return null;
    }
    */
    public pageReference doNothing(){
       // quickSaveAll();
        return null;
    } 
    /* obsolete? @ELC  
    public PageReference doReviewSubject() {
        debugLog('in doReviewSubject... caseSubjectIdReviewed='+ caseSubjectIdReviewed);
        this.caseSubjectReviewed = SubjectUtils.retrieveSubject(caseSubjectIdReviewed, false);
        this.renderSubjectViewComponent = true;
        return null;
    }
    */
    public PageReference doCancelNewCase() {
        if(cse!=null) {
            try {
                delete cse;
                debugLog('<font color=orange>deleted case:</font>');
            } catch (Exception e) {
                debugLog('<font color=red>EXCEPTION DELETING CASE:'+e+'</font>');
            }
        }
        return null;
    }
    
    public Pagereference doCancelNewCase2() {
        Contact clt = new Contact();
        if(cse!=null) {
            if (cse.contact != null) {
                clt = ContactUtils.retrieveAllContactInfo(cse.contactid);
            }
            try {
                delete cse;
                debugLog('<font color=orange>deleted case:</font>');
            } catch (Exception e) {
                debugLog('<font color=red>EXCEPTION DELETING CASE:'+e+'</font>');
            }
            if (clt != null) {
                List<String> cCategories = Utilities.getPlValues(clt.category__c);
      			// TODO-ELC find a better way of doing this - probably custom setting
                if (clt.nbr_of_case_party_associations__c == 0 && clt.nbr_of_case_client_associations__c == 0
                        && !(Utilities.doesListHaveValue(cCategories, 'Attorney') || Utilities.doesListHaveValue(cCategories,'Volunteer') || 
                        	Utilities.doesListHaveValue(cCategories,'Donor') || Utilities.doesListHaveValue(cCategories,'Rejected') )){
                            
                    // This record has no other associations and can be deleted
                    try {
                        delete clt;
                        debugLog('<font color=orange>deleted client:</font>');
                    } catch (Exception e) {
                        debugLog('<font color=red>EXCEPTION DELETING CLIENT:'+e+'</font>');
                    }
                }
            }
            
        }       
        return null;
    }

    /*
    public Pagereference doCancelArticleReview() {
        this.renderArticleReviewComponent = true;
        
        debugLog('in doCancelArticleReview');
        isCollapseFaqData = false;
        this.initSectionState();
        return null;        
    }
    */
    /**
     *
     * @TODO Doc.. rewrite of Knowledge subject stuff.
     */
    public PageReference doSelectSubject() {
        
        debugLog('<font color=blue> doSelectSubject actionId = '+actionId+' subjCseId = '+subjCseId+'</font>');
        if(actionId == null || actionId == '') {
            debugLog('<font color=red> in doSelectSubject actionId is null!! </font>');
            this.initSectionState();
            return null;
        }
        
        debugLog('<font color=orange> doSelectSubject actionId='+actionId + '</font>');
        caseSubjectIdSelected = actionId;
        
        // ELC - added following lines to pass case id to this function
        if(subjCseId == null || subjCseId == '') {
            debugLog('<font color=red> in doSelectSubject subjCseId is null!! </font>');
            this.initSectionState();
            return null;
        }
        debugLog('<font color=orange> doSelectSubject subjCseIdId='+subjCseId + '</font>');
        sourceCaseId = subjCseId;
        debugLog('doSelectSubject sourceCaseId = '+sourceCaseId+' this.cse.id = '+this.cse.id);
        // ELC - if this isn't the right case, return
        if(sourceCaseId == null || sourceCaseId != this.cse.id) {
            return null;
        } 
        Subject__c subj = SubjectUtils.retrieveSubject(caseSubjectIdSelected);
        //debugLog('sub retrieve='+subj);
        this.subjectClicked = subj;
        if(subjectClicked != null) {
            this.cse.subject = subjectClicked.title__c;
            this.cse.Selected_Subject__c = subjectClicked.id;
            Set<Id> subjectIds = new Set<Id>();
            Boolean alreadyApplied = false;
            
            for(Applied_Resource__c ar : this.appliedResources) {
                if((this.cse.selected_subject__c == ar.subject__c) && (ar.type__c == 'FAQ')) {
                    alreadyApplied = true;
                    break;
                }
            }
            // ELC - if the subject is being selected for a new case, there is no consultation yet
            // The applied resource will be created when the consultation is
            if(!alreadyApplied && (currentConsultation != null)) {
                    Id arId = arUtils.createAppliedResource(subjectClicked, cse, currentConsultation);
                    debugLog('in doSelectSubject  AR id created='+arId+' case = '+cse.id+'Consultation = '+currentConsultation);
                    this.refreshAppliedResources();
            }   
            debugLog('<font color=blue> UPDATING CASE</font>');
            if(isPreCase) {
                ProblemCodeWrapper subjPc = new ProblemCodeWrapper(subj);
                debugLog('<font color=green>Using Problem Codes from Subject to set case value</font>');
                cse.Practice_Area__c = subjPc.practiceArea;
                cse.Problem_Category__c = subjPc.problemCategory;
                cse.Problem_Code__c = subjPc.problemCode;
                cse.Jurisdiction__c = subjPc.jurisdiction;
            }           
            update this.cse;
            this.refreshCaseSummaryData();
            String msg = cse.Selected_Subject__r.name + ' applied to the case!';
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
            //this.displayCaseCustomPageMessage = true;  
            
        //  this.showSubjectSelectedMsgPanel = true;
            this.customPageMessageSeverityStyleClass = 'confirmM3';     
            this.customPageMessage = msg;
            
            //RJN check here
            if(isPreCase) {
                this.isCaseDetailEdit = true;
            }
            

            
        }
        if(isPreCase) {
            
            doSaveNewCase();
        }
        this.isPreCase = false;
        this.initSectionState();
        // this is where we need to initialize the case questions because we now know the subject
        // ELC - needed to comment this out for now because it put the # of SQL queries over the edge
       	//this.initCaseQuestions();
        
        return null;
}

    public Pagereference doConflictYes() {
        debugLog('in doConflictYes setting is conflict to true, yesConflictCliced to true, noConflictClicked to false, showConflictLogEntryPanel to true');
        this.isConflict = true;
        this.yesConflictClicked = true;
        this.noConflictClicked = false;
        this.showConflictLogEntryPanel = true;
        
        this.initConflictPanel();
        return null;
    }
    public Pagereference doConflictNo() {
        
        //this.isConflict = false;  
        this.yesConflictClicked = false; 
        this.noConflictClicked = true;
        this.showConflictLogEntryPanel = true;  
        
        this.initConflictPanel();
        return null;
    }
    public void initConflictPanel() {
        this.jsConflictProcess = 'return;';
        this.conflictLog = new conflict_log__c();   
        this.superAttorneys = this.retrieveSupervisors();
        this.prePopConflictLog();
        
        if(this.isConflict) {
            conflictLog.finding__c = 'Conflict of Interest';
            jsSaveOnCompleteMethod = 'doConflictYesRefresh()';
        } else if (!this.isConflict) {
            jsSaveOnCompleteMethod = 'doConflictNoRefresh()';
            conflictLog.finding__c = 'No Conflict of Interest';
            //conflictLog.reason__c = 'Former Client - Different Legal Issue';    
        }       
        if(this.contactIdBeingReviewed != null) {   
            if(casePartyClicked == null) {
                
                //this.casePartyClicked = caseUtils.retrieveCaseParty(ctrl.cpIdClickedFromClient);
                this.casePartyClicked = caseUtils.retrieveCaseParty(this.cse.id, this.contactIdBeingReviewed); 
                if(casePartyClicked != null) {
                    this.conflictLog.Case_Party_Type__c = casePartyClicked.type__c;
                    //this.conflictLog
                }
            }
            //debugLog('caseparty='+casePartyClicked);
        }
        this.isViewOnly = false;                    
        
    }
    public PageReference doNoConflictRefresh() {
        return new PageReference(this.reloadUrl);   
    }

    /*
    public PageReference doAddService() {
        
        this.doAddNewDisp();
        this.isUserAddingService = true;

        this.initSectionState();
        return null;
    }
    */
    public PageReference doAddServiceNew() {
        debugLog('In doAddServiceNew');
        this.isServiceEditNew = true;
        if(this.currentConsultation == null) {
            this.addConsultation();
        }

        this.isViewOnly = false;
        this.isRealEditMode = true;
        this.isCaseDetailEdit = true;
    
        
        this.cse.status = 'Open';
        
        update cse;
        
        this.refreshCaseSummaryData();
        
        jsAddNewService = 'if( isNoSfdcValErrors() ) { ';
        jsAddNewService += 'newSubTab(\'/apex/vfService?id=';
        jsAddNewService += currentConsultation.id;
        jsAddNewService += '&caseId=';
        jsAddNewService += cse.id;
        jsAddNewService += '&addingFromCase=true';
        jsAddNewService += '&isdtp=vw\',\'New Service\'); }';
        this.jsMainSaveOnCompleteMethod = jsAddNewService + 'reInitSubjects();';
        
        this.initSectionState();
//
        //return this.doEditDetail();
        
        return null;
    }
    public PageReference doAddServiceNew2() {
        debugLog('In doAddServiceNew2');
        this.isServiceEditNew = true;
        // elc 12/5 - the check that was being done in doAddServiceNew was NOT Being done here
        // could this be the cause of our duplicate services??  It was just set to null
        // in the calling method, but justin case...
        // elc 12/6 - I think that adding the check was causing a service to NEVER be added
        //  Don't know how current Consultation is anything other than NULL here though 
//        if (this.currentConsultation == null) {
        	this.addConsultation();
//        }

        this.isViewOnly = false;
        this.isRealEditMode = true;
        this.isCaseDetailEdit = true;
    
        //Boolean alreadyApplied = false;
            
        //for(Applied_Resource__c ar : this.appliedResources) {
        //    if((this.cse.selected_subject__c == ar.subject__c) && (ar.type__c == 'FAQ')) {
        //        alreadyApplied = true;
        //        break;
        //    }
       // }
        
        //if(!alreadyApplied && (currentConsultation != null)) {
        // ELC - if there are no applied resources yet, this must be a new case and we need to insert
		// This had been using the SubjectClicked variable, but was failing if the intake was
		// interuppted.  Now using the selected subject from the case
        if ((this.appliedResources == null || this.appliedResources.isEmpty()) && currentConsultation != null) {
        	if (this.cse.selected_subject__c != null) {
                Id arId = arUtils.createAppliedResource(SubjectUtils.retrieveSubject(this.cse.selected_subject__c), cse, currentConsultation);
                debugLog('in doSelectSubject  AR id created='+arId+' case = '+cse.id+'Consultation = '+currentConsultation);
        	}
        }   
        
        this.cse.status = 'Open';
        
        update cse;
        
        
        this.refreshCaseSummaryData();
        
        jsAddNewService = 'if( isNoSfdcValErrors() ) { ';
        jsAddNewService += 'newSubTab(\'/apex/vfService?id=';
        jsAddNewService += currentConsultation.id;
        jsAddNewService += '&caseId=';
        jsAddNewService += cse.id;
        jsAddNewService += '&addingFromCase=true';
        jsAddNewService += '&isdtp=vw\',\'New Service\'); }';
        this.jsMainSaveOnCompleteMethod = jsAddNewService + 'reInitSubjects();';
        
        this.initSectionState();
//
        //return this.doEditDetail();
        
        return null;
        
        //oncomplete="newSubTab('/apex/vfService?caseId={!cse.id}&isdtp=vw','New Service');"        
        
    }
    public Pagereference doSaveEditProblemCodeInfo() {
        this.isUserEditingProblemCode = false;
        debugLog('------in doSaveEditProblemCodeInfo----');
        //---ApexPages.currentPage().getParameters().put('newcase','false');

        this.isPreCase = false;
        this.isNewCase = false;
        this.isCaseDetailEdit = true;
        this.isServiceEditNew = true;
        this.detailViewOnlyMode = false;
        this.initSectionState();
        return null;
    }
    public Pagereference doSaveNewCase() {
        this.isNewCase = false;
        
        debugLog('------in doSaveNewCase ----');
                
        cse.start_it__c = true;
        cse.Left_Open__c = true;
        if(caseParties != null) {
            List<Id> contactIds = new List<Id>();
            for(Case_Party__c cp : caseParties) {
                if(cp.contact__c != null) {
                    contactIds.add(cp.contact__c);  
                }
            }
            if(!contactIds.isEmpty()) {
                List<Contact> cs = [select Id, status__c from Contact where Id in :contactIds];
                for(Contact c : cs ) {
                    c.status__c = 'Current';
                    c.temp_record__c = false;
                }
                debugLog('<font color=blue>UPDATING '+cs.size()+ ' contacts to a status of Current');
                update cs;
            }
        } else {
            debuglog('<font color=red> NO Case Parties found!</font>'); 
        }
        update cse;
        //----------------this.addConsultation();
        
        this.displayFaqs = true; 
        //this.refreshkArticles();
        this.refreshSubjects();
        this.isNewEditMode = true;
            
        this.isNewCase = false;
        //this.isNewEditMode = true;
        //Pagereference pr = this.doSaveAndContinueCurrentPage();
        //isRealEditMode = true;
        debugLog('---- in doSaveNewCase ---- ');
        this.isServiceEditNew = true;
        this.setIsProblemCodeInfoPopulated(this.getIsProblemCodeInfoPopulated());   
        /*
        this.jsAddNewService = 'newSubTab(\'/apex/vfService?id=';
        jsAddNewService += currentConsultation.id;
        jsAddNewService += '&caseId=';
        jsAddNewService += cse.id;
        jsAddNewService += '&addingFromCase=true';
        jsAddNewService += '&isdtp=vw\',\'New Service\');';
        */
        //this.jsMainSaveOnCompleteMethod = jsAddNewService;
        this.initSectionState(); 
        return null;
    } 
    
    public PageReference doAddPartySearch() {
        
       // slClient = SearchWrapper.getLatestSearchLog(UserInfo.getUserId());
       // debuglog('<font color=red> in doAddPartySearch: slClient='+slClient+'</font>');
        
         
        //if(slClient != null) {
            this.searchTabUrl = '/apex/vfIntakeSearch?fromCaseId='+cse.id+'&fromPage=vfCaseDetail_AddParty';
            this.searchTabLabel = 'Search: Add Party';    
            debuglog('<font color=red> in doAddPartySearch: searchTabUrl='+searchTabUrl+'</font>'); 
            //slClient.fromPage__c = 'vfCaseDetail_AddParty';
            //update slClient;
        //}       
        
        return null;    
    } 
    
    public PageReference doEditProblemCode() {
        this.isUserEditingProblemCode = true;
        ApexPages.currentPage().getParameters().put('newcase','true');
        this.wasEditProblemCodeBtnClicked = true;
        if(cse.Description !=null && cse.Description.length() == 1 && cse.Description == '.') {
            cse.Description = null;
        }     
        update cse;
        this.preCasePcWrap = new ProblemCodeWrapper(cse);
        
        this.constructorInitCode();
        doInitSubjectsForPcInfo();
        this.isPreCase = true;
        this.isNewCase = true;
        debugLog('--- IN doEditProblemCode() action');
        //this.initSectionState();
        this.wasEditProblemCodeBtnClicked = false;
        return null;
    }
    
    public PageReference doCancelAddServiceEdit() {
        if(currentConsultation != null && consultations != null 
                && consultations.size() > 1 && currentConsultation.disposition__c != null) {
            debugLog('<font color=purple> bypassing delete of current consultation in doCancelAddServiceEdit');
            this.refreshConsultations(); 
        } else {        
            if(currentConsultation != null && currentConsultation.status__c  != 'Closed') {
                try {
                    delete currentConsultation;
                } catch (Exception e) {
                    currentConsultation = null;
                    System.debug(logginglevel.warn,e);
                }
                debugLog('<font color=red>---- in doCancelAddServiceEdit... deleting currentConsulation which is.. '+this.currentConsultation + '</font>');
            } else {
                debugLog('<font color=orange>---- in doCancelAddServiceEdit bypassing delete of current consultation (only one total consultation) because its status__c is Closed</font>');
                
            }
            this.refreshConsultations();            
        }
        this.isServiceEditNew = false;
        if(currentConsultation !=null) {
            this.cse.status = 'Closed';
            update cse;
        }
        this.refreshCaseSummaryData();
        return doCancelEdit();
    }
    public PageReference doCancelEdit() {
        debugLog('------in doCancelEdit ----'); 
        this.isServiceEdit = false;
        this.isRealEditMode = false;
        this.isCaseDetailEdit = false;
        this.isViewOnly = true;
        //-------------------------------------this.constructorInitCode();
        
        
        //this.refreshkArticles();
        this.refreshSubjects();
        //this.displayRelatedFaqs = true;
        this.displayFaqs = true; 
        
        this.displayCaseParties = true;
        this.displayConsultations = true; 
        this.isUserAddingService = false;
        this.isRealEditMode = false;
        //this.isServiceEdit = true;
        this.initSectionState();
        return null;    
    } 
    public PageReference doSaveAndClose() {
        debugLog('------in doSaveAndClose ----');
        cse.Status = 'Closed';
        if(this.currentConsultation != null) {
            // ELC - following code added to send client satisfaction survey.  
            // sent only if a Legal Advice was given
            // Call is within the IF statement because the survey must be passed a service.  
            // This may need to be moved or even made into a batch process - 
            // hate multiple surveys to fire if there are several services done on the same day.
            Contact c = [select email, language__c from contact where id = :cse.contact.id];
            String emailAddr = c.email; 
   
            // Need to make sure that the email address isn't null.  May later need to add check to 
            // exclude a 'default' email address for those clients that don't have one.
            if (currentConsultation.Disposition__c != null && currentConsultation.survey_sent__c != true &&
                    currentConsultation.Disposition__c.equals('Legal Service') && emailAddr != null) {
                system.debug('calling sendEmailTemplate with cse.contact.id = '+cse.contact.id+' and service = '+this.currentConsultation.id+' and client lang = '+c.language__c);
                Boolean emailSent = false;
                if (c.language__c == 'Spanish') {
                	emailSent = Utilities.sendEmailTemplate('Client Satisfaction Survey - Spanish', cse.contact.id, this.currentConsultation.id);
                } else {
                	emailSent = Utilities.sendEmailTemplate('Client Satisfaction Survey', cse.contact.id, this.currentConsultation.id);                	
                }             
               if (!emailSent) {
                  System.debug('Email send failed in ctrlCaseDetail.doSaveAndClose, case: '+currentConsultation.case__r.casenumber);
                } else {
                	currentConsultation.survey_sent__c = true;
                }
            }
            
            try {
                currentConsultation.Status__c = 'Closed';
                update currentConsultation;
                //---- RJN Go and check for other opened services as well and close the suckers.
                if(consultations != null && !consultations.isEmpty()) {
                    List<Consultation__c> svcsToClose = new List<Consultation__c>();
                    for(Consultation__c svc : consultations) {
                        if(svc.Status__c != 'Closed') {
                            svc.Status__c = 'Closed';
                            svcsToClose.add(svc);
                        }
                    }
                    if(!svcsToClose.isEmpty()) {
                        debugLog('updating other services to closed as well'+svcsToClose);
                        update svcsToClose;
                    }
                }
                
                
            } catch (Exception e) {
                debugLog(e.getStackTraceString());
            }
            
        }
        update cse;
        
        
        //------------------this.constructorInitCode();
        this.isServiceEdit = false;
        this.isRealEditMode = false;
                
        this.displayFaqs = true; 
        this.displayCaseParties = true;
        this.displayConsultations = true; 
        this.isUserAddingService = false;
        this.isRealEditMode = false;
        this.isViewOnly = true;
        //this.isServiceEdit = true;
        this.initSectionState();
        return null; 
    }
    public PageReference doSaveAndContinueNewServicePage() {
        
        debugLog('------in doSaveAndContinueNewServicePage clearning out current consultation----');
        this.currentConsultation = null;
        this.doSaveAndContinueCurrentPage();
        //if(!isServiceEditNew) {
            this.doAddServiceNew2();
        //}

        debugLog('=== bottom of doSaveAndContinueNewServicePage... jsAddNewService='+jsAddNewService);
        if(cse.Selected_Subject__c != null && cse.Description != null) {
            actionCompleted = true;
        }
        return null;
        
    }
    public PageReference doSaveAndContinueCurrentPage() {
        debugLog('------in doSaveAndContinueCurrentPage ----cse.subject='+cse.subject);
        update cse;
        if(currentConsultation == null) {
            debugLog('------in doSaveAndContinueCurrentPage current cons is null attempting to retrieve ----');
            this.currentConsultation = caseUtils.retrieveCurrentCaseConsultation(cse);
            debugLog('in doSaveAndContinuteCurrentPAge... currentCons was null but is now='+this.currentConsultation);    
                                
        }
        if(cse.Problem_Code__c != null && cse.Problem_Category__c != '' 
            && this.currentConsultation == null) {
                if(cse.Subject == null  || cse.subject == '') {
                    String msg = 'Case subject must be selected!.';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,msg));   

                    return null;    
                }
                
                
                cse.start_it__c = true;
                cse.Left_Open__c = true;
                //this.doAddServiceNew2();
                
                //this.addConsultation();
                //this.doAddNewDisp();
                //this.jsMainSaveOnCompleteMethod='jqFocusConsPanel();';            
                //this.isServiceEdit = true;
                //this.isUserAddingService = true;
                debugLog('------in doSaveAndContinueCurrentPage setting serviceEdit to true.. bypassing constructorInit ----');
        } else {
            this.isServiceEdit = false;
            debugLog('------in doSaveAndContinueCurrentPage setting serviceedit to false  ----');
            //this.constructorInitCode();
        }
        
        this.displayFaqs = true; 
        this.displayCaseParties = true;
        this.displayConsultations = true; 
        this.isUserAddingService = false;
        this.isRealEditMode = false;
        this.isCaseDetailEdit = false;
        //this.isServiceEdit = true;
        this.initSectionState();
        return null;
    }

    public void refreshCaseSummaryData() {
        if(cse == null || cse.id == null) {
            return;
        }
        // RJN  changed to new method. this.cse = caseUtils.retrieveCaseSummaryData(cse.id);
        this.cse = caseUtils.retrieveCaseSummaryDataWithActivities(cse.id);
        if( cse!= null) {
            debugLog('refreshed case summary data!');
            if(cse.activityHistories != null) {
                this.doesCaseActivityHistoryExist = true;
            }       
            
        }           
    }

    public Pagereference doNotesRowSelect() {
        debugLog('doNotesRowSelect.. clickedRowId='+this.clickedNotesRowId);
        if(showExpandedNote){  
            showExpandedNote = false;  
        } else {  
            showExpandedNote = true;  
        } 
        return null;
        
    } 
    
    public Pagereference doSubjectTypeSelect() {
        debugLog('doSubjectTypeSelect.. status='+this.selectedSubjectType);
        this.refreshSubjects();
        return null;        
    }
    public Pagereference doPublishingStatusSelect() {
        debugLog('doPublishingStatusSelect.. status='+this.selectedPublishingStatus);
        //this.refreshkArticles();
        this.refreshSubjects();

        return null;
    }
    
    public List<Selectoption> getPublishingStatusOptions() {
         List<SelectOption> options = new List<SelectOption>(); 
         options.add(new SelectOption('All','All Statuses')); 
        options.add(new SelectOption('Online','Published')); 
        options.add(new SelectOption('Draft','Draft'));         
        return options;     
    } 
    public List<Selectoption> getSubjectTypeOptions() {
         List<SelectOption> options = new List<SelectOption>(); 
         options.add(new SelectOption('All','All')); 
         List<SelectOption> tempSos = UiUtils.retrievePlValues(new Subject__c(), 'type__c');
         for(SelectOption so : tempSos) {
            if(!'Pending'.equalsIgnoreCase(so.getValue())) {
                options.add(so);
            }  
         }            
        return options;     
    } 
    
    public List<Selectoption> getSubjectStatusOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('All','All'));
        List<SelectOption> tempSos = UiUtils.retrievePlValues(new Subject__c(), 'status__c');
   //     for(SelectOption so : tempSos) {
        	// ELC - New is not a value for status - delete this code after testing 
   //         if(!'New'.equalsIgnoreCase(so.getValue())) {
   //             options.add(so);
   //         }
   //     }
        options.addAll( UiUtils.retrievePlValues(new Subject__c(), 'status__c') ); 
        return options;     
    }  

    public PageReference doRemoveCaseParty() {
        Case_Party__c cp = caseUtils.retrieveCaseParty(this.selectedCpId);
        delete cp;
        String msg = 'Party successfully deleted!';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        this.refreshCaseParties();      
        return null;
    }
    public PageReference doRemoveAppliedResource() {
        Applied_Resource__c ar  = arUtils.retrieveAppliedResource(this.selectedAppliedResourceId);
        String arType = ar.type__c;
        String js = 'fireRemoveAppliedResource("'+arType+'");';
        this.jsRemoveArOnComplete  = js;
        delete ar;
        String msg = 'Applied Resource successfully deleted!';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        this.refreshAppliedResources();     
        return null;
    }
    public PageReference doRefreshCaseParties() {
        //-- Added a party to the case.. give msg to user..
        Integer cpOldSize = 0;
        if(this.caseParties != null) {
            cpOldSize = caseParties.size();
        }       
        debugLog('refreshing case parties');
        this.refreshCaseParties();
        Integer cpNewSize = 0;
        if(this.caseParties != null) {
            cpNewSize = caseParties.size();
        }
        String msg = '';
        debugLog('cpOldSize='+cpOldSize+'...cpNewSize='+cpNewSize);
        if(cpNewSize > cpOldSize) {
            
            if(cpNewSize - cpOldSize > 1) {
                msg +='Parties were';
            } else {
                msg +='A Party was';
            }
            msg+=  ' successfully added to your case.';

            this.displayCaseCustomPageMessage = true;   
            this.showPartyMsgPanel = true;          
            this.customPageMessageSeverityStyleClass = 'confirmM3';     
            this.customPageMessage = msg;
        }
            
        return null;
    }
    public PageReference doRefreshAppliedResourcesAfterSelected() {
        this.refreshAppliedResources();
        String msg = 'Resource successfully applied to the case!';
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        this.displayCaseCustomPageMessage = true;        
        this.showResourceAppliedMsgPanel = true;
        this.customPageMessageSeverityStyleClass = 'confirmM3';     
        this.customPageMessage = msg;
        
        this.jsRefreshArOnComplete = '';
        
        if(this.actionId != null) { 
            Id ddpId = actionId;
            debugLog('retrieving ar with ddpid='+ddpId);
            Applied_Resource__c ar = ArUtils.retrieveAppliedResource(this.cse, ddpId);
            
            if(ar!=null) {
                this.lastArApplied= ar;
                if(ar.Type__c == 'DDP') {
                    Loop__DDP__c ddp = DDPUtils.retrieveDdp(ddpId);
                    String ddpAutoNumId = ddp.Ddp_Id__c;
                    String ddpTitle = ddp.title__c;
                    this.jsRefreshArOnComplete = 'initDdpProcess("'+ddpId+'","'+ar.id+'","'+ddpAutoNumId+'","'+ddpTitle+'");';
                    actionId = null;
                } else  {
                    
                    
                }
            }
        }
        
        return null;    
    }
    public PageReference doClearCustomPageMessages() {
        this.customPageMessage = null;
        this.displayCaseCustomPageMessage = false;
        this.showServiceMsgPanel = false;
        this.showPartyMsgPanel = false;
        return null;
    }
    
 
    public Boolean getIsIncompleteServices() {
        return  incompleteServices != null && !incompleteServices.isEmpty();
    }
    private void findIncompleteServices(List<Consultation__c> pConsultations) {
        Boolean foundOne = false;
        mIncompleteServiceId_Service = new Map<Id,Consultation__c>();
        for(Consultation__c service : pConsultations) {
            if(service.Is_Incomplete_Service__c) {
                if(this.incompleteServices == null) {
                    incompleteServices = new List<Consultation__c>();   
                }
                foundOne = true;
                incompleteServices.add(service);
                mIncompleteServiceId_Service.put(service.id,service);
            }
        }

        debugLog('in findIncompleteServices found an incomplete Service='+foundOne);
    }
    private void refreshConsultations(){
        this.consultations = caseUtils.retrieveConsultations(this.cse);
        if(consultations != null && !consultations.isEmpty()) {
            this.findIncompleteServices(consultations);
        }
        if(consultations == null) {
            String msg = 'There are no consulations for this case.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,msg));            
        }
        if (consultations != null && consultations.size() > 1) {
            /*
            for(consultation__c c: consultations) {
                if(c.disposition__c == null || c.disposition__c.trim() == ''){
                    currentConsultation = c;
                    break;
                }
            }
            */
            /*
            Just pull the current consultation by the latest date. (it's soreded created date desc)
            @TODO change this is it's dangerous.
            */
            currentConsultation = consultations[0];
            
            
        } else if(consultations!=null && consultations.size() == 1){
            currentConsultation = consultations[0];
        }
        if (currentConsultation != null && currentconsultation.id != null) {
            currentConsultationNotes = [SELECT id, ParentId, Title, Body, CreatedDate, createdById, createdBy.Name FROM Note WHERE ParentId = :currentConsultation.Id ORDER BY CreatedDate]; 
        }
        
        if(consultations != null && !consultations.isEmpty()) {
            this.caseConsultationNotes = caseUtils.retrieveCaseConsultationNotesWraps(this.cse);
            if(caseConsultationNotes != null && !caseConsultationNotes.isEmpty()) {
                this.displayCaseConsulationNotes = true;
            }
            //refreshConsultationArticles();
        }
        
    } 

    public void refreshAppliedResources() {
        List<al.OrderBy> lOrderBy = new List<al.OrderBy> {
                            new al.OrderBy('createdDate').descending().nullsLast()
                        };      
        this.appliedResources = arUtils.retrieveAppliedResources(this.cse,lOrderby); 
    } 
    public void refreshCaseAttachments() {
        this.caseAttachments = caseUtils.retrieveCaseAttachments(this.cse);
        if(this.caseAttachments == null || caseAttachments.isEmpty()) {
            if(caseUtils.debugMessages != null && !caseUtils.debugMessages.isEmpty()) {
                String msg = '';                
                for(DebugMessage d : caseUtils.debugMessages ) {
                    debugLog(d.message);
                }
            } else {
                debugLog('# of Case Attachments retrieved: 0'); 
            }
        } else {
            debugLog('<font color=green># of Case Attachments retrieved:'+caseAttachments.size()+'</font>');    
        }
    }
    public void refreshCaseReviews() {
        // ELC - changed this to reference the new CaseReviewUtils class
        // status passed is Published for those unable to add case reviews
        if (displayAddNewReview == true) {
            this.caseReviews = caseReviewUtils.retrieveCaseReviews(this.cse, 'ALL');
        } else {
            this.caseReviews = caseReviewUtils.retrieveCaseReviews(this.cse, 'Published');
        }
        
        if(this.caseReviews == null) {
            if(caseUtils.debugMessages != null && !caseUtils.debugMessages.isEmpty()) {
                String msg = '';                
                for(DebugMessage d : caseUtils.debugMessages ) {
                    debugLog(d.message);
                }
            }
        }
    } 
    public void refreshCaseSurveys() {
        // this was causing an error - too many SQL queries.  Will need to get around. 
        this.caseSurveys = caseUtils.retrieveSurveysByCase(this.cse);
    }
    /**
     *  Refresh the subject List for all subjects of FAQ recordtype, the
     *  selected publishings status, and the problemcode wrapper.
     *
     *  @TODO change algorith that pushes selected subject to the top.. very bad performing..
     */
    public void refreshSubjects() {     
        //string publishStatus = this.selectedPublishingStatus;     
        //String subjectType = this.selectedSubjectType;
        
        ProblemCodeWrapper pcWrap; 
        if(this.isPreCase) {
            pcWrap = this.preCasePcWrap;
            debugLog('in doRefreshSubject..Using precase problem code wrapper');    
        } else  {
            debugLog('in doRefreshSubject..Using case object saved problem code wrapper info'); 
            pcWrap = new ProblemCodeWrapper(this.cse);
        }
        //debugLog('calling retrieveSubjects with pcWrap='+pcWrap+ ' ... rt=FAQ....status='+publishStatus);
        //debugLog('calling retrieveSubjects with pcWrap='+pcWrap+ ' ... rt=FAQ....type='+subjectType);
        String status = 'Active';
        if(!this.showActiveSubjects) {
            status = 'Archived';
        }
        debugLog('calling retrieveSubjects with pcWrap='+pcWrap+ ' ... rt=FAQ....status='+status);
        this.relatedSubjects = SubjectUtils.retrieveSubjects( pcWrap, 'FAQ', status);   
        
        If(relatedSubjects != null && !relatedSubjects.isEmpty()) {
            
            
        
            String msg = 'In refreshSubjects.. relatedSubjects size='+relatedSubjects.size();
            debugLog('\n<font color=orange>'+msg+'</font>');
            
            
            
        } else {
            if(SubjectUtils.debugMessages != null) {
                for( String msg : SubjectUtils.debugMessages) {
                    debugLog('\n<font color=red>'+msg+'</font>');
                }
            }           
        }
        /*
         * @TODO replace with real comparable sort as this is not a good performer.
         * Poor man sort in liu of creating a wrapper class with a comparable interface
         * to push the selected subject to the top. @TODO Why isn't display updating???
         */
         if(relatedSubjects!=null && !relatedSubjects.isEmpty() & cse.selected_subject__c != null) {
            List<Subject__c> tmpSubjects = new List<Subject__C>();
            Boolean bPushed = false;
            for(Subject__c s : relatedSubjects) {
                if(cse.Selected_Subject__c == s.id) {
                    tmpSubjects.add(s);
                    bPushed = true;
                    debugLog('<font color=orange>PUSHED SELECTED SUBJECT TO THE TOP!</font');
                    break;
                }
            }
            if(bPushed) {
                for(Subject__c s : relatedSubjects) {
                    if(s.id != cse.selected_subject__c) {
                        tmpSubjects.add(s);
                    }
                }
                relatedSubjects.clear();
                relatedSubjects = tmpSubjects;
            }
         }
            
        //relatedSubjects.clear();
    }

    public Pagereference doAbortCase() {
        debugLog('aborting case... not doing anything yet');
        return null;
    } 
    public Pagereference doContinueToSearch() {
        debugLog('continuing to search (after no conflicts found)');
        
        if(slClient != null) {
            if(slClient.fromPage__c != 'vfCaseDetail_AddParty') {
                slClient.fromPage__c = 'vfCaseDetail';
            }
            slClient.Marked_as_Match__c = 'Yes'; //rjn double check this!
            update slClient;
        }
        return null;
    }
    public Pagereference doContinueToClient() {
        debugLog('continuing to client. (after no conflicts found)');
        if(slClient != null) {
            slClient.fromPage__c = 'vfCaseDetail';
            slClient.Marked_as_Match__c = 'Yes'; //rjn double check this!
            update slClient;
        }
        return null;
    }
    public PageReference doAddNewSubject() {
        this.renderArticleCreateComponent = true;
        this.renderSubjectCreateComponent = true;
        this.newSubject = new Subject__c();
        this.newSubject.status__c = 'Active';
        this.newSubject.type__c = 'Pending';
        ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(this.cse);
        if(pcWrap != null) {
            this.newSubject.practice_Area__c = pcWrap.practiceArea;
            this.newSubject.problem_category__c = pcWrap.problemCategory;
            this.newSubject.problem_Code__c = pcWrap.problemCode;
            this.newSubject.jurisdiction__c = pcWrap.jurisdiction;
            //this.isPreCase = false;
        }
        this.initSectionState();
        return null;
        
    }
    public PageReference doAddNewCaseReview() {
        this.renderCaseReviewCreateComponent = true;
        this.newCaseReview = new Case_Review__c();
        this.newCaseReview.case__c = this.cse.id;
        this.newCaseReview.service__c = this.serviceIdForReview;
        // ELC - TODO change this - bad way to do the defaults, but I'm not sure how else to 
        // get them to appear before the insert
        this.newCaseReview.review_status__c = 'Final';
        this.newCaseReview.review_code__c = 'No Note';
        this.newCasereview.reviewed_by__c = UserInfo.getUserId();
        this.initSectionState();
        return null;
    }
    
    public pageReference addConsultation() {
        update this.cse;
            
        currentConsultation = caseUtils.buildConsultation(this.cse);
        insert currentConsultation;

        currentConsultationNotes = new List<Note>();

        newConsultationNote = new Note();
        this.refreshConsultations();
        //this.rerefreshkarticles();
        //refreshreferrals();
        return null;
    }   
    public void refreshConflictLogs() {
        this.conflictLogs = caseUtils.retrieveContlictLogs(this.cse);   
    }  
    public void refreshCaseParties() {
        this.caseParties = caseUtils.retrieveCaseParties( this.cse );
    } 

    
    public void refreshPossibleCaseConflicts() {
        this.displayCaseParties = true;
        this.displayCaseCustomPageMessage = true;
        this.displayConflictButtons = true;
        this.displayConflictLogs = true;
        this.displayConsultations = true;
        customPageMessageSeverityStyleClass = 'warningM3';
                
        this.possibleCaseConflicts = caseUtils.retrievePossibleCaseConflicts(slId, searchType);
        if(this.possibleCaseConflicts != null && !this.possibleCaseConflicts.isEmpty()) {
            this.currentConflict = possibleCaseConflicts[0];
        } else {
            this.currentConflict = null;
        }
        //.possibleConflictingCasePartyRecords(contactIdBeingReviewed, searchType);
        debugLog('----conflicting case records:'+possibleCaseConflicts);        
    }
    
    public void refreshPotentialConflicts() {
          
        this.displayCaseParties = true;
        this.displayCaseCustomPageMessage = true;
        this.displayConflictButtons = true;
        this.displayConflictLogs = true;
        this.displayConsultations = true;
        customPageMessageSeverityStyleClass = 'warningM3';
                
        this.possibleConflictingCaseParties = caseUtils.possibleConflictingCasePartyRecords(contactIdBeingReviewed, searchType);
    
        debugLog('----conflicting caseparty records:'+possibleConflictingCaseParties);

        
    }   
    public Case_Party__c checkForMoreConflictingCaseParties() {
        Case_Party__c newConflict;
        if(this.possibleConflictingCaseParties != null && !this.possibleConflictingCaseParties.isEmpty()) {
            newConflict  = possibleConflictingCaseParties[0];
            //this.cse = caseUtils.retrieveCaseSummaryData(cp.case__c);
            //this.cse = (Case)new ApexPages.StandardController(possibleConflictingCaseParties[0]);
            //this.constructorInitCode();
            //hasMore = true;
        }
        return newConflict;
    }


    /**
     * Retrieve the users latest search log and associated that with the new 
     * conflict log.
     */ 
    private void prePopConflictLog() {
    	// ELC 10/27/16 added SearchLogChildren to get accurate information
        Search_Log__c sl = SearchWrapper.getLatestSearchLog(UserInfo.getUserId() );
        
        Search_Log_Children__c slc = SearchWrapper.getLatestSearchLogChild(UserInfo.getUserId() );
        
        if (slc != null && sl != null && slc.client_search_log__c == sl.id) {
        	// we have a search log client, so last search was a party search
            this.searchedClientName = sl.first_name__C + ' ' + sl.last_name__c;
            conflictLog.Search_Log__c = sl.id;
            this.conflictSearchLog = sl;
            this.conflictLog.SearchContactReviewed__c = slc.party_reviewed__c;
            //RJN copy FF to Text field to ensure value is saved after SL deleted.
            this.conflictLog.Potential_Client_Text__c = sl.First_Name__c + ' '  + sl.Last_Name__c;
            this.conflictLog.Association_Text__c = slc.Association__c;         	
        } else if(slc!=null) {
            this.searchedClientName = sl.first_name__C + ' ' + sl.last_name__c;
            conflictLog.Search_Log__c = sl.id;
            this.conflictSearchLog = sl;
            this.conflictLog.SearchContactReviewed__c = sl.contact_reviewed__c;
            //RJN copy FF to Text field to ensure value is saved after SL deleted.
            this.conflictLog.Potential_Client_Text__c = sl.First_Name__c + ' '  + sl.Last_Name__c;
            this.conflictLog.Association_Text__c = sl.Association__c;   
            //-----




        } else {
            debugLog('-- no search log to use to prepopConflictLog');       
        }
        
        debugLog('prepoping conflict log cl='+conflictLog);
        
        //debugLog('conflict log built='+conflictLog);      
    }



    
    /**
     *  Get list of carpls supervisor attorney user records
     *  so we can show them in the picklist (if required)
     */
     private List<User> retrieveSupervisors() {
        String profileName = 'CARPLS Supervising Attorney';
        String userName = 'Al Schwartz';

        Profile p = UserUtils.getProfileByName(profileName);
        //User u = UserUtils.retrieveUserByName(userName);
        User u = [SELECT Id, isActive, Name FROM User WHERE Name = :userName LIMIT 1];
        
        if( p == null) { return null; }
        //List<User> supers = UserUtils.getUsersByProfileId(p.id);
        List<User> supers = [SELECT Id, isActive, Name FROM User WHERE ProfileId = :p.Id];
                
        List<User> activeSupers = new List<User>();
        for (User au: supers) {
            if (au.isactive) {
                activeSupers.add(au);
            }
        }
             
        if(u != null) {
            if (u.isactive) {
                activeSupers.add(u);
            }
        }
              
        
        
        //debugLog('supervisors='+supers);
        return activeSupers;
    }
    public Boolean getIsProblemCodeInfoPopulated() {
        if(this.wasEditProblemCodeBtnClicked) {
            return false;
        }
        
        Boolean isIt = false;
        if(this.cse != null) {
            if(cse.Problem_Code__c != null && cse.Problem_Code__c != '') {
                isIt = true;
            }
        }
        this.isProblemCodeInfoPopulated = isIt;
        return isIt;
    }   
    public void setIsProblemCodeInfoPopulated(Boolean b) {
        this.isProblemCodeInfoPopulated = b;
    }
    /**
     *  Carpls supervising attorneys.
     *
     */
    public List<SelectOption> getApproverOptions() {
        if(this.superAttorneys == null) { return null; }
        List<SelectOption> options = new List<SelectOption>();
        for(User u : superAttorneys) {
            Selectoption so = new SelectOption(u.id, u.name);
            options.add(so);
        }
        return options;
    }
    /**
     *  @TODO TRY TO USE RECORD TYPE TO MAKE MORE DYNAMIC
     *
     */
    public List<SelectOption> getReasonOptions() {
        List<SelectOption> validOptions = new List<SelectOption>();
        Boolean conflict = false;
        conflict = this.isConflict;
        RecordType rt = new RecordType();
        
        if (conflict) {
            rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Conflict_Log__c', 'Conflict');
        } else {
            rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Conflict_Log__c', 'No_Conflict');
        }
        debugLog('In getReasonOptions, rt = '+rt);
        // This doesn't work because VF/Apex query will not respect record types - Salesforce limitation
        //List<SelectOption> options = UiUtils.retrievePlValues(new Conflict_Log__c(), 'Reason__c', rt);
        List<SelectOption> options = UiUtils.retrievePlValues(new Conflict_Log__c(), 'Reason__c');
        for(SelectOption so : options) {
            String val = so.getValue();
            if(conflict) {
                if(!'Former Client - Unrelated Legal Issue'.equalsIgnoreCase(val) 
                && !'Existing Adverse Party - Unrelated Legal Issue'.equalsIgnoreCase(val)
                && !'Former CARPLS Staff/Volunteer/Law Firm'.equalsIgnoreCase(val)
                && !'Former Legal Services Partner'.equalsIgnoreCase(val)) {
                    validOptions.add(so);
                }
            } else {
                if('Former Client - Unrelated Legal Issue'.equalsIgnoreCase(val) 
                || 'Existing Adverse Party - Unrelated Legal Issue'.equalsIgnoreCase(val)
                || 'Former CARPLS Staff/Volunteer/Law Firm'.equalsIgnoreCase(val)
                || 'Former Legal Services Partner'.equalsIgnoreCase(val)) {
                    validOptions.add(so); 
                }           	
            }
        
        }
        return validOptions;
        //return options;        
    }   
    public Boolean evalIsServiceComplete(Consultation__c c) {
        Boolean isComplete = false;
        if(c != null) {
            isComplete = c.Project__c != null && c.Location__c != null && c.Service_Code__c != null && c.disposition__c != null
                         && c.Follow_Up_Public_Group__c != null;            
        }
        return isComplete;
    }
    /**
     * Insert the conflict log.
     * Refresh the parent controller conflict logs related list.
     */
    public Pagereference doAddConflictLog() {
    
        try{
            conflictLog.Case__c = this.cse.id;
            conflictLog.contact__c = this.cse.ContactId;
            //conflictLog.Contact__c = ctrl.cpIdClickedFromClient;
            if(!this.isConflict) {
                conflictLog.approved_by__c = selectedApproverVal;       
            } else {
                conflictLog.Reason__c = this.selectedReasonVal;
            }
            debugLog('<font color=\'blue\'>Inserting Conflict Log..'+conflictLog+'</font>');
            insert this.conflictLog;

            //----------RJN REally need to review what this is doing?
            if(conflictLog.Search_Log__C != null) {
                this.conflictLogsAdded = caseUtils.retrieveConflictLogsBySearchLogId(conflictLog.Search_Log__c);
            } else {
                this.conflictLogsAdded = caseUtils.retrieveConflictLogs(conflictLog.id);
                // ---------
            }
            
            this.displayConflictLogsAdded = true;
            //ctrl.conflictLogsAdded.add(conflictLog);
            //String msg = 'The conflict record: '+conflictLog.name + ' has been successfully logged';
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
            this.displayCaseCustomPageMessage = false;  
            
            //update case party record.
            Boolean isItAConflict = this.isConflict;

                String status = '';
                if(isItAConflict) {
                    status = 'Yes';
                } else {
                    status = 'No';
                }
                this.currentConflict.marked_conflict__c = status;
                update this.currentConflict;
//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'isItAConflict='+isItAConflict));       
  
                if(isItAConflict) {

                    this.yesConflictCompleted = true;
                    this.showConflictLogEntryPanel = false;
                    this.displayCaseCustomPageMessage = true;
                    this.displayConflictButtons = false;
                    return null;
                } 
//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'isItAConflict='+isItAConflict));       
                
                
        //--ctrl.customPageMessageSeverityStyleClass = 'infoM3';
                    
        } catch (DmlException e) {
                String msgSDF = 'DML EXX';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));     
            debugLog(e.getMessage() );
        }
        this.refreshConflictLogs();
        // seek out more cases.. 
        this.showConflictLogEntryPanel = false;
        this.refreshPossibleCaseConflicts();
        if(this.currentConflict != null) {
            
            String url = '/apex/vfCaseDetail?id='+this.currentConflict.case__c;
            url+='&tempCase=false&review=true';
            url+='&potentialConflict=true';
            url+='&contactBeingReviewed='+this.currentConflict.contact_being_reviewed__c;
            url+='&searchType='+this.searchType;
            url+='&slId='+this.slId;
            String msg4 = 'new url:'+url;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,msg4));
                debugLog('-- no casepartyrecord updated');  
            return new Pagereference(url).setRedirect(true);        
        } else {
                if(this.searchType == 'Client') {
                    try {
                        Search_Log__c sl = SearchWrapper.retrieveSearchLog(this.slId);
                        debugLog('sl = '+sl);
                        updateSearchLogMatchStatus('Yes',sl.id,sl.Contact_Reviewed__c,'Client');
                        Contact clientReviewed = ContactUtils.retrieveAllContactInfo(sl.contact_reviewed__c);
                        Integer iCpAttorneyAssoc = Integer.valueOf(clientReviewed.Nbr_of_Case_Attorney_Associations__c);
                        Integer iCpClientAssoc = Integer.valueOf(clientReviewed.Nbr_of_Case_Client_Associations__c);
                        Integer iCpPartyAssoc = Integer.valueOf(clientReviewed.Nbr_of_Case_Party_Associations__c);
                        
                        if(iCpPartyAssoc > 0 && (iCpAttorneyAssoc > 0 || iCpClientAssoc >0)){
                            debugLog('<font color=blue>Client:'+clientReviewed.name + ' has multiple case party associations.. iCpPartyAssoc:'+iCpPartyAssoc + ' iCpClientAssoc:'+iCpClientAssoc + ' iCpAttorneyAssoc:'+ iCpAttorneyAssoc + '</font>') ;
                            contactHasMultipleCpAssoc = true;
                        }
                        
                        
                    }catch (Exception e) {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));                                     
                    }
                }
                if(this.searchType == 'Party') {
                    Search_Log_Children__c slc = SearchWrapper.retrieveSearchLogChild(this.slId);
                    updatePartySearchLogMatchStatus('Yes', slc);
                }

            //this.jsConflictProcess = 'alert("There are no more possible conflicts.. need code to go to search")';
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'DEBUG!!!! No more possible conflicts close window redirect to search!'));                  
            this.displayConflictLogsAdded = true;
            this.showConflictLogEntryPanel = false;
            this.displayConflictButtons = false;
            this.noConflictCompleted = true;
            /*
            Per Al per defect 00006356
            
            When performing a Client Search which results in a match to an existing record 
            with multiple case associations (ie Client, AP, IP), if and when the user makes 
            it through the conflict analysis with no conflict findings – 
            the user should navigate to the existing Contact Record rather 
            than back to the Search. From the Contact record, the user could open a 
            further service on an existing Client case or select the Add Case button 
            from the Contact record to add a new Case. If the Add Case button is
            selected the user would navigate back to the Search feature per current functionality.                  
            */
            //1. determine 
            

        }
        

        
        
        return null;
    }
    public void refreshFeedItemWrappers() {
        this.feedItemWrappers = ChatterUtils.retrieveFeedItemWrappersByParentId(cse.id);
        Integer size = 0;
        if(feedItemWrappers != null) {
            size = feedItemWrappers.size();
        }
        debugLog('feedItemWrappers retrieved sized='+size);
    }
    public void refreshContentVersionWrappers() {
        this.contentVersionWrappers = ChatterUtils.retrieveContentVersionWrappersByCaseId(cse.id);
        Integer size = 0;
        if(contentVersionWrappers != null) {
            size = contentVersionWrappers.size();
        }
        debugLog('contentVersionWrappers retrieved sized='+size);
    }
    
     public PageReference doDeleteDoc() {
        super.debugLog('<b>doDeleteDoc=</b>' + selectedId+ '<br/>');
        Id contentVersionId = selectedId;
        //Id feedItemId = selectedId;
        //FeedItem fiToDel = [select id,contentFileName,relatedRecordId from feeditem where id = :feedItemId];
        //Id relatedRecordId = fiToDel.RelatedRecordId;
        
        ContentVersion cv = [select id, contentdocument.id, title
                             from ContentVersion cv 
                             where cv.isLatest = true 
                             and cv.id = :contentVersionId limit 1];
        Id contentDocumentId = cv.ContentDocumentId;
        try {                    
            ContentDocument cd = [select id from ContentDocument where id = :contentDocumentId limit 1];
            delete cd;      
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
        }
        String msg = 'Attachment: '+ cv.title + '  deleted successfully!';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        this.refreshContentVersionWrappers();
        
        
        return null;
    }

     public PageReference doDeleteAttachment() {
        super.debugLog('<b>doDeleteAttachment=</b>' + selectedId+ '<br/>');
        Id attachmentId = selectedId;
         
        Attachment attachmentToDel = [select id,name from Attachment where id = :attachmentId];

        try {                               
            delete attachmentToDel;     
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
            return null;
        }
        String msg = 'Attachment: '+attachmentToDel.name + '  deleted successfully!';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        this.refreshCaseAttachments();      
        return null;
    }    
    public PageReference doDownloadDoc() {
        String url = '';
        //url += '/sfc/servlet.shepherd/version/download/' + this.selectedId + '?asPdf=false&operationContext=CHATTER';
        url += '/sfc/servlet.shepherd/version/download/' + this.selectedId + '?asPdf=false';
        Pagereference pr = new Pagereference (url);
        String msg = 'File Download Initiated';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        return pr;      
    }   
    public PageReference doCreateSubject() {
        debugLog('in do createSubject');

        if(this.newSubject != null) {
            newSubject.title__c = this.newSubjectTitle;
            debugLog('<font color=blue>Attempting to insert subject:'+newSubject+ '</font>');
            Id newSubjectId = SubjectUtils.createSubject(newSubject);
                        
            debugLog('in do createSubject.. id created='+newSubjectId);
           // this.faqKav = kUtils.retrieveFaq(kFaqId, true);
            Subject__c subjectCreated;  
            if(newSubjectId != null) {
                subjectCreated = SubjectUtils.retrieveSubject(newSubjectId);
                Id arId = arUtils.createAppliedResource(subjectCreated, this.cse, this.currentConsultation);
                debugLog('<font color=blue> in doCreateSubject creating applied resource. id created='+arId + '</font>');
                cse.Subject = subjectCreated.title__c;
                cse.Selected_Subject__c = subjectCreated.id;
                update cse;
                this.selectedPublishingStatus = 'All';
                this.refreshCaseSummaryData();
                this.refreshSubjects();
                /**
                 * @TODO RJN not functioning below but figure out a way to add a new subject in precase mode and have it act
                 * as if they selected an existing subject in precase mode.
                 */
                //if(isPreCase) {
                    jsCloseNewSubjectMethod += 'jsSelectSubject(\''+cse.Selected_Subject__c+'\',\''+cse.id + '\');';
                  //  jsCloseNewSubjectMethod += 'jsSelectSubject(\''+cse.Selected_Subject__c + '\');';
                //}
                //if(isPreCase) {
                //  isCaseDetailEdit = false;
                //}
                this.jsCloseNewSubjectMethod  += 'closeNewSubjectDialog();';
                debugLog('jsCloseNewSubjectMethod = '+jsCloseNewSubjectMethod);
                //this.isPreCase = false;
            }
        }

        return null;
    }   
    public Pagereference doCancelCreateSubject() {
        //this.doInit();
        //ctrl.renderArticleCreateComponent = false;
        this.renderSubjectCreateComponent = false;
        return null;
    }   
    
    public PageReference doCreateCaseReview() {
    
        debugLog('in doCreateCaseReview');

        if(this.newCaseReview != null) {
            debugLog('<font color=blue>Attempting to insert case review:'+newCaseReview+ '</font>');
            
            Id newCaseReviewId = CaseReviewUtils.createCaseReview(newCaseReview);
        
            debugLog('in do createCaseReview.. id created='+newCaseReviewId);
           
            Case_Review__c caseReviewCreated;  
            if(newCaseReviewId != null) {
                caseReviewCreated = CaseReviewUtils.retrieveCaseReview(newCaseReviewId);
                
                this.refreshCaseReviews();
               
                        
            }
        }

        return null;
    }   
    public Pagereference doCancelCreateCaseReview() {
        
        this.renderCaseReviewCreateComponent = false;
        return null;
    } 
    public List<SelectOption> getSubjectRecordTypeOptions() {
        List<RecordType> rts = Utilities.retrieveSObjectRecordTypes('Subject__c',null);
        List<SelectOption> options = new List<SelectOption>();
        if(rts != null && !rts.isEmpty()) {
            for(RecordType rt: rts) {
                options.add(new selectOption(rt.name, rt.name)); 
            }
        }
        return options;
    }
    public PageReference doShowActiveSubjects() {
        this.showActiveSubjects = true;
        debugLog('in doShowActiveSubjects() setting showActiveSubjects = true');
        this.refreshSubjects();
        return null;
    }
    public PageReference doShowArchivedSubjects() {
        this.showActiveSubjects = false;
    
        debugLog('in doShowArchivedSubjects() setting showActiveSubjects = false');
        this.refreshSubjects();
        return null;    
    }

    public Pagereference doCheckForOrphanedService() {
         debugLog('in doCheckForOrphanedService()');
        return null;
    }
    /*
     *  RJN TABX service del custom msg
     */
    public Pagereference doIncompleteServiceRemoved() {
 		String msg = 'An incomplete service was successfully deleted.';
 		this.displayCaseCustomPageMessage = true;   
        this.showServiceMsgPanel = true;          
        this.customPageMessageSeverityStyleClass = 'confirmM3';     
        this.customPageMessage = msg;
        return null;    	
    }
    
    public Pagereference doServiceSaved() {
        debugLog('SERVICE SAVED service object id:'+this.serviceSubTabObjectId + ' action: '+this.serviceSubTabAction);
        ApexPages.currentPage().getParameters().put('newCase','false');
        ApexPages.currentPage().getParameters().put('review','true');
        this.constructorInitCode();
        
        Consultation__c svc;
        if(serviceSubTabObjectId != null && serviceSubTabObjectId != '') {
            try {
                svc = CaseUtils.retrieveConsultation(serviceSubTabObjectId);
            }  catch (Exception e) {
                
            }
            if(svc != null) {
                String msg = 'Service ';
                msg += svc.Name;
                if(serviceSubTabAction == 'Edit') {
                    msg+= ' edited ';
                } else {
                    msg+= ' created ';
                }
                msg += ' successfully.';
                this.displayCaseCustomPageMessage = true;   
                this.showServiceMsgPanel = true;          
                this.customPageMessageSeverityStyleClass = 'confirmM3';     
                this.customPageMessage = msg;
            }
        }
        
            
        return null;
    }
    public Pagereference doServiceCancelled() {
        debugLog('SERVICE CANCELLED service object id:'+this.serviceSubTabObjectId + ' action: '+this.serviceSubTabAction);
        /*
        this.isViewOnly = true;
        this.displayCaseParties = true;
        this.displayConsultations = true;
        this.displayFaqs = true;  
        this.initSectionState();
        */
        ApexPages.currentPage().getParameters().put('newCase','false');
        ApexPages.currentPage().getParameters().put('review','true');
        try {
            this.cse.status = 'Closed';
            update cse;
        } catch (Exception e) {
            
        }
        this.constructorInitCode();        

        string msg = 'Service cancelled successfully! ';

                this.displayCaseCustomPageMessage = true;   
                this.showServiceMsgPanel = true;          
                this.customPageMessageSeverityStyleClass = 'infoM3';     
                this.customPageMessage = msg;
    
        return null;
    }    
    public Boolean getRelatedSubjectsExist() {
        return this.relatedSubjects != null && !this.relatedSubjects.isEmpty();
    }   
    /**
     * Help with names with single quotes and javascript calls. 
     * @TODO move to utils method and make generic.
     */
    public String getCaseContactNameSanitized() {
        String clean = '';
        String name = '';
        if(cse.Contact.name != null) {
            name = cse.contact.name;
        }
        if(name != null) {
            String raw = name;
            if(raw != null) {
                clean = String.escapeSingleQuotes(raw);
            }
        }
        return clean;
    }      
    
	// The following methods are for Case Question Functionality
	public void initCaseQuestions() {
        System.debug(logginglevel.warn,'----- in doInitCaseQuestions!!!');
        this.doQuestionsExist = false;
        
        List<Consultation_Question__c> caseQuestions        = new List<Consultation_Question__c>();
        
        caseQuestions = this.retrieveAllCaseQuestions();
        
        for(Consultation_Question__c q : caseQuestions) {
            DynaQaWrapper dynaQa = new DynaQaWrapper(q.id);
            debugLog('building wrapper list.. question apifieldname='+q.case_answer_field_name__c);
            dynaQa.sObjfield = UiUtils.getSObjectField(sObjectFieldMap, q.Case_Answer_Field_Name__c);           
            dynaQa.apiFieldName = q.Case_Answer_Field_Name__c;
            dynaQa.question = q;
            if(dynaQa.apiFieldName!=null && dynaQa.apiFieldName != '') {            
                cseQaWraps.add(dynaQa);
            }
        }
		debugLog('----- in doInitCaseQuestions cseQaWraps size='+cseQaWraps.size());
		
        this.doQuestionsExist = ( cseQaWraps != null && !cseQaWraps.isEmpty());
        return;                        
    }
    private List<Consultation_Question__c> retrieveAllCaseQuestions() {      
        List<Consultation_Question__c> allCaseQuestions = new List<Consultation_Question__c>();
        Id subjectId = cse.Selected_Subject__c;
        if(subjectId == null) {
            return allCaseQuestions;
        }
        Set<Id> allPossibleQIds = CaseQuestionUtils.retrieveCaseQIdsBySubject(subjectId);
        
        // CaseQuestionUtils.retrieveCaseQuestions(Ids, boolean) gets those questions in the ID list
        // AS WELL AS any questions that are for all problem codes
        //if(allPossibleQIds != null && allPossibleQIds.size() > 0) {
            allCaseQuestions = CaseQuestionUtils.retrieveCaseQuestions(allPossibleQIds,false);

        //}
        return allCaseQuestions;    
    }   
}