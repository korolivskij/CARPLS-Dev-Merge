global with sharing class ctrlResourcesAndComments extends ctrlCarplesGeneric {
/* RJN TABX made global for remote method */    
     
    public String                                   currRecordId                    { get; set; }
    public String                                   parentRecordId                  { get; set; }
    public String                                   parentRecordName                { get; set; }
    public String                                   currRecordName                  { get; set; }
    public String                                   parentCaseId                    { get; set; }
    public String                                   subjClickedId                   { get; set; }

    public AppliedResourceUtils                     arUtils                         { get; set; }   
    public CaseUtils                                caseUtils                       { get; set; }
    
    public Case                                     cse                             { get; set; }
    public Consultation__c                          currentService                  { get; Set; }
    public Subject__c                               subjectClicked                  { get; set; }
    public Contact                                  client                          { get; set; }
    
    public List<Applied_Resource__c>                allSubjectArs                   { get; set; }
    public List<Applied_Resource__c>                allCaseArs                      { get; set; }
    public List<IRefWrapper>                        legalRefWraps                   { get; set; }
    public List<IRefWrapper>                        socialRefWraps                  { get; set; }   
    public List<IRefWrapper>                        webLinkRefWraps                 { get; set; }
    public List<DdpWrapper>                         ddpWraps                        { get; set; }
    
    public Boolean                                  displayJsRenderLegalRefInit     { get; set; }
    public String                                   clickedChkBoxType               { get; set; }
    public String                                   clickedRefAcctId                { get; Set; }
    public Integer                                  activeAccordionIdx              { get; Set; }
                     
    public ctrlResourcesAndComments() {
        //this.showDebugMessages = true;
        this.currRecordId       =   ApexPages.currentPage().getParameters().get('id'); 
        if(currRecordId != null && currRecordId != '') {
            debugLog('in constructor.. setting currRecordId and parentRecordId to :'+currRecordId);
            this.parentRecordId = currRecordId;
            this.parentRecordName = Utilities.findObjectNameById(parentRecordId);
            debugLog('in constructor.. derived parentRecordNAme ='+parentRecordName);
        } else {
            debugLog('<font color=red>in constructor.. no currRecordId found!</font>');
        }
        
        this.subjClickedId      =   ApexPages.currentPage().getParameters().get('subjClickedId'); 

        this.caseUtils          =   new CaseUtils();
        this.arUtils            =   new AppliedResourceUtils();
        activeAccordionIdx      =   0;
        initConstructorCode();      
    }
    /**
     * Triggered on vfResourceLibrary.page via event listener delIncompleteServiceListener.
     * Event listener is listening for event = evtDelIncompleteService.
     * This is currently fired from vfService.page but could be fired elsewhere.
     * RJN TABX
     * @TODO Return object as opposed to simple boolean
     */
	@RemoteAction
    global static boolean remoteDeleteIncompleteService(String serviceId) {
        
        boolean deleted = false;
		try  {
        	Id svcId = serviceId;
          	Id parentCaseId;
          	Consultation__c svc = [select id,Case__c from Consultation__c where id = :svcId];
          	parentCaseId = svc.case__c;
          	delete svc;
          	deleted = true;
        	if(parentCaseId != null) {
        		Case c = [select id, status from case where id = :parentCaseId];
        		if(c != null) {
					System.debug(logginglevel.debug, 'In remoteDeleteIncompleteService: setting case closed');
            		c.status = 'Closed';
            		update c;           			
        		}
        	}  	
         } catch (Exception e) {
          	  System.debug(logginglevel.error,e);
          	  //static method so no debug method avail
         }
         return deleted;
    }   
    
    public PageReference refreshSubjectId() {
        debugLog('firing refreshSubjectId with id='+subjClickedId);
        initConstructorCode();
        return null;    
    }
    public PageReference doFindParentRecordName() {
        if(parentRecordId != null) {
            try {
                this.parentRecordName = Utilities.findObjectNameById(parentRecordId);
            } catch (Exception e) {
                debugLog('<font color=red> in doFindParentRecordName.. error attempting to derive parentRecordName with Id='+parentRecordId + ' error is.'+e +'</font>');
            }
        }
        debugLog('in doFindParentObjectName parentRecordName='+parentRecordName);
        try {
            this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
            debugLog('in doFindParentRecordName..<font color=orange>currentService set to '+currentService.name+'</font>');
        } catch (Exception e) {
            debugLog('<font color=red> in doFindParentRecordName.. error attempting to get currentService error is.'+e +'</font>');
        }
        
        return null;
    }
    private void initConstructorCode() {
        this.displayJsRenderLegalRefInit     = false;
        this.clickedChkBoxType               = '';
        
        if(currRecordId == null || currRecordId == '') {
            this.currRecordId       =   ApexPages.currentPage().getParameters().get('id');  
        }
        if(currRecordId != null && currRecordId != '') {
            this.currRecordName = Utilities.findObjectNameById( currRecordId );
            System.debug(logginglevel.info, 'current record name='+currRecordName);
        }
        this.caseUtils      =   new CaseUtils();
        this.allSubjectArs = new List<Applied_Resource__c>();
        this.allCaseArs    = new List<Applied_Resource__c>();
        
        if(this.currRecordName != null && this.currRecordName != 'null' && currRecordName != '') {
            if('Case'.equalsIgnoreCase(currRecordName)) {
                this.cse        = caseUtils.retrieveCaseSummaryData(currRecordId);
                //System.debug(logginglevel.info,'case summary data retieved='+cse);
                if(cse!=null ) {
                    try {
                        this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
                        if (currentService != null) {
                        	debugLog('in initConstructorCode <font color=orange>CurrentService='+currentService.Name+'</font>');
                        }
                    } catch (Exception e) {
                        debugLog('in initConstructorCode error finding currentService. <font color=red>'+e+'</font>');
                    }
                    
                
                }
                
            }
            if('Service__c'.equalsIgnoreCase(currRecordName)) {
                String sCaseId =  ApexPages.currentPage().getParameters().get('caseId');
                if(sCaseId != null && sCaseId != '') {
                    parentCaseId = sCaseId;
                } else {
                    //@TODOgetcaseid from service record..
                }
            }
            if (this.cse != null) {
                client = contactUtils.retrieveAllContactInfo(cse.ContactId);
            } else {
                if (parentCaseId != null) {
                    client = contactUtils.retrieveAllContactInfo(parentCaseId);
                }
                // @TODO see above
            }
                
            this.setPrimarySubjectClicked();
            
            if(this.subjectClicked != null) {
                debugLog('... in initConstructorCode subjectClicked is.. id='+subjectClicked.Id + ' ...title='+subjectClicked.title__c);
                this.refreshRelatedData();              
            } else {
                debugLog('... in initConstructorCode subjectClicked is null!');
            }
        }
    }
    private void refreshRelatedData() {
        //debugLog('... in refreshRelatedData.. subjectClicked='+subjectClicked);
        this.allSubjectArs      = arUtils.retrieveAppliedResources(this.subjectClicked);            
        //debugLog('... in refreshRelated Data.. allSubjectArs='+allSubjectArs);
        this.allCaseArs         = arUtils.retrieveAppliedResources(this.cse);
        //debugLog('... in refreshRelated Data.. allCaseArs='+allCaseArs);
        
        this.ddpWraps           = retrieveDdpWrappers();    
        this.refreshRefs();
    }   
    private void refreshRefs() {        
        this.legalRefWraps      = retrieveRefWrappers(ResourceType.LEGAL);              
        this.socialRefWraps     = retrieveRefWrappers(ResourceType.SOCIAL);     
        this.webLinkRefWraps    = retrieveRefWrappers(ResourceType.WEBLINK);        
    }
    
    private void setPrimarySubjectClicked() {
        System.debug(logginglevel.info,'Starting setPrimarySubjectClicked cse='+cse); 
                    
        if(cse != null) {
            try {
                if(subjClickedId != null && subjClickedId != '') {                      
                    Id tmpSubjectClickedId = Id.valueOf(subjClickedId);
                    this.subjectClicked = SubjectUtils.retrieveSubject(tmpSubjectClickedId);    
                    debugLog('<b>Using REQUEST PARAM subjClickedId.....subjectClicked title='+subjectClicked.title__c + ' id='+subjectClicked.id +'  number='+subjectClicked.Name+'</b>');      
                     
                } else {            
                    if(cse.Selected_subject__c != null) {
                        System.debug(logginglevel.info, 'running retrievesubject with cse.selectedSubjectId='+cse.Selected_Subject__c);
                        this.subjectClicked = SubjectUtils.retrieveSubject(cse.selected_subject__c);            
                        debugLog('<b>Using Case.Selected_Subject_Id: subjectClicked title='+subjectClicked.title__c + ' id='+subjectClicked.id +'  number='+subjectClicked.Name+'</b>');            
                    }
                }  
            } catch (Exception e) {
                debugLog(e.getMessage());
                System.debug(logginglevel.error, 'error retrieveing subject='+e);
            }
        }       
    }
    public PageReference doRefreshDdps() {  
        activeAccordionIdx = 0;
        debugLog('<b>in doRefreshDdps</b>'); 
        this.allSubjectArs      = arUtils.retrieveAppliedResources(this.subjectClicked);
        this.allCaseArs         = arUtils.retrieveAppliedResources(this.cse);
        this.ddpWraps           = retrieveDdpWrappers();    
        return null;
    }   
    public PageReference doRefreshLegalRefs() { 
        activeAccordionIdx = 1;
        debugLog('<b>in doRefreshLegalRefs</b>'); 
        this.allSubjectArs      = arUtils.retrieveAppliedResources(this.subjectClicked);
        this.allCaseArs         = arUtils.retrieveAppliedResources(this.cse);
        this.legalRefWraps      = retrieveRefWrappers(ResourceType.LEGAL);  
    
        return null;
    }
    public PageReference doRefreshSocialRefs() {    
        activeAccordionIdx = 2;
        debugLog('<b>in doRefreshSocialRefs</b>'); 
        this.allSubjectArs      = arUtils.retrieveAppliedResources(this.subjectClicked);
        this.allCaseArs         = arUtils.retrieveAppliedResources(this.cse);
        this.socialRefWraps     = retrieveRefWrappers(ResourceType.SOCIAL);     
        return null;
    }
    public PageReference doRefreshWebLinksRefs() {  
        activeAccordionIdx = 3;
        debugLog('<b>in doRefreshWebLinksRefs</b>'); 
        this.allSubjectArs      = arUtils.retrieveAppliedResources(this.subjectClicked);
        this.allCaseArs         = arUtils.retrieveAppliedResources(this.cse);
        this.webLinkRefWraps    = retrieveRefWrappers(ResourceType.WEBLINK);    
        return null;
    }   
    private List<IRefWrapper> retrieveRefWrappers(ResourceType eType) {
        List<Account> refsAll = this.retrieveAllRefs(eType);
        
        List<Applied_Resource__c> refsApplied = this.retrieveAppResources(eType);
        
        Set<Id> refAppliedIds = new Set<Id>();
        Integer numApplied = 0;
        if(refsApplied != null /*&& !refsApplied.isEmpty()*/) {
            numApplied = refsApplied.size();
            for(Applied_Resource__c ar : refsApplied) {
                refAppliedIds.add(ar.account__c);   
            }
        }   
        debugLog('<font color="blue">'+numApplied+'</font>-->APPLIED '+eType + ' refs for this subject');       
        List<IRefWrapper> refWraps = new List<IRefWrapper>();
        
        if(refsAll != null && !refsAll.isEmpty()) {
            for(Account a : refsAll) {
                /* RJN DEMO ADD don't add those applied to the display list */
                /*
                if(refAppliedIds.contains(a.Id)) {              
                    continue;
                }
                */
                
                if(eType ==  ResourceType.LEGAL) {
                    refWraps.add( new LegalRefWrapper(a, refAppliedIds.contains(a.Id)) );
                }
                if(eType ==  ResourceType.SOCIAL) {
                    refWraps.add( new SocialRefWrapper(a, refAppliedIds.contains(a.Id)) );
                }
                if(eType ==  ResourceType.WEBLINK) {
                    refWraps.add( new WebLinkRefWrapper(a, refAppliedIds.contains(a.Id)) );
                }
            }
        }
        if(refWraps != null) {          
            refWraps.sort();
        }       
        return refWraps;
        
        //return null;
    }   
    private List<DdpWrapper> retrieveDdpWrappers() {
        List<Loop__DDP__c> ddpsAll = this.retrieveAllDdps();
        List<Applied_Resource__c> ddpsApplied = this.retrieveAppResources(ResourceType.DDP);
        Set<Id> ddpAppliedIds = new Set<Id>();
        Integer numApplied = 0;
        if(ddpsApplied != null && !ddpsApplied.isEmpty()) {
            numApplied = ddpsApplied.size();
            for(Applied_Resource__c ar : ddpsApplied) {
                ddpAppliedIds.add(ar.ddp__c);   
            }
        }   
        debugLog('<font color="blue">'+numApplied+'</font>-->APPLIED DDPS for this subject');       
        List<DDPWrapper> ddpWraps = new List<DDPWrapper>();
        
        if(ddpsAll != null && !ddpsAll.isEmpty()) {
            for(Loop__DDP__c ddp : ddpsAll) {
                ddpWraps.add(new DdpWrapper(ddp, ddpAppliedIds.contains(ddp.id)) );
            }
        }
        if(ddpWraps != null) {          
            ddpWraps.sort();
        }       
        return ddpWraps;
    }
    private List<Account> retrieveAllRefs(ResourceType eType) { 
        
        List<Account> allRefs;
        AccountUtils.startDebugging();
        Set<Id> allPossibleAccountIds = AccountUtils.retrieveAcctIdsBySubject(subjectClicked.Id, eType);
        
        Integer numAllPossible = 0;
        if(allPossibleAccountIds != null && allPossibleAccountIds.size() > 0) {
            allRefs = AccountUtils.retrieveAccounts(allPossibleAccountIds, eType, this.client);
            if(allRefs != null) {
                numAllPossible = allRefs.size();
            }       
        }
        debugLog('<font color="blue">'+numAllPossible+'</font>-->POSSIBLE ' + eType + ' refs (account_subject_junction) for this subject'); 
        if(numAllPossible == 0) {
            if(AccountUtils.getHasDebugMessages()) {
                for(String s : AccountUtils.debugMessages) {
                    debugLog(s);
                }
            }
        }
        AccountUtils.stopDebugging();
        return allRefs;         
    }
    private List<Loop__DDP__c> retrieveAllDdps() {       
        List<Loop__DDP__c> allDdps;
        Set<Id> allPossibleDdpIds = DdpUtils.retrieveDdpIdsBySubject(subjectClicked.Id);
        
        Integer numAllPossible = 0;
        if(allPossibleDdpIds != null && allPossibleDdpIds.size() > 0) {
            allDdps = DdpUtils.retrieveDdps(allPossibleDdpIds);
            if(allDdps != null) {
                numAllPossible = allDdps.size();
            }       
        }
        debugLog('<font color="blue">'+numAllPossible+'</font>-->POSSIBLE DDPS (DDP_subject_junction) for this subject');   
        return allDdps; 
    }
    private List<Applied_Resource__c> retrieveAppResources(ResourceType eType) {
        List<Applied_Resource__c> selectedRefs = new List<Applied_Resource__c>();
        
        //if(this.allSubjectArs != null && !allSubjectArs.isEmpty()) {
        //  for(Applied_Resource__c ar : allSubjectArs) {
        if(this.allCaseArs != null && !allCaseArs.isEmpty()) {
            for(Applied_Resource__c ar : allCaseArs) {
                if(eType == resourceType.LEGAL) {
                    if(ar.type__c == 'Legal Referrals') {
                        selectedRefs.add(ar);
                    }
                }
                if(eType == resourceType.SOCIAL) {
                    if(ar.type__c == 'Social Referrals') {
                        selectedRefs.add(ar);
                    }
                }
                if(eType == resourceType.WEBLINK) {
                    if(ar.type__c == 'Web Links') {
                        selectedRefs.add(ar);
                    }
                }
                if(eType == resourceType.DDP) {
                    if(ar.type__c == 'DDP') {
                        selectedRefs.add(ar);
                    }
                }
            }
        } else {
            //debugLog('... in retrieveAppResources....allSubjectArs is null or empty!!');
            debugLog('... in retrieveAppResources....allCaseArs is null or empty!!');
        }
        return selectedRefs;
    }
    public PageReference doRefreshEntirePage() {
        this.initConstructorCode();
        return null;
    }
    /* OBSOLETE!!
    public PageReference doSaveCheckBoxes() {
        ResourceType eType;
        if(clickedChKBoxType == 'LEGAL') {
            eType = ResourceType.LEGAL;
        }
        debugLog('----- in action doSaveCheckBoxes.. clickedChkBoxType='+eType+'-------');  
        Boolean transAttempted = false;
        Boolean insertSuccess = false;
        Boolean deleteSuccess = false;
        
        List<Applied_Resource__c> arsToInsert   = new List<Applied_Resource__c>();
        List<Applied_Resource__c> arsToDel      = new List<Applied_Resource__c>();      
        List<Applied_Resource__c> tempInserts   = new List<Applied_Resource__c>();
        List<Applied_Resource__c> tempDels      = new List<Applied_Resource__c>();
        
        //debugLog('<font color=green>===clickedRefAcctId='+clickedRefAcctId+'</font>');
        If(eType == ResourceType.LEGAL) {
            for(IRefWrapper  iWrap :  legalRefWraps )    {
                if(iWrap.getCheckBox()) {
                    arsToInsert.add(arUtils.buildAppliedResource(iWrap,cse,currentService));
                } else {
                    arsToDel.add(arUtils.buildAppliedResource(iWrap,cse,currentService));   
                }                   
            }
        }
        if(arsToInsert == null || arsToInsert.isEmpty()) {
            debugLog('----- in action doSaveCheckBoxes.. Nothing to insert -------');   
        } else {
            //debugLog('----- in action doSaveCheckBoxes.. Nothing to insert '-------');    
        }
        if(arsToInsert != null && !arsToInsert.isEmpty()) {
            transAttempted = true;
            Id caseId = cse.id;
            Set<Id> acctIds = new Set<Id>();
            
            for(Applied_Resource__c ar : arsToInsert) {
                acctIds.add(ar.account__c);
            }
        
            List<Applied_Resource__c> existingArs  = [      select  id,account__c,case__c
                                                            from    applied_resource__c
                                                            where   case__c = :caseId
                                                            and     account__c in :acctIds ];           
            Set<Id> existingIds = new Set<Id>();
            if(existingArs != null) {
                for(Applied_Resource__c ar : existingArs) {
                    existingIds.add(ar.account__c); 
                }
            }
            if(existingIds.size() > 0) {
                for(Applied_Resource__c ar : arsToInsert) {
                    if(!existingIds.contains(ar.account__c)) {
                        tempInserts.add(ar);
                    }
                }
            } else {
                tempInserts = arsToInsert;
            }
            if(tempInserts != null && tempInserts.size() > 0) {
                debugLog('----- in action doSaveCheckBoxes.. NBR of tempInserts = '+tempInserts.size());    
            }
            Set<Id> idsUpserted;
            try {
                idsUpserted  = DmlUtils.DBUpsert(tempInserts, true);
                insertSuccess = idsUpserted != null && !idsUpserted.isEmpty();          
                debugLog('action-->doSaveCheckBoxes ('+eType+')  upserted '+tempInserts.size() + ' applied resources... idsUpserted='+idsUpserted);
            } catch (Exception e) {
                debugLog('action-->doSaveCheckBoxes ('+eType+')  upsert failed:'+e);            
            }
        }   
        if(arsToDel != null && !arsToDel.isEmpty()) {
            transAttempted = true;
            Id caseId = cse.id;
            Set<Id> acctIds = new Set<Id>();
            for(Applied_Resource__c ar : arsToDel) {
                acctIds.add(ar.account__c);
            }
            tempDels  = [       select  id,account__c,case__c
                                from    applied_resource__c
                                where   case__c = :caseId
                                and     account__c in :acctIds ];   
            
            if(tempDels != null && !tempDels.isEmpty()) {               
                try {
                    Set<Id> idsDel = DmlUtils.DBDelete(tempDels, true);
                    deleteSuccess = idsDel != null && !idsDel.isEmpty();    
                    debugLog('action-->doSaveCheckBoxes ('+eType+')  DELETED '+tempDels.size() + ' applied resources... idsDeleted='+idsDel);
                } catch (Exception e) {
                    debugLog('action-->doSaveCheckBoxes ('+eType+')  DELETE failed:'+e);            
                }
            }
        }       
        if(eType == ResourceType.LEGAL) {   
            this.legalRefWraps = retrieveRefWrappers(ResourceType.LEGAL);
            //this.editLegalRefsClicked = false;            
        }
            
        return null;
    }
    */
    public Integer getTotalLegalRefs() {
        Integer numTotal = 0;
        if(this.legalRefWraps != null) {
            numTotal = legalRefWraps.size();
        }
        return numTotal;
    }
    public Integer getTotalSocialRefs() {
        Integer numTotal = 0;
        if(this.socialRefWraps != null) {
            numTotal = socialRefWraps.size();
        }
        return numTotal;
    }   
    public Integer getTotalWebLinkRefs() {
        Integer numTotal = 0;
        if(this.webLinkRefWraps != null) {
            numTotal = webLinkRefWraps.size();
        }
        return numTotal;
    }   
    public Integer getTotalDdps() {
        Integer numTotal = 0;
        if(this.ddpWraps != null) {
            numTotal = ddpWraps.size();
        }
        return numTotal;
    }   

    
}