public with sharing class ctrlSubjectExtension extends ctrlCarplesGeneric {

    public Subject__c                   subject                         {   get; set;   }
    public ProblemCodeWrapper           pcWrapper                       {   get; set;   }   
    public List<LegalRefWrapper>        legalRefWraps                   {   get; set;   }
    public List<SocialRefWrapper>       socialRefWraps                  {   get; set;   }
    public List<WebLinkWrapper>         webLinkWraps                    {   get; set;   }
    public List<DDPWrapper>             ddpWraps                        {   get; set;   }
    public List<CaseQuestionWrapper>    caseQWraps                      {   get; set;   }   
    public List<Applied_Resource__c>    appliedResources                {   get; set;   }
	public List<Case>					cases							{ 	get; set;	} 
	public List<Subject__c>				relatedSubjects					{	get; set;	}
    
    public Boolean                      isViewOnlyMode                  {   get; set;   }
    public Boolean                      editDdpsClicked                 {   get; set;   }
    public Boolean                      editCaseQsClicked               {   get; set;   }
    public Boolean                      editLegalRefsClicked            {   get; set;   }
    public Boolean                      editSocialRefsClicked           {   get; set;   }   
    public Boolean                      editWebLinksClicked             {   get; set;   }   
    
    public Boolean                      doesAnyDdpEpcDataExist          {   get; set;   }
    public Boolean                      doesAnyCaseQEpcDataExist        {   get; set;   }   
    public Boolean                      doesAnySocialRefEpcDataExist    {   get; set;   }
    public Boolean                      doesAnyWebLinksEpcDataExist     {   get; set;   }
    public Boolean                      doesAnyLegalRefEpcDataExist     {   get; set;   }
    
    public String                       clickedAcctType                 {   get; set;   }

	public List<Solution__c>            solutions                       {   get; set;   }
	public List<SolutionWrapper>        solutionWraps                   {   get; set;   }
	public Boolean                      doesAnySolutionDataExist        {   get; set;   }
	public Solution__c                  newSolution                     {   get; set;   }
	public List<SubjectComment__c>      subjectComments                 {   get; set;   }
	public Boolean                      doesAnySubjectCommentDataExist  {   get; set;   }
    
	public boolean displayPopup {get;set;} 
	
        
    public ctrlSubjectExtension(ApexPages.StandardController stdController) {
        super();
        //---------this.showDebugMessages = true;
        this.subject = (Subject__c)stdController.getRecord();        
        this.getObjects();
        this.initSettings();
        this.initSectionState();
        this.getAllRecordData();
        this.refreshRelatedData();
    }
    public ctrlSubjectExtension getTheController() {
        return this;
    }
    
    public void getAllRecordData() {
        id id = subject.id;
        String soql = SoqlUtils.getAllFieldsSOQL('Subject__c',false,'' );       
        soql += ' where id =:id';       
        this.subject = Database.query(soql);        
        if(subject != null) {
            this.pcWrapper = new ProblemCodeWrapper(subject);
            debugLog('getAllRecordData Set pcWrapper to '+pcWrapper);
        } 
    }
    public override void getObjects() {      
        this.editDdpsClicked = false;
        this.editCaseQsClicked = false;
        this.editLegalRefsClicked = false;
        this.editSocialRefsClicked = false;
        this.editWebLinksClicked = false;
        this.isViewOnlyMode = true;
        this.doesAnyDdpEpcDataExist = false;
        this.doesAnyCaseQEpcDataExist = false;
        this.doesAnySocialRefEpcDataExist = false;
        this.doesAnyLegalRefEpcDataExist = false;
        this.doesAnyWebLinksEpcDataExist = false;
        this.clickedAcctType = '';
        super.getObjects();
    }  
    public override void initSettings() {
        super.initSettings();
        System.debug('overriding ancestor');
    }  
    private void initSectionState() {
        this.mSectionState = new Map<String,SectionStateBean>();    
        mSectionState.put( 'msgDdpsPanel', new SectionStateBean('msgDdpsPanel',false) );
        mSectionState.put( 'msgCaseQsPanel', new SectionStateBean('msgCaseQsPanel',false) );
        mSectionState.put( 'msgLrPanel', new SectionStateBean('msgLrPanel',false) );
        mSectionState.put( 'msgSrPanel', new SectionStateBean('msgSrPanel',false) );
        mSectionState.put( 'msgWlPanel', new SectionStateBean('msgWlPanel',false) );
    }
    private void refreshRelatedData() {
        
        this.webLinkWraps = retrieveWebLinkWrappers(this.pcWrapper,true);
        this.ddpWraps = this.retrieveDdpWrappers(this.pcWrapper,true);
        this.caseQWraps = this.retrieveCaseQuestionWrappers(this.pcWrapper,true);
        this.legalRefWraps = retrieveLegalRefWrappers(this.pcWrapper,true);
        this.socialRefWraps = retrieveSocialRefWrappers(this.pcWrapper,true);
        //this.appliedResources = this.retrieveAppliedResources(this.subject);   
        this.cases = this.retrieveCases(this.subject);   
        SubjectUtils sUtils = new SubjectUtils();
        this.relatedSubjects = retrieveRelatedSubjects(this.pcWrapper);    
		this.solutions = retrieveSolution();
		this.solutionWraps = retrieveSolutionWrappers();

		this.subjectComments = retrieveSubjectComments();
    }

    public PageReference doEditDdps(){
        debugLog('action-->doEditDdps');
        this.initSectionState();
        this.editDdpsClicked = true;
        this.displayCustomPageMessage = false;
        this.ddpWraps = this.retrieveDdpWrappers( new ProblemCodeWrapper(subject),false );
        if(ddpWraps == null || ddpWraps.isEmpty() ) {
            SectionStateBean ssBean = mSectionState.get('msgDdpsPanel');
            ssBean.showIt = true;
            ssBean.cssStyleClass = 'infoM4';
            ssBean.msg = 'No DDPs available for Subject Problem Code';                      
        }
        return null;        
    }
    public PageReference doEditCaseQuestions(){
        debugLog('action-->doEditCaseQuestions');
        this.initSectionState();
        this.editCaseQsClicked = true;
        this.displayCustomPageMessage = false;
        this.caseQWraps = this.retrieveCaseQuestionWrappers( new ProblemCodeWrapper(subject),false );
        if(caseQWraps == null || caseQWraps.isEmpty() ) {
            SectionStateBean ssBean = mSectionState.get('msgCaseQsPanel');
            ssBean.showIt = true;
            ssBean.cssStyleClass = 'infoM4';
            ssBean.msg = 'No Case Questions available for Subject Problem Code';                        
        }
        return null;        
    }
    public PageReference doEditLegalRefs(){
        debugLog('action-->doEditLegalRefs');
        this.initSectionState();
        this.editLegalRefsClicked = true;
        this.displayCustomPageMessage = false;
        this.legalRefWraps = this.retrieveLegalRefWrappers( new ProblemCodeWrapper(subject),false );
        return null;        
    }
    public PageReference doEditSocialRefs(){
        debugLog('action-->doEditSocialRefs');
        this.initSectionState();
        this.editSocialRefsClicked = true;
        this.displayCustomPageMessage = false;
        this.socialRefWraps = this.retrieveSocialRefWrappers( new ProblemCodeWrapper(subject),false );
        return null;        
    }
    public PageReference doEditWebLinks(){
        debugLog('action-->doEditWebLinks');
        this.initSectionState();
        this.editWebLinksClicked = true;
        this.displayCustomPageMessage = false;
        this.webLinkWraps = this.retrieveWebLinkWrappers( new ProblemCodeWrapper(subject),false );
        return null;        
    }
    public PageReference doCancelPubs() {
        debugLog('action-->doCancelPubs');
        this.ddpWraps = this.retrieveDdpWrappers(this.pcWrapper,true);
        this.editDdpsClicked = false;
        return null;
    }
    public PageReference doCancelCaseQuestions() {
        debugLog('action-->doCancelCaseQuestions');
        this.caseQWraps = this.retrieveCaseQuestionWrappers(this.pcWrapper,true);
        this.editCaseQsClicked = false;
        return null;
    }   
    public PageReference doCancel() {
        debugLog('action-->doCancel.... clickedAcctType='+clickedAcctType);

        
        if('SOCIAL'.equalsIgnoreCase(clickedAcctType)) {    
            this.socialRefWraps = this.retrieveSocialRefWrappers(this.pcWrapper,true);
            this.editSocialRefsClicked = false; 
        }   
        if('LEGAL'.equalsIgnoreCase(clickedAcctType)) { 
            this.legalRefWraps = this.retrieveLegalRefWrappers(this.pcWrapper,true);
            this.editLegalRefsClicked = false;          
        }
        if('WEBLINK'.equalsIgnoreCase(clickedAcctType)) {   
            this.webLinkWraps = this.retrieveWebLinkWrappers(this.pcWrapper,true);
            this.editWebLinksClicked = false;   
        }
        return null;        
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

    private List<Loop__DDP__c> retrieveDdps(ProblemCodeWrapper aPcWrapper) {
        List<Loop__DDP__c> ddps = DDPUtils.retrieveDdps(aPcWrapper);
        Integer numDdps = 0;
        if(ddps != null) {
            numDdps = ddps.size();  
        }
        debugLog('Num ddps retrieved='+numDdps);

        return ddps;
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
    private List<Consultation_Question__c> retrieveCaseQuestions(ProblemCodeWrapper aPcWrapper) {
        List<Consultation_Question__c> caseQs = CaseQuestionUtils.retrieveCaseQs(aPcWrapper);
        Integer numQs = 0;
        if(caseQs != null) {
            numQs = caseQs.size();  
        }
        debugLog('Num case questions retrieved='+numQs);

        return caseQs;
    }
    private List<CaseQuestionWrapper> retrieveCaseQuestionWrappers(ProblemCodeWrapper aPcWrapper, Boolean isSelectedOnly) {
        List<Consultation_Question__c> caseQs = this.retrieveCaseQuestions(aPcWrapper);
        if(caseQs != null && caseQs.size() > 0) {
            this.doesAnyCaseQEpcDataExist = true;
        }

        List<CaseQuestionWrapper> caseQWraps = new List<CaseQuestionWrapper>();

        ID subjectId = this.subject.id;
        if(caseQs != null) { 
            Set<ID> selectedCaseQIds = CaseQuestionUtils.retrieveCaseQIdsBySubject(subjectId);
            Integer numSelected = 0;
            if(selectedCaseQIds != null) {
                numSelected = selectedCaseQIds.size();  
            }
            debugLog('Num Case Questions selected='+numSelected);
            
            for(Consultation_Question__c caseQ : caseQs) {
                if(isSelectedOnly) {
                    if(selectedCaseQIds.contains(caseQ.id)) {
                        CaseQWraps.add( new CaseQuestionWrapper(caseQ,selectedCaseQIds.contains(caseQ.id)) );
                    }   
                } else {
                    CaseQWraps.add( new CaseQuestionWrapper(caseQ,selectedCaseQIds.contains(caseQ.id)) );
                }
            }
        }
        if(CaseQWraps != null) {
            caseQWraps.sort();
        }
        return CaseQWraps;
    }   
    private List<Applied_Resource__c> retrieveAppliedResources(Subject__c subj) {
        AppliedResourceUtils arUtils = new AppliedResourceUtils();
        List<Applied_Resource__c> ars = arUtils.retrieveAppliedResources(subj);
        Integer numArs = 0;
        if(ars != null) {
            numArs = ars.size();    
        }
        debugLog('Num applied resources retrieved='+numArs);

        return ars;
    }
    
    private List<Case> retrieveCases(Subject__c subj) {
        CaseUtils csUtils = new CaseUtils();
        List<Case> cs = csUtils.retrieveCasesBySubject(subj);
        Integer numCs = 0;
        if(cs != null) {
            numCs = cs.size();    
        }
        debugLog('Num cases retrieved='+numCs);

        return cs;
    }
    private List<Subject__c> retrieveRelatedSubjects(ProblemCodeWrapper pcWrap) {
        
        List<String> types = new List<String>();
        types.add('Draft');
        types.add('Published');
        types.add('Work in Progress');
        
        List<String> statuses = new List<String>();
        statuses.add('Active');
        statuses.add('Archived');
        
        List<Subject__c> subjs = SubjectUtils.retrieveRelatedSubjects(pcWrap, this.subject, types, statuses );
        Integer numSubjs = 0;
        if(subjs != null) {
            numSubjs = subjs.size();    
        }
        debugLog('Num Related Subjects retrieved='+numSubjs);

        return subjs;
    }
    public PageReference doSaveDdps() {
        debugLog('action-->doSaveDdps');
        this.initSectionState();
        displayCustomPageMessage = false;
        customPageMessage = '';
        List<DDP_Subject_Junction__c> ddpSjsToInsert = new List<DDP_Subject_Junction__c>();
        List<DDP_Subject_Junction__c> ddpSjsToDel = new List<DDP_Subject_Junction__c>();
        List<DDP_Subject_Junction__c> tempInserts = new List<DDP_Subject_Junction__c>();
        List<DDP_Subject_Junction__c> tempDels = new List<DDP_Subject_Junction__c>();
        Boolean insertSuccess = false;
        Boolean deleteSuccess = false;
        Boolean transAttempted = false;
        
        for(DdpWrapper ddpWrap  : ddpWraps) {
            if(ddpWrap.checkBox) {
                DDP_Subject_Junction__c ddpSj = new DDP_Subject_Junction__c();
                ddpSj.ddp__c = ddpWrap.ddp.Id;
                ddpSj.subject__c = subject.id;
                ddpSjsToInsert.add(ddpSj);
            } else {
                DDP_Subject_Junction__c ddpSj = new DDP_Subject_Junction__c();
                ddpSj.ddp__c = ddpWrap.ddp.Id;
                ddpSj.subject__c = subject.id;
                ddpSjsToDel.add(ddpSj);             
            }
        }
        if(ddpSjsToInsert != null && !ddpSjsToInsert.isEmpty()) {
            transAttempted = true;
            Id subjId = subject.id;
            Set<Id> ddpIds = new Set<Id>();
            
            for(DDP_Subject_Junction__c ddpSj : ddpSjsToInsert) {
                ddpIds.add(ddpSj.ddp__c);
            }
            List<DDP_Subject_Junction__c> existingddpSjs  = [   select  id,ddp__c
                                                                from    DDP_Subject_Junction__c
                                                                where   subject__c = :subjId
                                                                and     ddp__c in :ddpIds ];            
            Set<Id> existingIds = new Set<Id>();
            if(existingddpSjs != null) {
                for(DDP_Subject_Junction__c ddpSj : existingddpSjs) { 
                    existingIds.add(ddpSj.ddp__c);  
                }
            }
            if(existingIds.size() > 0) {
                for(DDP_Subject_Junction__c ddpSj : ddpSjsToInsert) {
                    if(!existingIds.contains(ddpSj.ddp__c)) {
                        tempInserts.add(ddpSj);
                    }
                }
            } else {
                tempInserts = ddpSjsToInsert;
            }
            Set<Id> idsUpserted;
            try {
                DmlUtils.DBUpsert(tempInserts, true);
                insertSuccess = idsUpserted != null && !idsUpserted.isEmpty();          
                debugLog('action-->doSaveDdps ('+clickedAcctType+')  upserted '+tempInserts.size() + ' Ddps ');
            } catch (Exception e) {
                debugLog('action-->doSaveAccounts ('+clickedAcctType+')  upsert of DDP failed:'+e);
            }           
        }
        if(ddpSjsToDel != null && !ddpSjsToDel.isEmpty()) {
            transAttempted = true;
            Id subjId = subject.id;
            Set<Id> ddpIds = new Set<Id>();
            for(DDP_Subject_Junction__c ddpSj : ddpSjsToDel) {              
                ddpIds.add(ddpSj.ddp__c);
            }
            tempDels = [    select  id,Ddp__c
                                                                from    DDP_Subject_Junction__c
                                                                where   subject__c = :subjId
                                                                and     ddp__c in :ddpIds ];
            
            if(tempDels != null && !tempDels.isEmpty()) {
                debugLog('action-->doSaveDdpsP  attempting to delete '+tempDels.size() + ' ddps ');
                Set<Id> idsDel = DmlUtils.DBDelete(tempDels, true);
                deleteSuccess = idsDel != null && !idsDel.isEmpty();            
            }
        }
        if(transAttempted) {
            String suffix = '';
            if(insertSuccess && tempInserts.size() != 0) {                          
                if(tempInserts.size() > 1) {
                    suffix = ' DDPs.';
                } else {
                    suffix = ' DDP.';
                }
                customPageMessage += 'Successfully associated '+tempInserts.size() + suffix;
                displayCustomPageMessage = true;
                SectionStateBean ssBean = mSectionState.get('msgDdpsPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'confirmM4';
                ssBean.msg = customPageMessage;         
                
            } 
            if(deleteSuccess && tempDels.size() != 0) {             
                if(tempDels.size() > 1) {
                    suffix = ' DDPs.';
                } else {
                    suffix = ' DDP.';
                }   
                customPageMessage += 'Successfully removed '+tempDels.size() + suffix;
                displayCustomPageMessage = true;
                SectionStateBean ssBean = mSectionState.get('msgDdpsPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'confirmM4';
                ssBean.msg = customPageMessage;                 
            }           
        }

        this.ddpWraps = this.retrieveDdpWrappers(this.pcWrapper, true);
        this.editDdpsClicked = false;
        return null;
    }   
    public PageReference doSaveQuestions() {
        debugLog('action-->doSaveQuestions');
        this.initSectionState();
        displayCustomPageMessage = false;
        customPageMessage = '';
        List<Question_Subject_Junction__c> qSjsToInsert = new List<Question_Subject_Junction__c>();
        List<Question_Subject_Junction__c> qSjsToDel = new List<Question_Subject_Junction__c>();
        List<Question_Subject_Junction__c> tempInserts = new List<Question_Subject_Junction__c>();
        List<Question_Subject_Junction__c> tempDels = new List<Question_Subject_Junction__c>();
        Boolean insertSuccess = false;
        Boolean deleteSuccess = false;
        Boolean transAttempted = false;
        
        for(CaseQuestionWrapper caseQWrap  : caseQWraps) {
            if(caseQWrap.checkBox) {
                Question_Subject_Junction__c qSj = new Question_Subject_Junction__c();
                qSj.case_question__c = caseQWrap.caseQ.id;
                qSj.subject__c = subject.id;
                qSjsToInsert.add(qSj);
            } else {
                Question_Subject_Junction__c qSj = new Question_Subject_Junction__c();
                qSj.case_question__c = caseQWrap.caseQ.id;
                qSj.subject__c = subject.id;
                qSjsToDel.add(qSj);             
            }
        }
        if(qSjsToInsert != null && !qSjsToInsert.isEmpty()) {
            transAttempted = true;
            Id subjId = subject.id;
            Set<Id> qIds = new Set<Id>();
            
            for(Question_Subject_Junction__c qSj : qSjsToInsert) {
                qIds.add(qSj.case_question__c);
            }
            List<Question_Subject_Junction__c> existingQSjs  = [    select  id,case_question__c
                                                                from    Question_Subject_Junction__c
                                                                where   subject__c = :subjId
                                                                and     case_question__c in :qIds ];            
            Set<Id> existingIds = new Set<Id>();
            if(existingqSjs != null) {
                for(Question_Subject_Junction__c qSj : existingqSjs) { 
                    existingIds.add(qSj.case_question__c);  
                }
            }
            if(existingIds.size() > 0) {
                for(Question_Subject_Junction__c qSj : qSjsToInsert) {
                    if(!existingIds.contains(qSj.case_question__c)) {
                        tempInserts.add(qSj);
                    }
                }
            } else {
                tempInserts = qSjsToInsert;
            }
            Set<Id> idsUpserted;
            try {
                DmlUtils.DBUpsert(tempInserts, true);
                insertSuccess = idsUpserted != null && !idsUpserted.isEmpty();          
                debugLog('action-->doSaveDdps ('+clickedAcctType+')  upserted '+tempInserts.size() + ' Case Question Subject Junctions ');
            } catch (Exception e) {
                //debugLog('action-->doSaveAccounts ('+clickedAcctType+')  upsert of Case Question Subject Junction failed:'+e);
            }           
        }
        if(qSjsToDel != null && !qSjsToDel.isEmpty()) {
            transAttempted = true;
            Id subjId = subject.id;
            Set<Id> qIds = new Set<Id>();
            for(Question_Subject_Junction__c qSj : qSjsToDel) {             
                qIds.add(qSj.case_question__c);
            }
            tempDels = [    select  id,case_question__c
                                                                from    Question_Subject_Junction__c
                                                                where   subject__c = :subjId
                                                                and     case_question__c in :qIds ];
            
            if(tempDels != null && !tempDels.isEmpty()) {
                debugLog('action-->doSaveCaseQuestions  attempting to delete '+tempDels.size() + ' case questions sjs ');
                Set<Id> idsDel = DmlUtils.DBDelete(tempDels, true);
                deleteSuccess = idsDel != null && !idsDel.isEmpty();            
            }
        }
        if(transAttempted) {
            String suffix = '';
            if(insertSuccess && tempInserts.size() != 0) {                          
                if(tempInserts.size() > 1) {
                    suffix = ' Case Questions.';
                } else {
                    suffix = ' Case Question.';
                }
                customPageMessage += 'Successfully associated '+tempInserts.size() + suffix;
                displayCustomPageMessage = true;
                SectionStateBean ssBean = mSectionState.get('msgCaseQsPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'confirmM4';
                ssBean.msg = customPageMessage;         
                
            } 
            if(deleteSuccess && tempDels.size() != 0) {             
                if(tempDels.size() > 1) {
                    suffix = ' Case Questions.';
                } else {
                    suffix = ' Case Question.';
                }   
                customPageMessage += 'Successfully removed '+tempDels.size() + suffix;
                displayCustomPageMessage = true;
                SectionStateBean ssBean = mSectionState.get('msgCaseQsPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'confirmM4';
                ssBean.msg = customPageMessage;                 
            }           
        }

        this.caseQWraps = this.retrieveCaseQuestionWrappers(this.pcWrapper, true);
        this.editCaseQsClicked = false;
        return null;
    }   
    public PageReference doSaveAccounts() {
        
        debugLog('action-->doSaveAccounts... clicked acct Type='+this.clickedAcctType);
        this.initSectionState();
        displayCustomPageMessage = false;
        customPageMessage = '';
        
        List<Account_Subject_Junction__c> asjsToInsert = new List<Account_Subject_Junction__c>();
        List<Account_Subject_Junction__c> asjsToDel = new List<Account_Subject_Junction__c>();
        List<Account_Subject_Junction__c> tempInserts = new List<Account_Subject_Junction__c>();
        List<Account_Subject_Junction__c> tempDels = new List<Account_Subject_Junction__c>();
        Boolean insertSuccess = false;
        Boolean deleteSuccess = false;
        Boolean transAttempted = false;
        
        if('LEGAL'.equalsIgnoreCase(clickedAcctType)) {
            for(LegalRefWrapper lrWrap  : legalRefWraps) {
                if(lrWrap.checkBox) {
                    Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
                    asj.account__c = lrWrap.legalRef.Id;
                    asj.subject__c = subject.id;
                    asjsToInsert.add(asj);
                } else {
                    Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
                    asj.account__c = lrWrap.legalRef.Id;
                    asj.subject__c = subject.id;
                    asjsToDel.add(asj);             
                }
            }           
        }
        if('SOCIAL'.equalsIgnoreCase(clickedAcctType)) {
            for(SocialRefWrapper srWrap  : SocialRefWraps) {
                if(srWrap.checkBox) {
                    Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
                    asj.account__c = srWrap.SocialRef.Id;
                    asj.subject__c = subject.id;
                    asjsToInsert.add(asj);
                } else {
                    Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
                    asj.account__c = srWrap.SocialRef.Id;
                    asj.subject__c = subject.id;
                    asjsToDel.add(asj);             
                }
            }           
        }       
        if('WEBLINK'.equalsIgnoreCase(clickedAcctType)) {
            for(WebLinkWrapper wlWrap  : WebLinkWraps) {
                if(wlWrap.checkBox) {
                    Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
                    asj.account__c = wlWrap.WebLink.Id;
                    asj.subject__c = subject.id;
                    asjsToInsert.add(asj);
                } else {
                    Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
                    asj.account__c = wlWrap.WebLink.Id;
                    asj.subject__c = subject.id;
                    asjsToDel.add(asj);             
                }
            }           
        }
        

        if(asjsToInsert != null && !asjsToInsert.isEmpty()) {
            transAttempted = true;
            Id subjId = subject.id;
            Set<Id> AcctIds = new Set<Id>();
            
            for(Account_Subject_Junction__c asj : asjsToInsert) {
                acctIds.add(asj.account__c);
            }
        
        
            List<Account_Subject_Junction__c> existingAsjs  = [ select  id,account__c
                                                                from    Account_Subject_Junction__c
                                                                where   subject__c = :subjId
                                                                and     account__c in :acctIds ];           
            Set<Id> existingIds = new Set<Id>();
            if(existingAsjs != null) {
                for(Account_Subject_Junction__c asj : existingAsjs) {
                    existingIds.add(asj.account__c);    
                }
            }
            if(existingIds.size() > 0) {
                for(Account_Subject_Junction__c asj :asjsToInsert) {
                    if(!existingIds.contains(asj.account__c)) {
                        tempInserts.add(asj);
                    }
                }
            } else {
                tempInserts = asjsToInsert;
            }
            Set<Id> idsUpserted;
            try {
                idsUpserted  = DmlUtils.DBUpsert(tempInserts, true);
                insertSuccess = idsUpserted != null && !idsUpserted.isEmpty();          
                debugLog('action-->doSaveAccounts ('+clickedAcctType+')  upserted '+tempInserts.size() + ' accounts ');
            } catch (Exception e) {
                debugLog('action-->doSaveAccounts ('+clickedAcctType+')  upsert failed:'+e);            
            }
            
        }
        
        if(asjsToDel != null && !asjsToDel.isEmpty()) {
            transAttempted = true;
            Id subjId = subject.id;
            Set<Id> acctIds = new Set<Id>();
            for(Account_Subject_Junction__c asj : asjsToDel) {              
                acctIds.add(asj.account__c);
            }
            tempDels = [    select  id,account__c
                                                                from    Account_Subject_Junction__c
                                                                where   subject__c = :subjId
                                                                and     account__c in :acctIds ];
            
            if(tempDels != null && !tempDels.isEmpty()) {
                debugLog('action-->doSaveAccounts ('+clickedAcctType+')  attempting to delete '+tempDels.size() + ' accts ');
                Set<Id> idsDel = DmlUtils.DBDelete(tempDels, true);
                deleteSuccess = idsDel != null && !idsDel.isEmpty();    
            }
        }
        if(transAttempted) {
            String sTransType = '';
            String msgPanel = '';
            if('SOCIAL'.equalsIgnoreCase(clickedAcctType)) {
                sTransType = ' Social Referrals.';
                msgPanel = 'msgSrPanel';
            } 
            if('LEGAL'.equalsIgnoreCase(clickedAcctType)) {
                sTransType = ' Legal Referrals.';
                msgPanel = 'msgLrPanel';
            }           
            if('WEBLINK'.equalsIgnoreCase(clickedAcctType)) {
                sTransType = ' Web Links.';
                msgPanel = 'msgWlPanel';
            }
            if(insertSuccess && tempInserts.size() != 0) {                          
                customPageMessage += 'Successfully associated '+tempInserts.size() + sTransType;
                displayCustomPageMessage = true;
                SectionStateBean ssBean = mSectionState.get(msgPanel);
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'confirmM4';
                ssBean.msg = customPageMessage; 
            }                   
            
            if(deleteSuccess && tempDels.size() != 0) {             
                customPageMessage += 'Successfully removed '+tempDels.size() + sTransType;
                displayCustomPageMessage = true;
                SectionStateBean ssBean = mSectionState.get(msgPanel);
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'confirmM4';
                ssBean.msg = customPageMessage;                 
            }           
        }
        if('SOCIAL'.equalsIgnoreCase(clickedAcctType)) {    
            this.socialRefWraps = this.retrieveSocialRefWrappers(this.pcWrapper,true);
            this.editSocialRefsClicked = false; 
        }   
        if('LEGAL'.equalsIgnoreCase(clickedAcctType)) { 
            this.legalRefWraps = this.retrieveLegalRefWrappers(this.pcWrapper,true);
            this.editLegalRefsClicked = false;          
        }
        if('WEBLINK'.equalsIgnoreCase(clickedAcctType)) {   
            this.webLinkWraps = this.retrieveWebLinkWrappers(this.pcWrapper,true);
            this.editWebLinksClicked = false;   
        }
        return null;
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
    
    Public Class DdpWrapper implements Comparable {
        Public Loop__DDP__c ddp{get;set;}
        Public Boolean checkBox{get;set;}   
        public Integer sortOrder{get;set;}
        
        Public DdpWrapper( Loop__DDP__c d, boolean selected){
            ddp         = d;
            checkBox    = selected;
            if(selected) { sortOrder = 1;} else { sortOrder = 0; }
        }
        public Integer compareTo(Object oToCompare) {
            if(sortOrder > ((DdpWrapper)oToCompare).sortOrder) {
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
		newSolution = new Solution__c();
		System.debug('new Solution show '+newSolution);
		displayPopup = true; 
		System.debug('show popup '+displayPopup);
	} 

	public PageReference createNewSolution(){
		System.debug('new Solution create '+newSolution);
		newSolution.Practice_Area__c = subject.Practice_Area__c;
		newSolution.Problem_Category__c = subject.Problem_Category__c;
		newSolution.Problem_Code__c = subject.Problem_Code__c;
		

		System.debug('new Solution create2 '+newSolution);
		
		try{
			insert newSolution;
			closePopup();
		} catch(Exception ex){
			System.debug('exeption '+ex.getMessage());
		}			
		return  null;
			

	}
    

}