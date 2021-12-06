public with sharing class ctrlSubjectView extends ctrlCarplesGeneric {

    public  Id                          clickedSubjectId;
    public  Subject__c                  clickedSubject                      { get; set; }
    public  CaseUtils                   caseUtils                           { get; set; }
    public  String                      reRenderList                        { get; set; }
    public  Boolean                     compInitialized                     { get; Set; }
    public  Subject__c                  subject                             { get; set; }

    public Boolean                                      isSubjectAlreadySelected            { get; set; }
    public Boolean                                      isCancelClicked                     { get; set; }
    public Boolean                                      isSelectClicked                     { get; set; }
    public Case                                         cse                                 { get; set; }
    public Boolean                                      isCaseOpen                          { get; set; }
    public Boolean                                      bCaseHasNoSubject                   { get; set; }
    public List<Applied_Resource__c>                    activeResources                     { get; set; }
    public Boolean                                      hasActiveResources                  { get; set; }

	public ProblemCodeWrapper           pcWrapper                       {   get; set;   }   
	public List<DDPWrapper>             ddpWraps                        {   get; set;   }
	public List<LegalRefWrapper>        legalRefWraps                   {   get; set;   }
	public List<SocialRefWrapper>       socialRefWraps                  {   get; set;   }
	public List<WebLinkWrapper>         webLinkWraps                    {   get; set;   }
	public List<SolutionWrapper>        solutionWraps                   {   get; set;   }
	public List<Solution__c>            solutions                       {   get; set;   }
	public List<SubjectComment__c>      subjectComments                 {   get; set;   }

	public Boolean                      doesAnyDdpEpcDataExist          {   get; set;   }
	public Boolean                      doesAnyLegalRefEpcDataExist     {   get; set;   }
	public Boolean                      doesAnySocialRefEpcDataExist    {   get; set;   }
	public Boolean                      doesAnyWebLinksEpcDataExist     {   get; set;   }
	public Boolean                      doesAnySolutionDataExist        {   get; set;   }
	public Boolean                      doesAnySubjectCommentDataExist  {   get; set;   }
	
	public SubjectComment__c            newSubjectComment               {   get; set;   }
	public boolean                      displayPopup                    {   get; set;   } 

    public String activeResourceIds;
    /**
     * used for sconsole event to pass back to vfCase if needed.
     *
     * @return serialized JSON string.
     */
    public String getActiveResourceIds() {
        String sIds = '';
        if(hasActiveResources != null && hasActiveResources == true) {
            for (Applied_Resource__c ar : activeResources) {
                sIds += ar.Id + ',';
            }
            sIds.removeEnd(',');
        }
		
        return sIds;
    }

    public ctrlSubjectView() {

        super();
        this.isCaseOpen = false;
        this.bCaseHasNoSubject = false;
        this.activeResources = new List<Applied_Resource__c>();
        this.hasActiveResources = false;
        debugLog('ctrlSubjectView constructor');
        this.compInitialized = false;
        this.caseUtils = new CaseUtils();
        debugLog('ctrlSubjectView contructor.. clickedSubjectId='+clickedSubjectId);
        this.processQueryParams();
    }
    public ctrlSubjectView(ApexPages.StandardController stdController) {
        super();
        this.showDebugMessages = true;
        this.caseUtils = new CaseUtils();
        this.subject = (Subject__c)stdController.getRecord();
        this.getObjects();
        this.initSettings();
        this.initSectionState();
        this.getAllRecordData();
        this.processQueryParams();
        this.refreshRelatedData();
    }

	private void refreshRelatedData() {
        
        this.ddpWraps = this.retrieveDdpWrappers(this.pcWrapper,true);
        this.legalRefWraps = retrieveLegalRefWrappers(this.pcWrapper,true);
        this.socialRefWraps = retrieveSocialRefWrappers(this.pcWrapper,true);
        this.webLinkWraps = retrieveWebLinkWrappers(this.pcWrapper,true);
		this.solutionWraps = retrieveSolutionWrappers();
		this.solutions = retrieveSolution();
		this.subjectComments = retrieveSubjectComments();

        //this.caseQWraps = this.retrieveCaseQuestionWrappers(this.pcWrapper,true);
        ////this.appliedResources = this.retrieveAppliedResources(this.subject);   
        //this.cases = this.retrieveCases(this.subject);   
        //SubjectUtils sUtils = new SubjectUtils();
        //this.relatedSubjects = retrieveRelatedSubjects(this.pcWrapper);    
    }

	private List<DdpWrapper> retrieveDdpWrappers(ProblemCodeWrapper aPcWrapper, Boolean isSelectedOnly) {
        List<Loop__DDP__c> ddps = this.retrieveDdps(aPcWrapper);
        if(ddps != null && ddps.size() > 0) {
            this.doesAnyDdpEpcDataExist = true;
        }

        List<DdpWrapper> ddpWraps = new List<DdpWrapper>();

        ID subjectId = this.subject.id;
		
        if(ddps != null) { 
            Set<ID> selectedDdpIds = DDPUtils.retrieveDdpIdsBySubject(subjectId);
            Integer numSelected = 0;
            if(selectedDdpIds != null) {
                numSelected = selectedDdpIds.size();    
            }
            debugLog('Num Ddps selected='+numSelected);
			isSelectedOnly = false;    
            for(Loop__DDP__c ddp : ddps) {
                if(isSelectedOnly) {
                    if(selectedDdpIds.contains(ddp.id)) {
                        DdpWraps.add( new DdpWrapper(ddp,selectedDdpIds.contains(ddp.id)) );
                    }   
                } else {
                    DdpWraps.add( new DdpWrapper(ddp,selectedDdpIds.contains(ddp.id)) );
                }
            }
        }
        if(DdpWraps != null) {
            DdpWraps.sort();
        }
        return DdpWraps;
    }   
	private List<Loop__DDP__c> retrieveDdps(ProblemCodeWrapper aPcWrapper) {
        List<Loop__DDP__c> ddps = DDPUtils.retrieveDdps(aPcWrapper);
        Integer numDdps = 0;
        if(ddps != null) {
            numDdps = ddps.size();  
        }
        debugLog('Num ddps retrieved='+numDdps);

        return ddps;
    }

	private List<Account> retrieveLegalRefs(ProblemCodeWrapper aPcWrapper) {
        List<Account> legalRefs = AccountUtils.retrieveLegalRefs(aPcWrapper);
        Integer numLegalRefs = 0;
        if(legalRefs != null) {
            numLegalRefs = legalRefs.size();    
        }
        debugLog('Num legalRefs retrieved='+numLegalRefs);

        return legalRefs;
    }
    private List<LegalRefWrapper> retrieveLegalRefWrappers(ProblemCodeWrapper aPcWrapper, Boolean isSelectedOnly) {
        List<Account> legalRefs = this.retrieveLegalRefs(aPcWrapper);
        if(legalRefs != null && legalRefs.size() > 0) {
            this.doesAnyLegalRefEpcDataExist = true;
        }
        List<LegalRefWrapper> lrWraps = new List<LegalRefWrapper>();
        
        String acctType = 'legal';
        ID subjectId = this.subject.id;
        if(legalRefs != null) { 
            Set<ID> selectedAcctIds = AccountUtils.retrieveAcctIdsBySubject(subjectId, acctType);
            Integer numSelected = 0;
            if(selectedAcctIds != null) {
                numSelected = selectedAcctIds.size();   
            }
            debugLog('Num legalRefs selected='+numSelected);
            isSelectedOnly = false;
            for(Account a : legalRefs) {
                if(isSelectedOnly) {
                    if(selectedAcctIds.contains(a.id)) {
                        lrWraps.add( new LegalRefWrapper(a,selectedAcctIds.contains(a.id)) );   
                    }
                } else  {
                    lrWraps.add( new LegalRefWrapper(a,selectedAcctIds.contains(a.id)) );   
                }
            }
        }
        if(lrWraps != null) {           
            lrWraps.sort();
        }       
        return lrWraps;
    }

	private List<Account> retrieveSocialRefs(ProblemCodeWrapper aPcWrapper) {
        List<Account> SocialRefs = AccountUtils.retrieveSocialRefs(aPcWrapper);
        Integer numSocialRefs = 0;
        if(SocialRefs != null) {
            numSocialRefs = SocialRefs.size();  
        }
        debugLog('Num SocialRefs retrieved='+numSocialRefs);

        return SocialRefs;
    }
    private List<SocialRefWrapper> retrieveSocialRefWrappers(ProblemCodeWrapper aPcWrapper, Boolean isSelectedOnly) {
        List<Account> SocialRefs = this.retrieveSocialRefs(aPcWrapper);
        if(socialRefs != null && socialRefs.size() > 0) {
            this.doesAnySocialRefEpcDataExist = true;
        }       
        List<SocialRefWrapper> srWraps = new List<SocialRefWrapper>();
        
        String acctType = 'Social';
        ID subjectId = this.subject.id;
        if(SocialRefs != null) { 
            Set<ID> selectedAcctIds = AccountUtils.retrieveAcctIdsBySubject(subjectId, acctType);
            Integer numSelected = 0;
            if(selectedAcctIds != null) {
                numSelected = selectedAcctIds.size();   
            }
            debugLog('Num SocialRefs selected='+numSelected);
            isSelectedOnly = false;
            for(Account a : SocialRefs) {
                if(isSelectedOnly) {
                    if(selectedAcctIds.contains(a.id)) {
                        srWraps.add( new SocialRefWrapper(a,selectedAcctIds.contains(a.id)) );  
                    }
                } else  {
                    srWraps.add( new SocialRefWrapper(a,selectedAcctIds.contains(a.id)) );  
                }
            }
        }
        if(srWraps != null) {           
            srWraps.sort();
        }        
        return srWraps;
    }

	private List<Account> retrieveWebLinks(ProblemCodeWrapper aPcWrapper) {
        List<Account> webLinks = AccountUtils.retrieveWebLinks(aPcWrapper);
        Integer numWebLinks = 0;
        if(webLinks != null) {
            numWebLinks = weblinks.size();  
        }
        debugLog('Num weblinks retrieved='+numWebLinks);

        return webLinks;
    }
    private List<WebLinkWrapper> retrieveWebLinkWrappers(ProblemCodeWrapper aPcWrapper, Boolean isSelectedOnly) {
        List<Account> webLinks = this.retrieveWebLinks(aPcWrapper);
        if(webLinks != null && webLinks.size() > 0) {
            this.doesAnyWebLinksEpcDataExist = true;
        }
        List<WebLinkWrapper> wlWraps = new List<WebLinkWrapper>();
        
        String acctType = 'webLink';
        ID subjectId = this.subject.id;
        if(webLinks != null) { 
            Set<ID> selectedAcctIds = AccountUtils.retrieveAcctIdsBySubject(subjectId, acctType);
            Integer numSelected = 0;
            if(selectedAcctIds != null) {
                numSelected = selectedAcctIds.size();   
            }
            debugLog('Num weblinks selected='+numSelected);
            isSelectedOnly = false;
			//AccountUtil
            for(Account a : weblinks) {
                if(isSelectedOnly) {
                    if(selectedAcctIds.contains(a.id)) {
                        wlWraps.add( new WebLinkWrapper(a,selectedAcctIds.contains(a.id)) );    
                    }
                } else  {
                    wlWraps.add( new WebLinkWrapper(a,selectedAcctIds.contains(a.id)) );    
                }
            }
        }
        if(wlWraps != null) {           
            wlWraps.sort();
        }       
        return wlWraps;
    }

	private List<Solution__c> retrieveSolution(){
		System.debug('subject '+subject);
		List<Solution__c> solutions = [SELECT Id, Name, Title__c, Status__c, Type__c, Recommended_Level_of_Service__c, Level_of_Merit__c,Goal__c, LastModifiedBy.CommunityNickname, LastModifiedDate FROM Solution__c WHERE Practice_Area__c =: subject.Practice_Area__c AND Problem_Category__c =: subject.Problem_Category__c AND Problem_Code__c =: subject.Problem_Code__c];
		System.debug('solutions '+solutions);

		Integer numSolutions = 0;
        if(solutions != null) {
            numSolutions = solutions.size();  
        }
        debugLog('Num SocialRefs retrieved='+numSolutions);

        return solutions;
	}
	private List<SolutionWrapper> retrieveSolutionWrappers(){
		List<Solution__c> solutions = retrieveSolution();

		if(solutions != null && solutions.size() > 0) {
            this.doesAnySolutionDataExist = true;
        }   

		List<SolutionWrapper> solutionWraps = new List<SolutionWrapper>();

		if(solutionWraps != null){
			for(Solution__c solution: solutions){
				solutionWraps.add(new SolutionWrapper(solution,true));
			}
		}
		if (solutionWraps !=null){
			solutionWraps.sort();
		}
		System.debug('solutionWraps solutionWraps solutionWraps solutionWraps '+solutionWraps);
		return solutionWraps;
	}

	private List<SubjectComment__c> retrieveSubjectComments(){
		System.debug('subject '+subject);
		List<SubjectComment__c> subjectCommentsList = [SELECT Id, Title__c, Description__c, Status__c, Subject__c, Owner.Name, LastModifiedBy.CommunityNickname, LastModifiedDate FROM SubjectComment__c WHERE Subject__c =: subject.Id];
		System.debug('subjectCommentsList '+subjectCommentsList);

		Integer numSubjectComments = 0;
        if(subjectCommentsList != null) {
            numSubjectComments = subjectCommentsList.size();  
        }
        debugLog('Num SubjectComments retrieved='+numSubjectComments);

		if(subjectCommentsList != null && subjectCommentsList.size() > 0) {
            this.doesAnySubjectCommentDataExist = true;
        }   

        return subjectCommentsList;
	}

    public Pagereference doInitPage() {

        this.initSectionState();

        this.isSubjectAlreadySelected = this.findSubjectMatch();
        debugLog('<font color="blue"> doInitPage.. isSubjectAlreadySelected='+isSubjectAlreadySelected+'</font>');

        if(!isSubjectAlreadySelected) {
            this.isCaseOpen = this.evalCaseStatus();
        }

        Boolean checkactiveResources = false;
        //RJN Conditional switch this on.. if we want to check for active resources. default of custom setting is off..
        try {
            checkActiveResources = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'SubjectView_Check_Active_Resources__c');
        } catch (Exception e) {
            system.debug(logginglevel.error, '-- failed on check of active resources prob cause custom setting is missing..'+e);
        }
        if(checkActiveResources) {
            this.retrieveActiveResources(cse.id);
            this.hasActiveResources = this.evalHasActiveResources();
            debugLog('<font color="blue"> doInitPage.. isCaseOpen='+isCaseOpen+' ..has activeResources='+hasActiveResources +'</font>');
            system.debug(logginglevel.info, '--- running with custom setting SubjectView_Check_Active_Resources__c switched on.. hasActiveResources='+hasActiveResources);
            debugLog('<font color="blue"> doInitPage.. isCaseOpen='+isCaseOpen+' ..has activeResources='+hasActiveResources +'</font>');
        } else {
            system.debug(logginglevel.info, '--- running with custom setting SubjectView_Check_Active_Resources__c switched OFF');
        }
		this.subjectComments = retrieveSubjectComments();
        return null;
    }
    /**
     * Fired via ActionFunction. refresh the state of the page.
     *
     * @return null PR
     */
    public PageReference doRefreshPage() {
        this.processQueryParams();
        this.getAllRecordData();
        this.doInitPage();
        return null;
    }
    private void initSectionState() {
        this.mSectionState = new Map<String,SectionStateBean>();
        mSectionState.put( 'msgMainPanel', new SectionStateBean('msgMainPanel',false) );
    }
    public Boolean evalCaseStatus() {
        Boolean isOpen = false;
        if(cse != null) {
            if(cse.selected_subject__c == null) {
                this.bCaseHasNoSubject = true;
            }

            isOpen = !cse.IsClosed;

            if(!isOpen) {
                SectionStateBean ssBean = mSectionState.get('msgMainPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'infoM4';
                ssBean.msg = 'Case: '+cse.casenumber + ' is closed and must be open to add a subject!';
            }
        }

        return isOpen;
    }
    /**
     *
     *
     * @return
     */
    public Boolean evalHasActiveResources() {
        Boolean hasResources =  activeResources != null && !activeResources.isEmpty();
        if(hasResources) {
            SectionStateBean ssBean = mSectionState.get('msgMainPanel');
            ssBean.showIt = true;
            ssBean.cssStyleClass = 'infoM4 message-panel-resources-override';
            String msg = '';
            if(activeResources.size() > 1) {
                msg+='The following resources are open and must be closed before adding a new subject:';
            } else {
                msg+='The following resource is open and must be closed before adding a new subject:';
            }
            msg+='<ul style="margin-top:7px">';
            for(Applied_Resource__c ar : activeResources) {
                msg+='<li>';
                    msg+='#'+ar.name+' - '+ar.title__c;
                    if(ar.recordtypeid != null) {
                        msg +=' - '+ar.recordtype.name;
                    }
                    msg+= ' - <b>'+ar.status__c+'</b>';
                msg+='</li>';
            }
            msg+='</ul>';
            if(ssBean.msg!= null && ssBean.msg!='') {
                ssBean.msg += '</br>' + 'Additionally: ' + msg;
            } else {
                ssBean.msg = msg;
            }
        }
        return hasResources;
    }
    /**
     *
     * @param caseId
     */
    private void  retrieveActiveResources(Id caseId) {
        this.activeResources = [select  id, name, status__c,title__c,active__c,recordtype.name,recordtypeid
                                from    applied_resource__c
                                where   case__c = :caseId
                                and     active__c = true ];

    }

    private boolean findSubjectMatch() {
        Boolean selected = false;
        if(this.cse != null) {
            debugLog('findSubjectMatch..... cse.selected_subject__c='+cse.Selected_Subject__c+'... this subject id='+subject.id);
            if(cse.Selected_Subject__c == this.subject.id) {
                selected = true;
                SectionStateBean ssBean = mSectionState.get('msgMainPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'infoM4';
                ssBean.msg = 'This subject has already been applied to case: '+cse.casenumber + '.';
            } else {
                //now we can have more then one subject so we need to roll through them.break;
                Boolean match = false;
                AppliedResourceUtils arUtils = new AppliedResourceUtils();
                List<applied_resource__c> caseArs = arUtils.retrieveAppliedResources(this.cse);
                if(caseArs == null || caseArs.isEmpty() ) {
                    match =false;
                } else {
                    for(Applied_Resource__c ar : caseArs) {

                        if(ar.subject__c == this.subject.id && (null != ar.type__C && ar.type__c.equalsIgnoreCase('FAQ'))) {
                            match = true;
                            break;
                        }
                    }
                }
                selected = match;
                if(match) {
                    SectionStateBean ssBean = mSectionState.get('msgMainPanel');
                    ssBean.showIt = true;
                    ssBean.cssStyleClass = 'infoM4';
                    ssBean.msg = 'This subject has already been applied to case: '+cse.casenumber + '.';
                }
            }
        }
        return selected;
    }

    public override void getObjects() {
        this.isSubjectAlreadySelected = false;
        super.getObjects();
    }
    public override void initSettings() {
        super.initSettings();
        System.debug('overriding ancestor');
    }

    private void getAllRecordData() {
        this.subject = SubjectUtils.retrieveSubject(subject.id);
		if(subject != null) {
            this.pcWrapper = new ProblemCodeWrapper(subject);
            debugLog('getAllRecordData Set pcWrapper to '+pcWrapper);
        } 
    }
    public Pagereference doCancelSubjectSelect() {
        this.isCancelClicked = true;
        return null;
    }

    public Pagereference doSelectSubject() {
        this.isSelectClicked = true;
        /*
        Applied_Resource__c ar = arUtils.buildAppliedResource(acct, cse, currentService);
        if(ar != null && ar.Type__c != null) {
            try {
                this.arIdInserted = DmlUtils.DBInsert(ar);
            } catch (Exception e) {
                debugLog('<font color=red>Exception inserting applied resource: '+e.getMessage() + ' </font>');
            }
        } else {
            debugLog('in doSelectResource.. NO ar INSERTED!... ar to build='+ar);
        }
        */
        return null;
    }
    /**
     * Must do some eval in this setter as parent controller info
     * is not available in the constructor.
     */
    public void setClickedSubjectId(Id id) {
        debugLog('ctrlSubjectView setClickedSubjectId method called with id:'+id);
        this.clickedSubjectId = id;
        //if(!compInitialized && id != null ) {
            initMyComponent();
            compInitialized = true;
        //}
    }
    public Id getClickedSubjectId() {

        return this.clickedSubjectId;
    }

    private void initMyComponent() {
        debugLog('ctrlSubjectView initMyComponent method');
        if(clickedSubjectId != null) {
            this.clickedSubject = SubjectUtils.retrieveSubject( clickedSubjectId, false );
            compInitialized = true;
        }
    }
    public PageReference doInitComponent() {
        debugLog('ctrlSubjectView doInitComponent Method');
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'-- In doInitComponent.. clickedSubjectId= -- '+clickedSubjectId));
        //if(!compInitialized && clickedSubjectId != null ) {
            initMyComponent();
            compInitialized = true;
        //}
        return null;
    }
    private void processQueryParams() {
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        debugLog('processQueryParms().. caseId='+caseId);
        if(caseId !=null && caseId != '') {
            this.cse = caseUtils.retrieveCaseSummaryData(caseId);
            /*
            if(this.cse != null) {
                this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
                this.caseArs = arUtils.retrieveAppliedResources(this.cse);
            }
            */
        }
    }

	Public Class LegalRefWrapper implements Comparable {
        Public Account legalRef{get;set;}
        Public Boolean checkBox{get;set;}   
        public Integer sortOrder{get;set;}
        
        Public LegalRefWrapper(Account a, boolean selected){
            legalRef    = a;
            checkBox    = selected;
            if(selected) { sortOrder = 1;} else { sortOrder = 0; }
        }
        public Integer compareTo(Object oToCompare) {
            if(sortOrder > ((LegalRefWrapper)oToCompare).sortOrder) {
                return 0;
            } else {
                return 1;
            }
        }       
     }  

	 Public Class SocialRefWrapper implements Comparable{
        Public Account socialRef{get;set;}
        Public Boolean checkBox{get;set;} 
        public Integer sortOrder{get;set;}
        
        Public SocialRefWrapper(Account a, boolean selected){
            socialRef   = a;
            checkBox    = selected;
            if(selected) { sortOrder = 1;} else { sortOrder = 0; }
        }
        public Integer compareTo(Object oToCompare) {
            if(sortOrder > ((SocialRefWrapper)oToCompare).sortOrder) {
                return 0;
            } else {
                return 1;
            }
        }
    }

	Public Class WebLinkWrapper implements Comparable {
        Public Account webLink{get;set;}
        Public Boolean checkBox{get;set;} 
        public Integer sortOrder{get;set;}
        
        Public WebLinkWrapper(Account a, boolean selected){
            webLink     = a;
            checkBox    = selected;
            if(selected) { sortOrder = 1;} else { sortOrder = 0; }
        }
        public Integer compareTo(Object oToCompare) {
            if(sortOrder > ((WebLinkWrapper)oToCompare).sortOrder) {
                return 0;
            } else {
                return 1;
            }
        }
    }

	Public Class SolutionWrapper implements Comparable {
        Public Solution__c solution{get;set;}
        Public Boolean checkBox{get;set;} 
        public Integer sortOrder{get;set;}
        
		
        Public SolutionWrapper(Solution__c s, boolean selected){
            solution     = s;
            checkBox     = selected;
            if(selected) { sortOrder = 1;} else { sortOrder = 0; }
        }
        public Integer compareTo(Object oToCompare) {
				System.debug('sortOrder sortOrder sortOrder '+sortOrder);
            //if(sortOrder > ((Solution__c)oToCompare).sortOrder) {
                //return 0;
            //} else {
                //return 1;
            //}
			return 0;
        }
    }
	
	public void closePopup() { 
		displayPopup = false; 
	} 
	public void showPopup() { 	
		newSubjectComment = new SubjectComment__c();
		System.debug('newSubjectComment show '+newSubjectComment);
		displayPopup = true; 
	} 

	public void saveTask(){
		System.debug('newTask save '+newSubjectComment);
		newSubjectComment.Title__c = subject.Title__c;
		newSubjectComment.OwnerId = subject.OwnerId;
		newSubjectComment.Subject__c = subject.Id;
		newSubjectComment.Status__c = 'Submited';

		System.debug('newTask save 2'+newSubjectComment);
		try{
			insert newSubjectComment;
		} catch (Exception ex){
			System.debug(ex.getMessage());
		}
		closePopup();
		subjectComments = retrieveSubjectComments();
	}

}