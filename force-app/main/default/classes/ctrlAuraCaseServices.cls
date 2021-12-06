public without sharing class ctrlAuraCaseServices {

    @AuraEnabled
    public static Consultation__c retrieveSvc() {
        //return  [select id, follow_up_public_group__c from Consultation__c limit 1];
        Consultation__C svc = new Consultation__c();
        //svc.Follow_Up_Date__c = Date.today();
        return svc;
    }
    @AuraEnabled
    public static Consultation__c retrieveSvc(Id svcId) {
        Consultation__c svc = [
                select Name, Applied_Resources_Accepted__c, Case__c, Client__c, Contact__c, Contact_xx__c, Date_Closed__c, Date_Opened__c,
                        Disposition__c, Fee__c, Follow_Up_Date__c, Follow_Up_Public_Group__c, Follow_Up_Reason__c, Is_Incomplete_Service__c,
                        Last_Contact__c, Last_Serviced_By__c, Location__c, Project__c, Service_Disposition_Accepted__c, Service_Code__c,
                        Service_End_Time__c, Service_Start_Time__c, Service_Time__c, Status__c, Subject__c, Survey_Completed_Time__c,
                        Request_Follow_Up_Reason_PL__c, AOC_Consult__c,Service_Form_Guid__c
                from Consultation__c
                where id = :svcID
        ];


        return svc;
    }
    @AuraEnabled
    public static Case retrieveCase(Id caseId) {
        Case cse = [
                select id, selected_subject__c,service_related__c
                from Case
                where id = :caseID
        ];


        return cse;
    }
    @AuraEnabled
    public static ResponseDTO retrieveSvcAndNote(Id svcId) {
        Consultation__c svc = retrieveSvc(svcId);
        Note n;
        try {
            n = [
                    select Id, Title, Body, ParentId
                    from Note
                    where parentId = :svcId
            ];
        } catch (Exception e) {
            system.debug(e);
        }

        ResponseDTO res = new ResponseDTO();
        res.values.put('Consultation__c', svc);
        res.values.put('Note', n);
        return res;

    }
	/**
	 * Intended to ensure the case subject ie FAQ. is added to the case as an applied resource both on the initial service
	 * and any ensuing service.. @TODO what about use case of create case select subj create service close case. click add new service
	 * change the case subject but don't save the service. sign... the complexity of this shit.
	 */
    public static id addCaseSubjectAsAppliedResource(Consultation__c svc) {
        Id arIdInserted;
        //try {
        system.debug('addCaseSubectAsApplied resource svc='+svc);
        Case cse = [select id, selected_subject__c, accountId from case where id = :svc.case__c];
        Subject__c subj = [select id, recordtype.developername, title__c, createdDate, Resource_Brief__c from subject__c where id = :cse.selected_subject__c];
        AppliedResourceUtils arUtils = new AppliedResourceUtils();
        List<Applied_Resource__c> caseArs = arUtils.retrieveAppliedResources(new Case(id = svc.case__c));

        if (caseArs != null && !caseArs.isEmpty()) {
            system.debug('has existing ars');
            Boolean wasAdded = false;
            for (Applied_Resource__c ar: caseArs) {
                //--- ridck here!!
                if(ar.type__C == 'FAQ') {
                    if (subj.id == ar.subject__c) {
                        system.debug('saying subject was already added as subject on case = subject on ar associated with this svc.. svc=' + svc.id);
                        wasAdded = true;
                        break;
                    }
                }
            }
            if (!wasAdded) {
                system.debug('was not added.. attempting to create the applied resource');
                arIdInserted = arUtils.createAppliedResource(subj, cse, svc);


                //find if service has a note attached.
                //if(subj.createdDate == system.today()) {
                List<Note> notes = [
                        select Id, Title, Body, ParentId
                        from Note
                        where parentId = :svc.id
                ];
                Note n;
                if (notes != null && !notes.isEmpty()) {
                    n = notes[0];
                }
                if (n != null) {
                    //subj.Practice_Brief__c = n.body;
                    //update subj;
                }
                //}
                caseArs =  arUtils.retrieveAppliedResources(new Case(id = svc.case__c));

            }
            tieAppliedResourcesToService(svc, caseArs);
        } else { //case has no resources yet so obviously faq was anot already inserted  just insert the faq ar
            system.debug('single call to create applied resource on first faq?');
            arIdInserted = arUtils.createAppliedResource(subj, cse, svc);
        }

        return arIdInserted;
    }
    @TestVisible
    private static void tieAppliedResourcesToService(Consultation__c svc, List<Applied_Resource__c>ars) {

        if (ars != null && svc != null) {
            List<Applied_Resource__c> arsToUpd = new List<Applied_Resource__c>();
            List<Consultation__c> svcsToUpdate = new List<Consultation__c>();

            for (Applied_Resource__c ar : ars) {
                if (
                     (ar.service_form_guid__c == svc.service_form_guid__c || ar.service_form_guid__C == null)
                             && (ar.consultation__C == null)

                ) {
                    ar.Consultation__c = svc.id;
                    ar.service_form_guid__C = svc.service_form_guid__C;
                    arsToUpd.add(ar);
                }else {

                }
            }
            if (!arsToUpd.isEmpty()) {
                update arsToUpd;
            }
            updateServiceArToggles(arsToUpd,svc);
        }
    }

    @TestVisible
    public static void updateServiceArToggles(List<Applied_Resource__c> ars, Consultation__c svc) {
        //consultation number of ar is updated now roll through again to determine type and flag checkboxes on associated service.break;
        if(ars == null || ars.isEmpty() || svc == null) {
            return;
        }
        Boolean updateSvc = false;
        for (Applied_Resource__c ar :ars) {
            if(ar.consultation__c == svc.id) { //rjn recent add. is this correct?
                // sigh.. SFDC we could use a Switch statement you DBs
                if (ar.type__C == 'Legal Referrals') {
                    try {
                        if (svc.Legal_Referral__c != true && ar.Account_Sub_Type__c == 'Legal Aid') {
                            svc.Legal_referral__c = true;
                            updateSvc = true;
                        }
                    } catch (Exception e) {
                        system.debug(logginglevel.error,e);
                    }
                } else if (ar.type__c == 'Web Links') {
                    if (svc.Weblink__c != true) {
                        svc.weblink__c = true;
                        updateSvc = true;
                    }
                } else if (ar.type__c == 'DDP') {
                    if (svc.publication__c != true) {
                        svc.publication__c = true;
                        updateSvc = true;
                    }
                } else if (ar.type__c == 'Social Referrals') {
                    if (svc.social_referral__c != true) {
                        svc.social_referral__c = true;
                        updateSvc = true;
                    }
                } else if (ar.type__c == 'FAQ') {
                    if (svc.faq__c != true) {
                        svc.faq__c = true;
                        updateSvc = true;
                    }
                }

            }
        }
        if (updateSvc) {
            try {
                update svc;
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
            }
        }
    }
    @AuraEnabled
    public static ResponseDTO upsertSvc(Consultation__c svc, Note svcNote, Boolean bIsSvcEdit,
            Boolean bEditedSvcHadNoNote) {
        return upsertSvc(svc, svcNote, bIsSvcEdit,bEditedSvcHadNoNote,null);
    }
    @AuraEnabled
    public static ResponseDTO upsertSvc(Consultation__c svc, Note svcNote, Boolean bIsSvcEdit,
            Boolean bEditedSvcHadNoNote, String serviceRelatedValue) {
        ResponseDTO res = new ResponseDTO();
        Note n = svcNote;
        try {
            //backwards compatibility..
            if (svc.Request_Follow_Up_Reason_PL__c != null) {
                svc.Follow_Up_Reason__c = svc.Request_Follow_Up_Reason_PL__c;
            }
            //@todo is this svc end time correct

            if(bIsSvcEdit) {
                //dont need this.. and per all svc time should stay the same after it's created.
                //since we are not opening / closing the case on edit (svc is closed on close of the case normally.. make sure we close an edited service here
                //--svc.Status__c = 'Closed';
               // svc.Service_End_Time__c = Datetime.now(); //
            }

            upsert svc;
            Consultation__c svcNew = [select id,project__c,location__c,createdById from consultation__c where id = :svc.id];
            //--- set case info up top;
            Id cID = svc.case__c;
            Case cse = [select id,project__c,origin,last_service_by__c,service_related__c from case where id = :cID];
            cse.origin = svcNew.location__c;
            cse.project__c = svcNew.project__c;
            cse.last_service_by__c = svcNew.createdById;
            cse.is_service_form_open__C = false;
            if(serviceRelatedValue != '') {
                cse.service_related__c = serviceRelatedValue;
            }

            update cse;




           // if(!bIsSvcEdit) {
                Id arId = addCaseSubjectAsAppliedResource(svc);
           // }

            if (svc.Follow_Up_Public_Group__c != null && svc.Follow_Up_Public_Group__c != 'No Follow Up') {
                Id tOwnerId = UserInfo.getUserId();
                RecordType rt;
                rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task', 'System_Assigned');

                if (svc.Request_Follow_Up_Reason_PL__c != 'Myself') {
                    tOwnerId = Activity.retrieveOnCallPersonBySupportTypeForTheCaseService(svc.Request_Follow_Up_Reason_PL__c);
                    System.debug('tOwnerId>' + tOwnerId);
                }
                String sSupportType = svc.Request_Follow_Up_Reason_PL__c;
                if (sSupportType == 'Myself') {
//                    sSupportType = 'Staff';
                }
                if (tOwnerId != null) {
                    System.debug('tOwnerId>' + tOwnerId);
                    Id caseID = svc.case__c;
                    Case c = [select id, casenumber, ContactId from case where id = :caseId];
                    Task t = new Task();
                    t.WhoId = c.ContactId;
                    t.ActivityDate = svc.Follow_Up_Date__c;
                    t.Subject = svc.Follow_Up_Public_Group__c; // follow up label
                    t.type = 'Task';
                    System.debug('Danylo Task Type 2 ' + t.type);
                    t.support_type__c = sSupportType; //assigned to Request_Follow_Up_Reason_PL__c
                    t.group__c = sSupportType;
                    t.WhatId = c.id;
                    t.OwnerId = tOwnerId;
                    t.Description = svc.Follow_Up_Reason__c;
                    t.Status = 'Open';
                    t.isCreatedFromService__c = true;
                    t.recordTypeId = rt.id;
                    insert t;
                }

            }


            n.Title = 'Service Note';
            if (!bIsSvcEdit || bEditedSvcHadNoNote) {
                n.parentId = svc.id;
                insert n;
            } else {
                update n;
            }
            res.isSuccess = true;
            svc = retrieveSvc(svc.id);
            res.title = 'Success!';
            if (bIsSvcEdit) {
                res.mode = 'edit';
                res.message = 'Update of service ' + svc.name + ' successful!';
            } else {
                res.message = 'Creation of service ' + svc.name + ' successful!';
            }
            Id caseID = svc.case__c;
            if(caseId != null) {
                //@TODO prob not the best place to put this but had to for now.
                Case c = [select id, is_service_form_open__c from case where id = :caseId];
                c.is_service_form_open__c = false;
                update c;
            }
            res.severity = 'success';
            res.values.put('Consultation__c', svc);
        } catch (Exception e) {
            res.isSuccess = false;
            res.title = 'Failed';
            res.message = e.getMessage() + '...bIsSvcEdit=' + bIsSvcEdit ;
            res.severity = 'error';
        }
        return res;
    }

    public class SinglePlValues {
        @AuraEnabled
        public List<String> fuPlValues         {get;set;}
        @AuraEnabled
        public List<String> fuReasonPlValues   {get;set;}
        @AuraEnabled
        public List<String> dispPlValues       {get;set;}
        @AuraEnabled
        public List<String> projectPlValues    {get;set;}
        @AuraEnabled
        public List<String> serviceRelatedPlValues {get;set;}


        public SinglePlValues() {

        }
    }
    /**
     * @todo make more generic
     */
    @AuraEnabled
    public Static SinglePlValues retrieveAllSvcSinglePlValues() {
        SinglePlValues splValues = new SinglePlValues();
        splValues.fuPlValues =  retrieveFollowUpPlValues();
        splValues.fuReasonPlValues =  retrieveFollowUpReasonPlValues();
        splValues.dispPlValues = retrieveDispositionPlValues();
        splValues.projectPlValues = retrieveProjectPlValues();
        splValues.serviceRelatedPlValues =  retrieveServiceRelatedPlValues();
        return splValues;
    }
    //helper.populatePL(cmp,'fSvcFollowUp','c.retrieveFollowUpPlValues','',fTypeExcludeVals,true);

    @AuraEnabled
    public Static List<String> retrieveFollowUpPlValues() {
        return UiUtils.retrievePlValuesString(new Consultation__c(), 'Follow_Up_Public_Group__c');
    }
    @AuraEnabled
    public Static List<String> retrieveDispositionPlValues() {
        return UiUtils.retrievePlValuesString(new Consultation__c(), 'Disposition__c');
    }

    @AuraEnabled
    public static List<String> retrieveProjectPlValues() {
        return UiUtils.retrievePlValuesString(new Consultation__c(), 'Project__c');
    }

    @AuraEnabled
    public Static List<String> retrieveFollowUpReasonPlValues() {
        return UiUtils.retrievePlValuesString(new Consultation__c(), 'Request_Follow_Up_Reason_PL__c');
    }
    @AuraEnabled
    public Static List<String> retrieveServiceRelatedPlValues() {
        return UiUtils.retrievePlValuesString(new Case(), 'Service_Related__c');
    }
    @AuraEnabled
    public static Map<String, List<String>> retrieveDispositionAndServiceCodePlValues() {
        Map<String, List<String>> mValues = UiUtils.GetDependentOptions('Consultation__c', 'Disposition__c', 'Service_Code__c');
        return mValues;
    }
}