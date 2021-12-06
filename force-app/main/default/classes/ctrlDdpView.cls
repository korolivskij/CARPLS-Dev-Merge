public with sharing class ctrlDdpView  extends ctrlCarplesGeneric{
    
    public Loop__DDP__c                                 ddp                                 { get; set; }
    public Case                                         cse                                 { get; Set; }
    public Consultation__c                              currentService                      { get; Set; }
    public List<ContentDocument>                        contentDocs                         { get; Set; }
    public List<Applied_Resource__c>                    caseArs                             { get; Set; }
    public Id                                           arIdInserted                        { get; Set; }
    public Boolean                                      isPublishClicked                    { get; set; }
    
    public CaseUtils                                    caseUtils                           { get; Set; }
    
    
    //public List<Eligible_Problem_Codes__c>                relatedProblemCodes                 { get; set; }
    //public Eligible_Problem_Codes__c                  relatedProblemCode                  { get; Set; }
    public AppliedResourceUtils                         arUtils                             { get; Set; }
    
    
    public Boolean                                      isResourceAlreadyApplied            { get; Set; }
    public Boolean                                      isCaseOpen                          { get; set; }   
    public Boolean                                      isCancelClicked                     { get; Set; }
    //needed for case 2.0
    public id                                           arIdAlreadyApplied                  { get; set; }
    
    
    public ctrlDdpView(ApexPages.StandardController stdController) {          
        this.ddp                = (Loop__DDP__c)stdController.getRecord();  
        this.ddp                = DdpUtils.retrieveDdp(ddp.id);
        this.caseUtils          = new CaseUtils();
        this.arUtils            = new AppliedResourceUtils();       
        this.processQueryParams();      
        this.refreshContentDocs();
    }
    public Pagereference doInitPage() {
        // somehow 
        this.initSectionState();
        this.isResourceAlreadyApplied = this.retrieveArMatch();


        this.isCaseOpen = this.evalCaseStatus();
        if(isCaseOpen) {
            this.evalServiceStatus();
        }
        this.isCancelClicked = false;
        this.isPublishClicked = false;
        
        //this.relatedContacts = ContactUtils.retrieveResourceContacts(acct.id);
        Integer numRelated = 0;
//      if(relatedContacts != null  ) { numRelated = relatedContacts.size(); }
    //  debugLog('<font color="blue">'+numRelated+'</font>-->Related Contacts for this account ');
        numRelated = 0;
        /*
        this.relatedProblemCodes = ProblemCodeUtils.retrieveEligibleProblemCodes(this.acct, this.cse);
        if(relatedProblemCodes!=null) {
            numRelated = relatedProblemCodes.size();
            if(numRelated > 0) {
                this.relatedProblemCode = relatedProblemCodes[0];
            } else {
                debugLog('<font color=red>empty relatedProblemCodes List='+relatedProblemCodes + '</font>');
            }
        }
        debugLog('<font color=green>'+numRelated + '</font> problem codes related.');
        */
        if (cse != null) {
        	debugLog('Case:'+cse.casenumber);
        } else {
        	debugLog('Null cse in vfDdpView');
        }
        String currentServiceName = 'No Current Service Active!!!';
        if(currentService != null) { currentServiceName = currentService.name; }
        debugLog('CurrentService:'+currentServiceName);
        debugLog('<font color=green>Is Resource Already Applied To Case?: '+this.isResourceAlreadyApplied+' </font>');          
        return null;        
    }
    private void initSectionState() {
        this.mSectionState = new Map<String,SectionStateBean>();    
        mSectionState.put( 'msgMainPanel', new SectionStateBean('msgMainPanel',false) );
    }   
    public Pagereference doCancelSelectResource() {
        this.isCancelClicked = true;
        return null;
    }
    public Pagereference doSelectResource() {
        this.isPublishClicked = true;
        if(!isResourceAlreadyApplied) {
            Applied_Resource__c ar = arUtils.buildAppliedResource(ddp, cse, currentService);
            if(ar != null && ar.Type__c != null) {          
                try {
                    this.arIdInserted = DmlUtils.DBInsert(ar);
                } catch (Exception e) {
                    debugLog('<font color=red>Exception inserting applied resource: '+e.getMessage() + ' </font>');
                }
            } else {
                debugLog('in doSelectResource.. NO ar INSERTED!... ar to build='+ar);
            }
        } 
        
        return null;
    }
    
    private Boolean retrieveArMatch() {
        Boolean match = false;
        if(caseArs == null || caseArs.isEmpty()) {
            match =false;
        } else {
            for(Applied_Resource__c ar : caseArs) {
                if(ar.ddp__c == ddp.Id) {
                    match = true;
                    this.arIdAlreadyApplied = ar.id;
                    break;
                }
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
    private void refreshContentDocs() {
        this.contentDocs = DDPUtils.retrieveDdpContentDocs(ddp.id); 
    }
    private void processQueryParams() {
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        //currentServiceId allows for add of ddp while in edit mode
        String currentServiceId = ApexPages.currentPage().getParameters().get('currentServiceId');
        if(caseId !=null && caseId != '') {
            this.cse = caseUtils.retrieveCaseSummaryData(caseId);
            if(this.cse != null) {
                if(currentServiceId != null && currentServiceId != '') {
                    this.currentService = caseUtils.retrieveConsultation(currentServiceId);
                } else {
                    this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
                }
                this.caseArs = arUtils.retrieveAppliedResources(this.cse);
            }
        }
    }
    public Boolean evalCaseStatus() {
        Boolean isOpen = false; 
        if(cse != null) {
            isOpen = !cse.IsClosed;
        }
        if(!isOpen) {
            SectionStateBean ssBean = mSectionState.get('msgMainPanel');
            ssBean.showIt = true;
            ssBean.cssStyleClass = 'infoM4';
            if (cse != null) {
            	ssBean.msg = 'Case: '+cse.casenumber + ' is closed and must be open to add a resource!';
            } else {
            	ssBean.msg = 'Error: Case is null!';
            }            
        }
        return isOpen;
    }
    // to simulate ctrlAccountView.. note an edited service will remain closed.. .. it will be up to the service code to assign the correct service to the resource.
    public Boolean evalServiceStatus() {
        Boolean isOpen = false;
        if(evalCaseStatus()) {
            String msg = '';
            this.currentService = caseUtils.retrieveCurrentCaseConsultation(cse);
            debugLog('in evalServiceStatus..<font color=orange>currentService ='+currentService+'</font>');

            if(currentService == null) {

                // msg = 'Case: '+cse.casenumber + ' does not have an associated service. Please Add a new service!';
                isOpen = true;
            } else {

                if(currentService.Status__c != 'Open') {
                    //msg = 'Case: '+cse.casenumber + ' does not have an open service. Please Add a new service!';
                    currentService = null;
                    //gotta do this since we no longer insert a blank service upon open of the service entry form.
                    isOpen = true;
                } else {
                    isOpen = true;
                }
            }
            if(!isOpen) {
                SectionStateBean ssBean = mSectionState.get('msgMainPanel');
                ssBean.showIt = true;
                ssBean.cssStyleClass = 'infoM4';
                ssBean.msg = msg;
            }

        }
        return isOpen;
    }
}