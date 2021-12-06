/**
 * Test class for Utilities
 */
@isTest(seeAllData=false) /* RJN Added */
private class TEST_Utilities_Utils {

  static testMethod void UtiltiiesTest() {
      
      System.assertEquals('', Utilities.LEFT(null,5));
      System.assertEquals('', Utilities.LEFT('',5));
      System.assertEquals('134', Utilities.LEFT('134',5));
      System.assertEquals('12345', Utilities.LEFT('123456789',5));
      
      System.assertEquals('', Utilities.spaceUnderscore(null));
      System.assertEquals('t_t', Utilities.spaceUnderscore('t t'));
      
      System.assertEquals('t', Utilities.nullString('t'));
      date d = null;
      System.assertEquals('', Utilities.nullString(d));
      d = date.newInstance(2005,5,5);
      System.assertEquals('t', Utilities.nullString('t'));
      
      System.assertEquals(true, Utilities.isBLANK(null));
      System.assertEquals(true, Utilities.isBLANK(''));
      System.assertEquals(true, Utilities.isBLANK(' '));
      System.assertEquals(false, Utilities.isBLANK(' string '));
    }
    //test sortOptionsList
    static testMethod void SortOptionList() {
    List<SelectOption> testOptions = new List<SelectOption>();
    testOptions.add(new SelectOption('b','b'));
    testOptions.add(new SelectOption('a','a'));
    testOptions.add(new SelectOption('j','j'));
    testOptions.add(new SelectOption('i','i'));
    testOptions.add(new SelectOption('d','d'));
    testOptions.add(new SelectOption('f','f'));
    testOptions.add(new SelectOption('c','c'));
    testOptions.add(new SelectOption('e','e'));
    testOptions.add(new SelectOption('g','g'));
    testOptions.add(new SelectOption('h','h'));
    List<SelectOption> sortOptions = Utilities.SortOptionList(testOptions);
    System.assertEquals('a',sortOptions[0].getLabel());
    System.assertEquals('b',sortOptions[1].getLabel());
    System.assertEquals('c',sortOptions[2].getLabel());
    System.assertEquals('d',sortOptions[3].getLabel());
    System.assertEquals('e',sortOptions[4].getLabel());
    System.assertEquals('f',sortOptions[5].getLabel());
    System.assertEquals('g',sortOptions[6].getLabel());
    System.assertEquals('h',sortOptions[7].getLabel());
    System.assertEquals('i',sortOptions[8].getLabel());
    System.assertEquals('j',sortOptions[9].getLabel());
    
    //test getSelectStarSOQL -- test both bu using the overloaded method taking a string
    string testType = 'Contact';
    string result = Utilities.getSelectStarSOQL(testType);
    string result2 = Utilities.getSelectStarSOQL(testType, true);
    System.assertEquals(true, result.contains('createddate'));
    System.assertEquals(false, result2.contains('createddate'));
    System.assertEquals(true, result.contains(' FROM Contact'));
    System.assertEquals(true, result2.contains(' FROM Contact'));
    
    //test random
    string rand = Utilities.generateRandomString(5);
    system.assertEquals(5,rand.length());
    string rand2 = Utilities.generateRandomString(15);
    system.assertEquals(15,rand2.length());
    
    //test object methods
    Contact co = Utilities.createContact();
    system.assertNotEquals(null,co);
    Case c =  Utilities.createCase(co.Id);
    system.assertNotEquals(null,c);
    
    //-- RJN ADDED THE BELOW TO INCREASE ON ETHERIOS COVERAGE FROM ABOVE
    List<Object> lObjnull = null;
    List<Object> lObjEmpty = new List<Object>();
    List<Object> lObjHasObjects = new List<Object>();
    lObjHasObjects.add(new Account(name='UNIT TEST ACCOUNT'));
    system.assert(Utilities.doesListHaveValue(lObjnull) == false);
    system.assert(Utilities.doesListHaveValue(lObjEmpty) == false);
    system.assert(Utilities.doesListHaveValue(lObjHasObjects) == true);
    
    List<SObject> lSObjnull = null;
    List<SObject> lSObjEmpty = new List<SObject>();
    List<SObject> lSObjHasObjects = new List<SObject>();
    lSObjHasObjects.add(new Account(name='UNIT TEST ACCOUNT'));
    system.assert(Utilities.doesListHaveValue(lSObjnull) == false);
    system.assert(Utilities.doesListHaveValue(lSObjEmpty) == false);
    system.assert(Utilities.doesListHaveValue(lSObjHasObjects) == true);	
    
    system.assertEquals(Utilities.shortenText('UNIT',3),'UNI');
    
    String sNull = null;
    system.assertEquals(Utilities.nullString(sNull),'');
   	system.assertEquals(Utilities.nullString('VALUE'),'VALUE');       
 	
 	Integer iNull = null;
 	system.assertEquals(Utilities.nullString(iNull),'');
 	Integer iObj = Integer.valueOf('123');
 	system.assertEquals(Utilities.nullString(iObj),'123');
 	
 	system.assert(Utilities.isNotNullObject(new Account(name='unit test')));
 	system.assert(Utilities.isNotNullObject(null) == false);
 	
 	system.assert(Utilities.getSelectStar('Account') != null);
 	
 	system.assertNotEquals(Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Account','Resources'),null);	

 	Case cseAlert = new Case(subject = 'UNIT TEST CASE');
 	Contact cAlert = new Contact(lastname='UNIT TEST LN');
 	insert cseAlert;
 	insert cAlert;
 	Alert__c alert = new Alert__c(contact__c=cAlert.id,case__c=cseAlert.id,status__c='Open' );
 	insert alert;
 	List<Alert__c> alerts = Utilities.retrieveAllAlertsForContact(cAlert.id, 'Open');
 	System.assertNotEquals(alerts,null);
 	alerts = null;
 	alerts = Utilities.retrieveAllAlertsForCase(cseAlert.id, 'Open');
 	System.assertNotEquals(alerts,null);	
 	List<String> lRtDevNames = new List<String> {'Resources' };
 	system.assertNotEquals(Utilities.retrieveSObjectRecordTypes('Account',lRtDevNames),null); 
 	
 	system.assertNotEquals(Utilities.getPlValues('val1;val2'),null);
 	
 	List<String> lTestVal = new List<String> {'unittestvalue'};
 	system.assert(Utilities.doesListHaveValue(lTestVal,'unittestvalue'));
 	system.assert(!Utilities.doesListHaveValue(lTestVal,'SFDCISGOD'));
 	
 	system.assertEquals(Utilities.tokenizeString(null,null,null),null);
 	system.assertEquals(Utilities.tokenizeString('old',null,null),'old');
 	system.assertEquals(Utilities.tokenizeString('old','new',null),null);
 	system.assertEquals(Utilities.tokenizeString('old1','new1',','),'old1,new1');
	
 	system.assertEquals(Utilities.findObjectNameById(null),'');
 	system.assertEquals(Utilities.findObjectNameById(alert.id),'Alert__c');
 	
 	system.assertEquals(Utilities.findObjectLabelById(null),'');
 	system.assertNotEquals(Utilities.findObjectLabelById(alert.id),null);
 	
 	//test email
 	Utilities.sendEmail('blah@blah.com', 'subj', 'textbody', 'htmlBody');
 	List<String> toAddys = new List<String>();
 	toAddys.add('blah1@blah.com');
 	toAddys.add('blah2@blah.com');
 	Utilities.sendEmail(toAddys,'subj','tb','hb');
 	
 	Account a = new Account();
 	a.name = 'blah';
 	insert a;
 	Utilities.findSObjectTypeById(a.id);
 	Utilities.findSObjectFieldbyId(a.id, 'name'); 
 	
 	//@TODO Set up mock tests.. yet another SFDC pita / hack System.debug(logginglevel.warn,'acct name='+Utilities.getSpecificFieldId('Account', 'name'));
 	
 	
 	
  }
  
}