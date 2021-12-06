public with sharing class ctrlCaseQuestions extends ctrlCarplesGeneric {
    
    public Id                               caseId;
    public Boolean                          pIsEditMode;
    public Boolean                          pAllowEditMode              { get; set; }
    public Boolean                          isEditMode                  { get; Set; }
    public Boolean                          classInitialized            { get; set; }
    public Case                             cse                         { get; set; }
    
    public CaseUtils                        cseUtils                    { get; set; }

    public List<DynaQaWrapper>              cseQaWraps                  { get; set; }   
    
    public Map<String, Schema.SObjectfield> sObjectFieldMap             { get; set; }
    
    public ctrlCaseQuestions( ) {
        debugLog('---- in ctrlCaseQuestions constructor---');
        this.showDebugMessages = true;
        this.isEditMode = false;    
        //this.pIsEditMode = false;
        this.pAllowEditMode = true;
        this.classInitialized = false;  
        this.cseUtils = new CaseUtils();    
        this.sObjectfieldMap = UiUtils.getSObjectFieldsMap(new Case());
        this.cseQaWraps = new List<DynaQaWrapper>();
       
        //doInitCaseQuestions();
        
    }
    public void setCaseId(Id pCaseId) {     
        this.caseId = pCaseId;
    }
    public Id getCaseId() {
        return this.caseId;
    }
    public void setPisEditMode(Boolean bSetIt) {
        this.pIsEditMode = bSetIt;  
    
        //this.isEditMode = pIsEditMode;
        debugLog('in setPIsEditMode .. parmPIsEditMode Passed='+bSetIt+'....');
        this.doInitCaseQuestions();
    }
    public Boolean getPisEditMode() {
        return this.pIsEditMode;    
    }
    public PageReference doInitCaseQuestions() {
        System.debug(logginglevel.warn,'----- in doInitCaseQuestions!!!');
        if(this.classInitialized) {
            debugLog('----- in doInitCaseQuestions.. Boolean shows class is already initted exiting method from top ---');
            return null;            
        }
        this.isEditMode = pIsEditMode;
    
        debugLog('----- in doInitCaseQuestions (component) editmode= '+this.isEditMode);
        this.cse = cseUtils.retrieveCaseSummaryData(caseId);
        
        List<Consultation_Question__c> caseQuestions        = new List<Consultation_Question__c>();
        
        caseQuestions = this.retrieveAllCaseQuestions();
        
        for(Consultation_Question__c q : caseQuestions) {
            DynaQaWrapper dynaQa = new DynaQaWrapper(q.id);
            debugLog('building wrapper list.. question apifieldname='+q.case_answer_field_name__c);
            dynaQa.sObjfield = UiUtils.getSObjectField(sObjectFieldMap, q.Case_Answer_Field_Name__c);           
            dynaQa.apiFieldName = q.Case_Answer_Field_Name__c;
            dynaQa.question = q;
            if(dynaQa.apiFieldName!=null && dynaQa.apiFieldName != '') {            
                cseQaWraps.add(dynaQa);
            }
        }

        debugLog('----- in doInitCaseQuestions cseQaWraps size='+cseQaWraps.size());
        this.classInitialized = true;
        return null;                        
    }
    private List<Consultation_Question__c> retrieveAllCaseQuestions() {      
        List<Consultation_Question__c> allCaseQuestions = new List<Consultation_Question__c>();
        Id subjectId = cse.Selected_Subject__c;
        if(subjectId == null) {
            return allCaseQuestions;
        }
        Set<Id> allPossibleQIds = CaseQuestionUtils.retrieveCaseQIdsBySubject(subjectId);
        
        Integer numAllPossible = 0;
        if(allPossibleQIds != null && allPossibleQIds.size() > 0) {
            allCaseQuestions = CaseQuestionUtils.retrieveCaseQuestions(allPossibleQIds,false);
            if(allCaseQuestions != null) {
                numAllPossible = allCaseQuestions.size();
            }       
        }
        debugLog('<font color="blue">'+numAllPossible+'</font>-->POSSIBLE Case Questions (Question_subject_junction) for this subject');    
        return allCaseQuestions;    
    }   
    public Boolean getDoQuestionsExist() {
        Boolean anyExist = false;
        anyExist =  ( cseQaWraps != null && !cseQaWraps.isEmpty());
        return anyExist;
    }
    public PageReference doSaveCaseQuestions() {
        debugLog('----- in doSaveCaseQuestions updating case ---');
        update cse;
        this.isEditMode = false;
        return null;
    }
    public PageReference doCancelEditMode() {
        debugLog('----- in doCancelEditMode ---');
        this.isEditMode = false;
        return null;
    }
    public PageReference doEditMode() {
        debugLog('----- in doEditMode ---');
        this.isEditMode = true;
        return null;
    }
    public pageReference doClearDebugMessages() {
        debugMessages = new List<DebugMessage>();       
        return null;
    }   
    
}