global class ctrlResources extends ctrlCarplesGeneric {


	public String currRecordId { get; set; }
	public String subjClickedId { get; set; }

	public AppliedResourceUtils arUtils { get; set; }
	public CaseUtils caseUtils { get; set; }

	public Case cse { get; set; }
	public Consultation__c currentService { get; Set; }
	public Subject__c subjectClicked { get; set; }
	public Contact client { get; set; }
	//rjn viewstate fix2.. hmmm this could be dangeours
	public transient List<Applied_Resource__c> allSubjectArs { get; set; }
	public transient List<Applied_Resource__c> allCaseArs { get; set; }




	public List<IRefWrapper> legalRefWraps { get; set; }
	public List<IRefWrapper> socialRefWraps { get; set; }
	public List<IRefWrapper> webLinkRefWraps { get; set; }
	public List<DdpWrapper> ddpWraps { get; set; }

	public Boolean displayJsRenderLegalRefInit { get; set; }
	public String clickedChkBoxType { get; set; }
	public String clickedRefAcctId { get; Set; }
	public Integer activeAccordionIdx { get; Set; }
	public Boolean isAnotherUsersOpenCase { get; set; }

	public Boolean displayLocalExpertTab { get; set; }
	public Boolean displayCommunitiesTab { get; set; }
	public Boolean displaySolutionTab { get; set; }
	public Boolean allowLENotifications { get; set; }
	public Boolean showTopicAssignments { get; set; }
	public Boolean showLikeOption { get; set; }
	public Boolean allowLEMultipleSendTos { get; set; }
	public Boolean showAllTab { get; set; }
	public String leTitle { get; set; }

	//** ** ** ** ** ** ** 
	public List<Solution__c> solutions { get; set; }
	public List<SolutionWrap> solutionsWrap { get; set; }
	public Solution__c newSolution { get; set; }
	public Integer solSize { get; set; }
	public Subject__c newSubject { get; set; }
	public STring newSubjectTitle { get; set; }
	public List<Applied_Resource__c> activeResources { get; set; }
	public Boolean hasActiveResources { get; set; }
	public String errorMessage { get; set; }

	
	public SubjectComment__c            newSubjectComment               {   get; set;   }
	public boolean                      displayPopup                    {   get; set;   } 

	public ctrlResources() {
		//this.showDebugMessages = true;
		this.displayCommunitiesTab = false;
		this.displayLocalExpertTab = false;
		this.displaySolutionTab = false;
		this.currRecordId = ApexPages.currentPage().getParameters().get('id');
		this.subjClickedId = ApexPages.currentPage().getParameters().get('subjClickedId');

		this.caseUtils = new CaseUtils();
		this.arUtils = new AppliedResourceUtils();
		system.debug('current record id=' + currRecordId);
		system.debug('current subjClicked Id=' + subjClickedId);
		this.cse = caseUtils.retrieveCaseSummaryData(currRecordId);
		System.debug('case ' + cse);

		activeAccordionIdx = 0;

		this.allowLENotifications = false;
		this.allowLEMultipleSendTos = false;
		this.showTopicAssignments = false;
		this.showAllTab = false;
		this.showLikeOption = false;
		this.leTitle = 'Community';

		initConstructorCode();
		if(cse != null){
			getActiveResources();
		}
		
		this.errorMessage = '';
		this.solutions = getSolution(cse, allCaseArs);
		this.solSize = solutions.size();
		System.debug('solutionsWrap     solutionsWrap solutionsWrap ' + solutionsWrap);
	}

	public PageReference refreshSubjectId() {
		system.debug('firing refreshSubjectId with id=' + subjClickedId);
		// initConstructorCode();
		initConstructorCode();
		if (currentService != null) {
			ctrlAuraCaseServices.addCaseSubjectAsAppliedResource(currentService);
		}
		return null;
	}

	public void getActiveResources() {
		this.activeResources = [SELECT id,
		                        Name,
		                        Active__c,
		                        Status__c,
		                        Type__c,
		                        Title__c,
		                        RecordTypeId,
		                        RecordType.Name
		                        FROM Applied_Resource__c
		                        WHERE Case__r.id = :cse.Id
		                        AND Type__c = 'Solution'
		                        AND Active__c = true];
	}

	public PageReference createNewSolution() {

		
		Boolean checkActiveResources = false;
		//RJN Conditional switch this on.. if we want to check for active resources. default of custom setting is off..
		try {
			checkActiveResources = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'SolutionView_Check_Active_Resources__c');
			System.debug('checkActiveResources '+checkActiveResources);
		} catch(Exception e) {
			system.debug(logginglevel.error, '-- failed on check of active resources prob cause custom setting is missing..' + e);
		}

		cse = caseUtils.retrieveCaseSummaryData(cse.Id);
		System.debug('cse.IsClosed ' + cse.IsClosed);
		errorMessage = '';
		if (cse.IsClosed) {
			errorMessage += '<p>Case: ' + cse.CaseNumber + ' is closed and must be open to create new Solution!</p>';
		}

		hasActiveResources = false;
		if(checkActiveResources){
			getActiveResources();
			hasActiveResources = activeResources != null && !activeResources.isEmpty();
		}
		if(activeResources.size() > 1) {
            errorMessage += '<p>The following Solutions are active and must be closed before adding a new one:</p>';
        } else {
            errorMessage += '<p>The following Solution is active and must be closed before adding a new one:</p>';
        }
		System.debug('hasActiveResources ' + hasActiveResources);
		if (hasActiveResources) {
			errorMessage += '<ul style="margin-top:7px">';
			for (Applied_Resource__c ar : activeResources) {
				errorMessage += '<li>';
				errorMessage += '#' + ar.name + ' - ' + ar.title__c;
				if (ar.recordtypeid != null) {
					errorMessage += ' - ' + ar.recordtype.name;
				}
				errorMessage += ' - <b>' + ar.status__c + '</b>';
				errorMessage += '</li>';
			}
			errorMessage += '</ul>';
		}
		System.debug('error message '+errorMessage);

		this.newSolution = new Solution__c();
		System.debug(newSolution);
		return null;
	}
	public PageReference doSaveNewSolution() {
		Id solutionId;
		
		newSolution.Type__c = 'Draft';
		newSolution.Status__c = 'Active';
		newSolution.Problem_Code__c = cse.Problem_Code__c;
		newSolution.Problem_Category__c = cse.Problem_Category__c;
		newSolution.Practice_Area__c = cse.Practice_Area__c;
		System.debug('newSol '+newSolution);
		try {
			solutionId = DmlUtils.DBInsert(newSolution);
			system.debug('solutionId ' + solutionId);
		} catch(Exception ex) {
			System.debug('insert solution exeption ' + ex.getMessage());
		}
		if (solutionId != null) {
			ctrlProblemCodeSelect ctrlProblemCode = new ctrlProblemCodeSelect();
			ctrlProblemCode.doCreateTaskForNewSolution(solutionId);

			Solution__c solution = [SELECT Id, Name, Title__c FROM Solution__c WHERE id = :solutionId];

			Consultation__c consultation = caseUtils.retrieveCurrentCaseConsultation(cse);
			system.debug('consultation ' + consultation);

			Id solutionRecordTypeId = Schema.getGlobalDescribe().get('Applied_Resource__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Solution').getRecordTypeId();

			Applied_Resource__c ar = new Applied_Resource__c();
			ar.Case__c = cse.Id;
			ar.Solution__c = solutionId;
			ar.Type__c = 'Solution';
			ar.RecordTypeId = solutionRecordTypeId;
			ar.Title__c = solution.Title__c;
			ar.Subject__c = cse.Selected_Subject__c;
			ar.Status__c = 'Applied';
			if (currentService != null) {
				ar.Consultation__c = currentService.Id;
			}
			System.debug('applied resource ' + ar);

			insert ar;

		}
		if (this.subjectClicked != null) {
			refreshRelatedData();
			initConstructorCode();
		}
		//ctrlCase cC = new ctrlCase();
		//cC.doRefreshArAura();
		return null;
	}

	private void initConstructorCode() {
		//fp7c  start_it__C filter added
		if (displayCommunitiesTab == null) {
			displayCommunitiesTab = false;
		}
		if (displaySolutionTab == null) {
			displaySolutionTab = false;
		}

		system.debug('current subjClicked Id=' + subjClickedId);
		if (cse != null) {

			String sClientStatus = '';
			if (cse.contactId != null) {
				Contact caseClient = [select id, status__c, temp_record__C from contact where id = :cse.contactId];
				if (CaseClient != null) {
					sClientStatus = caseClient.status__c;
				}
			}

			//  if(cse.status != 'closed' && (cse.start_it__c == true)) {
			if (cse.status != 'closed' && (cse.start_it__c == true || sClientStatus == 'Current')) {
				this.isAnotherUsersOpenCase = false;
				Id cseOwnerId = cse.ownerId;
				if (cseOwnerId != null && UserInfo.getUserId() != cseOwnerId) {
					this.isAnotherUsersOpenCase = true;
				}
			}
		}


		this.displayJsRenderLegalRefInit = false;
		this.clickedChkBoxType = '';

		if (currRecordId == null || currRecordId == '') {
			this.currRecordId = ApexPages.currentPage().getParameters().get('id');
		}

		this.caseUtils = new CaseUtils();
		this.allSubjectArs = new List<Applied_Resource__c> ();
		this.allCaseArs = new List<Applied_Resource__c> ();
		this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
		//--- special case now since we are not creating a service till the save of a service.
		// --the above will always return a service on a case with any existing services
		if (currentService != null && currentService.status__c == 'Closed') {
			currentService = null;
		}
		if (this.cse != null) {
			//client = contactUtils.retrieveAllContactInfo(cse.ContactId);
			Set<String> excludeFields = new Set<String> { 'OtherAddress' };
			client = retrieveAllContactInfo(cse.contactId, excludeFields);
			System.debug('client '+client);
			if (client == null) {
				system.debug('<font color="red"> ctrlResources.initContructorCode. client is null!</font>');
			} else {
				//find LE Custom settings
				this.findLeCustomSettings();

				if (displayCommunitiesTab != null && displayCommunitiesTab == true) {
					if (evalAflanRegions(client)) {
						this.displayLocalExpertTab = true;
					}
				}
			}
		} else {
			system.debug('<font color="red"> ctrlResources.initContructorCode. case is null!</font>');
		}
		if (this.client != null) {
			system.debug('<font color="blue"> om initContructor  client is :' + client.name + '..' + client.id + '</font>');
		}
		this.setPrimarySubjectClicked();

		if (this.subjectClicked != null) {
			system.debug('... in initConstructorCode subjectClicked is.. id=' + subjectClicked.Id + ' ...title=' + subjectClicked.title__c);
			this.refreshRelatedData();
		} else {
			system.debug('... in initConstructorCode subjectClicked is null!');
		}
		this.hasActiveResources = false;


	}
	@testvisible
	private void findLECustomSettings() {
		try {
			this.displayCommunitiesTab = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Display_Communities_Tab__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for Display_Communities_Tab__c' + e);
		}
		try {
			this.showAllTab = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Display_All_Tab__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for Display_All_Tab__c' + e);
		}
		try {
			this.showTopicAssignments = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Show_Topic_Assignments__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for show_topic_assignments__c' + e);
		}
		try {
			this.allowLENotifications = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Allow_LE_Notifications__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for Allow_LE_Notifications__c' + e);
		}
		try {
			this.allowLEMultipleSendTos = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Allow_LE_Multiple_Send_Tos__c');
			if (allowLEMultipleSendTos) {
				this.leTitle = 'Community';
			}
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for Allow_LE_Multiple_Send_Tos__c' + e);
		}
		try {
			this.showLikeOption = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Show_Like_Option__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for Show_Like_Option__c' + e);
		}
		try {
			this.displaySolutionTab = (Boolean) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'Display_Solution_Tab__c');
		} catch(Exception e) {
			system.debug(logginglevel.error, 'Could not find custom setting for Display_Solution_Tab__c' + e);
		}
	}
	/**
	 * @TODO RJN seems a bit nutz to have to do this.. sfdc. formula compilation size issues. what the hell is that?
	 *
	 * @param client that will be modified.
	 * @return boolean indicating if a region exists..
	 */
	@testvisible
	private Boolean evalAflanRegions(Contact c) {
		Boolean doesRegionExist = false;
		doesRegionExist = c.Region__c != null && c.Region__c != '';
		/*
		  if(c.IL_AFLAN_Central_Region__c) {
		  client.IL_AFLAN_Region__c = 'Central Region';
		  doesRegionExist = true;
		  } else if (c.IL_AFLAN_East_Region__c) {
		  client.IL_AFLAN_Region__c = 'East Region';
		  doesRegionExist = true;
		  } else if (c.IL_AFLAN_West_Region__c) {
		  client.IL_AFLAN_Region__c = 'West Region';
		  doesRegionExist = true;
		  } else if (c.IL_AFLAN_South_Region__c) {
		  client.IL_AFLAN_Region__c = 'South Region';
		  doesRegionExist = true;
		  }
		 */
		return doesRegionExist;
	}


	/**
	 * rjn added this to stop bs versioning errors such as otheraddress as well as i need the military field but did not want
	 * to mess with the above.
	 */
	public Contact retrieveAllContactInfo(Id contactId, Set<STring> excludeFields) {
		Contact c;
		al.NestableCondition whereC = new al.AndCondition();
		whereC.add(new al.FieldCondition('id').equals(contactId));

		// This field was not being included no matter what I did. Added it manually but am excluding here to
		// prevent another error in the future. ELC IF-LAN changes
		//Set<String> excludeFields = new Set<String>();
		//excludeFields.add('Is_Military__c');

		String soql = new al.SoqlBuilder()
		.selectx(SoqlUtils.getAllFieldsSet('Contact', false, excludeFields))
		//      .selectx(new Set<String> {'Is_Military__c'})
		.fromx('Contact')
		.wherex(whereC)
		.toSoql();
		try {

			c = Database.query(soql);
		} catch(Dmlexception dEx) {
			System.debug(logginglevel.error, dEx);
		} catch(Exception e) {
			System.debug(logginglevel.error, e);
		}
		return c;
	}
	private void refreshRelatedData() {
		//system.debug('... in refreshRelatedData.. subjectClicked='+subjectClicked);
		this.allSubjectArs = arUtils.retrieveAppliedResources(this.subjectClicked);
		//system.debug('... in refreshRelated Data.. allSubjectArs='+allSubjectArs);
		this.allCaseArs = arUtils.retrieveAppliedResources(this.cse);
		system.debug('... in refreshRelated Data.. allCaseArs=' + allCaseArs);

		this.ddpWraps = retrieveDdpWrappers();
		this.refreshRefs();
	}
	@testvisible
	private void refreshRefs() {
		this.legalRefWraps = retrieveRefWrappers(ResourceType.LEGAL);
		System.debug('legalRefWraps ' + legalRefWraps);
		this.socialRefWraps = retrieveRefWrappers(ResourceType.SOCIAL);
		this.webLinkRefWraps = retrieveRefWrappers(ResourceType.WEBLINK);
	}

	private void setPrimarySubjectClicked() {
		system.debug('Starting setPrimarySubjectClicked cse=' + cse);

		if (cse != null) {
			// try {
			//if(subjClickedId == null || subjClickedId == '') {
			//if(subjectIdSelected != null && subjectIdSelected != '') {
			//    subjClickedId = subjectIdSelected;

			//}
			// }

			if (subjClickedId != null && subjClickedId != '') {
				system.debug('subjClickedId=' + subjClickedId);
				Id tmpSubjectClickedId = Id.valueOf(subjClickedId);
				system.debug('tmpSubjectClickiedId=' + tmpSubjectClickedId);
				this.subjectClicked = SubjectUtils.retrieveSubject(tmpSubjectClickedId);
				system.debug('<b>Using REQUEST PARAM subjClickedId.....subjectClicked title=' + subjectClicked.title__c + ' id=' + subjectClicked.id + '  number=' + subjectClicked.Name + '</b>');

			} else {
				if (cse.Selected_subject__c != null) {
					System.debug(logginglevel.info, 'running retrievesubject with cse.selectedSubjectId=' + cse.Selected_Subject__c);
					this.subjectClicked = SubjectUtils.retrieveSubject(cse.selected_subject__c);
					system.debug('<b>Using Case.Selected_Subject_Id: subjectClicked title=' + subjectClicked.title__c + ' id=' + subjectClicked.id + '  number=' + subjectClicked.Name + '</b>');
				}
			}
			/* } catch (Exception e) {
			  system.debug('error retrieving subject.. msg:'+e.getMessage()+ 'stack='+e.getStackTraceString());
			  System.debug(logginglevel.error, 'error retrieveing subject='+e);
			  }*/
		}
	}
	public PageReference doRefreshDdps() {
		activeAccordionIdx = 0;
		system.debug('<b>in doRefreshDdps</b>');
		this.allSubjectArs = arUtils.retrieveAppliedResources(this.subjectClicked);
		this.allCaseArs = arUtils.retrieveAppliedResources(this.cse);
		system.debug('allCaseArs ' + allCaseArs);
		this.ddpWraps = retrieveDdpWrappers();
		return null;
	}
	public PageReference doRefreshLegalRefs() {
		activeAccordionIdx = 1;
		system.debug('<b>in doRefreshLegalRefs</b>');
		this.allSubjectArs = arUtils.retrieveAppliedResources(this.subjectClicked);
		this.allCaseArs = arUtils.retrieveAppliedResources(this.cse);
		system.debug('allCaseArs ' + allCaseArs);
		this.legalRefWraps = retrieveRefWrappers(ResourceType.LEGAL);

		return null;
	}
	public PageReference doRefreshSocialRefs() {
		activeAccordionIdx = 2;
		system.debug('<b>in doRefreshSocialRefs</b>');
		this.allSubjectArs = arUtils.retrieveAppliedResources(this.subjectClicked);
		this.allCaseArs = arUtils.retrieveAppliedResources(this.cse);
		system.debug('allCaseArs ' + allCaseArs);
		this.socialRefWraps = retrieveRefWrappers(ResourceType.SOCIAL);
		return null;
	}
	public PageReference doRefreshWebLinksRefs() {
		activeAccordionIdx = 3;
		system.debug('<b>in doRefreshWebLinksRefs</b>');
		this.allSubjectArs = arUtils.retrieveAppliedResources(this.subjectClicked);
		this.allCaseArs = arUtils.retrieveAppliedResources(this.cse);
		system.debug('allCaseArs ' + allCaseArs);
		this.webLinkRefWraps = retrieveRefWrappers(ResourceType.WEBLINK);
		return null;
	}
	private List<IRefWrapper> retrieveRefWrappers(ResourceType eType) {
		List<Account> refsAll = this.retrieveAllRefs(eType);

		List<Applied_Resource__c> refsApplied = this.retrieveAppResources(eType);

		Set<Id> refAppliedIds = new Set<Id> ();
		Integer numApplied = 0;
		if (refsApplied != null /*&& !refsApplied.isEmpty()*/) {
			numApplied = refsApplied.size();
			for (Applied_Resource__c ar : refsApplied) {
				refAppliedIds.add(ar.account__c);
			}
		}
		system.debug('<font color="blue">' + numApplied + '</font>-->APPLIED ' + eType + ' refs for this subject');
		List<IRefWrapper> refWraps = new List<IRefWrapper> ();

		if (refsAll != null && !refsAll.isEmpty()) {
			for (Account a : refsAll) {
				a.Case_Acceptance_Guidelines__c = null; //rjn we shouldn't need this for this display.. this is RTE viewstate fix attempt.
				a.description = null; // rjn shouldn't need either
				/* RJN DEMO ADD don't add those applied to the display list */
				/*
				  if(refAppliedIds.contains(a.Id)) {
				  continue;
				  }
				 */

				if (eType == ResourceType.LEGAL) {
					refWraps.add(new LegalRefWrapper(a, refAppliedIds.contains(a.Id)));
				}
				if (eType == ResourceType.SOCIAL) {
					refWraps.add(new SocialRefWrapper(a, refAppliedIds.contains(a.Id)));
				}
				if (eType == ResourceType.WEBLINK) {
					refWraps.add(new WebLinkRefWrapper(a, refAppliedIds.contains(a.Id)));
				}
			}
		}
		if (refWraps != null) {
			refWraps.sort();
		}
		return refWraps;

		//return null;
	}
	private List<DdpWrapper> retrieveDdpWrappers() {
		List<Loop__DDP__c> ddpsAll = this.retrieveAllDdps();
		List<Applied_Resource__c> ddpsApplied = this.retrieveAppResources(ResourceType.DDP);
		Set<Id> ddpAppliedIds = new Set<Id> ();
		Integer numApplied = 0;
		if (ddpsApplied != null && !ddpsApplied.isEmpty()) {
			numApplied = ddpsApplied.size();
			for (Applied_Resource__c ar : ddpsApplied) {
				ddpAppliedIds.add(ar.ddp__c);
			}
		}
		system.debug('<font color="blue">' + numApplied + '</font>-->APPLIED DDPS for this subject');
		List<DDPWrapper> ddpWraps = new List<DDPWrapper> ();

		if (ddpsAll != null && !ddpsAll.isEmpty()) {
			for (Loop__DDP__c ddp : ddpsAll) {

				ddpWraps.add(new DdpWrapper(ddp, ddpAppliedIds.contains(ddp.id)));
			}
		}
		if (ddpWraps != null) {
			ddpWraps.sort();
		}
		return ddpWraps;
	}

	private List<Account> retrieveAllRefs(ResourceType eType) {
		List<Account> allRefs = new List<Account>();
		System.debug('subjectClicked '+subjectClicked);
		if(subjectClicked != null && subjectClicked.Id != null && eType != null) {
		
			AccountUtils.startDebugging();
			Set<Id> allPossibleAccountIds = AccountUtils.retrieveAcctIdsBySubject(subjectClicked.Id, eType);
			system.debug('<font color="green"> ctrlResources.retrieveAllRefs.. allPossibleAccountIds=' + allPossibleAccountIds + '</font>');
			Integer numAllPossible = 0;
			if (allPossibleAccountIds != null && allPossibleAccountIds.size() > 0) {
				String clientName = '';
				if (client != null) {
					clientName = client.name;
				}
				system.debug('<font color="brown"> ctrlResources.retrieveAllRefs.. calling retrieveAllAccounts with client=' + clientName + ' type = ' + eType + '</font>');
				allRefs = AccountUtils.retrieveAccounts(allPossibleAccountIds, eType, this.client);
				
				if (allRefs != null) {
					numAllPossible = allRefs.size();
					allRefs = filterAccountsByEligibleProblemCodes(cse,allRefs);
				}

			}

			system.debug(DateTime.now() + '<font color="blue">' + numAllPossible + '</font>-->POSSIBLE ' + eType + ' refs (account_subject_junction) for this subject');
			if (numAllPossible == 0) {
				if (AccountUtils.getHasDebugMessages()) {
					for (String s : AccountUtils.debugMessages) {
						system.debug(s);
					}
				}
			}
			AccountUtils.stopDebugging();
		}
		return allRefs;
	}
	private List<Loop__DDP__c> retrieveAllDdps() {
		List<Loop__DDP__c> allDdps;
		Set<Id> allPossibleDdpIds = DdpUtils.retrieveDdpIdsBySubject(subjectClicked.Id);

		Integer numAllPossible = 0;
		if (allPossibleDdpIds != null && allPossibleDdpIds.size() > 0) {
			allDdps = DdpUtils.retrieveDdps(allPossibleDdpIds);
			if (allDdps != null) {
				numAllPossible = allDdps.size();
			}
		}
		system.debug('<font color="blue">' + numAllPossible + '</font>-->POSSIBLE DDPS (DDP_subject_junction) for this subject');
		return allDdps;
	}
	private List<Applied_Resource__c> retrieveAppResources(ResourceType eType) {
		List<Applied_Resource__c> selectedRefs = new List<Applied_Resource__c> ();
		system.debug('allCaseArs ' + allCaseArs);

		//if(this.allSubjectArs != null && !allSubjectArs.isEmpty()) {
		//  for(Applied_Resource__c ar : allSubjectArs) {
		if (this.allCaseArs != null && !allCaseArs.isEmpty()) {
			for (Applied_Resource__c ar : allCaseArs) {
				if (eType == resourceType.LEGAL) {
					if (ar.type__c == 'Legal Referrals') {
						selectedRefs.add(ar);
					}
				}
				if (eType == resourceType.SOCIAL) {
					if (ar.type__c == 'Social Referrals') {
						selectedRefs.add(ar);
					}
				}
				if (eType == resourceType.WEBLINK) {
					if (ar.type__c == 'Web Links') {
						selectedRefs.add(ar);
					}
				}
				if (eType == resourceType.DDP) {
					if (ar.type__c == 'DDP') {
						selectedRefs.add(ar);
					}
				}
			}
		} else {
			//system.debug('... in retrieveAppResources....allSubjectArs is null or empty!!');
			system.debug('... in retrieveAppResources....allCaseArs is null or empty!!');
		}
		return selectedRefs;
	}
	public PageReference doRefreshEntirePage() {
		system.debug('--- in doRefreshEntirePage --');
		this.initConstructorCode();
		return null;
	}

	public Integer getTotalLegalRefs() {
		Integer numTotal = 0;
		if (this.legalRefWraps != null) {
			numTotal = legalRefWraps.size();
		}
		return numTotal;
	}
	public Integer getTotalSocialRefs() {
		Integer numTotal = 0;
		if (this.socialRefWraps != null) {
			numTotal = socialRefWraps.size();
		}
		return numTotal;
	}
	public Integer getTotalWebLinkRefs() {
		Integer numTotal = 0;
		if (this.webLinkRefWraps != null) {
			numTotal = webLinkRefWraps.size();
		}
		return numTotal;
	}
	public Integer getTotalDdps() {
		Integer numTotal = 0;
		if (this.ddpWraps != null) {
			numTotal = ddpWraps.size();
		}
		return numTotal;
	}

	public List<Solution__c> getSolution(Case cse, List<Applied_Resource__c> allCaseArs) {
		Set<Id> solutionsId = new Set<Id> ();
		for (Integer i = 0; i<allCaseArs.size(); i++) {
			if (allCaseArs.get(i).Solution__c != null) {
				solutionsId.add(allCaseArs.get(i).Solution__c);
			}
		}
		List<Solution__c> solutions = new List<Solution__c>();
		try {
			solutions = [SELECT Name,
								Title__c,
								Level_of_Merit__c,
								Recommended_Level_of_Service__c,
								LastModifiedDate
							FROM Solution__c
							WHERE(Status__c != 'Inactive' OR Type__c != 'Pending' OR Id IN :(solutionsId))
							AND Practice_Area__c = :cse.Practice_Area__c
							AND Problem_Category__c = :cse.Problem_Category__c
							AND Problem_Code__c = :cse.Problem_Code__c];
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		System.debug(solutions);

		solutionsWrap = new List<SolutionWrap> ();
		for (Solution__c s : solutions) {
			system.debug('ssss ' + s);
			SolutionWrap solWrap = new SolutionWrap();
			solWrap.record = s;
			if (solutionsId.contains(s.Id)) {
				solWrap.checkBox = true;
			} else {
				solWrap.checkBox = false;
			}
			solutionsWrap.add(solWrap);
		}

		return solutions;
	}
	public List<Account> filterAccountsByEligibleProblemCodes(Case cse, List<Account> accs){
		Set<Id> accIds = new Set<Id>();
		List<Account> filteredAccs=new List<Account>();
		Map <Id,List<Eligible_Problem_Codes__c>> accToProbCodes = new Map<Id,List<Eligible_Problem_Codes__c>>();
		for(Account a:accs){
			accIds.add(a.Id);
		}

		List<Eligible_Problem_Codes__c> eligList=[SELECT Id,
														 Practice_Area__c,
														 Problem_Category__c,
														 Problem_Code__c,
														 Problem_Category_Closed_Until_Date__c,
														 Account__c
												 FROM Eligible_Problem_Codes__c
												 WHERE Account__c in:accIds
												 AND Practice_Area__c =: cse.Practice_Area__c
												 AND Problem_Category__c =: cse.Problem_Category__c
												 AND Problem_Code__c =: cse.Problem_Code__c
												 AND (Problem_Category_Closed_Until_Date__c = null 
													   OR 
													  Problem_Category_Closed_Until_Date__c <=: Date.today())];
		for(Eligible_Problem_Codes__c epc : eligList){
			if(!accToProbCodes.containsKey(epc.Account__c)){
				accToProbCodes.put(epc.Account__c,new List<Eligible_Problem_Codes__c>());
				accToProbCodes.get(epc.Account__c).add(epc);
			}
			else{
				accToProbCodes.get(epc.Account__c).add(epc);
			}
		}
		for(Account a : accs){
			if(accToProbCodes.containsKey(a.Id)){
				filteredAccs.add(a);
			}
		}
		return filteredAccs;
	}

	public class SolutionWrap {
		public Solution__c record { get; Set; }
		public Boolean checkBox { get; set; }
	}

	public void closePopup() { 
		displayPopup = false; 
	} 
	public void showPopup() { 	
		newSubjectComment = new SubjectComment__c();
		System.debug('newSubjectComment show '+newSubjectComment);
		displayPopup = true; 
	} 

	public void saveComment(){
		System.debug('newComment save '+newSubjectComment);
		newSubjectComment.Title__c = subjectClicked.Title__c;
		newSubjectComment.OwnerId = subjectClicked.OwnerId;
		newSubjectComment.Subject__c = subjectClicked.Id;
		newSubjectComment.Status__c = 'Submited';

		System.debug('newComment save 2'+newSubjectComment);
		try{
			insert newSubjectComment;
		} catch (Exception ex){
			System.debug(ex.getMessage());
		}
		closePopup();
	}

}