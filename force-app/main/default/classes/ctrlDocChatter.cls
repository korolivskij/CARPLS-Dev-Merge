public with sharing class ctrlDocChatter extends ctrlCarplesGeneric  {
    
    public String                       reRenderList    { get; set; }
    public ctrlDocumentExtension        ctrlDoc         { get; set; }
    
    /*
     * Transient otherwise ViewState Size limit will be exceeded 
     * upon file upload. Damn you SFDC!
     */
    public transient FeedItem           feedItem;
    
    public ctrlDocChatter() {
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
     
    public pageReference doSaveDoc() {
        
        feedItem.Type = 'ContentPost';
        //feedItem.ParentId = ctrlDoc.cDoc.id;
        try {
            insert feedItem;
            /*
             * Refresh the parent controller vars.
             */
            /*
            ctrlDoc.feedItems = ctrlDoc.retrieveAttachedFeedItems();        
            String msg = '';
            msg = 'Attachment: ' +  feedItem.contentFileName + ' uploaded successfully!';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));  
            feedItem = null;
            */
        } catch ( DmlException ex ) {
            super.debugLog( ex.getMessage() );      
        }       
        return null;            
    }    
}