/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)
public class TEST_vfIntakeClientSearch_PART2 {

    public static   User                uTstExecUser            { get; set; }
    public static   ctrlIntakeSearch    ctrlSearch              { get; set; }
    public static   PageReference       prIntakeSearch          { get; set; }
    
    public static   List<Contact>       newClientsBuilt         { get; set; }
    public static   List<Case>          newCasesBuilt           { get; set; }
    public static   List<Contact>       newPartiesBuilt         { get; set; }
      
    /**
     * Executed by SFDC when running unit test code via GUI
     */
    public static testMethod void executeTest() {
        
        prIntakeSearch = Page.vfIntakeSearch;
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
        
        buildClientsForMatches(); //<--- Build Any needed clients and caseparties prior to searches.
        buildPartiesForMatches(); //<--- Build Any needed parties and caseparties prior to searches.        
        /*
         *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
         */ 
        Test.startTest();
        
            System.runAs(uTstExecUser) {
            
                Test.setCurrentPage(prIntakeSearch);
                ctrlSearch = new ctrlIntakeSearch(); //used if we need to share between methods

                autoSearch(); //url params passed to search page from home, client, case...etc
                miscNonSearchActions(); //I hate calling it this but for the pure amount of test logic / lack of time.. got to do this.
                
                System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
            }
                
        Test.stopTest();
        /*
         *-- STOP THE TEST ---------------------------------------------------------------------------------
         */
    }


    private static void buildClientsForMatches() {
        
        Integer iNumRecords = 10;
        
        //------ build clients
        TEST_TestObjectGeneratorUtility.TestObjectGenerator contactGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Contact.sObjectType);  
        TEST_TestObjectGeneratorUtility.GeneratorOverride clientOverride = new ClientOverWrite('Nenz Rocks');
        
        contactGenerator.OverwrittenGeneration = clientOverride;        
        newClientsBuilt = contactGenerator.GenerateTestsObjects(iNumRecords, true);
        System.Debug(LoggingLevel.WARN, '-----------------> Clients Built:'+String.valueOf(newClientsBuilt));   
        
