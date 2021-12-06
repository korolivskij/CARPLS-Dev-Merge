public class CaseUtils {
    //rjn test comment just to save / recompile
    public List<DebugMessage> debugMessages { get; set; }
    public Static Final Integer MAX_DEBUG_MESSAGES = 100;

    public CaseUtils() {
        debugMessages = new List<DebugMessage>();
    }
    public List<FeedItem> addLeftOpenCasesPosts(List<Case> leftOpenCases) {
        List<FeedItem> posts = new List<FeedItem>();

        for (Case c : leftOpenCases) {
            FeedItem post = new FeedItem();
            post.ParentId = c.id;
            post.type = 'LinkPost';
            post.Title = 'Case :' + c.casenumber + ' has been left in an opened state. Please click on this text and take action before starting any new cases.';
            post.linkUrl = '/apex/vfCaseDetail?id=' + c.id + '&isdtp=vw';
            posts.add(post);
        }
        posts = ChatterUtils.addFeedItemLinks(posts);
        return posts;
    }
    public List<Attachment> retrieveCaseAttachments(Case cse) {
        Integer iDebugMessages = 0;
        if (cse == null || cse.id == null) {
            return null;
        }
        List<Attachment> caseAttachments = new List<Attachment>();

        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('parentId').equals(cse.id));

        Set<Object> attachFields;

        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Body');


        attachFields = SoqlUtils.getAllFieldsSet('Attachment', false, excludeFields);
        String soql = new al.SoqlBuilder()
                .selectx(attachFields)
                .selectx(new Set<String>{
                        'createdby.lastname'
                })
                .fromx('Attachment')
                .wherex(whereC)
                .orderByx(new al.OrderBy('lastmodifieddate'))
                .toSoql();

        try {
            caseAttachments = Database.query(soql);
        } catch (Exception e) {
            String msg = '';
            msg += e.getStackTraceString();
            msg += '<font color=\'red\'><b>' + e.getMessage() + '</b></font>';
            System.debug(logginglevel.error, e);
            debugMessages.add(new DebugMessage('<b>retrieveCaseAttachments: exception thrown:</b>' + msg));
        }
        if (caseAttachments == null || caseAttachments.isEmpty()) {
            if (iDebugMessages < MAX_DEBUG_MESSAGES) {
                debugMessages.add(new DebugMessage('retrieveCaseAttachments: No attachments for SOQL=:' + soql));
                iDebugMessages++;
            }
            system.debug(logginglevel.debug, 'No case attachments for SOQL=' + soql);
        }
        return caseAttachments;

    }

    public List<Case_Review__c> retrieveCaseReviews(Case cse) {
        Integer iDebugMessages = 0;
        if (cse == null || cse.id == null) {
            return null;
        }
        List<Case_Review__c> caseReviews = new List<Case_Review__c>();

        al.NestableCondition whereC = new al.AndCondition();

        whereC.add(new al.FieldCondition('Case__c').equals(cse.id));

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case_Review__c', false))
                .selectx(new Set<String>{
                        'Service_By__r.name'
                })
                .fromx('Case_Review__c c')
                .wherex(whereC)
                .orderByx(new al.OrderBy('lastmodifieddate'))
                .toSoql();
        try {
            caseReviews = Database.query(soql);
        } catch (Exception e) {
            String msg = '';
            msg += e.getStackTraceString();
            msg += '<font color=\'red\'><b>' + e.getMessage() + '</b></font>';
            System.debug(logginglevel.error, e);
            debugMessages.add(new DebugMessage('<b>retrieveCasesReviews: exception thrown:</b>' + msg));
        }
        if (caseReviews == null || caseReviews.isEmpty()) {
            if (iDebugMessages < MAX_DEBUG_MESSAGES) {
                debugMessages.add(new DebugMessage('retrieveCaseReviews: No case Reviews for SOQL=:' + soql));
                iDebugMessages++;
            }
            system.debug(logginglevel.info, 'No case reviews for SOQL=' + soql);
        }

        return caseReviews;
    }
    public List<Case> retrieveCasesLeftOpen(String status, Integer minutesBeforeNow) {
        Integer iDebugMessages = 0;
        List<Case> cases = new List<Case>();
        DateTime lowestTime = Datetime.now().addMinutes(minutesBeforeNow);
        //DateTime.

        al.NestableCondition whereC = new al.AndCondition();

        whereC.add(new al.FieldCondition('ownerId').equals(UserInfo.getUserId()));
        whereC.add(new al.FieldCondition('status').equals(status));
        whereC.add(new al.FieldCondition('start_it__c').equals(true));
        //whereC.add(new al.FieldCondition('lastModifiedDate',al.Operator.LESS_THAN_OR_EQUAL_TO,lowestTime));
        whereC.add(new al.FieldCondition('left_open__c').equals(true));

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case', false))
                .selectx(new Set<String>{
                        'contact.name'
                })
                .fromx('Case c')
                .wherex(whereC)
                .orderByx(new al.OrderBy('lastmodifieddate').descending())
                .toSoql();
        try {
            cases = Database.query(soql);
        } catch (Exception e) {
            String msg = '';
            msg += e.getStackTraceString();
            msg += '<font color=\'red\'><b>' + e.getMessage() + '</b></font>';
            debugMessages.add(new DebugMessage('<b>retrieveCasesLeftOpen: exception thrown:</b>' + msg));
        }
        if (cases == null || cases.isEmpty()) {
            if (iDebugMessages < MAX_DEBUG_MESSAGES) {
                debugMessages.add(new DebugMessage('retrieveCasesLeftOpen: No open cases found for SOQL=:' + soql));
                iDebugMessages++;
            }
        }

        return cases;
        //SELECT ID FROM Case WHERE OwnerId = :userInfo.getUserId() AND status = 'Open' AND lastModifiedDate <= :datetime.now().addMinutes(-5) AND Left_Open__c = true ORDER BY LastModifiedDate DESC];
    }
    public Consultation__c retrieveCurrentCaseConsultation(Case cse) {

        debugMessages = new List<DebugMessage>();
        //debugMessages.add(new debugMessage('ELC-in retrieveCurrentCaseConsultation with cse.id = '+ cse.id));
        Consultation__c currentConsultation;

        List<Consultation__c> consultations;
        try {
            consultations = retrieveConsultations(cse);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            return null;
        }
        if (consultations == null || consultations.isEmpty()) {
            debugMessages.add(new DebugMessage('No consultations for cse' + cse));
            return null;
        }

        /**
        RJN Below commented out due to the fact that multiple services related to a case may not have dispositions some how.
        7 lines below this block added in preference.

        if (consultations != null && consultations.size() > 1) {

            for(consultation__c c: consultations) {
                if(c.disposition__c == null || c.disposition__c.trim() == ''){
                    currentConsultation = c;
                    break;
                }
            }

            currentConsultation = consultations
        } else { //if(consultations!=null && consultations.size() == 1){
            currentConsultation = consultations[0];
        }
        */
        if (consultations != null && consultations.size() > 1) {
            currentConsultation = consultations[0];
        } else {
            if (consultations != null && consultations.size() == 1) {
                currentConsultation = consultations[0];
            }
        }

        if (currentConsultation == null) {
            if (consultations != null && consultations.size() > 1) {
                //      currentConsultation = consultations[consultations.size() - 1];
                currentConsultation = consultations[0];
            }
        }

        return currentConsultation;
    }
    /**
     * Original retrieveCaseSummaryData.. ie includes activities
     */
    public Case retrieveCaseSummaryDataWithActivities(Id caseId) {
        Case c;

        Set<String> setActivityHistoryFields = new Set<String>{
                'Id', 'WhoId', 'WhatId', 'What.Name', 'Subject', 'IsTask', 'ActivityType', 'ActivityDate', 'Status', 'Owner.Name', 'Description', 'LastModifiedDate', 'EndDateTime', 'Group__c', 'Support_Type__c'
        };
        //fp7
        setActivityHistoryFields.add('CallObject');
        setActivityHistoryFields.add('CallDisposition');
        Set<String> setOpenActivityFields = new Set<String>{
                'Id', 'ActivityDate', 'WhoId', 'WhatId', 'What.Name', 'Subject', 'IsTask', 'ActivityType', 'ActivityDate', 'Status', 'Owner.Name', 'Description', 'LastModifiedDate', 'Group__c', 'Support_Type__c'
        };
        //fp7
        setOpenActivityFields.add('CallObject');
        setOpenActivityFields.add('CallDisposition');

        /* needed for non admin profiles when querying activityhistory per sfdc implementation restriction*/
        /* ELC 8/19/15 changed sort on ActivityDate  to desc vs. asc per SF requirements */
        List<al.OrderBy> lOrderBys = new List<al.OrderBy>();
        lOrderBys.add(new al.OrderBy('ActivityDate').descending().nullslast());
        lOrderBys.add(new al.OrderBy('LastModifiedDate').descending());
        /* needed for non admin profs when querying openactivities per sfdc */
        List<al.OrderBy> lOrderBysOpen = new List<al.OrderBy>();
        lOrderBysOpen.add(new al.OrderBy('ActivityDate').ascending().nullslast());
        lOrderBysOpen.add(new al.OrderBy('LastModifiedDate').descending());
        //in contact filters

        al.NestableCondition wherec = new al.AndCondition();
        /*
        wherec.add( new al.NotCondition(new al.AndCondition()

                .add(new al.FieldCondition('subject').likex('Call%'))
                .add(new al.FieldCondition('CallDurationInSeconds').equals(null))
                .add(new al.FieldCondition('CallDurationInSeconds').equals(0))


        )
        );
        */
        wherec.add(
                new al.FieldCondition('CallObject').equals(null)

        );


        //{ whereC.add(new al.FieldCondition('c.contact_identifier__c').likex(contactId.trim()));}
        //whereArC.add(new al.FieldCondition('Status__c').equals(pStatus));
        //whereArC.add(new al.FieldCondition('Distribution__c').equals(pDistribution));


        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case', false))
                .selectx(new Set<String>{
                        'c.CreatedBy.Name', 'c.lastmodifiedby.name', 'c.selected_subject__r.title__c', 'c.selected_subject__r.name'
                })
                .selectx(new Set<String>{
                        'c.owner.name,c.createdby.communitynickname', 'c.lastmodifiedby.communitynickname', 'c.contact.name', 'c.Last_Service_By__r.communitynickname'
                })
                .selectx(new Set<String>{
                        'c.contact.email'
                })
                .selectx(new Set<String>{
                        'c.last_service_by__r.name'
                })
                .selectx(
                        new al.SoqlBuilder()
                                .selectx(setActivityHistoryFields)
                                .fromx('ActivityHistories')
                                /* in contact */
                                //.wherex (new al.FieldCondition('id').equals(caseId))
                                //  .wherex(wherec)


                                .orderbyx(lOrderBys)  //needed for non admin profiles when querying activityhistory per sfdc implementation restriction
                                .limitx (500)
                ) ///needed for non admin profiles when querying activityhistory per sfdc implementation restriction
                .selectx(
                        new al.SoqlBuilder()
                                .selectx(setOpenActivityFields)
                                .fromx('OpenActivities')
                                //.wherex(wherec)
                                .orderbyx(lOrderBysOpen)  //needed for non admin profiles when querying openactivities per sfdc implementation restriction
                                .limitx (500)
                )  /* needed for non admin profiles when querying activityhistory per sfdc implementation restriction*/
                .fromx ('Case c ')
                .wherex (new al.FieldCondition('id').equals(caseId))
                .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators());
        //   thisCase = database.query(Utilities.getSelectStar('Case') + ', Contact.Name, Adverse_party__r.Name, (SELECT ActivityDate, Description, Subject, Status, activityType, Id FROM ActivityHistories ORDER BY ActivityDate DESC) FROM Case  WHERE Id = \'' + caseId + '\'');
        try {
            c = Database.query(soql);
        } catch (Exception e) {
            String msg = 'In catch in retrieveCaseSummaryData.  CaseId : ' + caseId + ' ex=' + e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, msg));
            System.debug(logginglevel.ERROR, e);
        }

        if (c != null) {
            //this.isCaseClosed = 'Closed'.equalsIgnoreCase(c.status);
        } else {
            String msg = 'In retrieveCaseSummaryData. No case returned for caseId : ' + caseId;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, msg));
        }
        return c;
    }
    /**
     * modified to remove retrieval of activitiy related data.
     */
    public Case retrieveCaseSummaryData(Id caseId) {
        Case c;
        //have no idea what fields that every caller needs to lets paste them all in here (or most.. prod and dev or not in sync)
        //but not execute get describe calls
        //change dynamic soql to static
        /*

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case', false))
                .selectx(new Set<String>{
                        'c.CreatedBy.Name', 'c.lastmodifiedby.name', 'c.selected_subject__r.title__c', 'c.selected_subject__r.name'
                })
                .selectx(new Set<String>{
                        'c.owner.name,c.createdby.communitynickname', 'c.lastmodifiedby.communitynickname', 'c.contact.name', 'c.Last_Service_By__r.communitynickname'
                })
                .selectx(new Set<String>{
                        'c.contact.email'
                })
                .selectx(new Set<String>{
                        'c.last_service_by__r.name'
                })
                .fromx ('Case c ')
                .wherex (new al.FieldCondition('id').equals(caseId))
                .toSoql();
        */
        try {
            //c = Database.query(soql);
            c =   [select
                    AccountId,Alert__c,Approval_Status__c,AssetId,BusinessHoursId,CaseNumber,Case_Identifier__c,
                    ClosedDate,ContactId,CreatedById,CreatedDate,Date_Referral_Accepted__c,Date_Referred__c,Description,Description_First255__c,
                    Ever_Closed__c,Form_ID__c,Id,IsClosed,IsClosedOnCreate,IsDeleted,IsEscalated,IsSelfServiceClosed,Is_Service_Form_Open__c,
                    Jurisdiction__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Last_Contact__c,Last_Service_By__c,Last_Service_Date__c,
                    Left_Open__c,Module__c,New_Case_Review__c,No_Parties_Clicked__c,Origin,
                    Outcome_Survey_Link_for_VF__c,Outcome_Survey_Link__c,OwnerId,ParentId,Practice_Area__c,Priority,Problem_Category__c,
                    Problem_Code__c,Project__c,Reason,RecordTypeId,Resume__c,Selected_Subject__c,Service_Form_Guid__c,
                    Service_Totals__c,Solution_Description__c,Start_It__c,Status,Status_Per_Survey__c,Subject,Subject_Stage__c,
                    SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Survey_Completed_Time__c,Survey_Completed__c,Survey_Sent__c,
                    Survey_Status__c,SystemModstamp,Temp_Record__c,Total_Nbr_of_Services__c,Total_Review_Time_Minutes__c,Total_Review_Time__c,
                    Total_Services__c,Total_Service_Time_Minutes__c,Total_Service_Time_RS__c,Total_Service_Time__c,Type,View_Case__c,
                    CreatedBy.Name, lastmodifiedby.name,selected_subject__r.title__c,c.selected_subject__r.name,
                    c.owner.name,c.createdby.communitynickname, c.lastmodifiedby.communitynickname, c.contact.name, c.Last_Service_By__r.communitynickname,
                    c.contact.email,c.last_service_by__r.name, /* sergii */ Referral_Document_Generated__c,/* apauk */  c.contact.Birthdate, /* elc */ c.contact.Phone,
                    c.contact.firstname, c.contact.lastname, c.contact.MailingPostalCode, c.contact.Language__c, c.contact.Disability__c, c.contact.Age_at_intake__c      
            from     Case c
            where    id = :caseId ];
        } catch (Exception e) {
            String msg = 'In catch in retrieveCaseSummaryData.  CaseId : ' + caseId + ' ex=' + e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, msg));
            System.debug(logginglevel.ERROR, e);
        }

        if (c != null) {
            //this.isCaseClosed = 'Closed'.equalsIgnoreCase(c.status);
        } else {
            String msg = 'In retrieveCaseSummaryData. No case returned for caseId : ' + caseId;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, msg));
        }
        return c;

    }
    public Case_Party__c retrieveCaseParty(Id caseId, Id contactId) {
        Case_Party__c cp;
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('case__c').equals(caseId));
        whereC.add(new al.FieldCondition('contact__c').equals(contactId));
        List<Case_Party__c> caseParties = this.retrieveCaseParties(whereC);
        if (caseParties != null && !caseParties.isEmpty()) {
            cp = caseParties[0];
        }
        return cp;
    }
    public List<Case_Party__c> retrieveCaseParties(Case cse) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('case__c').equals(cse.id));
        return this.retrieveCaseParties(whereC);
    }
    public Case_Party__c retrieveCaseParty(Id cpId) {
        Case_Party__c cp;
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('id').equals(cpId));
        List<Case_Party__c> caseParties = this.retrieveCaseParties(whereC);
        if (caseParties != null && !caseParties.isEmpty()) {
            cp = caseParties[0];
        }
        return cp;

    }
    public Consultation__c retrieveConsultation(Id serviceId) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('id').equals(serviceId));
        List<Consultation__c> cons = this.retrieveConsultations(whereC);
        Consultation__c service;
        if (cons != null && !cons.isEmpty()) {
            service = cons[0];
        }
        return service;
    }
    public List<Carpls_Appt__c> retreiveCarplsAppt(Case cse) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('case__c').equals(cse.id));
        return this.retrieveCarplsAppt(whereC);
    }
    public List<Consultation__c> retrieveConsultations(Case cse) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('case__c').equals(cse.id));
        return this.retrieveConsultations(whereC);
    }

    public List<Conflict_Log__c> retrieveContlictLogs(Case cse) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('case__c').equals(cse.id));
        return this.retrieveConflictLogs(whereC);
    }
    public List<Conflict_Log__c> retrieveContlictLogs(Contact c) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('contact__c').equals(c.id));
        return this.retrieveConflictLogs(whereC);
    }
    public List<Conflict_Log__c> retrieveConflictLogs(Id clId) {
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('id').equals(clId));
        return this.retrieveConflictLogs(whereC);
    }
    public List<Conflict_Log__c> retrieveConflictLogsBySearchLogId(Id searchLogId) {
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('Search_Log__c').equals(searchLogId));
        return this.retrieveConflictLogs(whereC);
    }
    /**
     * RJN CPU Time Limit fix.. very iffy. this is somewhat of a guess on the cl fields needded.
     */
    public List<Conflict_Log__c> retrieveConflictLogs(al.NestableCondition whereC) {

        Set<String> excludeFields = new Set<String>();
        Set<String> excludeFields2 = new Set<String>();
        excludeFields.add('Description');
        excludeFields.add('Note__c');
        excludeFields2.add('Description');
        excludeFields2.add('Solution_Description__c');

        List<Conflict_Log__c> conflictLogs;
/*

Approved_By__c,Association_Text__c,Association__c,Case_Party_Type__c,Case__c,Contact__c,CreatedById,CreatedDate,
Finding__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,legacyId__c,
Legacy_Created_By__c,Name,OwnerId,Potential_Client_Text__c,Potential_Client__c,
Reason__c,RecordTypeId,SearchContactReviewed__c,Search_Log__c FROM Conflict_Log__c
 */

        String soql = new al.SoqlBuilder()
                .selectx(new Set<String>{
                        'name', 'Potential_Client_Text__c','SearchContactReviewed__c','contact__c','Case_Party_Type__c',
                        'Case__r.casenumber','Finding__c','Reason__c','Approved_By__c','CreatedDate','Contact__r.name',
                        'Case__c','Id','Potential_Client__c','Search_Log__c','Association_Text__c','Association__c','RecordTypeId',
                        'Case__r.casenumber'
                })
                .selectx(new Set<String>{
                        'createdBy.name', 'SearchContactReviewed__r.name', 'createdby.communitynickname'
                })
                .fromx ('Conflict_Log__c')
                .wherex(whereC)
                .toSoql();
        /*

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Conflict_Log__c', false))
                .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'contact__r', excludeFields))
                .selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r', excludeFields2))
                .selectx(new Set<String>{
                        'createdBy.name', 'SearchContactReviewed__r.name', 'createdby.communitynickname'
                })
                .fromx ('Conflict_Log__c')
                .wherex(whereC)
                .toSoql();
       */
        try {
            conflictLogs = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return conflictLogs;
    }


    private List<Case_Party__c> retrieveCaseParties(al.NestableCondition whereC) {
        //rjn very late add.. some case party records are dissociated with their case records sometimes .
        //ie.. back.. browser refresh..etc.. lets pull these out of here as they can cause havoc.

        //----whereC.add(new al.FieldCondition('case__c').notequals( null ));
        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case_Party__c', false))
                .selectx(new Set<String>{
                        'createdby.name', 'createdby.communitynickname', 'contact__r.relationship__c'
                })
                .selectx(new Set<String>{
                        'contact__r.name', 'contact__r.phone', 'contact__r.birthdate', 'contact__r.aliases__c'
                })
                .selectx(new Set<String>{
                        'contact__r.mailingstreet', 'relationship__c', 'contact__r.phone', 'contact__r.birthdate'
                })
                //.selectx(new Set<String> {'contact__r.recordtype.name'}) @TODO Contact Type mod
                .selectx(new Set<String>{
                        'contact__r.category__c'
                })
                .selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r'))
                .fromx ('Case_Party__c')
                .wherex(whereC)
                .toSoql();

        List<Case_Party__c> caseParties;

        try {
            caseParties = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn, e);
        }
        return caseParties;
    }

    // ELC - added for CARPLS Connect
    public List<Case> retrieveCasesByReferral(Account acct, String pStatus, String pClosingCode) {
        if (acct == null) {
            debugMessages.add(new DebugMessage('Null acct passed to retrieveCasesByReferral'));
            return null;
        }
        al.NestableCondition whereArC = new al.AndCondition();
        whereArC.add(new al.FieldCondition('Account__c').equals(acct.id));
        whereArC.add(new al.FieldCondition('Status__c').equals(pStatus));
        //whereArC.add(new al.FieldCondition('Distribution__c').equals(pDistribution));
        whereArC.add(new al.FieldCondition('Closing_Code__c').equals(pClosingCode));

        String soql = new al.SoqlBuilder()
                .selectx(new Set<String>{
                        'case__c'
                })
                .fromx ('Applied_Resource__c')
                .wherex(whereArC)
                .toSoql() ;
        List<Applied_Resource__c> ars;

        try {
            ars = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn, e);
        }

        List<Id> lCaseIds = new List<Id>();

        for (Applied_Resource__c ar : ars) {
            lCaseIds.add(ar.case__c);
        }

        // if there are no cases, return null
        if (lCaseIds.size() < 1) {
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.SetCondition('id', al.Operator.INX, (lCaseIds)));

        // added the limit here to prevent View State errors
        soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case', false))
                .selectx(new Set<String>{
                        'createdby.name', 'createddate'
                })
                .selectx(new Set<String>{
                        'contact.name', 'contact.last_four_ssn__c'
                })
                .selectx(new Set<String>{
                        'contact.birthdate', 'selected_subject__r.title__c'
                })              
                .selectx(new Set<String>{
                        '(select account__r.name, rejected_reason__c, referral_note__c, status__c, createddate, lastmodifieddate from applied_resources__r)'
                })
                .fromx ('Case')
                .wherex(whereC)
                .orderbyx(new al.OrderBy('last_service_by__c').descending())
                .limitx (100)
                .toSoql() ;

        List<Case> cases = new List<Case>();

        try {
            cases = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn, e);
        }

        return cases;
    }
    // ELC - added for use on the Subject page
    public List<Case> retrieveCasesBySubject(Subject__c subj) {

        if (subj == null) {
            debugMessages.add(new DebugMessage('Null subject passed to retrieveCasesBySubject'));
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('selected_subject__c').equals(subj.id));

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case', false))
                .selectx(new Set<String>{
                        'createdby.name', 'last_service_by__r.communitynickname'
                })
                .selectx(new Set<String>{
                        'contact.name'
                })
                .fromx ('Case')
                .wherex(whereC)
                .orderbyx(new al.OrderBy('last_service_date__c').descending())
                .limitx (10)
                .toSoql() ;
        List<Case> cases;

        try {
            cases = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn, e);
        }
        return cases;
    }
    public Note retrieveLatestCaseSvcNote(Case cse, Consultation__c svc) {
        Note latestNote;
        List<NotesWrapper> noteWraps = retrieveCaseConsultationNotesWraps(cse);
        if (noteWraps != null && !noteWraps.isEmpty()) {
            NotesWrapper latestNoteWr = noteWraps[noteWraps.size() - 1];
            if (latestNoteWr.note != null && latestNoteWr.note.ParentId == svc.id) {
                latestNote = latestNoteWr.note;
            }
        }
        return latestNote;
    }
    public List<NotesWrapper> retrieveCaseConsultationNotesWraps(Case cse) {
        Datetime dt;
        List<Consultation__c> cons = this.retrieveConsultations(cse);
        if (cons == null || cons.isEmpty()) {
            system.debug(logginglevel.info, 'no consultations for case ' + cse.caseNumber);
            return null;
        }
        List<Id> consIds = new List<Id>();
        for (Consultation__c con : cons) {
            consIds.add(con.id);
        }
        List<NotesWrapper> notesWrappers = new List<NotesWrapper>();
        List<Note> notes = new List<Note>();
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.SetCondition('parentId', al.Operator.INX, consIds));
        //whereClause.add(new al.SetCondition('id',al.Operator.NOT_IN,templateIds));
        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Note', false))
                .selectx(new Set<Object>{
                        'parentid'
                })
                .selectx(new Set<Object>{
                        'parent.name'
                })
                .selectx(new Set<Object>{
                        'createdBy.name', 'lastModifiedBy.name'
                })
                .fromx ('Note')
                .wherex(whereC)
                .orderByx(new al.OrderBy('CreatedDate'))
                .toSoql();

        try {
            notes = Database.query(soql);

        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        Set<Id> setIds = new Set<Id>();
        for (Note n : notes) {
            setIds.add(n.parentId);
        }
        //Map<Id, Consultation__c> mapOfNotedByParetId = new Map<Id, Consultation__c>([SELECT Id,AOC__r.Name FROM Consultation__c WHERE Id IN: setIds AND AOC__r.Name != null]);
        Map<Id, Consultation__c> mapOfNotedByParetId = new Map<Id, Consultation__c>([SELECT Id,AOC__r.Name, AOC__c FROM Consultation__c WHERE Id IN: setIds]);

        if (notes != null) {
            for (Note n : notes) {
                for (Consultation__c con2 : cons) {
                    if (con2.id == n.parentid) {
                        dt = con2.createddate;
                    }
                }
                if(mapOfNotedByParetId.containsKey(n.parentid)){
                    Consultation__c consult = mapOfNotedByParetId.get(n.ParentId);
                    
                    if (consult.AOC__c!=null) {
                    NotesWrapper nw = new NotesWrapper(n, dt ,mapOfNotedByParetId.get(n.parentId).AOC__r.Name );
                    notesWrappers.add(nw);
                    }
                    else {
                    	NotesWrapper nw = new NotesWrapper(n, dt ,mapOfNotedByParetId.get(n.parentId).AOC__r.Name );
                        notesWrappers.add(nw);
                    }
                    
                }
            }
            
        }
        notesWrappers.sort();
        return notesWrappers;
    }
    
    public List<CARPLS_Appt__c> retrieveCarplsAppt(al.NestableCondition whereC) {
        String soql = new al.SoqlBuilder()
            .selectx(new set<String>{'Name','Applied_Resource__c','Start_DateTime__c', 'Status__c' , 'Type__c'})
            .fromx ('CARPLS_Appt__c')
                .wherex(whereC) // NOT NOT CHANGE THIS ORDER BY
                .orderByx(new al.OrderBy('CreatedDate').descending())
                .toSoql();
        
        List<CARPLS_Appt__c> appts;

        try {
            appts = Database.query(soql);
        } Catch (Dmlexception e) {
            system.debug(e);
        }
        return appts;
    }
    /**
     * RJN CPU Time Limit fix.. very iffy. this is somewhat of a guess on the case fieldsd needed.
     */
    private List<Consultation__c> retrieveConsultations(al.NestableCondition whereC) {
        String soql = new al.SoqlBuilder()
                .selectx(new set<String> {'AOC_Consult__c','Applied_Resources_Accepted__c','CarplsConnect_Agency__c','Case__c',
                        'Client_Sat_Survey_Link__c','Client__c','Consultation_Category__c','Contact_xx__c','Contact__c','CreatedById',
                        'CreatedDate','Created_Date_for_CST_CDT__c','Date_Closed__c','Date_Opened__c','Date_Survey_Emailed__c','Disposition__c',
                        'FAQ__c','Fee__c','Follow_Up_Date__c','Follow_Up_Public_Group__c','Follow_Up_Reason__c','Form_ID__c',
                        'Has_Been_Reviewed__c','Id','Is_Incomplete_Service__c','LastActivityDate','LastModifiedById','LastModifiedDate',
                        'Last_Contact__c','Last_Serviced_By__c','Legal_Referral__c','Location__c','Name','Parties_Accepted__c',
                        'Project__c','Publication__c','Queue__c','Rejection__c','Request_Follow_Up_Reason_PL__c','Review_Case__c','Service_Code__c',
                        'Service_Disposition_Accepted__c','Service_End_Time__c','Service_Form_Guid__c',
                        'Service_Start_Time__c','Service_Time__c','Social_Referral__c','Status__c','Subject__c',
                        'View_Case__c','Weblink__c','Survey_Sent__c'})
                .selectx(new set<String> { 'case__r.AccountId','case__r.Alert__c','case__r.Approval_Status__c','case__r.CaseNumber',
                        'case__r.Case_Identifier__c','case__r.ClosedDate','case__r.ContactId',
                        'case__r.CreatedById','case__r.CreatedDate','case__r.Date_Referral_Accepted__c','case__r.Date_Referred__c',
                        'case__r.Ever_Closed__c','case__r.Form_ID__c','case__r.Id','case__r.IsClosed','case__r.Is_Service_Form_Open__c',
                        'case__r.Jurisdiction__c','case__r.LastModifiedById','case__r.LastModifiedDate','case__r.Last_Service_By__c',
                        'case__r.Last_Service_Date__c','case__r.Left_Open__c','case__r.New_Case_Review__c',
                        'case__r.OwnerId','case__r.Service_Form_Guid__c','case__r.Service_Totals__c',
                        'case__r.Start_It__c','case__r.Status' } )
                .selectx(new Set<String>{
                        'createdBy.name', 'createdby.communitynickname'
                })
                .selectx(new Set<String>{
                        'lastModifiedBy.name', 'lastModifiedBy.communitynickname'
                })
                .fromx ('Consultation__c')
                .wherex(whereC) // NOT NOT CHANGE THIS ORDER BY
                .orderByx(new al.OrderBy('CreatedDate').descending())
                .toSoql();
        /*
        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Consultation__c', false))
                .selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r'))
                //.selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Contact_xx__r' ))
                .selectx(new Set<String>{
                        'createdBy.name', 'createdby.communitynickname'
                })
                .selectx(new Set<String>{
                        'lastModifiedBy.name', 'lastModifiedBy.communitynickname'
                })
                .fromx ('Consultation__c')
                .wherex(whereC) // NOT NOT CHANGE THIS ORDER BY
                .orderByx(new al.OrderBy('CreatedDate').descending())
                .toSoql();
        */
        List<Consultation__c> consultations;

        try {
            consultations = Database.query(soql);
        } Catch (Dmlexception e) {
            system.debug(e);
        }
        return consultations;
    }
    public Consultation__c buildConsultation(Case cse) {
        Consultation__c cons = new Consultation__c();
        cons.Subject__c = 'Service ' + string.valueOf(date.today());
        cons.Consultation_Category__c = cse.Practice_Area__c + '_' +
                cse.Problem_Category__c + '_' + cse.Problem_Code__c;
        cons.last_contact__c = date.today();
        cons.contact_xx__c = cse.contactId;
        cons.Case__c = cse.Id;
        return cons;
    }

    public Note buildConsultationNote(Case cse, Consultation__c cons) {
        Note n = new Note();
        n.Title = 'Opened';
        n.body = 'Case opened from ' + cse.Origin + ' by ' + UserInfo.getName() + ' on ' + datetime.now().format();
        n.ParentId = cons.Id;
        return n;
    }
    public List<Case_Party__c> possibleConflictingCasePartyRecords(Id contactId, String searchType) {
        List<Case_Party__c> conflictingCasePartyRecords;

        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('contact__c').equals(contactId));

        //whereC.add(new al.FieldCondition('case__c').notequals( null));
        //whereC.add(new al.FieldCondition('case__c').notequals(''));

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Case_Party__c', false))
                .selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r'))
                .selectx(new Set<String>{
                        'createdBy.name'
                })
                .fromx ('Case_Party__c')
                .wherex(whereC)
                .toSoql();

        try {
            conflictingCasePartyRecords = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return conflictingCasePartyRecords;
    }
    /**
     * RJN CPU Time Limit fix.. not I see nothing using the case fields by a search but double check as things could go boom!
     */
    public List<Possible_Conflict__c> retrievePossibleCaseConflicts(Id slId, String searchType) {
        List<Possible_Conflict__c> conflicts;
        al.NestableCondition whereC = new al.AndCondition();
        if ('Client'.equalsIgnoreCase(searchType)) {
            whereC.add(new al.FieldCondition('search_log_client__c').equals(slId));
        }
        if ('Party'.equalsIgnoreCase(searchType)) {
            whereC.add(new al.FieldCondition('search_log_Party__c').equals(slId));
        }
        whereC.add(new al.FieldCondition('marked_conflict__c').equals(null));

        //rick here
        String soql = new al.SoqlBuilder()
                .selectx(new Set<String> {'Case__c','Contact_Being_Reviewed__c','CreatedById','CreatedDate','Id','LastModifiedById','LastModifiedDate','Marked_Conflict__c','Name','OwnerId','Possible_Reason__c','Search_Log_Client__c','Search_Log_Party__c'})

                /*
                .selectx(SoqlUtils.getAllFieldsSet('Possible_Conflict__c', false))

                .selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r'))
                */
                .selectx(new Set<String>{
                        'createdBy.name'
                })
                .fromx ('Possible_Conflict__c')
                .wherex(whereC)
                .toSoql();

        try {
            conflicts = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return conflicts;
    }
    public List<String> buildCaseCats(Case cse) {
        List<string> cats = new List<string>();

        if (cse.Problem_Category__c != null && cse.Problem_Category__c.length() > 0) {
            cats.add(cse.Practice_area__c + '_2');
            cats.add(cse.Practice_area__c + '_2' + cse.Problem_Category__c + '_9');
            cats.add(cse.Practice_area__c + '_2' + cse.Problem_Category__c + '_9' + cse.Problem_Code__c);
        }
        return cats;
    }
    /* @TODO Obsolete?
    public List<String> buildCurrentConsTags(Consultation__c cons) {

        List<string> strTags = null;
        List<string> tempstrTags = null;

        if (cons.tags__c != null && cons.tags__c.length() > 1) {
            tempstrTags = cons.tags__c.split(';');
        }else{
            tempstrTags = new List<string>();
        }
        strTags = new List<string>();
        for (string s : tempstrTags){
            system.debug('Tag: ' + s.trim());
            strTags.add(s.trim());
        }
        return strTags;
    }
    */

    /* @TODO Obsolete??
    public List<Consultation_Question__c> retrieveConsQuestions(List<String> strTags) {
        if(strTags == null || strTags.isEmpty()) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();
        al.SetCondition inClauseName = new al.SetCondition('name__c',al.Operator.INX,strTags);
        al.SetCondition inClauseGroup = new al.SetCondition('group__c',al.Operator.INX,strTags);

        whereC.add(inClauseName);
        whereC.add(inClauseGroup);

        return retrieveQuestions(whereC);
    }
    */
    /*
    @TODO Obsolete ??
    public List<Consultation_Question__c> retrieveCaseQuestions(List<String> strCats) {
        if(strCats == null || strCats.isEmpty()) {
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        al.SetCondition inClause = new al.SetCondition('Consultation_Category_N__c',al.Operator.INX,strCats);
        whereC.add(inClause);

        return retrieveQuestions(whereC);
    }
    */
    public List<Consultation_Question__c> retrieveCaseLitigationQuestions(Subject__c s) {
        if (s == null) {
            System.debug(logginglevel.warn, 'passed subject cannot be null!');
            return null;
        }
        if (!s.show_litigation_questions__c) {
            System.debug(logginglevel.warn, 'passed subject does not have show litigation checked.');
        }
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('is_litigation__c').equals(true));
        return retrieveQuestions(whereC);
    }
    /* @TODO Obsolete?
    public List<Consultation_Question__c> retrieveCaseQuestions(List<String> strCats, Subject__c s) {
        if(strCats == null || strCats.isEmpty()) {
            return null;
        }
        if(s == null ) {
            return null;
        }

        al.NestableCondition whereC = new al.OrCondition();
        al.SetCondition inClause = new al.SetCondition('Consultation_Category_N__c',al.Operator.INX,strCats);
        whereC.add(inClause);

        //String subjectLitigation = s.Litigation__c;
        //if(subjectLitigation != null && !subjectLitigation.contains('Pre')){
         //   whereC.add(new al.FieldCondition('is_litigation__c').equals(true));
        //}



        return retrieveQuestions(whereC);
    }
    */
    public List<Consultation_Question__c> retrieveCaseLitQuestions(Subject__c s) {

        if (s == null) {
            return null;
        }
        if (!s.show_litigation_questions__c) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('is_litigation__c').equals(true));
        return retrieveQuestions(whereC);
    }
    public List<Consultation_Question__c> retrieveQuestions(al.NestableCondition aWhereC) {

        List<al.OrderBy> lOrderBys = new List<al.OrderBy>();

        lOrderBys.add(new al.OrderBy('Group__c'));
        lOrderBys.add(new al.OrderBy('Order__c').ascending().nullslast());

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Consultation_Question__c', false))
                .selectx(new Set<String>{
                        'createdBy.name'
                })
                .fromx ('Consultation_Question__c')
                .wherex(awhereC)
                .orderbyx(lOrderBys)
                .toSoql();

        List<Consultation_Question__c> questions = Database.query(soql);
        return questions;
    }
    public List<Survey_Feedback__c> retrieveSurveysByCase(Case cse) {
        if (cse == null) {
            debugMessages.add(new DebugMessage('Null case passed to retrieveSurveysByCase'));
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('case__c').equals(cse.id));
        return retrieveSurveys(whereC);
    }
    public List<Survey_Feedback__c> retrieveSurveys(al.NestableCondition aWhereC) {

        List<al.OrderBy> lOrderBys = new List<al.OrderBy>();
        List<Survey_Feedback__c> surveys = new List<Survey_Feedback__c>();

        lOrderBys.add(new al.OrderBy('createddate'));

        String soql = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Survey_Feedback__c', false))
                .selectx(new Set<String>{
                        'recordtype.name, service__r.name '
                })
                .fromx ('Survey_Feedback__c')
                .wherex(awhereC)
                .orderbyx(lOrderBys)
                .toSoql();
        try {
            surveys = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return surveys;
    }
    public Consultation__c buildNewService(Case cse) {
        Consultation__c cons = new Consultation__c();
        cons.Case__c = cse.id;
        cons.Status__c = 'Open';
        cons.Subject__c = 'Service ' + string.valueOf(date.today());
        cons.Consultation_Category__c = cse.Practice_Area__c + '_' +
                cse.Problem_Category__c + '_' + cse.Problem_Code__c;
        cons.last_contact__c = date.today();
        cons.contact_xx__c = cse.contactId;
        return cons;
    }
    /**
     *  Called from ctrlCase.. UT Covered in TEST_CaseUtils.
     */
    public Boolean sendClientSatSurvey(Case cse, Consultation__c currentSvc) {
        Boolean emailSent = false;
        if (cse == null || currentSvc == null) {
            return false;
        }
        String cEmail;
        try {
            if (cse.contact.email != null) {
                cEmail = cse.contact.email;
            } else {
                Contact c = [select email from contact where id = :cse.ContactId];
                cEmail = c.email;
            }
        } catch (Exception e) {
            system.debug(logginglevel.error, e);
        }

        String emailAddr = cEmail;
        List<String> emailAddrs = new List<String>();
        emailAddrs.add(emailAddr);
        String subj = 'CARPLS Legal Aid Survey';
        Boolean noReply = true;
        String htmlBody = 'Dear ' + cse.contact.name + ',<br><br>';
        htmlBody += 'Thank you for contacting CARPLS Legal Aid. We hope that we were able ';
        htmlBody += 'to assist you with your legal problem.  Your feedback is important ';
        htmlBody += 'to us. Please follow the link below to complete a short survey and help ';
        htmlBody += 'us to improve our services to clients.<br><br>';
        htmlBody += '<a href="https://www.getfeedback.com/r/D7FK126r?ConsultationId=' + currentSvc.id;
        htmlBody += '&CaseId=' + cse.id + '&Contact_Name=' + cse.contact.name;
        htmlBody += '">';
        htmlBody += 'CARPLS Survey</a><br><br>';
        htmlBody += 'Sincerely,<br>Patricia Wrona<br>Director of Legal Services<br>CARPLS Legal Aid';

        if (currentSvc.service_Code__c != null && currentSvc.survey_sent__c != true &&
                currentSvc.Service_Code__c.contains('Legal Advice') && emailAddr != null) {
            system.debug('calling sendEmailTemplate with cse.contact.id = ' + cse.contact.id + ' and service = ' + currentSvc.id);

            emailSent = Utilities.sendEmailTemplate('Client Satisfaction Survey', cse.contactId, currentSvc.id);
            if (!emailSent) {
                System.debug('Email send failed in ctrlCaseDetail.doSaveAndClose');
            }
        }

        return emailSent;
    }
    /*
     * Create 1280big guid (ripped off from SFDCFox)
     */
    public String createGuid() {
        String result =
                EncodingUtil.convertToHex(
                        Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format()))
                );
        return result;
    }


}