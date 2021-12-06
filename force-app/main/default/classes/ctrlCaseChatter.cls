public with sharing class ctrlCaseChatter extends ctrlCarplesGeneric {
    
    public String                       reRenderList            { get; set; }
    public ctrlCaseDetail               ctrl                    { get; set; }
    public String                       selectedCvCustomType    { get; set; }
     
    /*
     * Transient otherwise ViewState Size limit will be exceeded 
     * upon file upload. Damn you SFDC!
     */
    public transient FeedItem       feedItem;
    public transient ContentVersion contentVersion;
    public transient Blob           fileContent                 { get; set; }
    public id        				cvVersionIdSaved			{ get; set; } 
    
    public ctrlCaseChatter() {
        super();
        feedItem = new FeedItem();
    }
    public FeedItem getFeedItem() {
        if(this.feedItem == null) {
            this.feedItem = new FeedItem();
        }
        return this.feedItem;
    }   
    public void setFeedItem(FeedItem fi ) {
        this.feedItem = fi;
    }
    public ContentVersion getContentVersion() {
        if (this.contentVersion == null) {
            this.contentVersion = new contentVersion();
        }
        return this.contentVersion;
    }
    public void setContentVersion(ContentVersion cv) {
        this.contentVersion = cv;
    }
    
    public pageReference doSaveDoc() {
        
        //feedItem.Type = 'ContentPost';
        //feedItem.ParentId = ctrl.cse.id;
        //contentVersion.firstPublishLocationId = ctrl.cse.id;
        contentVersion.Case__c = ctrl.cse.id;
        contentVersion.versionData = fileContent;
        
        List<ContentWorkSpace> CWListtest = [SELECT Id, Name From ContentWorkspace];
        
        for(ContentWorkSpace cw: CWListtest)
        {
			System.debug('ContentWorkSpace name:' + cw.Name);            
        }
        
        List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'User Attached Documents'];
        contentVersion.firstPublishLocationId = CWList.get(0).Id;
        try {
            //insert feedItem;
            insert contentVersion;
            /*
             * Refresh the parent controller vars.
             */
            //ctrl.refreshFeedItemWrappers();
            ctrl.refreshContentVersionWrappers();
            String msg = '';
            //msg = 'Attachment: ' +  feedItem.contentFileName + ' uploaded successfully!';
            msg = 'Attachment: ' +  contentVersion.pathOnClient + ' uploaded successfully!';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));  
            //Id fiid = feedItem.id;
            //feedItem = [select id, relatedRecordId,contentFileName,contentDescription from FeedItem where id = :fiId ];
            //Id contentVersionId = feedItem.RelatedRecordId;
            Id contentVersionId = contentVersion.id;
            System.debug(logginglevel.warn, 'CV related record id='+contentVersionId);
            ContentVersion cv = [select id, custom_type__c from ContentVersion where id = :contentVersionId];
            cv.Custom_Type__c = this.selectedCvCustomType;
            
            //ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
            //cwd.ContentDocumentId = cv.ContentDocumentId;
            //cwd.ContentWorkspaceId = CWList.get(0).Id;
            //-------------  The below fails in a TEST case due to a retarded SFDC bug.
            if(!Test.isRunningTest()) {
            	update cv;
            }
            cvVersionIdSaved = cv.id;
            //insert cwd;
            //feedItem = null;
            contentVersion = null;
        } catch ( DmlException ex ) {
        	System.debug(logginglevel.error,ex);
            super.debugLog( ex.getMessage() );      
        }       
        
        
       
        return null;            
    }
    public List<Selectoption> getCvCustomTypeOptions() {
        List<Selectoption> selOptions = UiUtils.retrievePlValues(new ContentVersion(), 'Custom_Type__c');   
        List<SelectOption> visibleSelOptions = new List<SelectOption>();
        for(Selectoption so : selOptions) {
            if(so.getValue() != 'Publication') {
                visibleSelOptions.add(so);
            }
        }
        return visibleSelOptions;
    }    
}