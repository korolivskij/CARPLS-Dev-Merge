global class ctrlProblemCodeSelect extends ctrlComponentBase {
    public Case                 cse                                 { get; set; }
    public String               searchTerm                          { get; set; }
    public ProblemCodeWrapper   pcWrap                              { get; set; }
    public String               actionId                            { get; set; }

    public transient List<Subject__c>     relatedSubjects                     { get; set; }
    public transient List<Subject__c>     relatedArchivedSubjects             { get; set; }
    public Integer              MAX_RESULTS                         { get; set; }
    public Boolean              searchClicked                       { get; set; }
    public Boolean              isAddingNewSubject                  { get; set; }
    public Boolean              isNewSubjectAdded                   { get; set; }
    public String               retUrl                              { get; set; }
    public String               currentPageUrl                      { get; set; }
    public String               newTabUrl                           { get; set; }
    public transient Subject__c           subjectSelected                     { get; set; }
    public String               subjectIdSelected                   { get; set; }
    public boolean pcSearchCalled {get;set;}
    public Boolean  showSearchFilters {get;set;}
    public Boolean  showArchived            {get;set;}
    public String   searchResultsMsg  {get;set;}


    public Subject__c  newSubject {get;set;}
    public STring newSubjectTitle {get;set;}



    public boolean getIsCaseOpen() {
        return cse!=null && cse.status == 'Open';
    }
    global ctrlProblemCodeSelect() {
        MAX_RESULTS = 50;
        searchClicked = false;
        this.showSearchFilters = true;
        this.showArchived = false;
        this.isAddingNewSubject = false;
        this.pcSearchCalled = false;
        this.pcWrap = new ProblemCodeWrapper();
        this.retUrl = '';
        this.currentPageUrl = Apexpages.currentPage().getUrl();
    }
    public Integer getNumActiveSubjects() {
        return relatedSubjects!=null ? relatedSubjects.size() : 0;
    }
    public Integer getNumArchivedSubjects() {
        return relatedArchivedSubjects!=null ? relatedArchivedSubjects.size() : 0;
    }
    @remoteaction
    global static SubjectState retrieveSubjectState () {
        SubjectState ss = new SubjectState();
        //  if(caseId != null && caseId != '') {
        //      lCase = [select Id, Selected_Subject__c, Subject, Description,ContactId from Case where Id = :caseId];
        //  }
        return ss;
    }
    /**
     * Should only be called once.
     */
    public Pagereference doComponentInit() {
        if(cse!=null) {
            if(cse.Selected_Subject__c != null) {
                this.subjectIdSelected = cse.Selected_Subject__c;
                this.pcWrap = new ProblemCodeWrapper(cse);
                doSelectSubject();
            }
        }
        return null;
    }
    public PageReference doShowArchived() {

        this.refreshSubject();
        this.showArchived = true;
        return null;
    }
    public PageReference doShowActive() {
        this.refreshSubject();
        this.showArchived = false;
        return null;
    }
    public PageReference doPcSearch()  {
            this.searchResultsMsg = null;
        this.pcWrap = new ProblemCodeWrapper(cse);
        this.pcWrap.searchTerm = searchTerm;
        searchClicked = true;
            this.showSearchFilters = false;
        this.refreshSubject();
        return null;
    }
    public PageReference doClearPcSearch() {
            this.searchResultsMsg = null;
        cse.Practice_Area__c = null;
            cse.problem_code__c = null;
            cse.problem_category__c = null;
            cse.jurisdiction__c = null;
            this.showArchived = false;
            this.searchTerm = '';
        this.pcWrap = new ProblemCodeWrapper(cse);
      this.relatedSubjects = new List<Subject__c>();
      this.relatedArchivedSubjects = new List<Subject__c>();
            this.pcSearchCalled = true;
            this.searchClicked = false;
        return null;
    }
    public PageReference doCreateTaskForNewSubject() {
            
            String sTaskSubject = 'New Subject';
            String sSupportType = 'AOC';

            //if(svc.Follow_Up_Public_Group__c != null && svc.Follow_Up_Public_Group__c != 'No Follow Up') {
                Id tOwnerId = UserInfo.getUserId();
                RecordType rt;
                rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','System_Assigned');
                
                
                tOwnerId = Activity.retrieveOnCallPersonBySupportType(sSupportType);
            
                

                if(tOwnerId != null) {
                    
                    Task t = new Task();
                    t.ActivityDate = System.now().date();
                    t.Subject = sTaskSubject;
                    t.type = 'Task';
                    t.support_type__c = sSupportType; //assigned to Request_Follow_Up_Reason_PL__c
                    t.group__c = sSupportType;
                    t.WhatId = subjectIdselected;
                    t.OwnerId = tOwnerId;
                    //t.Description = svc.Follow_Up_Reason__c;
                    t.Status = 'Open';
                    t.recordTypeId = rt.id;
                    insert t;
                }

            //}
            return null;
    }

	public PageReference doCreateTaskForNewSolution(String solutionIdselected) {
            
            String sTaskSubject = 'New Solution';
            String sSupportType = 'AOC';

            //if(svc.Follow_Up_Public_Group__c != null && svc.Follow_Up_Public_Group__c != 'No Follow Up') {
                Id tOwnerId = UserInfo.getUserId();
                RecordType rt;
                rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','System_Assigned');
                
                
                tOwnerId = Activity.retrieveOnCallPersonBySupportType(sSupportType);
            
                

                if(tOwnerId != null) {
                    
                    Task t = new Task();
                    t.ActivityDate = System.now().date();
                    t.Subject = sTaskSubject;
                    t.type = 'Task';
                    t.support_type__c = sSupportType; //assigned to Request_Follow_Up_Reason_PL__c
                    t.group__c = sSupportType;
                    t.WhatId = solutionIdselected;
                    t.OwnerId = tOwnerId;
                    //t.Description = svc.Follow_Up_Reason__c;
                    t.Status = 'Open';
                    t.recordTypeId = rt.id;
                    insert t;
                }

            //}
            return null;
    }
    /**
     * RJN ok normally the faq / subject is created as an applied resource in the service form when adding a new subject
     * after hitting save but since we are expanding this functionality.. ie. withdrawn / pending yada yada..
     * someone may add a subject to a service. save the service still be in the case.. withdraw the subject.
     * select a different subject. and it will get selected as a subject but not created as an ar.. we need to do that here.
     *
     *
     * @return
     */
    public Pagereference doSelectSubject() {
        this.subjectSelected = SubjectUtils.retrieveSubject(subjectIdSelected);


        Consultation__c currentSvc = new CaseUtils().retrieveCurrentCaseConsultation(cse);
        if(currentSvc != null && subjectSelected != null) {
            //make sure this subjectSelected wasn't already created as an ar attached to this case somehow..
            List<Applied_Resource__c> ar =  [select id
                                             from   applied_resource__c
                                             where  case__c = :cse.id
                                             and    subject__c =  :subjectSelected.id];
            if(ar.isEmpty()) {
                new AppliedResourceUtils().createAppliedResource(subjectSelected, cse, currentSvc);
            }
        }

        this.refreshSubject();
            this.pcWrap = new ProblemCodeWrapper(subjectSelected);
            //@TODO should the view bind to pcWrap instead. the update of the case object
            //seems to happen in vfCase so this cse object passed here is outdated and just temp anyway.
            cse.Practice_Area__c = pcWrap.practiceArea;
            cse.problem_code__c = pcWrap.problemCode;
            cse.problem_category__c = pcWrap.problemCategory;
            cse.jurisdiction__c = pcWrap.jurisdiction;
            cse.selected_subject__c = subjectIdSelected;
            //@TODO is this query needed or can we get the refreshed version of the Case
            //from pageController and a prop on there?
            //this.cse = new CaseUtils().retrieveCaseSummaryData(cse.id);
        //@TODO init case questions maybe.. or fire event or something?
        return null;
    }
    /**
     *
     */
    public PageReference doAddNewSubject() {
        this.newSubject = new Subject__c();
        this.newSubject.status__c = 'Active';
        this.newSubject.type__c = 'Pending';
        if(searchTerm !=null  && searchTerm != ''){
            
            newSubject.title__c = searchTerm;
        }
        ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(this.cse);
        if(pcWrap != null) {
            this.newSubject.practice_Area__c = pcWrap.practiceArea;
            this.newSubject.problem_category__c = pcWrap.problemCategory;
            this.newSubject.problem_Code__c = pcWrap.problemCode;
            this.newSubject.jurisdiction__c = pcWrap.jurisdiction;
            //this.isPreCase = false;
        }
        return null;
    }  
    public Pagereference doSaveNewSubject() {
        if(this.newSubject != null) {
            
            system.debug('attempting to insert newsubject rec='+newSubject);
            Id newSubjectId = SubjectUtils.createSubject(newSubject);

            Subject__c subjectCreated;  
            if(newSubjectId != null) {
                this.isNewSubjectAdded = true;
                subjectCreated = SubjectUtils.retrieveSubject(newSubjectId);  
                this.subjectIdSelected = newSubjectId;   
                this.doSelectSubject();
                //this.doSelectSubject();
               // this.doCreateTaskForNewSubject();



                /*
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
                   // jsCloseNewSubjectMethod += 'jsSelectSubject(\''+cse.Selected_Subject__c+'\',\''+cse.id + '\');';
                  //  jsCloseNewSubjectMethod += 'jsSelectSubject(\''+cse.Selected_Subject__c + '\');';
                //}
                //if(isPreCase) {
                //  isCaseDetailEdit = false;
                //}
               // this.jsCloseNewSubjectMethod  += 'closeNewSubjectDialog();';
                //debugLog('jsCloseNewSubjectMethod = '+jsCloseNewSubjectMethod);
                //this.isPreCase = false;
            }
        }  
        return null;    
    }  
    public void refreshSubject() {
        /*
            String status = 'Active';
            if(this.showArchived) {
                status = 'Archived';
            }
        */  
        Integer iResLimit = MAX_RESULTS; //@todo customsetting
        String status = 'Active';
        this.relatedSubjects = SubjectUtils.retrieveSubjects( pcWrap, 'FAQ', status,iResLimit);

        status = 'Archived';
        this.relatedArchivedSubjects = SubjectUtils.retrieveSubjects( pcWrap, 'FAQ', status,iResLimit);

        Integer iSize = relatedSubjects!=null ? relatedSubjects.size() : 0;
        searchResultsMsg = iSize + ' ' + status +' subjects found';
        String filterMsgs = this.getSearchMsgFromFilters();
        if(filterMsgs != null && filterMsgs != '') {
            searchResultsMsg += ' for criteria...'+filterMsgs;
        }


                
        if(pcWrap.cse != null && pcWrap.cse.selected_subject__c != null && this.subjectIdSelected == null) {
            this.subjectIdSelected = pcWrap.cse.selected_subject__c;
        }
    }

    public Boolean getShowResultsMaxWarning() {
        return relatedSubjects != null && !relatedSubjects.isEmpty() && relatedSubjects.size() >= MAX_RESULTS - 1;
    }
    public Boolean getShowNoResultsWarning() {
        Boolean showIt = false;
        if(null != searchClicked) {
            showIt = (searchClicked && (null == relatedSubjects  || relatedSubjects.size() == 0));
        }
        showIt = false; //rjn remove for now.. but TODO get back to this / autosearch after subject selected and why its popping htis!
        if(showIt) {searchClicked = false; }
        return showIt;
    }
    public PageReference doNewSubjectUrlCreate() {
        String url = this.retrieveNewSubjectPr().getUrl();
        url += '&isdtp=vw';
        //pageController.debugLog('new subject url='+url);
        this.newTabUrl = url;
        this.isAddingNewSubject = true;
        return null;
    }
        public String getSearchMsgFromFilters() {
            String msg = '';
            Boolean bBuilding = false;
            if(cse.practice_area__c != null) {
                msg+= cse.practice_area__c;
                bBuilding = true;
            }
            if(cse.problem_category__c != null) {
                if(bBuilding) { msg+= ' | ';}
                msg+= cse.problem_category__c;
            }
            if(cse.problem_code__c != null) {
                if(bBuilding) { msg+= ' | ';}
                msg+= cse.problem_code__c;
            }
            if(cse.jurisdiction__c != null) {
                if(bBuilding) { msg+= ' | ';}
                msg+= cse.jurisdiction__c;
            }
            if(this.searchTerm != null && this.searchTerm != '') {
                if(bBuilding) { msg+= ' | ';}
                msg+= searchTerm;
            }
            return msg;
        }
    /**
     *  Set default value on Standard New Subject Page Layout.
     */
    public PageReference retrieveNewSubjectPr() {
        PageReference pr = new PageReference('/' + Schema.SObjectType.Subject__c.getKeyPrefix() + '/e');

        String pTitleId = Utilities.getSpecificFieldId('Subject__c','title__c');
        String paId = Utilities.getSpecificFieldId('Subject__c','practice_area__c');
        String pCatId = Utilities.getSpecificFieldId('Subject__c','problem_category__c');
        String pCodeId = Utilities.getSpecificFieldId('Subject__c','problem_code__c');
        String pStatusId =  Utilities.getSpecificFieldId('Subject__c','status__c');
        String pTypeId = Utilities.getSpecificFieldId('Subject__c','type__c');
        String pJurisId = Utilities.getSpecificFieldId('Subject__c','jurisdiction__c');

        if(pTitleId != null && searchTerm!=null && searchTerm.length() > 0)  { pr.getParameters().put(pTitleId,searchTerm);}
        if(paId != null) { pr.getParameters().put(paId,cse.Practice_Area__c);}
        if(pCatId != null) { pr.getParameters().put(pCatId,cse.Problem_Category__c);}
        if(pCodeId != null) { pr.getParameters().put(pCodeId,cse.Problem_Code__c);}
        if(pStatusId != null) { pr.getParameters().put(pStatusId,'Active'); }
        if(pTypeId != null) { pr.getParameters().put(pTypeId,'Draft');}
        if(pJurisId != null && cse.jurisdiction__C != null) { pr.getParameters().put(pJurisId,cse.jurisdiction__c);}

        return pr;
    }
    global class SubjectState {

        global SubjectState() {

        }
    }
}