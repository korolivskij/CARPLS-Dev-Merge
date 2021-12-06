@isTest
private class TEST_ChatterUtils {
    public static   User                uTstExecUser                { get; set; }
    public static   ctrlCaseDetail      ctrlCaseDetail              { get; set; }
    public static   PageReference       prCase                      { get; set; }
    public static   Contact             newClient                   { get; Set; }   
    public static   Search_Log__c       newSlClient                 { get; set; }
    public static   Case                newCase                     { get; Set; }
    public static   List<Case_Party__c> newCaseParties              { get; Set; }
    public static   CaseUtils			caseUtils					{ get; set; }
	public static	Subject__c			newSubject					{ get; set; }
	public static	Attachment			newAttachment				{ get; set; }
	public static	Applied_Resource__c	newAppliedResource			{ get; set; }
    public static 	ContentVersion 		contentVersion 				{ get; set; }

	@isTest
    public static void executeTest(){
        buildTestData();
        FeedItem feed = new FeedItem (
            parentid = newCase.id,
            type = 'ContentPost',
            RelatedRecordId = contentVersion.id,
            Body = 'Hello'
    	);
        ChatterUtils.addFeedItemLink(feed);
        ChatterUtils.retrieveFeedItemWrappersByParentId(newCase.Id);
        ChatterUtils.retrieveContentVersionWrappersByCaseId(newCase.Id);
    }
     private static void buildTestData() {
        
        newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'jur1';
    	newSubject.Status__c = 'Active';
    	newSubject.Type__c = 'Pending';
    	newSubject.Litigation__c = 'Pending';
    	//newSubject.Show_Litigation_Questions__c = true;
    	insert newSubject;     
        
        newClient = TEST_TestUtils.createContact('Client');
        
        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        //newCaseParties = caseUtils.retrieveCaseParties(newCase);        
         
        ContentVersion cv= new ContentVersion();
        cv.Title='Test file';
        cv.PathOnClient='Test file.pdf';
        cv.Case__c=newCase.Id;
        cv.VersionData = Blob.valueOf('TEST');
        insert cv;
        
        Id cdId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = newCase.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        contentVersion=cv;
        
    }    
}