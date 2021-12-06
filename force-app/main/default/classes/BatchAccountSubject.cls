global with sharing class BatchAccountSubject implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    private List<Subject__c> subjectList = new List<Subject__c>();
    private List<Account_Subject_Junction__c> toInsertList = new List<Account_Subject_Junction__c>();
    global BatchAccountSubject(List<Subject__c> subjects) {
        this.subjectList =  subjects;                                                                     
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(Test.isRunningTest()){
            query = 'SELECT id, All_Subjects__c FROM Account WHERE All_Subjects__c = TRUE LIMIT 100';
        }else{
            query = 'SELECT id, All_Subjects__c FROM Account WHERE All_Subjects__c = TRUE';
        }
        
	  	return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(Subject__c subject :subjectList){
            ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(subject);
            List<Id> eAccountProblemCodeIds = ProblemCodeUtils.retrieveEligibleProblemCodes(pcWrap, 'account__c');
                Set<ID> eAccountProblemCodeSetIds = new Set<id>(eAccountProblemCodeIds);
                for(Account acc : (List<Account >)scope){
                    if(!eAccountProblemCodeSetIds.contains(acc.ID)){
                        eAccountProblemCodeSetIds.add(acc.ID);
                    }
                }
            
            if(Utilities.doesListHaveValue(new List<ID>(eAccountProblemCodeSetIds))) { 
                    System.debug(logginglevel.info, '... number of Eligible problem codes fround=:'+eAccountProblemCodeIds.size());
                    List<Account_Subject_Junction__c> aSjsInsert = new List<Account_Subject_Junction__c>();
                    for(Id aId : (new List<ID>(eAccountProblemCodeSetIds))) {
                        Account_Subject_Junction__c aSj = new Account_Subject_Junction__c();
                        aSj.subject__c = subject.id;
                        aSj.account__c = aId;
                        toInsertList.add(aSj);
                        
                    }
                    System.Debug('AS INSERTED ===== ' + toInsertList);
                }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(Utilities.doesListHaveValue(toInsertList)) {
              insert toInsertList;
              System.debug(logginglevel.info, 'INSERTED ' + toInsertList.size() + ' Account Sub Junction records'); 
        }
    }

}