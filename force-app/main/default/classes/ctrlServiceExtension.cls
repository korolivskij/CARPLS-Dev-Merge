public with sharing class ctrlServiceExtension  extends ctrlCarplesGeneric{
    /*
    public ApexPages.StandardController             stdController                   { get; set; }
     
    public Consultation__c                          service                         { get; set; }
    public Contact                                  serviceClient                   { get; set; }
    public Note                                     serviceNote                     { get; set; }
    public Case                                     cse                             { get; set; }
    public List<Applied_Resource__c>                appliedResources                { get; set; }
    public List<NotesWrapper>                       caseConsultationNotes           { get; set; }   
    
    public Id                                       selectedAppliedResourceId       { get; set; }
    public String                                   serviceId                       { get; set; }
    public String                                   parentCaseId                    { get; set; }

    public Boolean                                  isNewMode                       { get; set; }
    public Boolean                                  isEditMode                      { get; set; }
    public Boolean                                  isAddingFromCase                { get; set; }
    
    public String                                   jsOnClickMainCancelButton       { get; set; }
    public String                                   jsSaveAndContinueButton         { get; set; }
    public String									jsCancelNewServiceButton		{ get; set; }
    public String                                   jsRemoveArOnComplete            { get; Set; }
    public String									jsSaveOnTabClose				{ get; set; }
    public STring									jsDontSaveOnTabClose			{ get; set; }
    
    public AppliedResourceUtils                     arUtils                         { get; set; }   
    public CaseUtils                                caseUtils                       { get; set; }
    
    public Boolean									saveSuccess						{ get; set; } 
    public Boolean                                  followUpRequired                { set; }
    public Boolean									cancelSuccess					{ get; set; }
    public Boolean									noteEditModeActive				{ get; set; }
    public String									sAction							{ get; set; }
    
    public Boolean getFollowUpRequired() {
        Boolean required = false;
        if(service != null) { 
            if(service.Follow_Up_Public_Group__c != null) {
                if(service.Follow_Up_Public_Group__c != 'No Follow Up') {
                    required = true;
                }
            }       
        }
        debugLog('in getFollowupRequired... returning..'+required);
        return required;
    }   
        
    public ctrlServiceExtension(ApexPages.StandardController sController) {
        debuglog('--- contructor --');
        this.stdController  =   sController;
        this.caseUtils      =   new CaseUtils();
        
        this.arUtils        =   new AppliedResourceUtils();
        this.serviceId      =   ApexPages.currentPage().getParameters().get('id'); 
        debugLog('In constructor.. service id from url parm='+serviceId);
        this.parentCaseId   =   ApexPages.currentPage().getParameters().get('caseId'); 
        String s            =  ApexPages.currentPage().getParameters().get('addingFromCase');
        
        
        this.isAddingFromCase = false;
        if(s!=null && s!='') {
            try{
                this.isAddingFromCase = Boolean.valueOf(s);
            } catch (Exception e) {
                
            }
        }
                  
        this.evalPageMode();
       
        this.constructorInitCode();        
    }
  
    public Pagereference doDeleteIncompleteService() {
    	System.debug(logginglevel.debug, 'In doDeleteIncompleteService');
    	// add a check here for isNewMode to prevent services getting deleted while we are viewing them?
    	// And/or a check for a service note?  We have a problem with service notes 'disappearing'
    	debugLog('--- in afDoDeleteIncompleteService service='+service + '..isAddingFromCase='+isAddingFromCase);
    	if(service != null && isAddingFromCase) {
    		//-- A Attack the current service we are dealing with.
    			debugLog('--- in afDoDeleteIncompleteService service id='+service.id + '..service disposition='+service.disposition__c);
    		if(service.id != null && service.disposition__c == null) {
   				System.debug(logginglevel.debug, 'In doDeleteIncompleteService: Deleting current service.');
    			try {
    				delete service;
    				debugLog('--- in afDoDeleteIncompleteService service deleted!!');
 					if(cse != null) {
 						System.debug(logginglevel.debug, 'In doDeleteIncompleteService: setting case closed');
            			cse.status = 'Closed';
            			update cse;   
        			}     
        			// I don't think that the following variable is ever referenced.  Something Rick tried that 
        			// didn't pan out??  TODO - delete 				
    				//if(this.isAddingFromCase) {
    				//	this.jsDontSaveOnTabClose = 'alert(\'DEBUG-- is addingfromcase refreshprimaryandclosesubtab layed down\');refreshPrimaryAndCloseSub();';
    				//} else {
    				// this.jsDontSaveOnTabClose = 'alert(\'simply settabunsaved\');sforce.console.setTabUnsavedChanges(false);';
    				//}
    			} catch(Exception e) {
    				debugLog('--- in afDoDeleteIncompleteService ex='+e);
    				System.debug(logginglevel.warn,e);
    			}
    		}
		// Per Al on 12/4/14, removed code that did a cleanup of incomplete services.  
		// It may show up again in the close Case logic
    		
    	}
    	return null;   	
    }
    private void constructorInitCode() {
        debuglog('--- contructorInitCode --');
        this.noteEditModeActive = false;
        this.serviceClient = ContactUtils.retrieveAllContactInfo(service.contact_xx__c);
        this.jsRemoveArOnComplete = '';
        this.refreshAppliedResources();     
        this.refreshNotes();
        
        
        this.initSectionState();
    }
    public PageReference doInitPage() {
    	// @TODO fix or delete this code - doesn't make sense
        if(service == null) {
            debuglog('--- in doInitPage.. inserting service');
            insert service;         
        }
        if(this.isEditMode) {
            if(service != null && service.Status__c != 'Open') {
                this.service.Status__c = 'Open';
                update service;
                debugLog('<font color=blue>In doInitPage updating service status to Open</font>');
            }   
                    
        }
        if(this.serviceNote == null) {
            this.serviceNote = new Note();
            serviceNote.parentId = service.id;
        }
        if(this.isEditMode) {
        	if(this.caseConsultationNotes != null && !caseConsultationNotes.isEmpty()) {
        		//get most recent note to edit
        		NotesWrapper nw = caseConsultationNotes[caseConsultationNotes.size() - 1];
        		// ELC 3/5/15 adding check to make sure note is for this service
        		if(nw.note != null && nw.note.ParentId == service.id) {
        			serviceNote = nw.note;
        			this.noteEditModeActive = true;
        			caseConsultationNotes.remove(caseConsultationNotes.size() - 1);
        		}         
        	}
        }
        return null;
    }
    public PageReference doSaveService() {
        System.debug('*****In doSaveService');
        SavePoint sp = Database.setSavepoint();
        saveSuccess = false;
        try {  
            upsert service;
            System.debug('--- upserting service ---'+service);  
            if(serviceNote.ParentId == null) {
                serviceNote.ParentId = service.id;
            }
            if(serviceNote != null) {
                //Allow the presentaiton layer to decide if we should show the title for the note.
                //ie. if we don't show it just pump a space in there since it's required on the object.
                //but we don't really have a need for it.
                if(serviceNote.Title == null || serviceNote.Title == '') {
                	// NOTE: If this value is changed, also change the value looked for in
                	// vfCase Detail to distinguish the legacy notes
                    serviceNote.Title = 'Service Note';
                }
            }
            // ELC - 3/5/15 This could still be a new note in edit mode if the service 
            // had been incomplete.  Just always upsert            
            //if(!this.isEditMode) {
            	upsert serviceNote;
            	System.debug('--- upserting service note ---');
            //} else {
            //	if(serviceNote != null ) {//&& serviceNote.id != null) {
            //		System.debug('--- update service note ---');
			//
            //		update serviceNote;
            //	} else  {
            //		System.debug('--- cant update servicenote. .servicenote='+serviceNote);
            //	}
            //}
            this.jsSaveAndContinueButton = 'refreshPrimaryAndCloseSub();sforce.console.setTabUnsavedChanges(false);';
            this.jsSaveOnTabClose = 'refreshPrimaryAndCloseSub();sforce.console.setTabUnsavedChanges(false);';
            //this.jsSaveOnTabClose = 'svcRefreshPrimaryAndCloseSub();';
            //this.jsSaveAndContinueButton = 'alert(/''''Normally this would save and close tab but debugging now/'')';
       		saveSuccess = true;
        } catch (Exception e) {
            System.debug('error saving service and note:'+e.getMessage() );
            Database.rollback(sp);          
        }
 
        String groupName = service.Follow_Up_Public_Group__c;
        if(groupName != null && groupName != 'No Follow Up') {
        	
            Group g = GroupUtils.retrieveGroupByName(groupName);
            System.debug('--- Group found from picklist value ---'+g);
            if(g != null) {
                List<User> groupUsers = GroupUtils.retrieveGroupUsers(g);
                System.debug('--- GroupUsers found from query ---'+groupUsers);
                
                List<Task> tasks = new List<Task>();
                if(groupUsers != null && !groupUsers.isEmpty()) {
                	
                    for(User gu : groupUsers) {
                        Task t = new Task();
                        t.ActivityDate = service.Follow_Up_Date__c;
                        t.Subject = 'Request Follow Up - Case - '+cse.caseNumber;
                        t.type = 'Follow Up';
                        //t.WhoId = g.id;
                        t.WhatId = cse.id;
                        t.OwnerId = gu.id;
                        t.Description = service.Follow_Up_Reason__c;
                        t.Status = 'Not Started';                        
                        if(cse != null) {
                        	t.record_vfPage__c = 'vfCaseDetail?id='+cse.id;
                        }
                        if(cse != null) {
                        	t.record_Parms__c= '&isdtp=vw&review=true';
                        }                        
                       
                        tasks.add(t);
                        System.debug('--- Adding task for gu='+gu.username);
                    }
                } else if (g.Name == 'Myself') {
                        Task t = new Task();
                        t.ActivityDate = service.Follow_Up_Date__c;
                        t.Subject = 'Request Follow Up - Case - '+cse.caseNumber;
                        t.type = 'Follow Up';
                        //t.WhoId = g.id;
                        t.WhatId = cse.id;
                        t.OwnerId = UserInfo.getUserId();
                        t.Description = service.Follow_Up_Reason__c;
                        t.Status = 'Not Started';
                        if(cse != null) {
                        	t.record_vfPage__c = 'vfCaseDetail?id='+cse.id;
                        }
                        if(cse != null) {
                        	t.record_Parms__c= '&isdtp=vw&review=true&showCloseTabCancelOverride=true';
                        }                        
                        tasks.add(t); 
                        System.debug('--- Adding task for myself='+g.name);              	
                }
                if(!tasks.isEmpty()) {  
                    try {
                        insert tasks;
                        System.debug('--- inserting tasks ---'+tasks);
                      
                    } catch (Exception e) {
                        System.debug('error inserting task.. rolling back save trans:'+tasks + ' ..'+e.getMessage() );
                        Database.rollback(sp);
                    }
                }
            }
            
        }       

        return null;
    }
    public PageReference doCancelEditService() {
        return null;
    }
    public PageReference doCancelService() {
    	cancelSuccess = false;
        debugLog('at top of doCancelService');
        if(service != null && service.id != null) { 
            debugLog('--- in doCancel Service.. <font color=red>deleting service:'+service.name+' --- </font>');
            try {
            	delete service;
            } catch (Exception e) {
            	debugLog(e.getStackTraceString());
            }
        } else {
            
            debugLog('no service found in memory.. we are NOT deleting the serive');
        }
        if(serviceNote != null && serviceNote.id != null) {
            debugLog('--- in doCancel Service.. deleting service note ---');
            try {
            	delete serviceNote;
            } catch (Exception e) {
            	debugLog(e.getStackTraceString());
            	System.debug(logginglevel.error,e);
            } 
           
            cancelSuccess=true;
        }
        return null;
    }
    public PageReference doRefreshAppliedResourcesAfterSelected() {
        this.refreshAppliedResources();     
        return null;    
    }   
    public PageReference doCancelNewService() {
    	Boolean creatingNewCase = false;
    	if(cse!=null && service != null && service.Disposition__c == null ) {
    		creatingNewCase = true;
    	}
    	if(!creatingNewCase) {
        	this.jsCancelNewServiceButton = 'refreshPrimaryAndCloseSub();sforce.console.setTabUnsavedChanges(false);';
    	} else {
    		this.jsCancelNewServiceButton = 'refreshPrimaryAndCloseSub();sforce.console.setTabUnsavedChanges(false);';
    	}
       	if(cse != null) {
            cse.status = 'Closed';
            update cse;   
        }   
        if(service != null && service.id != null) {
            debugLog('--- in doCancelNewService.. deleting service ---');
            delete service;
        }
        if(serviceNote != null && serviceNote.id != null) {
            debugLog('--- in doCanceNewService.. deleting service note ---');
			delete serviceNote;
        }
        return null;        
    }

    public PageReference doFollowUpReasonSelect() {
        debuglog('--- in doFollowUpReasonSelect..service:'+service);
        if(!this.getFollowUpRequired()) {
            debuglog('--- in doFollowUpReasonSelect. setting followup date to null since its not required');
            service.Follow_Up_Date__c = null;
        } else {
            debuglog('--- in doFollowUpReasonSelect. Follow up reason is required');            
        }
        return null;
    }
    public PageReference doRemoveAppliedResource() {
        debugLog('in doRemoveAppliedResource()');
        Applied_Resource__c ar  = arUtils.retrieveAppliedResource(this.selectedAppliedResourceId);
        
        
        String arType = ar.type__c;
        String js = 'fireRemoveAppliedResource("'+arType+'");';
        this.jsRemoveArOnComplete  = js;        
        delete ar;
        //String msg = 'Applied Resource successfully deleted!';
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        this.refreshAppliedResources();     
        
        return null;
    }
    public void refreshAppliedResources() {
        this.appliedResources = arUtils.retrieveAppliedResources(this.cse, this.service);
    } 
    public void refreshNotes() {
    	debugLog('--- refreshing Notes ---');
        this.caseConsultationNotes = caseUtils.retrieveCaseConsultationNotesWraps(this.cse);        
    }
    private void initSectionState() {
        this.mSectionState = new Map<String,SectionStateBean>();
        mSectionState.put( 'panelLeftNav', new SectionStateBean('panelLeftNav',false) );  
        mSectionState.put('appliedResourcesSection', new SectionStateBean('appliedResourcesSection',true) );    
    }
    private void buildNewService(String parentCaseId) {
        
        this.cse = caseUtils.retrieveCaseSummaryData(parentCaseId);
        //this.cse = [select id from case where id = '500J0000001dS5j'];
        if(cse == null) {
            debugLog('Could not find case for id='+parentCaseId);
            return;
        } 
        Consultation__c cons = caseUtils.buildNewService(cse);
        this.service = cons;
        debuglog('--- in buildNewService..XXXXXXXXX building service.. (not yet inserted) service='+service);
        this.serviceNote = new Note();      
    }

    private void evalPageMode() {
        
        if(serviceId != null && serviceId != '') {
            this.service    = (Consultation__c)stdController.getRecord();
            this.service    = caseUtils.retrieveConsultation(serviceId);
            if(service == null) {
            	debuglog('error.. service could not be found!');
            	return;
            }
            debugLog('<font color=blue>In evalPageMode service='+service.name + ' id='+service.id +'</font>');
            this.cse        = caseUtils.retrieveCaseSummaryData(service.case__c);
            String js = '';
            this.isNewMode  = false;
            if(!this.isAddingFromCase) {
                this.isEditMode = true;
                sAction = 'Edit';
                js+= 'return confirm("Are you sure you wish to cancel? Any updates made will be discarded.");';

            } else {
            	this.isNewMode  = true;
                this.isEditMode = false;
                sAction = 'New';
                js+= 'return confirm("Are you sure you wish to cancel? The new service will not be saved.");';              
            }

            
            this.jsOnClickMainCancelButton = js;
        } else {
            debugLog(' XXXXXXXX This is a new consultation record! ie. must manually be tied to parent case.');
            if(parentCaseId == null || parentCaseId == ''){
                debugLog('no caseId in request..');
            } else { 
                buildNewService(parentCaseId);
                this.isEditMode = false;
                this.isNewMode  = true;
                String js = '';
                js+= 'return confirm("Are you sure you wish to cancel? The New Service will not be created.");';
                this.jsOnClickMainCancelButton = js; 
            }           
        }       
    }
*/
    
    
}