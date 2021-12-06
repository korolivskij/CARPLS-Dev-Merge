global  class ctrlCase extends ctrlCarplesGeneric {

    public Case                                     cse                                 { get; set; }
    public Contact                                  cseClient                           { get; set; }

    public Consultation__c                          svcBeingEdited                      { get; set; }

    public FormInfo                                 formInfo                            { get; set; } //inner class
    public RelatedListInfo                          rlInfo                              { get; set; } //inner class

    public Boolean                                  isNewCase                           { get; set; }
    public Boolean                                  showSvcEntryForm                    { get; set; }

    public Boolean                                  renderCaseReviewCreateComponent     { get; set; }
    public Boolean                                  isServiceSaved                      { get; set; }
    public Boolean                                  showFullHtmlNotesRl                 { get; set; }

    public String                                   subjCseId                           { get; set; }
    public String                                   actionId                            { get; set; }
    public String                                   arType                              { get; set; }

    public Case_Review__c                           newCaseReview                       { get; set; }
    public Consultation__c                          currentSvc                          { get; set; } //from memory the rule is latest svc created date?

    //===== For CaseQuestions
    //public List<DynaQaWrapper>                    cseQaWraps                          { get; set; }
    //public Map<String, Schema.SObjectfield>       sObjectFieldMap                     { get; set; }

    //===== Related list data
    public List<Consultation__c>                    cseServices                         { get; set; }
    public List<Case_Party__c>                      cseParties                          { get; set; }
    public List<CARPLS_Appt__c>                     cseCarplsAppt                       { get; set; }
    public List<Applied_Resource__c>                cseAppliedResources                 { get; set; }
    public List<NotesWrapper>                       cseServiceNotes                     { get; set; }
    public List<ActivityHistory>                    cseActivityHistories                { get; set; }
    public List<OpenActivity>                       cseOpenActivities                 { get; set; }
    public List<ActivityWrapper>                    activityWrappers                    {get;set;}
    public List<Case_Review__c>                     cseReviews                          { get; set; }
    public List<Conflict_Log__c>                                        cseConflictLogs {get;set;}
    public List<ContentVersionWrapper>              contentVersionWrappers              { get; set; }
    public List<Survey_Feedback__c>                 cseSurveys                          { get; set; }
    //====

    public Boolean                                  displayAddNewReview                 { get; set; }

    public Boolean isProblemCodeInfoPopulated {set;}

    public CaseUtils                                caseUtils = new CaseUtils();
    public AppliedResourceUtils                     arUtils = new AppliedResourceUtils();
    public String                                   selectedActivityType                {get;set;}
    public DateTime                                 svcStartTime                        {get;set;}
    public User                                     runningUser                         {get;set;}
    public Boolean                                  userClickedSaveAndContinueStartService {get;set;}
    /*
    public Consultation__c                          svc         {get;set;}
    public Note                                     svcNote     {get;set;}
    public String                                   svcNoteBody {get;set;}
    */
    public  User                                    openCaseUser {get;set;}
    public Boolean                                  isAnotherUsersOpenCase  {get;set;}

    public Boolean isEditingSvc {get;set;}

    public ctrlCase(ApexPages.StandardController stdCtrl) {
        staticIsNewCaseFlow = true; //this seems to be getting set to false for some strange reason.
        isEditingSvc = false;
        this.userClickedSaveAndContinueStartService = false;
        this.cse = (Case)stdCtrl.getRecord();
        this.runningUser = UserUtils.retrieveUserTypeAndProfile(UserInfo.getUserId());
        this.activityWrappers = new List<ActivityWrapper>();
        this.isNewCase = false;
        this.showSvcEntryForm = false;
        this.isAnotherUsersOpenCase = false;
        this.showFullHtmlNotesRl = false;
        this.isServiceSaved = false;
        this.displayAddNewReview = super.getIsReviewer();
        //this.displayCaseReview = this.doesUserHaveCRVisibility();
        // For Case Questions
        //this.sObjectfieldMap = UiUtils.getSObjectFieldsMap(new Case());
        //System.debug(logginglevel.warn, 'rj rjn sObjectFieldMap='+sObjectFieldMap);
        //this.cseQaWraps = new List<DynaQaWrapper>();


        refreshCaseSummaryData();
        this.isNewCase = !this.getIsProblemCodeInfoPopulated() && !cse.ever_closed__c;
        this.refreshCaseServices();
        this.refreshCaseCarplsAppt();
        this.refreshCaseParties();
        if(!isNewCase) {
            //this.refreshCaseServices();
            this.refreshCaseCarplsAppt();
            this.refreshCaseServiceNotes();
            //this.refreshCaseParties();
            this.refreshCaseReviews();
            this.refreshContentVersionWrappers();
            this.refreshAppliedResources();
            this.refreshConflictLogs();
            this.refreshCaseSurveyData();
            //this.InitCaseQuestions();
        } else {
            //
        }
        this.formInfo = new FormInfo(this);
        this.rlInfo = new RelatedListInfo(this);
        this.svcBeingEdited = new Consultation__c();

        if(rlInfo.getShowOpenActivities()) {
            this.selectedActivityType = 'Open Activities';
        } else if (rlInfo.getShowActivityHistories()) {
            this.selectedActivityType = 'Activity History';
        }
        DateTime current = System.now();

        this.svcStartTime = current;
    }
    public PageReference doRefreshCaseSummary() {
        refreshCaseSummaryData();
        return null;
    }
    public Boolean doesUserHaveCRVisibility() {
        /*
        String uId = UserInfo.getUserId();
        Set<String> goodCats = new Set<String>{'Supervisor'};
        Set<String> goodProfs = new Set<String>{'System Administrator','Carpls System Administrator', 'CARPLS Supervising Attorney'};

        List<User> users = [select id, type__c from user where id = :uId and (type__C in :goodCats or profile.name in :goodProfs) ];
        User u;
        if(users!=null && !users.isEmpty()) {
            u = users[0];
        }
        */
        Boolean showIt = false;
        if('System Administrator' == runningUser.profile.name
                || 'Carpls System Administrator' == runningUser.profile.name
                || 'CARPLS Supervising Attorney' == runningUser.profile.name
                || 'Supervisor' == runningUser.type__c ) {
           showIt = true;
        } else {
            showIt = false;
        }
        return showIt;

    }
    public PageReference doInit() {

        //------- don't save this yet don't need do....update cse;
        //rjn al wants this ie the client associated with the case flagged immediately as current when the case page opens for the first time.. this is in addition to updateclient below as a patch.. too afraid to change ctrlClient
        if(isNewCase) {
            Contact caseClient;

            try {
                caseClient = [select id, status__c, temp_record__C from contact where id = :cse.contactId];
                if(caseClient.status__c == 'Incomplete') {
                    cse.ownerid = UserInfo.getUserId();
                    update cse;
                }
                caseClient.status__c = 'Current';
                caseClient.temp_record__c = false;
                update caseClient;
                if(cse.contactId != null) {
                    this.cseClient = ContactUtils.retrieveAllContactInfo(cse.contactId);
                }
            } catch (Exception e) {
                system.debug(e);
            }
        }

        Boolean lockIt = false;
        String sClientStatus = '';
        if(cseClient != null) {
            sClientStatus = cseClient.status__c;
        }
        if(cse.status != 'closed' && (cse.start_it__c == true || sClientStatus == 'Current')) {

            this.isAnotherUsersOpenCase = false;
            Id cseOwnerId = cse.ownerId;
            if(cseOwnerId != null && UserInfo.getUserId() != cseOwnerId) {
                this.openCaseUser = UserUtils.retrieveUserById(cseOwnerId);
                this.isAnotherUsersOpenCase = true;
                lockIt = true;
            }
        }
        if(!lockIt) {

        if(cse.ever_closed__c == true) {
            if(cse.description == null) {
                cse.description = 'No Description';
            }
        }

            cse.service_form_guid__c = null; //alway null it out to help with first new c

            cse.Is_Service_Form_Open__c = false;
            update cse;//rjn yes we actually do need to update this here
        }


        //  if(isNewCase && cse.service_form_guid__c == null) {
        //      cse.service_form_guid__C = caseUtils.createGuid();
        //      update cse;
        // }
        return null;
    }

    private void reInitRlInfo() {
        this.rlInfo = new RelatedListInfo(this);
    }
//-------------------  Action Methods-------------------------------------------------------------
    public PageReference doSaveNewCase() {
        update cse;
        return null;
    }
    public PageReference doAddService() {
        //this.svcForm = new SvcForm(this);
        this.showSvcEntryForm = true;
        this.cse.is_service_form_open__c = true;
        system.debug('in doAddService showSvcEntryForm='+showSvcEntryForm);

        this.cse.status = 'Open';
        //if( (!isNewCase && this.currentSvc == null || this.currentSvc.id == null) || cse.service_form_guid__c == null ) {
        cse.Service_Form_Guid__c = caseUtils.createGuid();

        // }
        cse.ownerId = UserInfo.getUserId();
        cse.start_it__c = true;
        cse.Left_Open__c = true;
        update cse;
        /*
        this.svc = new Consultation__c();
        svc.case__c = cse.id;
        */

        //this.refreshCaseSummaryData();
        return null;
    }
    public PageReference doSaveAndContinue() {
        // cse.Left_Open__c = false;
        update cse;
        system.debug('--- in doSaveAndContinue.. cse desc='+cse.description);
        if(currentSvc == null && cse.Selected_Subject__c != null && cse.description == null) {
            return doAddService();
        }
        return null;
    }
    public PageReference doSaveAndContinueStartService() {
        //fp7b
        cse.ownerId = UserInfo.getUserId();
        //update cse;
        this.userClickedSaveAndContinueStartService = true;
        return doAddService();
    }
    public PageReference doAddPartySearch() {
        return null;
    }

    public PageReference doRefreshCaseParties() {
        this.refreshCaseParties();
        return null;
    }
    /*
    public PageReference doEditService() {
        system.debug('--- retrieving service for id:'+formInfo.clickedId);
        this.showSvcEntryForm = false;
        system.debug('in doEditService..showSvcEntryForm='+showSvcEntryForm);
        return null;
    }
    */
    public PageReference doEditServiceAura() {

        doEditServiceAuraAdmin();
        /*
        this.showSvcEntryForm = true;
        cse.is_service_form_open__C = true;
        this.isEditingSvc = true;
        this.svcBeingEdited = caseUtils.retrieveConsultation(formInfo.clickedId);
        cse.service_form_guid__C = svcBeingEdited.service_form_guid__c;
        update cse;
        system.debug('in doEditServiceAura showSvcEntryForm='+showSvcEntryForm);

        currentSvc = svcBeingEdited;

        */
        return null;
    }
    /**
    /**
     * Just exists in case we have to divert from the above.
     */
    public PageReference doEditServiceAuraAdmin() {
        this.showSvcEntryForm = true;
        this.isEditingSvc = true;
        system.debug('in doEditServiceAura showSvcEntryForm='+showSvcEntryForm);
        this.svcBeingEdited = caseUtils.retrieveConsultation(formInfo.clickedId);

        cse.is_service_form_open__C = true;
        cse.status = 'Open';
        cse.left_open__c = true;
        //fp7b
        cse.ownerId = UserInfo.getUserId();
        if(svcBeingEdited.service_form_guid__C == null) {
            svcBeingEdited.service_form_guid__c = caseUtils.createGuid();
            update svcBeingEdited;
        }
        cse.service_form_guid__C = svcBeingEdited.service_form_guid__c;
        update cse;
        currentSvc = svcBeingEdited;

        return null;
    }
    public PageReference doCancelAddService() {
        cse.status = 'Closed';
        cse.Service_Form_Guid__c = null;
        cse.is_service_form_open__C = false;
        cse.Left_Open__c = false;
        update cse;
        this.showSvcEntryForm = false;

        this.userClickedSaveAndContinueStartService = false;

        this.svcBeingEdited = new Consultation__c();
        this.refreshCaseSummaryData();
        this.refreshCaseServices();
        return null;
    }
    public PageReference doCloseTask() {
        Task t = [select id, status from task where id = :selectedId];
        t.status = 'Completed';
        update t;
        this.refreshCaseSummaryData();
        reInitRlInfo();
        return null;
    }
    public PageReference doCloseCase() {
        refreshCaseServices();
        cse.Status = 'Closed';
        cse.Left_Open__c = false;
        Boolean sendSurvey = true;

        // Send a Client Satisfaction Survey if there was legal advice given and client gave email address
        //RJN For whatever crazy reason this contact may be null. guard against that.`
        Contact c;
        String emailAddr;
        try {
            c = [select email from contact where id = :cse.contact.id];
            emailAddr = c.email;
        } catch (Exception e) {
            sendSurvey = false;
            system.debug(e);
        } 
        //fp7b this is probably null for whatever reason so find it again
        if(currentSvc == null) {
            currentSvc = CaseUtils.retrieveCurrentCaseConsultation(cse);
            currentSvc.status__c = 'Closed';
            update currentSvc;
        }
        //------
        if(currentSvc != null) {
            system.debug('going into If stmt, disp = '+currentSvc.Disposition__c + ' survey = '+currentSvc.Survey_Sent__c+' email = '+emailAddr);
            if (currentSvc.Disposition__c != null && currentSvc.survey_sent__c != true &&
                    currentSvc.Disposition__c.equals('Legal Service')
                 /*  currentSvc.Disposition__c.equals('Legal Advice')*/  // ELC - changed criteria from Legal Advice to Legal Service
                && emailAddr != null)
            {
                system.debug('calling sendEmailTemplate with cse.contact.id = ' + cse.contact.id + ' and service = ' + this.currentSvc.id);
                Boolean emailSent = false;
                if (currentSvc.Project__c.equals('IL-AFLAN Hotline'))
 				{
                    emailSent = Utilities.sendEmailTemplate('IL-AFLAN Client Satisfaction Survey', cse.contact.id, this.currentSvc.id);
                } else {
                    emailSent = Utilities.sendEmailTemplate('Client Satisfaction Survey', cse.contact.id, this.currentSvc.id);
                }

                if (!emailSent) {
                    System.debug('Email send failed in ctrlCase.doCloseCase, case: ' + this.cse.casenumber);
                } else {
                    currentSvc.survey_sent__c = true;
                }
           }          
           system.debug('------in doSaveAndClose ----');
            try {

                currentSvc.Status__c = 'Closed';
                //-------------------------------------------- currentSvc.Service_End_Time__c = DateTime.now();
                update currentSvc;
                //update currentSvc; //done twice as there is an order of execution issue with summing up form fields in the trigger.

            } catch (Exception e) {
                String body = 'Case =' + cse.casenumber + ' latest svc=' + currentSvc + '..errors='+e.getStackTraceString();
                Utilities.sendEmail('rnendza@gmail.com', 'Case closed without closing service',body,body);
                system.debug(e.getStackTraceString());
            }
            update cse;
        }else {
            try {
                String body = 'Case =' + cse.casenumber + ' latest svc=' + currentSvc;
                Utilities.sendEmail('rnendza@gmail.com', 'Case closed without closing service',body,body);

            } catch(Exception e) {
                system.debug(logginglevel.error,e);
            }
            update cse;  //just in case...
        }
        return null;
    }
    public PageReference doSaveServiceAura() {
        //this.refreshCaseSummaryData();
        this.showSvcEntryForm = false;
        cse.is_service_form_open__C = false;

        // update cse;
        system.debug('in doSaveServiceAura showSvcEntryForm='+showSvcEntryForm);
        this.isServiceSaved = true;
        this.isEditingSvc = false;
        this.userClickedSaveAndContinueStartService = false;


        //update cse; //specifically for case description.
        this.refreshCaseSummaryData();
        this.isNewCase = !this.getIsProblemCodeInfoPopulated() && !cse.ever_closed__c;
        this.refreshCaseServices();
        //-- we just saved the first service.
        if(cseServices!=null && !cseServices.isEmpty() && cseServices.size() == 1) {
            this.updateClientStatus();
        }

        this.refreshCaseSummaryData(); //rjn added halloween
        this.refreshCaseServiceNotes();
        this.refreshAppliedResources();

        this.svcBeingEdited = new Consultation__c();
        return null;
    }
    /**
     *
     *
     * @return
     */
    public PageReference doRefreshArAura() {
        this.refreshAppliedResources();
        return null;
    }
    /*
    public PageReference doSaveAddService() {
        system.debug('<font color=blue>in doSaveAddService</font>');
        system.debug('svc codes='+svcForm.sSelectedSvcCodes);
        if(svcForm.sSelectedSvcCodes == null || svcForm.sSelectedSvcCodes == '') {
            //this is the poor mans route @TODO replace with js or something that shows
            //the red error msg by the field itself.
            String sMsg = 'Service Codes: A value is required.';
            ApexPages.Message aMsg = new ApexPages.Message(Apexpages.Severity.ERROR, sMsg);
            ApexPages.addMessage(aMsg);
            isServiceSaved = false;
            return null;
        }
        Consultation__c svc = svcForm.svc;
        svc.Service_Code__c = svcForm.sSelectedSvcCodes;
        svc.follow_up_date__c = svcForm.followUpDate;
        svc.Case__c = cse.id;
        insert svc;

        //--- Save Service Note
        Note n = svcForm.note;
        if(n != null) {
            n.ParentId = svc.id;
            if(n.Title == null || n.Title == '') {
                n.Title = 'Service Note';
                insert n;
            }
        }

        String sTaskType = svc.Follow_Up_Public_Group__c;
        if(sTaskType != null && sTaskType!= 'No Follow Up') {
            Id tOwnerId = UserInfo.getUserId();
            RecordType rt;
            rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task','Request_Follow_Up');
            if(sTaskType != 'Myself') {
                tOwnerId = Activity.retrieveOnCallPersonBySupportType(sTaskType);

            }

                if(tOwnerId != null) {

                    Task t = new Task();
                    t.ActivityDate = svc.Follow_Up_Date__c;
                    t.Subject = 'Request Follow Up - Case - '+cse.caseNumber;
                    t.type = sTaskType;
                    t.WhatId = cse.id;
                    t.OwnerId = tOwnerId;
                    t.Description = svc.Follow_Up_Reason__c;
                    t.Status = 'Not Started'doSave
                    insert t;
                }

        }


        this.showSvcEntryForm = false;
        this.isServiceSaved = true;
        this.refreshCaseSummaryData();
        this.refreshCaseServices();
        this.refreshCaseServiceNotes();
        return null;
    }
    */
    /*
    public PageReference doServiceFollowUpReasonSelect() {
        system.debug('--- in doServiceFollowUpReasonSelect..service:'+svcForm.svc);
        if(!this.getFollowUpRequired()) {
            system.debug('--- in doServiceFollowUpReasonSelect. setting followup date to null since its not required');
            svcForm.svc.Follow_Up_Date__c = null;
        } else {
            system.debug('--- in doServiceFollowUpReasonSelect. Follow up reason is required');
        }
        return null;
    }
    */
    public PageReference doCancelNewCase() {
        if(cse!=null) {
            try {
                delete cse;
            } catch (Exception e) {
                system.debug('<font color=red>EXCEPTION DELETING CASE:'+e+'</font>');
            }
        }
        return null;
    }
    public PageReference doSelectSubject() {

        //  system.debug('<font color=blue> doSelectSubject actionId = '+actionId+' subjCseId = '+subjCseId+'</font>');
        Subject__c subj = SubjectUtils.retrieveSubject(actionId);
        cse.selected_subject__c = subj.id;
        cse.Subject = subj.Title__c;
        //  system.debug('<font color=green>Using Problem Codes from Subject to set case value</font>');
        ProblemCodeWrapper subjPc = new ProblemCodeWrapper(subj);
        cse.Practice_Area__c = subjPc.practiceArea;
        cse.Problem_Category__c = subjPc.problemCategory;
        cse.Problem_Code__c = subjPc.problemCode;
        cse.Jurisdiction__c = subjPc.jurisdiction;
        update cse;
        this.refreshCaseSummaryData();

        return null;
    }

    public PageReference doRemoveAppliedResource() {
        if(this.actionId == null) {
            return null;
        }
        Applied_Resource__c ar  = arUtils.retrieveAppliedResource(this.actionId);

        if(ar == null) {
            system.debug(logginglevel.warn,'could not find ar for actionId='+actionId);
            return null;
        }
        this.arType = ar.type__c;
        try {
            delete ar;
        } catch (Exception e) {
            system.debug(e);
        }
        this.refreshAppliedResources();
        return null;
    }
    public Pagereference doRemoveCaseParty() {
        Case_Party__c cp = caseUtils.retrieveCaseParty(this.actionId);
        delete cp;
        this.refreshCaseParties();
        return null;
    }
    public PageReference doAddNewCaseReview() {
        this.renderCaseReviewCreateComponent = true;
        this.newCaseReview = new Case_Review__c();
        this.newCaseReview.case__c = this.cse.id;
        this.newCaseReview.service__c = this.actionId;
        this.newCaseReview.review_status__c = 'Final';
        this.newCaseReview.review_code__c = 'No Note';
        this.newCasereview.reviewed_by__c = UserInfo.getUserId();


        return null;
    }

    public PageReference doCreateCaseReview() {
        system.debug('in doCreateCaseReview');
        if(this.newCaseReview != null) {
            system.debug('<font color=blue>Attempting to insert case review:'+newCaseReview+ '</font>');
            Id newCaseReviewId = CaseReviewUtils.createCaseReview(newCaseReview);
            system.debug('in do createCaseReview.. id created='+newCaseReviewId);

            Case_Review__c caseReviewCreated;
            if(newCaseReviewId != null) {
                caseReviewCreated = CaseReviewUtils.retrieveCaseReview(newCaseReviewId);
                this.refreshCaseReviews();
                this.refreshCaseServices();
            }
        }
        return null;
    }
    public PageReference doDeleteDoc() {
        system.debug('<b>doDeleteDoc=</b>' + actionId+ '<br/>');
        Id contentVersionId = actionId;
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

    public Pagereference doCancelCreateCaseReview() {
        this.newCaseReview = new Case_Review__c();
        actionId = null;
        this.renderCaseReviewCreateComponent = false;
        return null;
    }
    public PageReference doRefreshAppliedResourcesAfterModified() {

        //ctrlAuraCaseServices.updateServiceArToggles(this.cseAppliedResources,this.currentSvc);
        this.refreshAppliedResources();
        this.refreshContentVersionWrappers();
        this.refreshCaseServices();
        this.refreshCaseSummaryData();




        return null;
    }
    /**
     * TBD......
     *
     */
    @testvisible
    private void updateClientStatus() {
        if(this.cseParties != null && !this.cseParties.isEmpty()) {
            List<Id> contactIds = new List<Id>();
            for(Case_Party__c cp : cseParties) {
                if(cp.contact__c != null) {
                    contactIds.add(cp.contact__c);
                }
                cp.Temp_Record__c = false;
                cp.Conflict_Status__c = 'No Conflict'; //assuming since we are creating a svc it has been proven that there was no conflict already and that is what the status should be.
            }
            //now update the case party records.... or was the meaning of case party.. the contact record associated with a party?
            if(!cseParties.isEmpty()) {
                update cseParties;
            }
            if(!contactIds.isEmpty()) {
                List<Contact> cs = [select Id, status__c from Contact where Id in :contactIds];
                for(Contact c : cs ) {
                    c.status__c = 'Current';
                    c.temp_record__c = false;
                }
                update cs;

            }
        }
    }
//-------------------- Advanced Presentation Layer Methods ---------------------------------------------
    /*
    public Boolean getFollowUpRequired() {
        Boolean required = false;
        if(svcForm != null && svcForm.svc != null) {
            if(svcForm.svc.Follow_Up_Public_Group__c != null) {
                if(svcForm.svc.Follow_Up_Public_Group__c != 'No Follow Up') {
                    required = true;
                }
            }
        }
        system.debug('in getFollowupRequired... returning..'+required);
        return required;
    }
    */

//-------------------  Data Refresh Methods-------------------------------------------------------------
    public void refreshCaseSurveyData() {
        this.cseSurveys = caseUtils.retrieveSurveysByCase(this.cse);
    }
    public void refreshCaseSummaryData() {
        if(cse == null || cse.id == null) {
            return;
        }
        //this.cse = caseUtils.retrieveCaseSummaryData(cse.id);
        this.cse = caseUtils.retrieveCaseSummaryDataWithActivities(cse.id);
        this.isNewCase = !this.getIsProblemCodeInfoPopulated() && !cse.ever_closed__c;
        if(!isAnotherUsersOpenCase) {
            this.showSvcEntryForm = cse.Is_Service_Form_Open__c;
        }
        this.cseActivityHistories = cse.activityhistories;
        this.cseOpenActivities = cse.openActivities;
        if(activityWrappers!= null && !activityWrappers.isEmpty()) {
            activityWrappers.clear();
        }
        if(this.cseActivityHistories != null && !this.cseActivityHistories.isEmpty()) {

            for(ActivityHistory ah : cseActivityHistories) {
                //FP7
                if( null == ah.CallObject || (null != ah.CallObject && ah.CallDisposition != null)  ) {
                    activityWrappers.add(new ActivityWrapper(ah));
                }
            }
        }
        if(this.cseOpenActivities != null && !this.cseOpenActivities.isEmpty()) {

            for(OpenActivity oh : cseOpenActivities) {
                //FP7
                if( null == oh.CallObject || (null != oh.CallObject && oh.CallDisposition != null)  ) {
                    activityWrappers.add(new ActivityWrapper(oh));
                }
            }
        }



        if(cse != null && cse.contactId != null) {
            this.cseClient = ContactUtils.retrieveAllContactInfo(cse.contactId);
        }

    }
    @remoteaction
    global static Case retrieveCaseState (String caseId) {
        Case lCase;
        if(caseId != null && caseId != '') {
            lCase = [select Id, Selected_Subject__c, Subject, Description,ContactId,OwnerId from Case where Id = :caseId];
        }
        return lCase;
    }
    @remoteaction
    global static User retrieveUserRecord (String userId) {
        User u;
        if(userId != null && userId != '') {
            u = [select Id, name from User where Id = :userId];
        }
        return u;
    }
    @remoteaction
    global static Loop__DDP__c retrieveDdpRecord (String ddpId) {
        ///var ddpId = message.data.sobject.DDP__c;
        //        var arId  = message.data.sobject.Id;
        //       var ddpAutoNumId = message.data.sobject.DDP_AutoNum_Id__c;
        //      var ddpTitle = message.data.sobject.DDP_Title__c;

        Loop__DDP__c lDdp;
        if(ddpId != null && ddpId != '') {
            lDdp = [select Id from Loop__DDP__c where Id = :ddpId];
        }
        return lDdp;
    }
    @remoteaction
    global static Applied_Resource__c retrieveArRecord (String arId) {
        AppliedResourceUtils arUtils = new AppliedResourceUtils();
        Applied_Resource__c  ar = arUtils.retrieveAppliedResource(arId);
        return ar;
    }
    private void refreshCaseCarplsAppt(){
        this.cseCarplsAppt = caseUtils.retreiveCarplsAppt(this.cse);
        this.reInitRlInfo();
    }
    private void refreshCaseServices(){
        this.cseServices = caseUtils.retrieveConsultations(this.cse);
        if(cseServices!=null && !cseServices.isEmpty()) {
            List<ServiceWrapper> svcWraps = new List<ServiceWrapper> ();
            for(Consultation__c svc : this.cseServices) {
                svcWraps.add(new ServiceWrapper(svc));
            }
            svcWraps.sort();
            if(!isEditingSvc) {
                this.currentSvc = svcWraps[0].svc;
            } else {
                //already set upon going to edit the svc form.
            }
            //if(currentSvc.service_form_guid__C != cse.service_form_guid__c && !userClickedSaveAndContinueStartService) {
            if(userClickedSaveAndContinueStartService && cse.is_service_form_open__c) {
                currentSvc = null; //latest saved service not the current svc.. user is messing with a new service.
            }

            system.debug('----------currentSvc='+currentSvc);
            system.debug('---- case guid='+cse.service_form_guid__c);
        }
        this.reInitRlInfo();
    }
    public void refreshCaseParties() {
        this.cseParties = caseUtils.retrieveCaseParties( this.cse );
        this.reInitRlInfo();
    }
    public void refreshAppliedResources() {
        List<al.OrderBy> lOrderBy = new List<al.OrderBy> {
                new al.OrderBy('createdDate').descending().nullsLast()
        };
        this.cseAppliedResources = arUtils.retrieveAppliedResources(this.cse,lOrderby);
        this.reInitRlInfo();
    }
    public void refreshCaseServiceNotes() {
        //RJN FP7
        List<NotesWrapper> tmpNotes = caseUtils.retrieveCaseConsultationNotesWraps(this.cse);
        List<NotesWrapper> cleanNotes = new List<NotesWrapper>();
        if(tmpNotes!= null && !tmpNotes.isEmpty()) {
            for(NotesWrapper n : tmpNotes) {
                if(n!=null && n.note!=null & n.note.body != null) {
                    n.note.body = n.note.body.replaceAll('&nbsp;',' ');
                }
                cleanNotes.add(n);
            }
        }
        //this.cseServiceNotes = caseUtils.retrieveCaseConsultationNotesWraps(this.cse);
        this.cseServiceNotes = cleanNotes;

        this.reInitRlInfo();
    }
    public void refreshConflictLogs() {
        this.cseConflictLogs = caseUtils.retrieveContlictLogs(this.cse);
        this.reInitRlInfo();
    }
    public void refreshCaseReviews() {
        //  if (displayAddNewReview == true) {
        //      this.cseReviews = caseReviewUtils.retrieveCaseReviews(this.cse, 'ALL');
        //  } else {
        this.cseReviews = caseReviewUtils.retrieveCaseReviews(this.cse, 'Published');
        //rjn some weird final / published mismatch..

        // }
        this.reInitRlInfo();
    }
    public void refreshContentVersionWrappers() {
        this.contentVersionWrappers = ChatterUtils.retrieveContentVersionWrappersByCaseId(cse.id);
        Integer size = 0;
        if(contentVersionWrappers != null) {
            size = contentVersionWrappers.size();
        }
        system.debug('contentVersionWrappers retrieved sized='+size);
        this.reInitRlInfo();
    }
    // The following methods are for Case Question Functionality
    /* obsolete
    public void initCaseQuestions() {
        System.debug(logginglevel.warn,'----- in doInitCaseQuestions!!!');

        List<Consultation_Question__c> caseQuestions        = new List<Consultation_Question__c>();

        caseQuestions = this.retrieveAllCaseQuestions();
        Integer size = 0;
        for(Consultation_Question__c q : caseQuestions) {
            DynaQaWrapper dynaQa = new DynaQaWrapper(q.id);
                        system.debug('building wrapper list... question apiFieldName='+q.case_answer_field_name__c);
            system.debug('building wrapper list.. question apifieldname='+q.case_answer_field_name__c);
            dynaQa.sObjfield = UiUtils.getSObjectField(sObjectFieldMap, q.Case_Answer_Field_Name__c);
            dynaQa.apiFieldName = q.Case_Answer_Field_Name__c;
            dynaQa.question = q;
            if(dynaQa.apiFieldName!=null && dynaQa.apiFieldName != '') {
                cseQaWraps.add(dynaQa);
            }
        }
        if(cseQaWraps != null) {
            size = cseQaWraps.size();
        }
        system.debug('----- in doInitCaseQuestions cseQaWraps size='+size);

        return;

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
    */
    public ctrlCase getTheController() {
        return this;
    }

    public Boolean getIsProblemCodeInfoPopulated() {
        Boolean isIt = false;
        if(this.cse != null) {
            //if(cse.Problem_Code__c != null && cse.Problem_Code__c != '') {
            if(cse.Practice_Area__c != null && cse.Practice_Area__c != '') {
                isIt = true;
            }
        }
        this.isProblemCodeInfoPopulated = isIt;
        return isIt;
    }
    public Boolean getAnyTasksToClose() {
        boolean areThere = false;
        if(activityWrappers != null && !activityWrappers.isEmpty()) {
            for(activityWrapper aw : activityWrappers) {
                if(aw.actType == 'openactivity' && aw.isTask) {
                    areThere = true;
                    break;
                }
            }
        }
        return areThere;
    }

//----------------------------------------- Inner Classes -----------------------------------------

    public Class FormInfo {
        public ctrlCase ctrl                { get; set; }
        public String clickedId             { get; set; }
        public Boolean showPageNavigator    { get; set; }

        public FormInfo(ctrlCase pCtrlCase) {
            this.ctrl = pCtrlCase;
            this.showPageNavigator = ctrl.getShowPageNavigator();
        }
    }
    //-------------- Inner Svc Form wrapper class
    /*
    public Class SvcForm  {
        public Date                 followUpDate            { get; set; }
        public Consultation__c      svc                     { get; set; }
        public Note                 note                    { get; set; }
        public List<Selectoption>   svcCodeOptions          { get; set; }
        public String               sSelectedSvcCodes;
        public Boolean              isNewService            { get; set; }

        public SvcForm(ctrlCase ctrl) {
            this.isNewService = true;
            this.svc = ctrl.caseUtils.buildNewService(ctrl.cse);
            this.note = new Note();
            this.followUpDate = Date.today();
            this.svcCodeOptions = UiUtils.retrievePlValues(new Consultation__c(), 'Service_Code__c');
            this.sSelectedSvcCodes = '';
        }
        public SvcForm(Case pCse,Consultation__c pSvc) {

            this.svc = pSvc;
            this.note = new CaseUtils().retrieveLatestCaseSvcNote(pCse,svc);
            this.isNewService = false;
            this.followUpDate = svc.follow_up_date__c;
            this.svcCodeOptions = UiUtils.retrievePlValues(new Consultation__c(), 'Service_Code__c');
        }
        */

        /*
        public String getsSelectedSvcCodes() {
            return sSelectedSvcCodes;
        }
        */
    //-- replace comma delim with semi colon delim values for insert into multi-pl
    /*
        public void setsSelectedSvcCodes( String commaDelimValues ) {
            if(commaDelimValues != null) {
                commaDelimValues = commaDelimValues.replace('[]','');
            }
            List<String> lCodes = Utilities.detokenizeString(commaDelimValues, ',');
            if(lCodes != null) {
                for(String code : lCodes) {
                    sSelectedSvcCodes += code+';';
                }
                if(sSelectedSvcCodes != '') {
                    sSelectedSvcCodes = sSelectedSvcCodes.removeEnd(';');
                }
            }
    }
    */

    public class RelatedListInfo {
        ctrlCase ctrl;
        public Integer totalCaseParties         {get;set;}
        public Integer totalCarplsAppts         {get;set;}
        public Integer totalAppliedResources    {get;set;}
        public Integer totalServices            {get;set;}
        public Integer totalServiceNotes        {get;set;}
        public Integer totalActivityHistories   {get;set;}
        public Integer totalOpenActivities      {get;set;}
        public Integer totalActivities          {get;set;}
        public Integer totalReviews             {get;set;}
        public Integer totalConflictLogs        {get;set;}
        public Integer totalCvWrappers          {get;set;}
        public Integer totalSurveys             {get;set;}
        public List<SelectOption> activityTypes {get;set;}
        public Boolean  recordEditOverride      {get;set;}

        public RelatedListInfo(ctrlCase pCtrlCase) {
            this.totalReviews=0;this.totalCaseParties=0;this.totalServices=0;
            this.totalAppliedResources=0;this.totalServiceNotes=0;this.totalActivityHistories = 0;this.totalOpenActivities = 0;
            this.totalConflictLogs=0;this.totalCvWrappers=0;this.totalActivities = 0;this.totalSurveys = 0;this.totalCarplsAppts = 0;
            this.ctrl = pCtrlCase;

            this.activityTypes = new List<Selectoption>();
            activityTypes.add(new SelectOption('Open Activities', 'Open Activities'));
            activityTypes.add(new SelectOption('Activity History', 'Activity History'));

            if(getShowCarplsAppts()) {totalCarplsAppts = ctrl.cseCarplsAppt.size(); }
            if(getShowCaseParties()) { totalCaseParties = ctrl.cseParties.size(); }
            if(getShowAppliedResources()) { totalAppliedResources = ctrl.cseAppliedResources.size(); }
            if(getShowConflictLogs()) { totalConflictLogs = ctrl.cseConflictLogs.size();}
            if(getShowServices()) { totalServices = ctrl.cseServices.size(); }
            if(getShowServiceNotes()) { totalServiceNotes = ctrl.cseServiceNotes.size(); }
            if(getShowActivityHistories()) { totalActivityHistories = ctrl.cseActivityHistories.size(); }
            if(getShowOpenActivities()) { totalOpenActivities = ctrl.cseOpenActivities.size();}
            if(getShowCaseReviews()) { totalReviews = ctrl.cseReviews.size(); }
            if(getShowCvWrappers()) { totalCvWrappers = ctrl.contentVersionWrappers.size();}
            if(getShowActivities()) {totalActivities = ctrl.activityWrappers.size();}
            if(getShowSurveys()) {totalSurveys = ctrl.cseSurveys.size();}
            if(ctrl.runningUser != null) {
                //@todo kinda messy. clean this crap up.
                if('System Administrator' == ctrl.runningUser.profile.name || 'Carpls System Administrator' == ctrl.runningUser.profile.name || 'Supervisor' == ctrl.runningUser.type__c ) {
                    recordEditOverride = true;
                } else {
                    recordEditOverride = false;
                }
            }
        }
        public Boolean getShowCarplsAppts(){
            return ctrl.cseCarplsAppt != null && !ctrl.cseCarplsAppt.isEmpty();
        }
        public Boolean getShowCaseParties() {
            return ctrl.cseParties != null && !ctrl.cseParties.isEmpty();
        }
        public Boolean getShowAppliedResources() {
            return ctrl.cseAppliedResources != null && !ctrl.cseAppliedResources.isEmpty();
        }
        public Boolean getShowConflictLogs() {
            return ctrl.cseConflictLogs != null && !ctrl.cseConflictLogs.isEmpty();
        }
        public Boolean getShowServices() {
            return ctrl.cseServices != null && !ctrl.cseServices.isEmpty();
        }
        public Boolean getShowServiceNotes() {
            return ctrl.cseServiceNotes != null && !ctrl.cseServiceNotes.isEmpty();
        }
        public Boolean getShowActivityHistories() {
            return ctrl.cseActivityHistories != null && !ctrl.cseActivityHistories.isEmpty();
        }
        public Boolean getShowOpenActivities() {
            return ctrl.cseOpenActivities != null && !ctrl.cseOpenActivities.isEmpty();
        }
        public Boolean getShowActivities() {
            // return getShowActivityHistories() || getShowOpenActivities();
            return ctrl.activityWrappers != null && !ctrl.activityWrappers.isEmpty();
        }
        public Boolean getShowSurveys() {
            return ctrl.cseSurveys != null && !ctrl.cseSurveys.isEmpty();
        }
        public Boolean getShowCaseReviews() {
            return
                    ctrl.cseReviews != null && !ctrl.cseReviews.isEmpty()
                    && ctrl.doesUserHaveCRVisibility();
        }
        public Boolean getShowCvWrappers() {
            return ctrl.contentVersionWrappers != null  && !ctrl.contentVersionWrappers.isEmpty();
        }

        /**
         * Always show for now as long as there are some ar.
         *
         * @return
         */
        public Boolean  getShowArMoreActionsViewLink() {
            boolean showIt = false;
            if(getShowAppliedResources()) {
                showIt = true;
            }
            return showIt;
        }
        /**
         * always show for now as long as there are some ar.
         *
         * @return
         */
        public Boolean getShowArMoreActionsEditLink() {
            boolean showIt = false;
            if(getShowAppliedResources()) {
                if(!ctrl.showSvcEntryForm) {
                    showIt = true;
                }
            }
            return showIt;
        }
        public Boolean getShowCaMoreActionsEditLink() {
            boolean showIt = false;
            if(getShowCarplsAppts()) {
                if(!ctrl.showSvcEntryForm) {
                    showIt = true;
                }
            }
            return showIt;
        }
    }
    /**
     *  Used to do an apex sort the createdDate of the current service DESC.
     *  (Note sure how else to ID what the 'current service' is other then when one just
     *  created a new service via the service form.
     */

    public class ServiceWrapper implements Comparable {
        public Consultation__c svc;

        public ServiceWrapper(Consultation__c pSvc) {
            this.svc = pSvc;
        }

        public Integer CompareTo(Object compareTo) {
            ServiceWrapper compareToSvc = (ServiceWrapper)compareTo;
            Integer returnValue = 0;
            if (svc.createdDate > compareToSvc.svc.createdDate) {
                returnValue = -1;
            } else if (svc.createdDate < compareToSvc.svc.createdDate) {
                returnValue = 1;
            }
            return returnValue;
        }


    }

    //-----------------------------
    public class ActivityWrapper {
        public Id                   id          {get;set;}
        public String               subject     {get;set;}
        public String               actType     {get;set;}  //openactivity or activityhistory
        public String               type        {get;set;}
        public Boolean              isTask      {get;set;}
        public String               ownerName   {get;set;}
        public DateTime             activityDate{get;set;}
        public String               status      {get;set;}
        public String               xgroup       {get;set;}
        public String               supportType  {get;set;}

        public ActivityWrapper(OpenActivity oa) {
            this.id = oa.id;
            this.subject = oa.subject;
            this.actType = 'openactivity';
            this.isTask  = oa.isTask;
            this.type    = oa.ActivityType;
            if(type != null && type.contains('1_')) {  // underscore --> SFDC puts junk in there sometimes when it's empty
                if(isTask) {
                    type = 'Task';
                } else {
                    type = 'Event';
                }
            }
            this.ownerName = oa.owner.name;
            this.activityDate = oa.activityDate;
            this.status = oa.status;
            this.xgroup = oa.group__c;
            this.supportType = oa.support_type__c;
        }

        public ActivityWrapper(activityhistory ah) {
            this.id = ah.id;
            this.subject = ah.subject;
            this.actType = 'activityhistory';
            this.isTask  = ah.isTask;
            this.type    = ah.ActivityType;
            this.xgroup   = ah.group__c;
            this.supportType = ah.support_type__c;
            if(type != null && type.contains('1_')) { // underscore --> SFDC puts junk in there sometimes when it's empty
                if(isTask) {
                    type = 'Task';
                } else {
                    type = 'Event';
                }
            }
            this.ownerName = ah.owner.name;
            this.activityDate = ah.activityDate;
            this.status = ah.status;
            if(this.status == null || this.status == '') {
                if(!isTask) {
                    if(ah.EndDateTime != null) {
                        if(ah.EndDateTime < DateTime.now()) {
                            status = 'Completed';
                        } else {
                            status = 'Open';
                        }
                    }

                }
            }
        }

    }
}