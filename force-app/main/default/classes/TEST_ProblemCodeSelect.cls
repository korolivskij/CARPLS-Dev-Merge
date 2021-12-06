/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/04/11
**
** 
****/
@isTest(SeeAllData=false)  
public class TEST_ProblemCodeSelect {
    
    public static   User         				uTstExecUser       { get; set; }
    
  	public static   Account						newAcct			   { get; set; }   
    public static   Eligible_Problem_Codes__c	newAcctPc		   { get; set; }
    
    public static   Case						newCase			   { get; set; } 
    public static   Subject__c					newSubject		   { get; set; }     
    
    
     public static   PageReference       currentPage;
    /**
   	* Executed by SFDC when running unit test code via GUI
   	*/    
    public static testMethod void executeTest() {
           coreExecution('', '', '', '');
    }
    
    
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
    
    Datetime   dtTstStart        = Datetime.now();
    
    //-- Get testing user ---
    TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
    uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
    System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
    
    //-- If no org level custom setting a new one will be created.. 
    TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
    Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
    System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
    
    //-- Prepare data outside of starttest if possible.
    buildTestData(); 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
        System.runAs(uTstExecUser) {
            
            test();
			 System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
        }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
    
    private static void test()
    {
        //System.debug(logginglevel.INFO, ' test()');   
        //system.assert(true);
        
        currentPage = Page.vfCaseDetail;
        Test.setCurrentPage(currentPage); 
        //new ApexPages.StandardController(newCase)

        ctrlProblemCodeSelect pcs = new ctrlProblemCodeSelect();
        
        pcs.cse = newCase;
        pcs.doComponentInit();
        
        pcs.searchTerm = 'Test Case Subject';
        pcs.doPcSearch();
         //TODO: assert count of this.relatedSubjects,this.relatedArchivedSubjects 
        system.assertNotEquals(0, pcs.relatedSubjects.size());
       
        pcs.doClearPcSearch();
        //TODO: assert this.relatedSubjects,this.relatedArchivedSubjects are an empty lists
        system.assertEquals(0, pcs.relatedSubjects.size());
        
        pcs.doCreateTaskForNewSubject();
        
        pcs.doSelectSubject();
        system.assertEquals(newSubject.Id, pcs.cse.selected_subject__c);
        
        
        pcs.searchTerm = 'test subject title';
        pcs.doAddNewSubject();
        pcs.doSaveNewSubject();
        //assert new subject
        
        pcs.getIsCaseOpen();
        pcs.getNumActiveSubjects();
        pcs.getNumArchivedSubjects();
        pcs.getSearchMsgFromFilters();
        pcs.getShowNoResultsWarning();
        pcs.getShowResultsMaxWarning();
        pcs.doShowActive();
        pcs.doShowArchived();
        
        pcs.doNewSubjectUrlCreate();
        
    }
    
     private static void buildTestData() {   
        //TODO: add Account
        newAcct = new Account ( name='TEST Account Name1', description= 'TEST Account Desc1');
  		insert newAcct;
        
        // TODO: add Eligible_Problem_Codes__c
        newAcctPc = new Eligible_Problem_Codes__c();
  		newAcctPc.Practice_Area__c = 'pa1';
  		newAcctPc.Problem_Category__c = 'pcat1';
  		newAcctPc.Problem_Code__c = 'pc1';
  		newAcctPc.Account__c = newAcct.id;
  		insert newAcctPc;
         
        //TODO: add Subject__c
        newSubject = new Subject__c();
    	newSubject.Title__c = 'Unit Test Case Subject';
    	newSubject.Practice_Area__c = 'pa1';
    	newSubject.Problem_Category__c = 'pcat1';
    	newSubject.Problem_Code__c = 'pc1';
    	newSubject.Jurisdiction__c = 'Ricks House';
    	insert newSubject;
         
        //TODO: add Case
        newCase = new Case(subject='Unit TEST Case Subject');
  		newCase.Practice_Area__c = 'pa1';
  		newCase.Problem_Category__c = 'pcat1';
  		newCase.Problem_Code__c = 'pc1';
  		newCase.Jurisdiction__c = 'Ricks House';
         
        newCase.Selected_Subject__c = newSubject.Id;
         
    	insert newCase;	
     }

}