/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TEST_BatchUpdateCaseReviewReviewedBy {
	public static   User         			newUser	       		{ get; set; }
	public static   Case					newCase				{ get; set; }
	public static   Consultation__c	 		newService			{ get; set; }
	public static	Id						pId					{ get; set;	}
	
   static testMethod void fireBatchUpdateCaseReviewReviewedBy() {
      
      	
      	buildTestData();
      
      	Test.startTest();
          
          String soql = '';
          List<String> emailAddys = new List<String>();
          emailAddys.add('ericacox10@gmail.com');
          Boolean bCommitTrans = true;
          
          /**
           * Query All Records 
           */
          soql += '  SELECT   id, review_status__c, reviewed_by__c, service_by__c ';
          soql += '  from   Case_Review__c ';
          soql += '  where review_status__c = \'Test Status\'';
          if(Test.isRunningTest()) {
            soql += ' LIMIT 199 ';
          }
    
      BatchUpdateCaseReviewReviewedBy  batchUpd = 
        new BatchUpdateCaseReviewReviewedBy(  soql,emailAddys,
                              bCommitTrans);
      id batchId = Database.executeBatch(batchUpd); 
      System.debug(logginglevel.info,'\n=========== Executing batch id='+batchId);
               
        Test.stopTest();    
    }
    	/**
	 * Build new case, contact and child services and add to static var.. requery after adding services. 
	 */
    private static void buildTestData() {    
    
    	pId = UserInfo.getProfileId();
        
    	newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin', description = ' TEST DESC');
    	insert newCase;
    	
    	newService = new Consultation__c(Case__c = newCase.id);
    	insert newService;    	
    	
    	newUser = new User(username='testcr@carpls.org',email='testcr@carpls.org',alias='test',
    				CommunityNickname='testcr',TimeZoneSidKey='America/Chicago',LocaleSidKey='en_Us',
    				EmailEncodingKey='ISO-8859-1',ProfileId=pId,LanguageLocaleKey='en_US',
    				lastname = 'TestUser');
    	insert newUser;
    	
    	List<Case_Review__c> crs = new List<Case_Review__c>();
      
      	for(Integer i = 0 ; i < 99 ; i++) {
        	Case_Review__c cr = new Case_Review__c(Case__c = newCase.id, Service__c = newService.id);
        	cr.service_by__c = newUser.id;
        	cr.review_status__c = 'Test Status';
        	crs.add(cr);
      	}
      	insert crs;
    	
    	

	   	
    } 
    
}