        //------- build cases
        TEST_TestObjectGeneratorUtility.TestObjectGenerator caseGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Case.sObjectType);    
        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');
        TEST_TestObjectGeneratorUtility.GeneratorOverride caseOverride = new CaseOverWrite(rt);
        newCasesBuilt = caseGenerator.GenerateTestsObjects(iNumRecords,true);
        
        //--- Populate Case.clientId
        Integer iRecordIterator = 0;
        List<Case> casesToUpd = new List<Case>();
        
        for(Case cse : newCasesBuilt) {
            cse.contactId = newClientsBuilt.get(iRecordIterator).id;
            casesToUpd.add(cse);
            iRecordIterator++;
        }
        update casesToUpd;  
        newCasesBuilt = casesToUpd; 
        System.Debug(LoggingLevel.WARN, '-----------------> Cases Built:'+newCasesBuilt);
        
        //--- Build Case Party Junction
        List<Case_Party__c> caseParties = new List<Case_Party__c>();        
        for(Case cse : newCasesBuilt) {
            Case_Party__C cp = new Case_Party__c();
            cp.Type__c = 'Client';
            cp.contact__c = cse.contactId;
            cp.case__C = cse.id;
            caseParties.add(cp);
        }
        insert caseParties;
        System.Debug(LoggingLevel.WARN, '-----------------> Case Parties Built For Client Records:'+caseParties);           
    }
    
    private static void buildPartiesForMatches() {
        Integer iNumRecords = 10;
        
        //------ build parties
        TEST_TestObjectGeneratorUtility.TestObjectGenerator contactGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Contact.sObjectType);  
        TEST_TestObjectGeneratorUtility.GeneratorOverride partyOverride = new PartyOverWrite('Test Party');
        
        contactGenerator.OverwrittenGeneration = partyOverride;     
        newPartiesBuilt = contactGenerator.GenerateTestsObjects(iNumRecords, true);
        System.Debug(LoggingLevel.WARN, '-----------------> Parties Built:'+String.valueOf(newClientsBuilt));
        
        //--- Build Case Party Junction
        
        List<Case_Party__c> caseParties = new List<Case_Party__c>();
        Integer i = 0;      
        for(Case cse : newCasesBuilt) {
            Case_Party__C cp = new Case_Party__c();
            cp.Type__c = 'Party';
            cp.contact__c = newPartiesBuilt[i].id;
            cp.case__C = cse.id;
            caseParties.add(cp);
            i++;
        }
        
        insert caseParties;
        System.Debug(LoggingLevel.WARN, '-----------------> Case Parties Built For Party Records:'+caseParties);                
        
    }   
    /**
     * @todo starting to pile up DML Statements.. try to instantiate and set searchLogClient on the controller as opposed to relying on an 
     *  update if possible.
     *
     */
    private static void autoSearch() {  

        //-- build client search log record
        TEST_TestObjectGeneratorUtility.TestObjectGenerator SearchLogClientGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Search_Log__c.sObjectType);    
        List<Search_Log__c> searchLogClients = SearchLogClientGenerator.GenerateTestsObjects(1, true);
        Search_Log__c searchLogClient = searchLogClients[0];
        
        searchLogClient.User__c = UserInfo.getUserId();//Alex Grinevich
        update searchLogClient;//Alex Grinevich
        
        PageReference pr = Page.vfIntakeSearch;
        Test.setCurrentPage(pr);
        
        //run through trafficCop()
        
        pr.getParameters().put('clientSlId',searchLogClient.id);
        ctrlIntakeSearch    ctrl = new ctrlIntakeSearch(); //- first time through pageTrafficCop fired in constructor
        
        searchLogClient.fromPage__c = 'vfCarplsHome';
        update searchLogClient;
        ctrl = new ctrlIntakeSearch(); //- 2nd 
        
        searchLogClient.fromPage__c = 'vfClient';
        update searchLogClient;
        ctrl = new ctrlIntakeSearch(); //- 3rd 
        
        searchLogClient.Marked_as_Match__c = 'Yes';
        update searchLogClient;     
        pr.getParameters().put('clientReviewType','Client');
        ctrl = new ctrlIntakeSearch(); //- 4th

        searchLogClient.Marked_as_Match__c = 'Yes';
        searchLogClient.fromPage__c = null;
        update searchLogClient;     
        ctrl = new ctrlIntakeSearch(); //- 5th
        
        
        pr.getParameters().put('clientReviewType','Party');
        ctrl = new ctrlIntakeSearch(); //- 6th
        
        
        searchLogClient.fromPage__c = 'vfClient';
        update searchLogClient;     
        PageReference pr2 = Page.vfIntakeSearch;
        Test.setCurrentPage(pr2);       
        pr2.getParameters().put('newSearch','false');       
        ctrl = new ctrlIntakeSearch(); //- 7th
        
        /*
        ctrlSearch.doOnLoadSearchParties = true;
        //ctrl.doRapidCreateCase(); 
        ctrlSearch.slClient.Current_SL_Party__c = ctrlSearch.currentPartySlId;      
        Search_Log_Children__c slChild = SearchWrapper.retrieveSearchLogChild(ctrlSearch.currentPartySlId);
        slChild.marked_as_match__c = 'Yes';
        update slChild;             
        ctrlSearch.doInitActions();
        
        slChild.marked_as_match__c = 'No';
        update slChild;             
        ctrlSearch.doInitActions();     
        
        ctrlSearch.doClearAllSearches();
        */      
        
    }
    
    private static void miscNonSearchActions() {        
        ctrlIntakeSearch ctrl = new ctrlIntakeSearch();
        //PageReference pr = ctrl.doRapidCreateCase(); //-- this method generates client / party / searchlog data internally if it does not exist
        //System.assert(ctrl.wasRapidCreateCaseClicked);
        
        ctrl.togglePartyResults();
        ctrl.showAllPartyResults = !ctrl.showAllPartyResults;
        ctrl.togglePartyResults();
        
        ctrl.toggleIntakeResults();
        ctrl.showAllIntakeResults = !ctrl.showAllIntakeResults;
        ctrl.toggleIntakeResults();
        
        
        
        ctrl.getShowAddPartyButton();
        ctrl.partySw.getAssociationItems();
        ctrl.refreshSearchLogWraps();
        SearchLogWrapper slWrap = ctrl.slWraps[0];
        slWrap.isClientSlWrap();
        SearchLogWrapper sl = new SearchLogWrapper(); 
        
        ctrl.selectedClientSearchLogId = slWrap.clientSlId;
        ctrl.doRemoveClientSl();
        
        ctrl.getNewOrExistingItems();
        ctrl.getIndOrOrgItems();
    
        ctrl.getDisplayCreateCaseBtn();
        ctrl.doRadioSelect();
        ctrl.doIndOrOrgRadioSelect();      
        ctrl.doSelectPartySearchLog();  
        Search_Log__c slClient = new Search_Log__c(last_name__c='Unit Test Last');
        insert slClient;
        ctrl.selectedClientSearchLogId = slClient.id;
        ctrl.doClearAllSearches();
        
        
        //intentionally blow up case party trigger; @TODO.. but how???
        
		//bang on partysearch matcher to get coverge.
		PartySearchMatcher psm = new PartySearchMatcher();
		Contact client = TEST_TestUtils.createContact('Client');		
		client.Org_Name__c = 'UT Test Org Name';
		
		update client;
		Case tmpCase = TEST_TestUtils.createFullClientPartyCase(client, 'Closed');
		
		client = TEST_TestUtils.retrieveContactWithCaseParties(client);
		PartySearchWrapper psw = new PartySearchWrapper();
		psw.contact = client;		
		
		psm.processSearchTerms(psw);
		
				
		psm.buildOrgMatches( new List<Contact>{client},psw);   
		     
        
    }   
    
