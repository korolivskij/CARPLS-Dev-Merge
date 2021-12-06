/**
 * ELC - Modification 1/9/21
 * 		Requires the generation of Nintex document before making a New Leaf referral.
 * ELC - Modication 2/20/21
 * 		Switch to Partner Type from partner checkbox fields
 * ELC - Modification 4/9/21
 * 		Addition of additional referral fields for CCLAHD
 **/
public with sharing class ctrlAccountView extends ctrlCarplesGeneric {

	public Account acct { get; set; }
	public Case cse { get; Set; }
	public Consultation__c currentService { get; Set; }
	public List<Applied_Resource__c> caseArs { get; Set; }
	public Id arIdInserted { get; Set; }

	public CaseUtils caseUtils { get; Set; }
	public List<Contact> relatedContacts { get; set; }

	public List<Eligible_Problem_Codes__c> relatedProblemCodes { get; set; }
	public Eligible_Problem_Codes__c relatedProblemCode { get; Set; }
	public AppliedResourceUtils arUtils { get; Set; }


	public Boolean isResourceAlreadyApplied { get; Set; }
	public Boolean isCaseOpen { get; set; }
	public Boolean isServiceOpen { get; Set; }
	public Boolean isCancelClicked { get; Set; }
    public Boolean isPartnerReferral { get; set; }
//	public Boolean isCarplsConnect { get; set; }
	public Boolean isNewLeafReferral { get; set; }
    public Boolean isCCLAHDSpecial { get; set; }
//	public Boolean showCcCnfm { get; set; }
//	public Boolean ccReferralApproved { get; set; }
//  public String ccRefNote { get; set; }

//	public Boolean isIlAflan { get; set; }
	public Boolean showEreferral { get; set; }
    public Boolean showCarplsMunicipalCnfm { get; set; }
    public Boolean showEreferralReg { get; set; }
    public Boolean showCCLAHDreferral { get; set; }
	public String eRefNote { get; set; }
	
	public Date caseMngCourDate { get; set; }
	public String courtCase { get; set;}
    public String contactEmail { get; set;}
	public String courtDistrict { get; set;}
    public String legalIssue { get; set; }
    public String clientType { get; set; }
    public String amountOwed { get; set; }
    public Decimal amountOwedDecimal { get; set; }
    public String financialAssistance { get; set; }
    public String caseMngCourTime { get; set; }
    public String preferredCallBack { get; set; }
    

    public List<SelectOption> liOptions {get;set;}
	public String liSelectedVal {get;set;}
    public List<SelectOption> cdOptions {get;set;}
	public String cdSelectedVal {get;set;}
    public List<SelectOption> ctOptions {get;set;}
	public String ctSelectedVal {get;set;}
    public List<SelectOption> faOptions {get;set;}
	public String faSelectedVal {get;set;}
    public List<SelectOption> ptOptions {get;set;}
	public String ptSelectedVal {get;set;}

	public Boolean eReferralApproved { get; set; }
	public Boolean showError { get; set; }
	public Boolean eShareDocs { get; set; }

	// Sergii
	public Boolean showErrorWhenDocsNotGenerated { get; set; }

	public List<Applied_Resource__c> activeResources { get; set; }
	public Boolean hasActiveResources { get; set; }

	private static final Map<String, String> cclahd_getLegalIssuePLByProblemCode = new Map<String, String> {
		'Taxes & Insurance' => 'Tax Deed',
		'Mortgages/Loans/Foreclosures' => 'Foreclosure' 
	};

	public String activeResourceIds;
	/**
	 * used for sconsole event to pass back to vfCase if needed.
	 *
	 * @return serialized JSON string.
	 */
	public String getActiveResourceIds() {
		String sIds = '';
		if (hasActiveResources) {
			for (Applied_Resource__c ar : activeResources) {
				sIds += ar.Id + ',';
			}
			sIds.removeEnd(',');
		}
		return sIds;
	}

	public List<SelectOption> getOkOpts() {

		List<SelectOption> options = new List<SelectOption> ();
		options.add(new SelectOption('Yes', 'Yes'));
		options.add(new SelectOption('No', 'No'));
		return options;
	}

	public ctrlAccountView(ApexPages.StandardController stdController) {
		this.acct = (Account) stdController.getRecord();
		//this.acct               = accountUtils.retrieveAccount(acct.id);
		this.acct = this.retrieveAccount(acct.id);
		this.caseUtils = new CaseUtils();
		this.arUtils = new AppliedResourceUtils();
		this.processQueryParams();
		this.isCaseOpen = false;
		this.isServiceOpen = false;
		this.isResourceAlreadyApplied = false;

		this.activeResources = new List<Applied_Resource__c> ();
		this.hasActiveResources = false;
/*
		if (/*this.acct.carpls_connect__c == true** this.acct.Partner_Type__c == 'CARPLS Connect') {
			this.isCarplsConnect = true;
		} else {
			this.isCarplsConnect = false;
		}
*/
		//this.isNewLeafReferral = this.acct.New_Leaf_Account__c;
		this.isNewLeafReferral = this.acct.Partner_Type__c == 'New Leaf' ? true : false;
        this.isPartnerReferral = this.acct.Partner_Type__c != null && !(this.acct.Partner_Type__c == '');
        this.isCCLAHDSpecial = this.acct.Partner_Type__c == 'CCLAHD' && !(this.cse.Problem_Code__c == 'Taxes & Insurance' || this.cse.Problem_Code__c == 'Mortgages/Loans/Foreclosures');
		if (this.acct.Partner_Type__c == 'CCLAHD' && cclahd_getLegalIssuePLByProblemCode.containsKey(this.cse.Problem_Code__c)) {
			this.liSelectedVal = cclahd_getLegalIssuePLByProblemCode.get(this.cse.Problem_Code__c);
		}
		System.debug('isCCLAHDSpecial in constructor = '+ this.isCCLAHDSpecial);
    }

	public Pagereference doInitPage() {
		this.processQueryParams();
		this.initSectionState();
		this.isResourceAlreadyApplied = this.retrieveArMatch();
		if (!isResourceAlreadyApplied) {
			this.isCaseOpen = this.evalCaseStatus();
			if (isCaseOpen) {
				this.evalServiceStatus();
			}
		}
		this.isCancelClicked = false;
		// RJN this was giving al and NPE
		this.relatedContacts = ContactUtils.retrieveResourceContacts(acct.id);
		Integer numRelated = 0;
		if (relatedContacts != null) { numRelated = relatedContacts.size(); }
		debugLog('<font color="blue">' + numRelated + '</font>-->Related Contacts for this account ');
		numRelated = 0;

		this.relatedProblemCodes = ProblemCodeUtils.retrieveEligibleProblemCodes(this.acct, this.cse);
		if (relatedProblemCodes != null) {
			numRelated = relatedProblemCodes.size();
			if (numRelated > 0) {
				this.relatedProblemCode = relatedProblemCodes[0];
			} else {
				debugLog('<font color=red>empty relatedProblemCodes List=' + relatedProblemCodes + '</font>');
			}
		}
		debugLog('<font color=green>' + numRelated + '</font> problem codes related.');
		if (cse != null) {
			debugLog('Case:' + cse.casenumber);
		}
		String currentServiceName = 'No Current Service Active!!!';
		if (currentService != null) { currentServiceName = currentService.name; }
		debugLog('CurrentService:' + currentServiceName);
		debugLog('<font color=green>Is Resource Already Applied To Case?: ' + this.isResourceAlreadyApplied + ' </font>');

		//this.showCcCnfm = false;

		//if (this.acct.military_service__c == true && this.acct.type == 'Legal Referral') {
		/*
		if (this.acct.Partner_Type__c == 'Military Service' && this.acct.type == 'Legal Referral') {
		 	this.isIlAflan = true;
		} else {
		 	this.isIlAflan = false;
		}
		*/

		this.showEreferral = false;	
        this.showEreferralReg = false;
        this.showCCLAHDreferral = false;
		this.showError = false;
		// Sergii
		this.showErrorWhenDocsNotGenerated = false;
		
		Boolean checkactiveResources = false;
		//RJN Conditional switch this on.. if we want to check for active resources. default of custom setting is off..
		try {
			checkActiveResources = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'AccountView_Check_Active_Resources__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, '-- failed on check of active resources prob cause custom setting is missing..' + e);
		}
		if (checkActiveResources) {
			this.retrieveActiveResources(cse.id);
			if (activeResources != null && !activeResources.isEmpty()) {
				this.evalHasActiveResources();
				this.hasActiveResources = true;
			}
			system.debug(logginglevel.info, '--- running with custom setting AccountView_Check_Active_Resources__c switched on.. hasActiveResources=' + hasActiveResources);
		} else {
			system.debug(logginglevel.info, '--- running with custom setting AccountView_Check_Active_Resources__c switched OFF');
		}

		getCourtDistricts();
        getLegalIssues();
        getClientTypes();
        getPreferredTimes();
        getFinancialAssistance();
	
		return null;
	}
	private void initSectionState() {
		this.mSectionState = new Map<String, SectionStateBean> ();
		mSectionState.put('msgMainPanel', new SectionStateBean('msgMainPanel', false));
	}
	public Pagereference doCancelSelectResource() {
		this.isCancelClicked = true;
		return null;
	}
	/**
	 *
	 *
	 * @return
	 */
	public PageReference doRefreshPage() {
		this.doInitPage();
		return null;
	}

	public Pagereference doSelectResource() {
		/*
		  if(currentService == null) {
		  return null;
		  }
		 */

		List<Applied_Resource__c> appliedResources = [ SELECT Id FROM Applied_Resource__c
													   WHERE Case__c = :cse.Id 
													   AND Type__c = 'DDP' 
													   AND DDP__r.New_Leaf_Summary__c = true
													 ];
		//sergiy Nov 09/2020
		if (this.isNewLeafReferral && appliedResources.isEmpty()) {
			showErrorWhenDocsNotGenerated = true;
		//} else if (this.isCarplsConnect || this.isIlAflan == true || this.isNewLeafReferral) {
        }else if (this.acct.Name == 'CARPLS Municipal Court Advice Desk'){
            this.contactEmail = cse.Contact.Email;
            showEreferral = true;
            showCarplsMunicipalCnfm = true;
		} else if (this.isPartnerReferral == true) {
			showEreferral = true;
            System.debug('isCCLAHDSpecial in doSelectResource = '+ this.isCCLAHDSpecial);
            if (isCCLAHDSpecial == true) {
                showCCLAHDreferral = true;
            } else {
                showEreferralReg = true;
            }
		} else {
			saveResource();
		}
		return null;
	}
	
	public Boolean evalCaseStatus() {
		Boolean isOpen = false;
		if (cse != null) {
			System.debug('evalCaseStatus ' + cse);
			System.debug('evalCaseStatus isclosed ' + cse.IsClosed);
			isOpen = !cse.IsClosed;
			System.debug('evalCaseStatus isOpen ' + isOpen);
			if (!isOpen) {
				SectionStateBean ssBean = mSectionState.get('msgMainPanel');
				ssBean.showIt = true;
				ssBean.cssStyleClass = 'infoM4';
				ssBean.msg = 'Case: ' + cse.casenumber + ' is closed and must be open to add a resource!';
			}
		}

		return isOpen;
	}
	public void saveResource() {

		Boolean checkactiveResources = false;
		hasActiveResources = false;
		//RJN Conditional switch this on.. if we want to check for active resources. default of custom setting is off..
		try {
			checkActiveResources = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'AccountView_Check_Active_Resources__c');
			System.debug('checkactiveResources ' + checkactiveResources);
		} catch(Exception e) {
			system.debug(logginglevel.error, '-- failed on check of active resources prob cause custom setting is missing..' + e);
		}
		if (checkActiveResources) {
			retrieveActiveResources(cse.Id);
			hasActiveResources = evalHasActiveResources();
			System.debug('hasActiveResources ' + hasActiveResources);
		}
		cse = caseUtils.retrieveCaseSummaryData(cse.Id);
		isCaseOpen = evalCaseStatus();

		System.debug('isCaseOpen ' + isCaseOpen);
		if (!hasActiveResources && isCaseOpen) {
			Applied_Resource__c ar;
			if (this.isPartnerReferral == true) {
            //if (this.isCarplsConnect || this.isIlAflan == true || this.isNewLeafReferral) {
				//if (this.ccReferralApproved == true) {
				//	ar = arUtils.buildAppliedResource(acct, cse, currentService, ccReferralApproved);
                //    ar.referral_note__c = eRefNote;
				//} else {
				//	System.debug('The CARPLS Connect referral was not approved by the Client!!');
				//	return;
				//}
			//} else if (this.isIlAflan == true) {
                if(amountOwed!=null){
                    amountOwed = amountOwed.replaceAll('[,$€\\s+]', '');
					amountOwedDecimal = decimal.valueOf(amountOwed);
                    amountOwedDecimal = amountOwedDecimal.setScale(2);
                }
                if (this.acct.Partner_Type__c == 'CCLAHD') {
                    
                    ar = arUtils.buildAppliedResourceCCLAHD(acct, cse, currentService, eRefNote, caseMngCourDate, courtCase, cdSelectedVal);
                    ar.CCLAHD__c = true;
                }else{
                    ar = arUtils.buildAppliedResource(acct, cse, currentService, eRefNote, caseMngCourDate, courtCase, cdSelectedVal);
                }               
				ar.Preferred_Callback_Time__c = ptSelectedVal;
                ar.Legal_Issue_PL__c = liSelectedVal;
                ar.Client_Type__c = ctSelectedVal;
                ar.Amount_Owed__c = amountOwedDecimal;
                ar.Financial_Assistance__c = faSelectedVal;
                ar.CM_Court_Time_Text__c = caseMngCourTime;
                if (isCCLAHDSpecial == true) {
					ar.CCLAHD__c = true;
                }
                ar.Referral_Source_pl__c = 'Hotline';


                debugLog('<font color=red>eShareDocs:' + eShareDocs + '</font>');
				//ELC 2-14-21 if (this.isCarplsConnect || this.isNewLeafReferral) ar.referral_note__c = eRefNote;
				ar.referral_note__c = eRefNote;
			} else {
				ar = arUtils.buildAppliedResource(acct, cse, currentService);
			}
			if (ar != null && ar.Type__c != null) {
//				try {
					this.arIdInserted = DmlUtils.DBInsert(ar);
//				} catch(Exception e) {

//					debugLog('<font color=red>Exception inserting applied resource: ' + e.getMessage() + ' </font>');
//				}

				//AG
				try {

					//system.debug('saveResource-isIlAflan:' + this.isIlAflan + ', eShareDocs:' + this.eShareDocs);
					//this.eShareDocs= true;//TODO: AG delete on release

					//ELC 2-14-21 if ((this.isIlAflan || this.isNewLeafReferral || this.isCarplsConnect) && this.eShareDocs)
					if (this.isPartnerReferral && this.eShareDocs)
                        shareDocuments(this.arIdInserted);

				} catch(Exception e) {
					system.debug('Exception sharing case attachments: ' + e.getMessage());
				}
				////

			} else {
				debugLog('in SaveResource.. NO ar INSERTED!... ar to build=' + ar);
			}
		}
	}

	//AG
	public void shareDocuments(id arId)
	{
		System.debug('shareDocuments()...arId:' + arId + ',accId:' + acct.id);

		Set<Id> attacheddocs = new Set<Id> ();

		//Case attachments:
		//1. DrawLoop - ContentVersion
		for (ContentVersion item :[SELECT id, ContentDocumentId from ContentVersion WHERE Case__c = :cse.id])
		attacheddocs.add(item.ContentDocumentId);

		//2. VF classic - Attachment object
		//for(Attachment item: [SELECT id from Attachment WHERE ParentId = :cse.id])
		//    attacheddocs.add(item.Id);

		//3. f4lightning - ContentDocument(file),ContentDocumentLink(file,Case)
		for (ContentDocumentLink item :[SELECT id, ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId = :cse.id])
		attacheddocs.add(item.ContentDocumentId);
		
		if (!attacheddocs.isEmpty()) {

			List<ContentDocumentLink> cdlist = new List<ContentDocumentLink> ();
			Set<Id> entIds = new Set<Id> ();

			entIds.add(arId);

			//attach to Applied Resource
			for (Id docId : attacheddocs) {
				ContentDocumentLink ardl = new ContentDocumentLink();ardl.ContentDocumentId = docId;ardl.LinkedEntityId = arId;ardl.ShareType = 'V';ardl.Visibility = 'AllUsers';
				cdlist.add(ardl);
			}

			//Community users
			List<User> commUsers = [SELECT Id from User where ContactId IN (SELECT ContactId 
                                    		FROM AccountContactRelation 
                                            WHERE AccountID = :acct.id)]; //and Profile.Name = 'Profile IL-AFLAN Community User'
			if (!commUsers.isEmpty()) {
				System.debug('shareDocuments()...commUsers.size:' + commUsers.size());
				for (User u : commUsers) {
					for (Id docId : attacheddocs) {
						ContentDocumentLink commdl = new ContentDocumentLink();commdl.ContentDocumentId = docId;commdl.LinkedEntityId = u.Id;commdl.ShareType = 'V';commdl.Visibility = 'AllUsers';
						cdlist.add(commdl);
					}
					entIds.add(u.Id);
				}
			}
			//remove duplicates
			List<ContentDocumentLink> exCDL = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId in :attacheddocs and LinkedEntityId in :entIds];

			List<ContentDocumentLink> cdltoinsert = new List<ContentDocumentLink> ();

			boolean found = false;
			for (ContentDocumentLink newitem : cdlist) {
				found = false;

				for (ContentDocumentLink olditem : exCDL) {

					if (newitem.ContentDocumentId == olditem.ContentDocumentId
					    && newitem.LinkedEntityId == olditem.LinkedEntityId) {
						found = true;
						break;
					}
				}

				if (!found)
				cdltoinsert.add(newitem);
			}

			System.debug('cdltoinsert.size=' + cdltoinsert.size());

			//share attached documents with Account's community
			//DmlUtils.DBInsert(cdltoinsert, false);//old api version
			DataBase.Saveresult[] lsr = Database.insert(cdltoinsert, false);

			for (Database.Saveresult sr : lsr) {
				if (!sr.isSuccess()) {
					Database.Error err = sr.getErrors() [0];
					System.debug('-------------> shareDocuments Insert Error!! msg= ' + err.getMessage() + ', sc=' + err.getStatusCode());
				} else {
					//Id insertedId = sr.getId();
					if (sr.getId() != null) {
						System.debug('shareDocuments.inserted id=' + sr.getId());
					}
				}
			}
		}
	}


	public Boolean evalHasActiveResources() {
		Boolean hasResources = activeResources != null && !activeResources.isEmpty();
		if (hasResources) {
			SectionStateBean ssBean = mSectionState.get('msgMainPanel');
			ssBean.showIt = true;
			ssBean.cssStyleClass = 'infoM4 message-panel-resources-override';
			String msg = '';
			if (activeResources.size() > 1) {
				msg += 'the following ' + acct.type + 's are active and must be closed before adding a new one:';
			} else {
				msg += 'the following ' + acct.type + ' is active and must be closed before adding a new one:';
			}
			msg += '<ul style="margin-top:7px">';
			for (Applied_Resource__c ar : activeResources) {
				msg += '<li>';
				msg += '#' + ar.name + ' - ' + ar.title__c;
				if (ar.recordtypeid != null) {
					msg += ' - ' + ar.recordtype.name;
				}
				msg += ' - <b>' + ar.status__c + '</b>';
				msg += '</li>';
			}
			msg += '</ul>';
			if (ssBean.msg != null && ssBean.msg != '') {
				ssBean.msg += '</br>' + 'Additionally, ' + msg;
			} else {
				ssBean.msg = msg;
			}
		}
		return hasResources;
	}
	//note an edited service will remain closed.. .. it will be up to the service code to assign the correct service to the resource.
	public Boolean evalServiceStatus() {
		Boolean isOpen = false;
		if (evalCaseStatus()) {
			String msg = '';
			this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
			debugLog('in evalServiceStatus..<font color=orange>currentService =' + currentService + '</font>');

			if (currentService == null) {

				// msg = 'Case: '+cse.casenumber + ' does not have an associated service. Please Add a new service!';
				isOpen = true;
			} else {

				if (currentService.Status__c != 'Open') {
					//msg = 'Case: '+cse.casenumber + ' does not have an open service. Please Add a new service!';  
					currentService = null;
					//gotta do this since we no longer insert a blank service upon open of the service entry form.
					isOpen = true;
				} else {
					isOpen = true;
				}
			}
			if (!isOpen) {
				SectionStateBean ssBean = mSectionState.get('msgMainPanel');
				ssBean.showIt = true;
				ssBean.cssStyleClass = 'infoM4';
				ssBean.msg = msg;
			}

		}
		return isOpen;
	}
	private Boolean retrieveArMatch() {
		Boolean match = false;
		if (caseArs == null || caseArs.isEmpty()) {
			match = false;
		} else {
			for (Applied_Resource__c ar : caseArs) {
				System.debug('Account = ' + acct + ' ar = ' + ar);
				if (ar.account__c == acct.Id) {
					match = true;
					break;
				}
			}
		}
		if (match) {
			SectionStateBean ssBean = mSectionState.get('msgMainPanel');
			ssBean.showIt = true;
			ssBean.cssStyleClass = 'infoM4';
			ssBean.msg = 'This resource has already been applied to case: ' + cse.casenumber + '.';
		}
		return match;
	}
	/**
	 * We have to hope all the other services are closed as there isn't really a good way to tell where we are
	 * in the middle of adding a svc.
	 *
	 * @param caseId
	 */
	private void retrieveActiveResources(Id caseId) {

		if (acct == null || caseId == null) {
			debugLog('<font color=red>Exiting retrieveActiveResources at top..acct=' + acct + 'caseId=' + caseId + '</font>');
			return;
		}
		String svcStatus = 'Closed';

		this.activeResources = [
		                        select id, name, status__c, title__c, active__c,
		                        recordtype.name, recordtypeid, consultation__c, type__c
		                        from applied_resource__c
		                        where case__c = :caseId
		                        and active__c = true
		                        and type__c like :acct.Type + '%'
		                        and(consultation__r.status__c = :svcStatus or consultation__c = null)];
		debugLog('<font color=blue>Active Resources of type..like' + acct.Type + '% with a closed svc status' + activeResources + ' or a null svc.</font>');
	}

	private void processQueryParams() {
		String caseId = ApexPages.currentPage().getParameters().get('caseId');
		if (caseId != null && caseId != '') {
			this.cse = caseUtils.retrieveCaseSummaryData(caseId);
			if (this.cse != null) {
				this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
				this.caseArs = arUtils.retrieveAppliedResources(this.cse);
			}
		}
	}
	// for CARPLS Connect referrals
	/*
	public Pagereference doConfirmReferral() {
		this.ccReferralApproved = true;
		sendReferralEmail();
		saveResource();
		showCcCnfm = false;
		return null;
	}
	public Pagereference doRefuseReferral() {
		this.ccReferralApproved = false;
		showCcCnfm = false;
		return null;
	}
	*/
	// for Electronic referrals
	public Pagereference doSaveEReferral() {
		//AG iaReferralApproved is null on btn Save
		//iaReferralApproved = 'Yes';//TODO:AG delete from release!!!
		if(this.acct.Name == 'CARPLS Municipal Court Advice Desk'){
        	this.eReferralApproved=true;
        }
		system.debug('Saving Electronic Referral, approved = ' + this.eReferralApproved);
		//this.eReferralApproved = true;
		// ELC 7/10/19 this is temparary until the 'old' CARPLS Connect goes away
		System.debug('this.eRefNote ' + this.eRefNote);
		if(this.eRefNote != null && this.eRefNote.deleteWhiteSpace().length()==0)
		{
			this.eReferralApproved=false;
			showEreferral = true;
            if (isCCLAHDSpecial == true) {
                showCCLAHDreferral = true;
    
            
            } else {
                showEreferralReg = true;
            }
			showError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Referral Reason cannot be empty. Please enter additional information'));
			return null;
		}

		Integer descLength;
		try{ 
			descLength=cse.Description.length();
		}
		catch(Exception e)
		{
			descLength=0;
		}
		
		if(descLength<175){
			this.eReferralApproved=false;
			showEreferral = true;
            if (isCCLAHDSpecial == true) {
                showCCLAHDreferral = true;
            } else if(this.acct.Name == 'CARPLS Municipal Court Advice Desk'){
                showCarplsMunicipalCnfm = true;
        	} else {
                showEreferralReg = true;
            }
			showError = true;	
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your Case Description is incomplete. Please enter additional information.'));
			return null;
		}

        Boolean isPatternMatched = false;
        if (this.courtCase != null) {
			isPatternMatched = Pattern.matches('^([0-9]{4}-[M]{1}[0-9]{1}-[0-9]{6})$', this.courtCase);
        }
		System.debug(this.courtCase);
		if(String.isNotBlank(this.courtCase) && !isPatternMatched)
		{
			this.eReferralApproved=false;
			showEreferral = true;
            showCCLAHDreferral = true;
			showError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter correct format for Court Case - 9999-M9-999999'));
			return null;
		}
		if (String.isBlank(this.courtCase) && this.showCCLAHDreferral) {
			this.eReferralApproved=false;
			showEreferral = true;
            showCCLAHDreferral = true;
			showError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Court Case is required field'));
			return null;
		}
        //if (this.isCarplsConnect == TRUE && this.isNewLeafReferral && this.acct.community_activated__c == FALSE) {
           	//sendReferralEmail();
        //}
		if(this.eReferralApproved==false&&!showCarplsMunicipalCnfm) {
			// ToDo ELC: want to show an error here, but it isn't working, as page is new and variables re-initialized. 
			showEreferral = true;
            if (isCCLAHDSpecial == true) {
                showCCLAHDreferral = true;
            } else {
                
                showEreferralReg = true;
            }
			showError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot apply this resource without permission. Please cancel.'));
			return null;
		}
		else
			if (this.eReferralApproved == true || showCarplsMunicipalCnfm) {
				//this.ccReferralApproved = true;
				Contact con = [SELECT Id, Email FROM Contact WHERE Id = :cse.ContactId LIMIT 1];
				try {
                    if(con.Email!=contactEmail){
                        con.Email=contactEmail;
                    }
                    update con;
					saveResource();
                    showCarplsMunicipalCnfm = false;
					showEreferral = false;
					showCCLAHDreferral = false;
					showEreferralReg = false;
				} catch (Exception ex) {
					this.eReferralApproved=false;
					showError = true;
					showEreferral = true;
					showCCLAHDreferral = true;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
					return null;
				}
			}
		return null;
	}
	public Pagereference doCancelEReferral() {
		showEreferral = false;
        showCCLAHDreferral = false;
        showEreferralReg = false;
		return null;
	}
	
	//Sergii
	public Pagereference doCancelshowErrorWhenDocsNotGenerated() {
		showErrorWhenDocsNotGenerated = false;
		return null;
	}
	/* 
	  When a CARPLS Connect referral is applied, an email will be sent to the email addresses 
	  of those contacts associated with the account.  
	 */
    /* ELC 2/26/21 Deprecated functionality no longer needed with Community
	public void sendReferralEmail() {

		List<Contact> emailCts = ContactUtils.retrieveContactsByAcct(acct.id);

		for (Contact c : emailCts) {
			// Don't want to send it to the generic contact for the account
			if (c.name != acct.name) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				EmailTemplate et = [SELECT id from emailtemplate where name = 'CARPLS Connect Referral'];
				mail.setTemplateId(et.Id);
				mail.setSaveAsActivity(false);
				mail.setTargetObjectId(c.id);
				// Use Organization Wide Address 
				for (OrgWideEmailAddress owa :[select id, Address from OrgWideEmailAddress]) {
					if (owa.Address.contains('noreply')) {
						mail.setOrgWideEmailAddressId(owa.id);
					}
				}
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
		}
	}
	*/
	/**
	 * RJN. moved here locally and changed from dynamic to static to guard against
	 * API versioning issues as the dynamic SOQL in AccountUtils was trying to query
	 * for BillingAddress and throwing a.
	 *
	 * System.QueryException: No such column 'BillingAddress' on entity 'Account'
	 *
	 * @param acctId
	 *
	 * @return A single account record for the view.
	 */
	public Account retrieveAccount(Id acctId) {
		Account acct;
		try {
			acct = [SELECT id, name, type,partner_type__c, 
					//military_service__c, carpls_connect__c,New_Leaf_Account__c,
			        sub_type__c, address__c, phone, website,
			        createdBy.communitynickname, createddate,
			        LastModifiedBy.communitynickname, LastModifiedDate,
			        description, Income_Criteria__c, Max_Poverty_Level_Pct__c,
			        Min_Poverty_Level_Pct__c, Poverty_Formula__c, languages__c,
			        Geographic_Criteria__c, Serves_Only_Disabled__c, Minimum_Age__c,
			        Age_Disability_Logic__c, Case_Acceptance_Guidelines__c, Community_Activated__c
			        FROM Account
			        WHERE id = :acctId];
		} catch(Exception e) {
			system.debug(logginglevel.info, '<b>Exception on ctrlAccountView.retrieveAccount with acctId=</b>' + acctId);
		}
		return acct;
	}


	public List<SelectOption> getCourtDistricts()
    {
       cdOptions = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Applied_Resource__c.Court_District__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               cdOptions.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return cdOptions;
    }
	public List<SelectOption> getLegalIssues()
    {
       liOptions = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Applied_Resource__c.Legal_Issue_PL__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               liOptions.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return liOptions;
    }
	public List<SelectOption> getClientTypes()
    {
       ctOptions = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Applied_Resource__c.Client_Type__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               ctOptions.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return ctOptions;
    }
	public List<SelectOption> getPreferredTimes()
    {
       ptOptions = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Applied_Resource__c.Preferred_Callback_Time__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               ptOptions.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return ptOptions;
    }
    public List<SelectOption> getFinancialAssistance()
    {
       faOptions = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Applied_Resource__c.Financial_Assistance__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               faOptions.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return faOptions;
    }
}