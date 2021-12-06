public without sharing class ChatterUtils {

	public static FeedItem addFeedItemLink(FeedItem post) {
				
		List<FeedItem> feedItems = new List<FeedItem>();
		feedItems.add(post);
		
		feedItems = ChatterUtils.addFeedItemLinks(feedItems);
		if(feedItems != null && !feedItems.isEmpty()) {
			post = feedItems[0];
		}	
		return post;		
	}
	
	public static List<FeedItem> addFeedItemLinks(List<FeedItem> posts) {
		try {
			insert posts;
		} catch (DmlException dmlEx) {
			System.debug(logginglevel.error,dmlEx);
		} catch (Exception ex) {
			System.debug(logginglevel.error,ex);
		}
		String msg = posts.size() + ' inserted';
		System.debug(logginglevel.info,msg);
		return posts;
	} 
	public static List<FeedItemWrapper> retrieveFeedItemWrappersByParentId(Id pParentId) {
   		List<FeedItem> fis = new List<FeedItem>();
    	id parentId = pParentId;
    	String sType = 'ContentPost';
	
		//al.NestableCondition whereCOr = new al.OrCondition();	
		al.NestableCondition whereC = new al.AndCondition();	
		//whereCOr.add(new al.FieldCondition('Case__c').equals(parentId ));	
		whereC.add(new al.FieldCondition('parentId').equals( parentId ));
		//whereC.add(whereCOr);			
		Set<String> excludeFieldsFis = new Set<String>{'ContentData'};
		String soql = new al.SoqlBuilder()
					.selectx(SoqlUtils.getAllFieldsSet('FeedItem', false, excludeFieldsFis ))
					.selectx(new Set<String>{'insertedBy.name','insertedBy.firstname','insertedBy.lastname'})
					.fromx	('FeedItem')
					.wherex( whereC )
					.orderByx(new al.OrderBy('CreatedDate').descending())
					.limitx(20)
  					.toSoql();	
		
		try {	 
			fis = Database.query(soql);
		} catch (Exception e) {
			System.debug(logginglevel.warn,e);
			return null;
		}
		
		if(fis == null || fis.isEmpty()) {
			System.debug(logginglevel.info,'No chatter messages found for soql:'+soql);
			return null;	
		}
		
		List<Id> contentVersionIds = new List<Id>();
		for(FeedItem fi : fis) {
			contentVersionIds.add(fi.relatedRecordId);
		}
		al.NestableCondition whereCIn = new al.AndCondition();
		whereCIn.add(new al.SetCondition('id',al.Operator.INX,contentVersionIds));
		whereCIn.add(new al.FieldCondition('isLatest').equals( true ));			
		 
		Set<String> excludeFieldsCv = new Set<String>{'VersionData'};		
		String soql2 = new al.SoqlBuilder()
					.selectx(SoqlUtils.getAllFieldsSet('ContentVersion', false, excludeFieldsCv ))
					.fromx	('ContentVersion')
					.wherex( whereCIn )
					.orderByx(new al.OrderBy('CreatedDate').descending())
  					.toSoql();		
		
		List<ContentVersion> cvs;
		
		try {	
			cvs = Database.query(soql2);
		} catch (Exception e) {
			System.debug(logginglevel.warn,e);
			return null;
		}		 
								
		List<FeedItemWrapper> fiws = new List<FeedItemWrapper>();
									
    	for(FeedItem fi : fis) {    		
    		for(ContentVersion cv : cvs) {
    			if(cv.id == fi.relatedRecordId) {
    				FeedItemWrapper fiw = new FeedItemWrapper(fi,cv);
    				fiws.add(fiw);
    			}
    		}
    	}
    	return fiws;
	}
	
	public static List<ContentVersionWrapper> retrieveContentVersionWrappersByCaseId(Id pCaseId) {
   		List<ContentVersion> cvs = new List<ContentVersion>();
   		List<ContentVersionWrapper> cvws = new List<ContentVersionWrapper>();
		id caseId = pCaseId;
		
		List<ContentDocumentLink> cdls=[ SELECT 
											Id,
											LinkedEntityId,
											ContentDocumentId 
										FROM    
											ContentDocumentLink 
										WHERE   
											LinkedEntityId=:caseId
		];
		List<Id> cdIds=new List<Id>();
		for(ContentDocumentLink cdlItem:cdls){
			cdIds.add(cdlItem.ContentDocumentId);
		}

    	
		al.NestableCondition whereCOr = new al.OrCondition();	
		al.NestableCondition whereC = new al.AndCondition();
		whereCOr.add(new al.FieldCondition('Case__c').equals(caseId ) );
		if(!cdIds.isEmpty()){
			whereCOr.add(new al.SetCondition('ContentDocumentId').inx(cdIds));	
		}
		whereCOr.add(new al.FieldCondition('firstPublishLocationId').equals( caseId ));
		whereC.add(whereCOr);
		whereC.add(new al.FieldCondition('isLatest').equals( true ));
		Set<String> excludeFieldsCvs = new Set<String>{'VersionData'};
		String soql = new al.SoqlBuilder()
					.selectx(SoqlUtils.getAllFieldsSet('ContentVersion', false, excludeFieldsCvs ))
					.selectx(new Set<String>{'createdBy.name','createdBy.firstname','createdBy.lastname','createdBy.communitynickname'})
					.fromx	('ContentVersion')
					.wherex( whereC )
					.orderByx(new al.OrderBy('CreatedDate').descending())
// removed limit as some CLASS cases had more than 20 files attached.  Hope no view state errors result.
//					.limitx(20)
  					.toSoql();	
		
		try {	 
			cvs = Database.query(soql);
		} catch (Exception e) {
			System.debug(logginglevel.warn,e);
			return null;
		}
		
		if(cvs == null || cvs.isEmpty()) {
			System.debug(logginglevel.info,'No chatter messages found for soql:'+soql);
			return null;	
		}
		
		for(ContentVersion cv : cvs) {
    		ContentVersionWrapper cvw = new ContentVersionWrapper(cv);
    			cvws.add(cvw);
    	}
    	return cvws;
	}


}