//----------------   Inner Custom OverWrite classes -----------------------------------
    public class ClientOverWrite extends TEST_TestObjectGeneratorUtility.GeneratorOverride {
        
        private String                      TestContactName     { get; set; }
        private String                      sCategory           { get; set; }
        
        public ClientOverwrite (String TestName) {
            this.TestContactName = TestName;
            this.sCategory = 'Client';                        
        }
        public override sObject RetrieveOverwrittensObject(Integer Iterable) {          
            return new Contact( LastName = (this.TestContactName != null ? this.TestContactName : 'Test OverwrittenContact' )  + String.valueOf(Iterable),
                                Category__c = (this.sCategory != null ? this.sCategory : 'Client') /*Initialize other fields here*/);
        } 
    }
    public class PartyOverWrite extends TEST_TestObjectGeneratorUtility.GeneratorOverride {
        
        private String                      TestContactName     { get; set; }
        private String                      sCategory           { get; set; }
        
        public PartyOverwrite (String TestName) {
            this.TestContactName = TestName;
            this.sCategory = 'Party';                        
        }
        public override sObject RetrieveOverwrittensObject(Integer Iterable) {          
            return new Contact( LastName = (this.TestContactName != null ? this.TestContactName : 'Test OverwrittenParty' )  + String.valueOf(Iterable),
                                Category__c = (this.sCategory != null ? this.sCategory : 'Party') /*Initialize other fields here*/);
        } 
    }       
    public class CaseOverWrite extends TEST_TestObjectGeneratorUtility.GeneratorOverride {
        private RecordType recordType { get; set; }
        public CaseOverwrite (RecordType rt) {
            this.recordType = rt;
        }
        public override sObject RetrieveOverwrittensObject(Integer Iterable) {
            return new Case(RecordTypeId= (this.recordType.id != null ? this.recordType.Id : null )  /*Initialize other fields here*/);
        }
    }   

    
}