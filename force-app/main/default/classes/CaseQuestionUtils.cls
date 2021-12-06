public with sharing class CaseQuestionUtils{
	/**
	 * @TODO Doc.
	 * 
	 */
	public static List<Consultation_Question__c> retrieveCaseQs( ProblemCodeWrapper pcWrap) {
		
		Boolean byPassProblemCodes = false;
		al.NestableCondition whereCAnd = new al.AndCondition();		
		
		if(pcWrap == null) {
			System.debug(logginglevel.warn, 'pcWrap parm cannot be null!');
			return null;
		}
		if(pcWrap.practiceArea == null) {
			byPassProblemCodes = true;
			System.debug(logginglevel.warn,'problem code wrapper='+pcWrap);
		}
		
		if(!byPassProblemCodes) {
			List<Id> epcIds = ProblemCodeUtils.retrieveEligibleProblemCodes(pcWrap, 'Case_Question__c');
			if(epcIds == null || epcIds.isEmpty()) {
				system.debug(logginglevel.warn,'<b>NO PROBLEM CODES FOUND!');
				if( (pcWrap.practiceArea =='' && pcWrap.practiceArea == '' && pcWrap.problemCode == '' && pcWrap.jurisdiction == '') || 
			         pcWrap.practiceArea == null) {
					byPassProblemCodes = true;
					system.debug(logginglevel.warn,'problemcode wrapper contains no values.. retrieveing all records');		 
				} else {
					return null;	
				}
			}			
			if(epcIds !=null && epcIds.size() > 0) {
				whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (epcIds )));
				//whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lAccountIds )));
			}						
		} else {
			System.debug(logginglevel.warn, 'bypassing problem codes!');			
		}
		//whereCAnd.add(new al.FieldCondition('status__c').equals('Active'));

		String soqlCaseQ= '';
		try {
			soqlCaseQ = 	new al.SoqlBuilder()
							.selectx(SoqlUtils.getAllFieldsSet('Consultation_Question__C',false)) 
							.selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
							.fromx('Consultation_Question__c')
							
							.wherex( whereCAnd )
							
							.toSoql();
		} catch (Exception e) {
			system.debug(logginglevel.error,e);
			system.debug(logginglevel.error,'soql='+soqlCaseQ);
			return null;
		}
		
		List<Consultation_Question__c> caseQuestions;
		try {	
			system.debug(logginglevel.info,'<b>Case Question soql=</b>'+soqlCaseQ);	
			caseQuestions = Database.query (soqlCaseQ);			
		} catch (Exception e)  {
			system.debug(logginglevel.warn,e);
		}  							
		return caseQuestions;			
	}
	public static Set<Id> retrieveCaseQIdsBySubject(Id subjectId) {
		
		List<Question_Subject_Junction__c> qSjs;
		Set<ID> qIds = new Set<ID>();
	
		al.NestableCondition whereCAnd = new al.AndCondition();
		whereCAnd.add(new al.FieldCondition('subject__c').equals(subjectId));	
		
		String soql;
		try {
			soql		 = 	new al.SoqlBuilder()
							.selectx(SoqlUtils.getAllFieldsSet('Question_Subject_Junction__c',false)) 
							.fromx('Question_Subject_Junction__c')
							.wherex( whereCAnd )
							.toSoql();
		} catch (Exception e) {
			system.debug(logginglevel.error,e);
			system.debug(logginglevel.error, 'SOQLBase='+soql);
			return qIds;					
		}		
		try {	
			system.debug(logginglevel.info,'<b>Question subject soql =</b>'+soql);	
			qSjs = Database.query (soql);
			if(qSjs!= null) {
				system.debug(logginglevel.warn,'----------------------------> retrieved '+qSjs.size()+' junction objects.');
				
			}
		} catch (Exception e)  {
		
			system.debug(logginglevel.warn,'<b>ERROR IN Case Question by subject soql:'+e);
		}		
		if(qSjs != null) {
			for(Question_Subject_Junction__c qsj  : qSjs) {
				qIds.add(qsj.Case_Question__c);	
			}
		}
		return qIds;
		
	}
	// Will return a list of Case Question objects : those referenced in the set of Ids passed in AND
	// those that are marked for_all_problem_codes	  
	public static List<Consultation_Question__c> retrieveCaseQuestions(Set<Id> qIds, Boolean bExcludeLargeFields) {
	
		List<Consultation_Question__c> qs;
		String soql = '';		
		al.NestableCondition whereCOr = new al.OrCondition();
		
		List<Id> lqIds = new List<Id>();
		for(Id id : qIds) {
			lqIds.add(id);	
		}
		if (lqIds != null && !lqIds.isEmpty()) {
			whereCOr.add(new al.SetCondition('id',al.Operator.INX, (lqIds)));
		}
		whereCOr.add(new al.FieldCondition('For_All_Problem_Codes__c').equals(true));
		
		Set<Object> qFields;
		if(bExcludeLargeFields) {
			/*
			Set<String> excludeFields = new Set<String>();
			excludeFields.add('Loop__Security__c');		
			excludeFields.add('Loop__RelatedObjects__c');
			ddpFields = SoqlUtils.getAllFieldsSet('Loop__DDP__c',false,excludeFields);			
			*/
			qFields = SoqlUtils.getAllFieldsSet('Consultation_Question__c',false);
		} else {
			qFields = SoqlUtils.getAllFieldsSet('Consultation_Question__c',false);
		}
		
		try {
			soql	 = 	new al.SoqlBuilder()
							.selectx(qFields) 
							.selectx((new Set<String> {'CreatedBy.Name','CreatedBy.communitynickname','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
							.fromx('Consultation_Question__c')
							.wherex( whereCOr )
							.orderbyx(new al.OrderBy('order__c').ascending().nullsLast())
							.toSoql();
		} catch (Exception e) {
			system.debug(logginglevel.error,e);
			system.debug(logginglevel.error, 'SOQLBase='+soql);
			return null;						
		}	
		try {	
			system.debug(logginglevel.info,'<b>case question baseSOQL=</b>'+soql);	
			qs = Database.query (soql);
			if(qs!= null) {
				system.debug(logginglevel.warn,'----------------------------> retrieved '+qs.size()+' Case questions.');	
			}
		} catch (Exception e)  {			
			system.debug(logginglevel.warn,'<b>ERROR IN DDP soql');
		}
		// if the query returned no rows create an empty list to return.  This will prevent problems later
		if (qs == null) {
			qs = new List<Consultation_Question__c>();
		}		
		return qs;
	}	

}