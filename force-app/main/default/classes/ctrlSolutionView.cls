public class ctrlSolutionView extends ctrlCarplesGeneric{
	public Solution__c solution { get; set; }
	public Boolean isResourceAlreadyApplied { get; set; }
	public Boolean isCaseOpen { get; set; }
	public Boolean hasActiveResources { get; set; }
	public Case cse {get; set;}
	public Consultation__c currentService {get; set;}
	public List<Applied_Resource__c> caseArs { get; Set; }
	public AppliedResourceUtils arUtils { get; Set; }
	public List<Applied_Resource__c> activeResources {get; set;}
	public Id solutionId {get; set;}
	public Applied_Resource__c newAppliedResource {get; set;}
	public boolean displayPopup {get;set;} 

	public ctrlSolutionView(ApexPages.StandardController stdController) {
		solutionId = stdController.getRecord().Id;
		doInitPage();
	}

	public PageReference doInitPage(){
		system.debug('init');
		initSectionState();
		
		Boolean checkActiveResources = false;
		//RJN Conditional switch this on.. if we want to check for active resources. default of custom setting is off..
		try {
			checkActiveResources = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'SolutionView_Check_Active_Resources__c');
			System.debug('checkActiveResources '+checkActiveResources);
		} catch(Exception e) {
			system.debug(logginglevel.error, '-- failed on check of active resources prob cause custom setting is missing..' + e);
		}
		
		this.hasActiveResources = false;
		this.isResourceAlreadyApplied = false;
		this.arUtils = new AppliedResourceUtils();   

		this.currentService = new Consultation__c();

		if(solutionId !=null){
			//String solutionQuery = getAllFieldsFromObject('Solution__c') + ' WHERE id =\'' + solutionId + '\'';
			String solutionQuery ='SELECT id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, level_of_merit__c, recommended_level_of_service__c, status__c, goal__c, practice_area__c, problem_category__c, problem_code__c, type__c, title__c FROM Solution__c WHERE id =\'' + solutionId + '\'';
			
			System.debug('solutionQuery '+solutionQuery);
			this.solution = (Solution__c) Database.query(solutionQuery);
			System.debug('solution '+solution);
		} 
		System.debug('Solution ' + solution);

		if(ApexPages.currentPage().getParameters().get('caseId') != null){
			System.debug(ApexPages.currentPage().getParameters().get('caseId'));
			String caseQuery = getAllFieldsFromObject('Case') + ' WHERE id =\''+ ApexPages.currentPage().getParameters().get('caseId') +'\'';
			System.debug(caseQuery);
			this.cse = (Case)Database.query(caseQuery);
			//this.isCaseOpen = !cse.IsClosed;
			this.isCaseOpen = evalCaseStatus();
			System.debug(cse);

			this.caseArs = arUtils.retrieveAppliedResources(cse);
			System.debug('caseArs '+caseArs);
			//if (checkActiveResources) {
				this.isResourceAlreadyApplied = retrieveArMatch();
			//}
			System.debug('isResourceAlreadyApplied '+isResourceAlreadyApplied);
		}
		System.debug('Case ' + cse);
		
		if (checkActiveResources) {
			getActiveResources();
			this.hasActiveResources = evalHasActiveResources();
			system.debug(logginglevel.info, '--- running with custom setting SolutionView_Check_Active_Resources__c switched on.. hasActiveResources=' + hasActiveResources);
		} else {
			system.debug(logginglevel.info, '--- running with custom setting SolutionView_Check_Active_Resources__c switched OFF');
		}

		return null;
	}

	private void initSectionState() {
        this.mSectionState = new Map<String,SectionStateBean>();    
        mSectionState.put( 'msgMainPanel', new SectionStateBean('msgMainPanel',false) );
    }  

	public void getActiveResources(){
		this.activeResources = [SELECT id,
									Name,
									Active__c,
									Status__c,
									Type__c,
									Title__c,
									RecordTypeId,
									RecordType.Name
								FROM Applied_Resource__c
								WHERE Case__r.id =: cse.Id
								AND Type__c = 'Solution'
								AND Active__c = true];
	}

	 public Boolean evalHasActiveResources() {
        Boolean hasResources =  activeResources != null && !activeResources.isEmpty();
        if(hasResources) {
            SectionStateBean ssBean = mSectionState.get('msgMainPanel');
            ssBean.showIt = true;
            ssBean.cssStyleClass = 'infoM4 message-panel-resources-override';
            String msg = '';
            if(activeResources.size() > 1) {
                msg+='The following Solutions are active and must be closed before adding a new one:';
            } else {
                msg+='The following Solution is active and must be closed before adding a new one:';
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
                ssBean.msg += '</br>' + 'Additionally, ' + msg;
            } else {
                ssBean.msg = msg;
            }
        }
        return hasResources;
    }

	private Boolean retrieveArMatch() {
        Boolean match = false;
     
            for(Applied_Resource__c ar : caseArs) {
                System.debug('Solution = '+solution+' ar = '+ar);
                if(ar.Solution__c == solution.Id) {
                    match = true;
                    break;
                }
            }
        
        if(match ) {
            SectionStateBean ssBean = mSectionState.get('msgMainPanel');
            ssBean.showIt = true;
            ssBean.cssStyleClass = 'infoM4';
            ssBean.msg = 'This resource has already been applied to case: '+cse.casenumber + '.';                       
        }       
        return match;
    }

	 public Boolean evalCaseStatus() {
        Boolean isOpen = false; 
        if(cse != null) {
            isOpen = !cse.IsClosed;
            if(!isOpen) {
                SectionStateBean ssBean = mSectionState.get('msgMainPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'infoM4';
                ssBean.msg = 'Case: '+cse.casenumber + ' is closed and must be open to add a resource!';       
            }
        }

        return isOpen;
    }

	public void closePopup() { 
		displayPopup = false; 
	} 
	public void showPopup() {
		newAppliedResource = new Applied_Resource__c();
		System.debug('newAppliedResource '+newAppliedResource);

		
		displayPopup = true; 
		System.debug('displayPopup '+displayPopup); 
	
	} 

	public void doSelectResource() {
		Boolean checkActiveResources = false;
		hasActiveResources = false;
		//RJN Conditional switch this on.. if we want to check for active resources. default of custom setting is off..
		try {
			checkActiveResources = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'SolutionView_Check_Active_Resources__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, '-- failed on check of active resources prob cause custom setting is missing..' + e);
		}

		if(checkActiveResources){
			getActiveResources();
			hasActiveResources =  activeResources != null && !activeResources.isEmpty();
			system.debug(logginglevel.info, '--- running with custom setting SolutionView_Check_Active_Resources__c switched on.. hasActiveResources=' + hasActiveResources);
		} else {
			system.debug(logginglevel.info, '--- running with custom setting SolutionView_Check_Active_Resources__c switched OFF');
		}
		System.debug('hasActiveRes '+hasActiveResources);

		String caseQuery = getAllFieldsFromObject('Case') + ' WHERE id =\''+ cse.Id +'\'';
		cse = (Case)Database.query(caseQuery);

		isCaseOpen = evalCaseStatus();
		System.debug('isCaseOpen ' + isCaseOpen);
		 
		if(!hasActiveResources && isCaseOpen){
			saveResource();
		} else {
			doInitPage();
			closePopup();
			System.debug('dis '+displayPopup);
		}
		
	}

	private void saveResource() {
		
		currentService = retrieveCurrentCaseConsultation(cse);
		Id solutionRecordTypeId = Schema.getGlobalDescribe().get('Applied_Resource__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Solution').getRecordTypeId();

		//Applied_Resource__c ar = new Applied_Resource__c();
		newAppliedResource.Case__c = cse.Id;
		newAppliedResource.Solution__c = solution.Id;
		newAppliedResource.Type__c = 'Solution';
		newAppliedResource.RecordTypeId = solutionRecordTypeId;
		newAppliedResource.Title__c = solution.Title__c;
		newAppliedResource.Subject__c = cse.Selected_Subject__c;
		newAppliedResource.Status__c = 'Applied';
		if(currentService != null){
			newAppliedResource.Consultation__c = currentService.Id;
		}
		System.debug('applied resource '+ newAppliedResource);

		insert newAppliedResource;
		closePopup();
		
	}

	public Consultation__c retrieveCurrentCaseConsultation(Case cse) {

//        debugMessages = new List<DebugMessage>();
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
           // debugMessages.add(new DebugMessage('No consultations for cse' + cse));
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

	public List<Consultation__c> retrieveConsultations(Case cse) {
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('case__c').equals(cse.id));
        return retrieveConsultations(whereC);
    }

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

	public static String getAllFieldsFromObject(String nameOfSObject) {

		Map<String, Schema.SObjectField> sObjectFields = Schema.getGlobalDescribe().get(nameOfSObject).getDescribe().fields.getMap();
		List<String> fields = new List<String> ();

		for (String field : sObjectFields.keySet()) {
			if (sObjectFields.get(field).getDescribe().isAccessible()) {
				fields.add(field);
			}
		}
		String query = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + nameOfSObject;
		return query;
	}

}