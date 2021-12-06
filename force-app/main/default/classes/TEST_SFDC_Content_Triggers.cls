/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)	
public class TEST_SFDC_Content_Triggers {
	
	public static   User         			uTstExecUser       	{ get; set; }
	public static   Contact	 				newClient			{ get; set; }
	public static   Case					newCase				{ get; set; }		

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
   	createCollabGroup(); 
   	buildTestData(); 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {

     	testContentVersionDocInsert();
     	testFeedItemDocInsert();
     	testMiscWrappers();

      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
	/**
   	 * We used to insert into FeedItem but it was changed to ContentVersion, Can't remember
   	 * all the reasons. .anyway lets make sure we test the same stuff ctrlCaseChatter is going to do.
   	 * It was one of the numerous back and forth function req changes..
   	 */
	private static void testContentVersionDocInsert() {
		ContentVersion cv = buildContentVersion(newCase.id);
		insert cv;     	
  	}

  	/**
   	 * We used to insert into FeedItem but it was changed to ContentVersion, Can't remember
   	 * all the reasons. Let's just try to get coverage on trgOnFeedItem
   	 *
   	 * @see trgOnFeedItem on FeedItem (after insert)
   	 * @see FeedItems.linkCaseChatterFilesToOrg(Set<Id> fiIds) 
   	 *  
   	 */
	private static void testFeedItemDocInsert() {
		FeedItem fi = buildFeedItem(newCase.id);
		insert fi;   	
  	}
  	
  	private static void testMiscWrappers() {
  		ContentVersion cv = buildContentVersion(newCase.id);
  		FeedItem fi = buildFeedItem(newCase.id);
  		new FeedItemWrapper(fi,cv); 		
  	}

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
    
    private static ContentVersion buildContentVersion(Id caseId) {
    	Blob fileContent = Blob.valueOf('Unit Test Document Body');
    	ContentVersion cv = new ContentVersion();
		cv.Case__c = newCase.id;
		cv.versionData = fileContent; 
		cv.title = 'UNIT TEST TITLE';
		cv.Description = 'Blah Unit Test CV DESC';
		cv.Custom_Type__c ='Client Document';
		cv.PathOnClient = '/test';
		List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'User Attached Documents'];
		cv.firstPublishLocationId = CWList.get(0).Id;	
		return cv;    	
    }  
    private static void createCollabGroup() {
    	//-- special case, even though see all data is false, sfdc won't let is
    	//-- insert an imaginary collab group with the name name in a unit test
    	//-- do not change the name of the below!;
    	CollaborationGroup cg = new CollaborationGroup();
    	cg.Name = 'Case Documents - Read Only - UNIT TEST';
    	cg.CollaborationType = 'Public';
    	insert cg;    	
    }
    private static FeedItem buildFeedItem(Id caseId) {
    	FeedItem fi = new FeedItem();
    	
		fi.Type = 'ContentPost';
		fi.ParentId = caseId;
		fi.ContentData = Blob.valueOf('Unit Test Document Body');
		fi.ContentDescription = 'UNIT TEST CONTENT DESC';
		fi.ContentFileName = 'unittest.jpg';
		
		return fi;    	
    }
    
    
       
}