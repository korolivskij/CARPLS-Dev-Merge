@isTest(SeeAllData=false)
private class TEST_Case_Triggers {
	public static   User         			uTstExecUser       	{ get; set; }
	public static   Contact	 				newClient			{ get; set; }
	public static   List<Contact>           newParties			{ get; set; }
	public static   Case					newCase				{ get; set; }
	public static   Search_Log__c	 		newSl				{ get; set; }
	public static   Possible_Conflict__c 	newPc				{ get; set; }		
	
  /**
   * Executed by SFDC when running unit test code via GUI
   */
  public static testMethod void executeTest() {
    
    /* 
     *  Just pass blank parms for user now. This is a luxury that I wish we had but we may
     *  run out of time before we can test multiple users / roles / profiles via code.
     *  In the above scenario, a user will be created on the fly and is a system admin
     *  with no roles / permission sets applied.
     * 
     *  @TODO maybe pull testing user from custom setting.
     *  @TODO maybe create different users from different roles / profiles on the fly
     */
    coreExecution('', '', '', '');
  }
  /**
   * The core launch point for this test class.
   */
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

      	testCaseAdds();
      	testCaseUpdates();
      	testCaseDeletes();      	
    	 
      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
	/**
	 * blah blah i love to type.
	 * 
	 */
	private static void testCaseAdds() {	
		
		String caseDesc = '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234this sentence should be broken up';
		Case cse = new Case(subject='Test Case', description = caseDesc);
		insert cse;	
		cse = refreshCase(cse.Id);
		
		String shortDescResult = '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234this sent';		
		System.assertEquals(cse.Description_First255__c,shortDescResult);											    		
	}
	private static void testCaseUpdates() {
		if(newCase == null) {
			buildTestData();
		}
		newCase.Description = 'DESC UPDATED!';
		update newCase;
		newCase.status = 'Open';
		update newCase;
		List<Consultation__c> newServices = new List<Consultation__c>();
		for(Integer i=0; i<5; i++) {
			Consultation__c svc = new Consultation__c(case__c=newCase.id);
			if(i==2 || i==4) {
				svc.status__c = 'Open';
			} else  {
				svc.status__C = 'Closed';
			}
			newServices.add(svc);
		}
		insert newServices;
		newCase.status = 'Closed';
		update newCase;
		List<Consultation__c> svcs = [select id, createddate from consultation__c where status__c != 'Closed'];
		system.debug('---svc='+svcs);
		//Consultation__c svcLast = [select id,createddate from consultation__c where case__c = :newCase.id order by createddate desc limit 1 ];
		//system.assert(svcs[0].createddate < svcLast.createdDate);

	}	
	private static void testCaseDeletes() {
		//ensure case parties are nuked with case.
		Id caseId = newCase.id;
		
		//@see blogic_Conflict_Logs.cascadePossibleConflicts
		Possible_Conflict__c pc = new Possible_Conflict__c(Case__c = caseId);
		insert pc;		
		
		//@see blogic_Conflict_Logs.cascadeConflictLogDelete
		Conflict_Log__c cl = new Conflict_Log__c(case__c = caseId);
		insert cl;
		
		refreshNewCase();
		
		delete newCase;
		
		
				
		List<Case_Party__c> cps = [select id from case_party__c where case__c = :caseId];
		System.assert(cps == null || cps.isEmpty());
		
		buildTestData();
	}
	/**
	 * Build new case, contact and child services and add to static var.. requery after adding services. 
	 */
    private static void buildTestData() {    
    	newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin', description = ' TEST DESC');
    	insert newCase;
    	
    	newClient = new Contact(lastname='TEST CLIENT LAST', category__c = 'Client');
    	insert newClient;    	
    	List<Contact> parties = new List<Contact>();
    	Contact p1 = new Contact(lastname='TEST PARTY LAST1', category__c = 'Party');
    	parties.add(p1);
    	Contact p2 = new Contact(lastname='TEST PARTY LAST2', category__c = 'Party');
    	parties.add(p2);
    	
    	insert parties;
    	
    	List<Case_Party__c> cps = new List<Case_Party__c>();
    	
    	Case_Party__C cp = new Case_Party__c();
    	cp.Type__c = 'Client';
    	cp.contact__C = newClient.id;
    	cp.case__C = newCase.id;
    	cp.Primacy__C = 'Primary';
    	
    	cps.add(cp);
    	
    	for(Contact p : parties) {
    		Case_Party__C cp1 = new Case_Party__c();
			cp1.Type__c = 'Adverse Party';
			cp1.contact__c = p.id;
			cp1.case__C = newCase.id;
			cps.add(cp1);
    	}	
    	insert cps;
    	

	   	
    	refreshNewCase();
    } 
    /**
     * .......
     */
	private static void refreshNewCase() {
		newCase = refreshCase(newCase.Id);
	}
    private static Case refreshCase(Id caseId) {
 	   	Case c;
    	c = [	Select 	id, subject,project__c,status,origin,Total_Nbr_of_Services__c,Total_Service_Time__c,
    						Total_Service_Time_Minutes__c,Description_First255__c,
    						(select id,project__c from consultations__r)
    				From	Case
    				Where	id = :caseId limit 1];   
    	return c;			 	
    }
}