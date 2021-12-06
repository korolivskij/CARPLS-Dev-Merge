Public with sharing class CaseQuestionWrapper implements Comparable {
    	Public Consultation_Question__c caseQ{get;set;}
     	Public Boolean checkBox{get;set;}   
		public Integer sortOrder{get;set;}
     	
		Public CaseQuestionWrapper( consultation_question__c cQ, boolean selected){
        	caseQ 		= cQ;
        	checkBox 	= selected;
			if(selected) { sortOrder = 1;} else { sortOrder = 0; }
		}
 		public Integer compareTo(Object oToCompare) {
			if(sortOrder > ((CaseQuestionWrapper)oToCompare).sortOrder) {
				return 0;
			} else {
				return 1;
			}
    	}		
 }