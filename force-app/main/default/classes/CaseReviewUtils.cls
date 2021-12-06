public with sharing class CaseReviewUtils {
	public  static List<String>            debugMessages   = new List<String>();
    public Static Final Integer MAX_DEBUG_MESSAGES = 100;  
    
    public static Case_Review__c retrieveCaseReview( Id caseReviewId ) {
    	
    	Case_Review__c caseReview;
    	
        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('id').equals(caseReviewId));   
        
        Set<Object> caseReviewFields;
    
    	caseReviewFields = SoqlUtils.getAllFieldsSet('Case_Review__c',false);
    
        String soql = '';
        try {
             soql = new al.SoqlBuilder()
                            .selectx(caseReviewFields) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname','createdby.communitynickname' })) 
                            .selectx((new Set<String> {'Service__r.name','Reviewed_By__r.name' })) 
                            .fromx('Case_Review__c')
                            .wherex(whereCAnd)
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            return null;
        }
        try {   
            caseReview = Database.query( soql );
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
        } 
        return caseReview;
    }
    
    public static List<Case_Review__c> retrieveCaseReviews( Case pCse, String sStatus) {
        
        Integer iDebugMessages = 0;
        List<Case_Review__c> caseReviews = new List<Case_Review__c>();
        system.debug(logginglevel.debug,'<b>In CaseReviewUtils.retrieveCaseReviews, pCse ='+pCse+' sStatus = '+ sStatus);                                                        
        if(pCse == null || pCse.id == null) {
            return null;
        }
        
        al.NestableCondition whereCAnd = new al.AndCondition();     
        
        whereCAnd.add(new al.FieldCondition('case__c').equals(pCse.id));
        if (!sStatus.equals('ALL')) {
            //RJN per al
            if(sStatus.equalsIgnoreCase('Published')) { /*the whole final / completed / published crap */
                whereCAnd.add(new al.FieldCondition('review_status__c').notequals('Draft'));
                whereCAnd.add(new al.FieldCondition('review_status__c').notequals('No Note'));
                whereCAnd.add(new al.FieldCondition('review_status__c').notequals('Open'));
            } else {
                whereCAnd.add(new al.FieldCondition('review_status__c').equals(sStatus));
            }
        }    
        String soql = '';
        try {
             soql = new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Case_Review__c',false)) 
                            .selectx(new Set<String> {'Service__r.name','Reviewed_By__r.name','createdby.communitynickname' })
                            .fromx('Case_Review__c')
                            .wherex(whereCAnd)
                            .orderbyx(new al.OrderBy('service__r.createddate').ascending())
                            .limitx(1000)
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            debugMessages.add('retrieveCaseReviews.. exception='+e.getMessage());
            return null;
        }

        try {   
            caseReviews = Database.query( soql );
            if (iDebugMessages < MAX_DEBUG_MESSAGES) {
                debugMessages.add('retrieveCaseReviews.. soql='+soql);
                iDebugMessages++;
            }
            system.debug(logginglevel.info,'retrieveCaseReviews.. soql='+soql );
        } catch (Exception e)  {     
        	debugMessages.add('CaseReview search SOQL: '+soql);       
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
            debugMessages.add('retrieveCaseReviews.. exception='+e.getMessage());
        }       
        return caseReviews;
    }

    public static Id createCaseReview(Case_Review__c caseReview) {
        Id caseReviewId;
        
        try{
            caseReviewId = DmlUtils.DBInsert(caseReview);           
        } catch (DmlException dmlEx) {
            debugMessages.add(dmlEx.getMessage());
            System.debug(loggingLevel.error,dmlEx);
        } catch (Exception ex) {
            debugMessages.add(ex.getMessage());
            System.debug(loggingLevel.error,ex);
        }       
        
        return caseReviewId;
    }

}