public with sharing class SubjectUtils{
    
    public  static List<String>            debugMessages   = new List<String>();
    public Static Final Integer MAX_DEBUG_MESSAGES = 100;  
    public Static Final String ALL_JURISDICTIONS = 'All Jurisdictions'; 

    public static Subject__c retrieveSubject( Id subjectId ) {
        return retrieveSubject(subjectId, false);
    }
    
    public static Subject__c retrieveSubject( Id subjectId, Boolean bExcludeLargeFields ) {
        Subject__c subject;
    
        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('id').equals(subjectId));   
        
        Set<Object> subjectFields;
        if(bExcludeLargeFields) {
            Set<String> excludeFields = new Set<String>();
            excludeFields.add('Practice_Brief__c');     
            excludeFields.add('Resource_Brief__c');
            excludeFields.add('Solutions__c');
            subjectFields = SoqlUtils.getAllFieldsSet('Subject__c',false,excludeFields);
        } else {
            subjectFields = SoqlUtils.getAllFieldsSet('Subject__c',false);  
        }

        String soql = '';
        try {
             soql = new al.SoqlBuilder()
                            .selectx(subjectFields) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname','createdby.communitynickname' })) 
                            .selectx(new Set<String> {'RecordType.developername'}) 
                            .fromx('Subject__c')
                            .wherex(whereCAnd)
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            return null;
        }
        try {   
            subject = Database.query( soql );
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
        } 
        return subject;
    }
    
    public static List<Subject__c> retrieveSubjects( ProblemCodeWrapper pcWrap, String rtDevName, String sStatus) {
    	Integer iResLimit = 1000;
    	return retrieveSubjects( pcWrap,rtDevName, sStatus,iResLimit);
    }
    public static List<Subject__c> retrieveSubjects( ProblemCodeWrapper pcWrap, String rtDevName, String sStatus, Integer iResLimit) {
        List<Subject__c> subjects;
        Integer iDebugMessages = 0;
        Boolean byPassProblemCodes = false;
                                                                
        if(pcWrap == null && (pcWrap.searchTerm == null || pcWrap.searchTerm == '')) {
            System.debug(logginglevel.warn, 'ProblemCodeWrapper parm cannot be null!');
            debugMessages.add('retrieveSubjects.. problem code wrapper is null!');
            return null;
        }
        /*
        if(pcWrap.practiceArea == null && pcWrap.problemCode == null && pcWrap.problemCategory == null) {
            byPassProblemCodes = true;
            System.debug(logginglevel.warn,'problem code wrapper='+pcWrap);
        } 
        */
        if( (pcWrap.practiceArea == null ||  pcWrap.practiceArea == '') && (pcWrap.searchTerm == null || pcWrap.searchTerm == '')) {
            //byPassProblemCodes = true;
            //System.debug(logginglevel.warn,'problem code wrapper='+pcWrap);
            //--- never bypass problem codes.
            debugMessages.add('<font color=red>DUE TO VIEWSTATE ERRORS. SubjectUtils.retrieveSubjects requires a practiceArea to execute.. none was provided.. returning null</font>');
      		return null;
        }        
        
        al.NestableCondition whereCAnd = new al.AndCondition();  
        if(pcWrap.searchTerm != null && pcWrap.searchTerm != '') {
        	whereCAnd.add(new al.FieldCondition('Title__c').likex('%'+pcWrap.searchTerm+'%')); //Wildcard search term since only 20 will come back  
        }   
        whereCAnd.add(new al.FieldCondition('RecordType.name').equals(rtDevName));  
        
        

        /* 
         * If we are retrieveing subjects for a case. (ProblemCodeWrapper has it's cse varible populated.. 
         * Do special processing to ensure if the status of the selected subject on the case
         * is not equal to the sStatus passed .. we still retrieve it in the query.     
         *
         */
        if('FAQ'.equalsIgnoreCase(rtDevName)) {
            
        	al.NestableCondition whereCOr = new al.OrCondition();
            al.NestableCondition whereCAnd2 = new al.AndCondition();
            al.NestableCondition whereCOr2 = new al.OrCondition();
            /* always filter out Inactive  */
            /* filter out New except when it is the selected subject */ 
            whereCAnd2.add(new al.FieldCondition('status__c').equals(sStatus));   
            whereCAnd2.add(new al.FieldCondition('type__c').notequals('Pending'));
               
            if (sStatus == 'Active') {
             	if(pcWrap.cse != null) {
               		if(pcWrap.cse.selected_subject__c != null) {                    
                   		whereCOr.add(new al.FieldCondition('id').equals(pcWrap.cse.selected_subject__c));
               		}
               	}
                whereCOr.add(whereCAnd2);	  
                whereCAnd.add(whereCOr);  
                whereCAnd.add(new al.FieldCondition('status__c').notequals('Inactive'));            
            } else { 
                whereCAnd.add(whereCAnd2);              
            }       
        } 
        /* End special case detail subject select processing */
        
        
        
        
        if(!byPassProblemCodes) {
            if(pcWrap.practiceArea != null && pcWrap.practiceArea != '') {
                whereCAnd.add(new al.FieldCondition('Practice_Area__c').equals(pcWrap.practiceArea));   
            }
            if(pcWrap.problemCode != null && pcWrap.problemCode != '') {
                whereCAnd.add(new al.FieldCondition('Problem_Code__c').equals(pcWrap.problemCode));     
            }
            if(pcWrap.problemCategory != null && pcWrap.problemCategory != '') {
                whereCAnd.add(new al.FieldCondition('Problem_Category__c').equals(pcWrap.problemCategory)); 
            }   
            if(pcWrap.jurisdiction != null && pcWrap.jurisdiction != '') {
                if(pcWrap.jurisdiction != ALL_JURISDICTIONS) {
                	// TODO @ELC Setting this field should be done in the ProblemCodeWrapper, but since there is
                	// no case yet, only the null constructor is being called, with values set in the page
                	pcWrap.lJurisdictions = new List<String>();
                	pcWrap.lJurisdictions.add(pcWrap.jurisdiction);
                	pcWrap.lJurisdictions.add(ALL_JURISDICTIONS); 
                	whereCAnd.add(new al.SetCondition('Jurisdiction__c',al.Operator.INCLUDES,pcWrap.lJurisdictions));
                }
            }           
        }
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Practice_Brief__c');     
        excludeFields.add('Resource_Brief__c');
        excludeFields.add('Solutions__c');
        //Solutions__c
        String soql = '';
        try {
             soql = new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Subject__c',false,excludeFields)) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .selectx(new Set<String> {'RecordType.name'}) 
                            .fromx('Subject__c')
                            .wherex(whereCAnd)
                            .orderbyx(new al.OrderBy('title__c').ascending().nullsLast())
                            .limitx(iResLimit)
                            .toSoql();
                           
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            debugMessages.add('retrieveSubjects.. exception='+e.getMessage());
            return null;
        }

        try {   
            subjects = Database.query( soql );
            if (iDebugMessages < MAX_DEBUG_MESSAGES) {
                debugMessages.add('retrieveSubjects.. soql='+soql);
                iDebugMessages++;
            }
            system.debug(logginglevel.info,'retrieveSubjects.. soql='+soql );
        } catch (Exception e)  {     
        	debugMessages.add('Subject search SOQL: '+soql);       
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
            debugMessages.add('retrieveSubjects.. exception='+e.getMessage());
        }       
        return subjects;
    }

	public static List<Subject__c> retrieveRelatedSubjects(problemCodeWrapper pcWrap, Subject__c pSubj, List<String> pTypes, List<String> pStatus) {
		
		List<Subject__c> subjects;
        Integer iDebugMessages = 0;
        
		if (pcWrap == null) {
			System.debug(logginglevel.warn, 'Problem Code Wrapper cannot be null!');
            debugMessages.add('retrieveSubjectsByProblemCode.. pcwrap is null!');
            return null;
		}
		
				
		al.NestableCondition whereCAnd = new al.AndCondition();     
        whereCAnd.add(new al.FieldCondition('Practice_Area__c').equals(pcWrap.practiceArea));
        whereCAnd.add(new al.FieldCondition('Problem_Category__c').equals(pcWrap.problemCategory));
        whereCAnd.add(new al.FieldCondition('Problem_Code__c').equals(pcWrap.problemCode));
        whereCAnd.add(new al.SetCondition('status__c',al.Operator.INX, pStatus));
        whereCAnd.add(new al.SetCondition('type__c', al.Operator.INX, pTypes));
        whereCAnd.add(new al.FieldCondition('id').notequals(pSubj.id));
        
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Practice_Brief__c');     
        excludeFields.add('Resource_Brief__c');
        excludeFields.add('Solutions__c');
        //Solutions__c
        String soql = '';
        try {
             soql = new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Subject__c',false,excludeFields)) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .selectx(new Set<String> {'RecordType.name', 'CreatedBy.communitynickname'}) 
                            .fromx('Subject__c')
                            .wherex(whereCAnd)
                            .orderbyx(new al.OrderBy('title__c').ascending().nullsLast())
                            .limitx(1000)
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            debugMessages.add('retrieveSubjects.. exception='+e.getMessage());
            return null;
        }

        try {   
            subjects = Database.query( soql );
            if (iDebugMessages < MAX_DEBUG_MESSAGES) {
                debugMessages.add('retrieveSubjects.. soql='+soql);
                iDebugMessages++;
            }
            system.debug(logginglevel.info,'retrieveSubjects.. soql='+soql );
        } catch (Exception e)  {     
        	debugMessages.add('Subject search SOQL: '+soql);       
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
            debugMessages.add('retrieveSubjects.. exception='+e.getMessage());
        }       
        return subjects;
		
	}
    public static Id createSubject(Subject__c subject) {
        Id subjectId;
        
        try{
            subjectId = DmlUtils.DBInsert(subject);           
        } catch (DmlException dmlEx) {
            debugMessages.add(dmlEx.getMessage());
            System.debug(loggingLevel.error,dmlEx);
        } catch (Exception ex) {
            debugMessages.add(ex.getMessage());
            System.debug(loggingLevel.error,ex);
        }     

        return subjectId;
    }

}