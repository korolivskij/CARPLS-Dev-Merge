public with sharing class ctrlDocumentExtension extends ctrlCarplesGeneric {
	public ctrlDocumentExtension(ApexPages.StandardController stdController) {}
	/*
	
	public Carpls_Document__c 			cDoc 				{ get; set; }
	public List<FeedItem> 				feedItems 			{ get; set; }
	public List<FeedItemWrapper>		feedItemWrappers	{ get; set; }
	
	public ctrlDocumentExtension(ApexPages.StandardController stdController) {
		super();
        this.getObjects();
        this.initSettings();
        this.cDoc = (Carpls_Document__c)stdController.getRecord();
        this.getAllRecordData();  
        this.feedItems = this.retrieveAttachedFeedItems(); 
        
       // super.debugLog('feedItems are:'+this.feedItems);     
	}
	
	protected override void getObjects() {
		super.getObjects();
	}
    public ctrlDocumentExtension getTheController() {
        return this;
    }	
	protected override void initSettings() {
		super.initSettings();
		//-- anything custom to this specific controller here. 
	}
    private void getAllRecordData() {
		id docId = cDoc.id;
		String soql = SoqlUtils.getAllFieldsSOQL('Carpls_Document__c',false,'' );		
		soql += ' where id =:docId';
		this.cDoc = Database.query(soql);    	
    }
    
    public List<FeedItem>retrieveAttachedFeedItems() {

    	List<FeedItem> fis = new List<FeedItem>();
    	id docId = cDoc.id;
    	String sType = 'ContentPost';
		String soql = 'Select f.createdDate,f.relatedRecordId, f.Type, f.Title, f.ParentId, f.LinkUrl, f.Id, f.ContentType, f.ContentSize, f.ContentFileName, f.ContentDescription, f.Body, f.insertedby.name From FeedItem f ';	
		soql += ' where f.type = :sType';	
		debugLog(soql); 
		fis = Database.query(soql);
		debugLog('fis size='+fis.size());
		Set<Id> contentVersionIds = new Set<Id>();
		for(FeedItem fi : fis) {
			contentVersionIds.add(fi.relatedRecordId);
		}
		List<ContentVersion> cvs = [	select id, contentdocument.id from ContentVersion cv 
									where cv.isLatest = true 
									and cv.id in :contentVersionIds];
									
		List<FeedItemWrapper> fiws = new List<FeedItemWrapper>();
									
    	for(FeedItem fi : fis) {    		
    		for(ContentVersion cv : cvs) {
    			if(cv.id == fi.relatedRecordId) {
    				FeedItemWrapper fiw = new FeedItemWrapper(fi,cv);
    				fiws.add(fiw);
    			}
    		}
    	}
    	//super.debugLog(String.valueOf(fiws));
    	this.feedItemWrappers = fiws;
    	return fis;    	
    }  
    public Pagereference doPreviewDoc() {
    	return null;
    }  	
    public PageReference doDeleteDoc() {
    	super.debugLog('<b>doDeleteDoc=</b>' + selectedId+ '<br/>');
    	Id feedItemId = selectedId;
    	FeedItem fiToDel = [select id,contentFileName,relatedRecordId from feeditem where id = :feedItemId];
    	Id relatedRecordId = fiToDel.RelatedRecordId;
    	
    	ContentVersion cv = [select id, contentdocument.id from ContentVersion cv 
							 where cv.isLatest = true 
							 and cv.id = :relatedRecordId limit 1];
		Id contentDocumentId = cv.ContentDocumentId;					 
    	ContentDocument cd = [select id from ContentDocument where id = :contentDocumentId limit 1];
    	delete cd;   	
    	String msg = 'Attachment: '+fiToDel.ContentFileName + '  deleted successfully!';
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
    	this.feedItems = this.retrieveAttachedFeedItems();
    	
    	
    	return null;
    }  	
    public PageReference doDownloadDoc() {
    	String url = '';
    	url += '/sfc/servlet.shepherd/version/download/' + this.selectedId + '?asPdf=false&operationContext=CHATTER';
		Pagereference pr = new Pagereference (url);
		String msg = 'File Download Initiated';
		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
		return pr;    	
    }
	*/
}