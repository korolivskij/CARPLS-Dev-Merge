/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * @TODO this is approaching too many SOQL queries already... Tune it.. use less doRapidCreateCase() and doCreateCase 
 *       calls and rely more on the prebuilt data.
 *
 *       ******************************************************************************************************************
 *       RJN Just dumped everything I could in 1 execute method for now.. SFDC decided to start counting test code in test coverage.
 *       *******************************************************************************************************************
 */
@isTest(SeeAllData=false)
public class TEST_vfIntakeClientSearch {

    public static   User                uTstExecUser            { get; set; }
    public static   ctrlIntakeSearch    ctrlSearch              { get; set; }
    public static   PageReference       prIntakeSearch          { get; set; }
    
    public static   List<Contact>       newClientsBuilt         { get; set; }
    public static   List<Case>          newCasesBuilt           { get; set; }
      
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
       // coreExecution('', '', '', '');
        Datetime   dtTstStart        = Datetime.now();

        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('', '','','' );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);

       // buildClientsForMatches(); //<--- Build Any needed clients / and caseparties prior to searches.
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
        System.Debug(LoggingLevel.WARN, '-----------------> Case Parties Built:'+caseParties);
        Test.startTest();

        System.runAs(uTstExecUser) {

            Test.setCurrentPage(prIntakeSearch);
            ctrlSearch = new ctrlIntakeSearch(); //used if we need to share between methods

           // quickSearch(); //Currently done from home page.

            //existingClientSearchNoMatchFound();
            //existingPartySearchNoMatchFound();

            //existingClientSearchMatchFound();
            //existingPartySearchMatchFound();

            //------- do the below last..
           // autoSearch(); //url params passed to search page from home, client, case...etc
           // miscNonSearchActions(); //I hate calling it this but for the pure amount of test logic / lack of time.. got to do this.
            //-- Create a standard search log record.
            //--- begin quickSearch()
            TEST_TestObjectGeneratorUtility.TestObjectGenerator searchLogClientGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Search_Log__c.sObjectType);
            Search_Log__c  searchLogClient = (Search_Log__c)searchLogClientGenerator.generateSingleTestsObject(true);

            searchLogClient.fromPage__c = 'vfCarplsHome';
            searchLogClient.sessionId__c =  UserInfo.getSessionId();
            update searchLogClient;

            prIntakeSearch.getParameters().put('clientSlId',searchLogClient.id);
            ctrlIntakeSearch ctrl = new ctrlIntakeSearch();
            System.assertEquals(ctrl.showNewContactSearchInputs, false);
            //--- end quickSearch()

            //-begin existingClientSearchNoMatchFound();
            //Simulate bound client Form Fields.
            ctrlSearch.sw.contact.firstname = 'ClientFirst';
            ctrlSearch.sw.contact.lastname  = 'ClientLast';
            ctrlSearch.sw.contact.Last_Four_SSN__c = '6666';
            ctrlSearch.sw.contact.Birthdate = Date.today();
            ctrlSearch.sw.contact.phone = '6303100898';
            ctrlSearch.sw.contact.Aliases__c = 'Nenz';

            prIntakeSearch.getParameters().put('newSearch','true');
            ctrlSearch.searchBtnClicked = true;


            // Search Clicked for Client Search

            ctrlSearch.doClientSearch();
            //-- Search log created.
            System.assert(ctrlSearch.clientSearchLog.last_name__c == 'ClientLast');


            //Click Clear Search (Client Search) / Client Search Again.

            ctrlSearch.doClearClientSearch();
            System.assert(ctrlSearch.clientSearchLog == null);
            //Simulate bound client Form Fields.
            ctrlSearch.sw.contact.firstname = 'Rick2';
            ctrlSearch.sw.contact.lastname  = 'Nendza2';
            ctrlSearch.sw.contact.Last_Four_SSN__c = '6666';
            ctrlSearch.sw.contact.Birthdate = Date.today();
            ctrlSearch.sw.contact.phone = '6303100898';
            ctrlSearch.sw.contact.Aliases__c = 'Nenz';

            prIntakeSearch.getParameters().put('newSearch','true');
            ctrlSearch.doClientSearch();
            System.assert(ctrlSearch.clientSearchLog.last_name__c == 'Nendza2');


            // Save & Continue Pressed.

            ctrlSearch.doNoClientMatches();
            //-- Contact Inserted.. with Name that was searched.
            System.assert(ctrlSearch.sw.contact.lastname == 'Nendza2');
            //- end existingClientSearchNoMatchFound();

            //-begin existingPartySearchNoMatchFound();
            //Party Search - Individual
            if(ctrlSearch.clientSearchLog == null) {
                System.debug(logginglevel.warn,'please search for a client before searching for a party!');
                return;
            }
            ctrlSearch.selectedIndOrOrg = 'Individual';
            ctrlSearch.partySw.contact.FirstName = 'Susan';
            ctrlSearch.partySw.contact.LastName  = 'Chase1';
            ctrlSearch.partySw.contact.phone = '6305551212';
            ctrlSearch.partySw.relationship = 'Sister';
            ctrlSearch.partySw.selectedAssociation = 'Attorney';

            ctrlSearch.partySearchBtnClicked = true;
            ctrlSearch.addPartySearchBtnClicked = false;
            ctrlSearch.doPartySearch();
            System.assertNotEquals(ctrlSearch.currentPartySlId, null);
            ctrlSearch.doNoPartyMatches();
            Search_Log_Children__c currentSlParty = PartySearchWrapper.retrievePartySearchLog(ctrlSearch.currentPartySlId);
            System.assertNotEquals(currentSlParty.party_created__C,null);
            ctrlSearch.doContinuePartySearch();
            //-end existingPartySearchNoMatchFound();

            //-begin existingClientSearchMatchFound();
            //Simulate bound client Form Fields.
            ctrlSearch.sw.contact.firstname = 'ClientFirst';
            ctrlSearch.sw.contact.lastname  = 'Nenz Rocks';
            ctrlSearch.sw.contact.Last_Four_SSN__c = '6666';
            ctrlSearch.sw.contact.Birthdate = Date.today();
            ctrlSearch.sw.contact.phone = '6303100898';
            ctrlSearch.sw.contact.Aliases__c = 'Nenz';

            prIntakeSearch.getParameters().put('newSearch','true');
            ctrlSearch.searchBtnClicked = true;

            //Search Clicked for Client Search

            ctrlSearch.doClientSearch();
            //-- Search log created.
            System.assert(ctrlSearch.clientSearchLog.last_name__c == 'Nenz Rocks');


            //Continue to party search

            ctrlSearch.doContinueClientSearch();
            System.assert(ctrlSearch.isCollapseClientData);
            //-end existingClientSearchMatchFound();

            //-begin existingPartySearchMatchFound();
            if(ctrlSearch.clientSearchLog == null) {
                System.debug(logginglevel.warn,'please search for a client before searching for a party!');
                return;
            }
            currentSlParty = PartySearchWrapper.retrievePartySearchLog(ctrlSearch.currentPartySlId);
            System.assertNotEquals(currentSlParty.party_created__C,null);

            //Simulate bound party Form Fields with party created via no match in existingPartySearchNoMatchFound.
            ctrlSearch.selectedIndOrOrg = 'Individual';
            ctrlSearch.partySw.contact.FirstName = currentSlParty.First_Name__c;
            ctrlSearch.partySw.contact.LastName  = currentSlParty.Last_Name__c;
            ctrlSearch.partySw.contact.phone = currentSlParty.Phone__c;
            ctrlSearch.partySw.relationship = currentSlParty.Relationship__c;
            ctrlSearch.partySw.selectedAssociation = currentSlParty.Association__c;

            ctrlSearch.partySearchBtnClicked = true;
            ctrlSearch.addPartySearchBtnClicked = false;
            ctrlSearch.doPartySearch();

            //System.assertNotEquals(ctrlSearch.matchedPartySearchResults, null);

            ctrlSearch.partySearchBtnClicked = true;
            ctrlSearch.doAddPartySearch();
            ctrlSearch.doCreateCase();
            //-end existingPartySearchMatchFound();

            //-begin autoSearch();

            //-- build client search log record
            SearchLogClientGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Search_Log__c.sObjectType);
            List<Search_Log__c> searchLogClients = SearchLogClientGenerator.GenerateTestsObjects(1, true);
            searchLogClient = searchLogClients[0];

            PageReference pr = Page.vfIntakeSearch;
            Test.setCurrentPage(pr);

            //run through trafficCop()

            pr.getParameters().put('clientSlId',searchLogClient.id);
            ctrl = new ctrlIntakeSearch(); //- first time through pageTrafficCop fired in constructor

            searchLogClient.fromPage__c = 'vfCarplsHome';
            update searchLogClient;
            ctrl = new ctrlIntakeSearch(); //- 2nd
            //rjn moved from misc method here
            ctrl.refreshSearchLogWraps();
            SearchLogWrapper slWrap = ctrl.slWraps[0];
            slWrap.isClientSlWrap();
            SearchLogWrapper sl = new SearchLogWrapper();
            ctrl.selectedClientSearchLogId = slWrap.clientSlId;
            //ctrl.doRemoveClientSl();
            //---

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


            ctrlSearch.doOnLoadSearchParties = true;
            ctrlSearch.slClient.Current_SL_Party__c = ctrlSearch.currentPartySlId;
            Search_Log_Children__c slChild = SearchWrapper.retrieveSearchLogChild(ctrlSearch.currentPartySlId);
            slChild.marked_as_match__c = 'Yes';
            update slChild;
            ctrlSearch.doInitActions();

            slChild.marked_as_match__c = 'No';
            update slChild;
            ctrlSearch.doInitActions();
            //-end autoSearch();

            //-begin miscnonsearchactions();
            ctrl = new ctrlIntakeSearch();
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
            //-- rjn old spot of refresh search log wraps


            ctrl.getNewOrExistingItems();
            ctrl.getIndOrOrgItems();

            ctrl.getDisplayCreateCaseBtn();


            ctrlSearch.doClearAllSearches();
            //intentionally blow up case party trigger; @TODO.. but how???


            //-end miscnonsearchactions();

        }

        Test.stopTest();


    }
    /**
     * The core launch point for this test class.
     */
    /*
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
        
        buildClientsForMatches(); //<--- Build Any needed clients / and caseparties prior to searches.
        

        Test.startTest();
        
            System.runAs(uTstExecUser) {
            
                Test.setCurrentPage(prIntakeSearch);
                ctrlSearch = new ctrlIntakeSearch(); //used if we need to share between methods
                
                quickSearch(); //Currently done from home page.
            
                existingClientSearchNoMatchFound();
                existingPartySearchNoMatchFound();
            
                existingClientSearchMatchFound();
                existingPartySearchMatchFound();
            
                //------- do the below last..
                autoSearch(); //url params passed to search page from home, client, case...etc
                miscNonSearchActions(); //I hate calling it this but for the pure amount of test logic / lack of time.. got to do this.
            }
                
        Test.stopTest();

    }
*/
    /*
    private static void quickSearch() {
        //-- Create a standard search log record.
        TEST_TestObjectGeneratorUtility.TestObjectGenerator searchLogClientGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Search_Log__c.sObjectType);    
        Search_Log__c  searchLogClient = (Search_Log__c)searchLogClientGenerator.generateSingleTestsObject(true);
        
        searchLogClient.fromPage__c = 'vfCarplsHome';
        searchLogClient.sessionId__c =  UserInfo.getSessionId();
        update searchLogClient;
        
        prIntakeSearch.getParameters().put('clientSlId',searchLogClient.id);
        ctrlIntakeSearch ctrl = new ctrlIntakeSearch(); 
        System.assertEquals(ctrl.showNewContactSearchInputs, false);
    }
    */

     // Users hit the Intake Search Button. Performs a Search for Client.
/*
    private static void existingClientSearchNoMatchFound() {        
        
        //Simulate bound client Form Fields.
        ctrlSearch.sw.contact.firstname = 'ClientFirst';
        ctrlSearch.sw.contact.lastname  = 'ClientLast';
        ctrlSearch.sw.contact.Last_Four_SSN__c = '6666';
        ctrlSearch.sw.contact.Birthdate = Date.today();
        ctrlSearch.sw.contact.phone = '6303100898';
        ctrlSearch.sw.contact.Aliases__c = 'Nenz';
        
        prIntakeSearch.getParameters().put('newSearch','true');
        ctrlSearch.searchBtnClicked = true;
        

        // Search Clicked for Client Search

        ctrlSearch.doClientSearch();
        //-- Search log created.
        System.assert(ctrlSearch.clientSearchLog.last_name__c == 'ClientLast'); 
        

         //Click Clear Search (Client Search) / Client Search Again.

        ctrlSearch.doClearClientSearch();
        System.assert(ctrlSearch.clientSearchLog == null);
            //Simulate bound client Form Fields.
        ctrlSearch.sw.contact.firstname = 'Rick2';
        ctrlSearch.sw.contact.lastname  = 'Nendza2';
        ctrlSearch.sw.contact.Last_Four_SSN__c = '6666';
        ctrlSearch.sw.contact.Birthdate = Date.today();
        ctrlSearch.sw.contact.phone = '6303100898';
        ctrlSearch.sw.contact.Aliases__c = 'Nenz';
        
        prIntakeSearch.getParameters().put('newSearch','true');     
        ctrlSearch.doClientSearch();
        System.assert(ctrlSearch.clientSearchLog.last_name__c == 'Nendza2');
          

         // Save & Continue Pressed.

        ctrlSearch.doNoClientMatches();
        //-- Contact Inserted.. with Name that was searched.
        System.assert(ctrlSearch.sw.contact.lastname == 'Nendza2');         
    }
    */

    /*
     //Users Performs a Search for Party
    // @must call existClientSearch prior to this..

    private static void existingPartySearchNoMatchFound() { 

         //Party Search - Individual

        if(ctrlSearch.clientSearchLog == null) {
            System.debug(logginglevel.warn,'please search for a client before searching for a party!');
            return;
        }        
        ctrlSearch.selectedIndOrOrg = 'Individual';
        ctrlSearch.partySw.contact.FirstName = 'Susan';
        ctrlSearch.partySw.contact.LastName  = 'Chase1';
        ctrlSearch.partySw.contact.phone = '6305551212';
        ctrlSearch.partySw.relationship = 'Sister';
        ctrlSearch.partySw.selectedAssociation = 'Attorney';
        
        ctrlSearch.partySearchBtnClicked = true;
        ctrlSearch.addPartySearchBtnClicked = false;
        ctrlSearch.doPartySearch(); 
        System.assertNotEquals(ctrlSearch.currentPartySlId, null);  
        ctrlSearch.doNoPartyMatches();
        Search_Log_Children__c currentSlParty = PartySearchWrapper.retrievePartySearchLog(ctrlSearch.currentPartySlId);
        System.assertNotEquals(currentSlParty.party_created__C,null);
        ctrlSearch.doContinuePartySearch();
        
        
    }

*/
    /*
    //Users hit the Intake Search Button. Performs a Search for Client.
    private static void existingClientSearchMatchFound() {      
        
        //Simulate bound client Form Fields.
        ctrlSearch.sw.contact.firstname = 'ClientFirst';
        ctrlSearch.sw.contact.lastname  = 'Nenz Rocks';
        ctrlSearch.sw.contact.Last_Four_SSN__c = '6666';
        ctrlSearch.sw.contact.Birthdate = Date.today();
        ctrlSearch.sw.contact.phone = '6303100898';
        ctrlSearch.sw.contact.Aliases__c = 'Nenz';
        
        prIntakeSearch.getParameters().put('newSearch','true');
        ctrlSearch.searchBtnClicked = true;     

         //Search Clicked for Client Search

        ctrlSearch.doClientSearch();
        //-- Search log created.
        System.assert(ctrlSearch.clientSearchLog.last_name__c == 'Nenz Rocks');         
        

         //Continue to party search

        ctrlSearch.doContinueClientSearch();
        System.assert(ctrlSearch.isCollapseClientData); 
    }
*/
    /*
    //Users hit the Intake Search Button. Performs a Search for Client, and then party.
    //@see existingClientSearchMatchFound()
    //
    private static void existingPartySearchMatchFound() {

        if(ctrlSearch.clientSearchLog == null) { 
            System.debug(logginglevel.warn,'please search for a client before searching for a party!');
            return;
        }   
        Search_Log_Children__c currentSlParty = PartySearchWrapper.retrievePartySearchLog(ctrlSearch.currentPartySlId);
        System.assertNotEquals(currentSlParty.party_created__C,null);  
        
        //Simulate bound party Form Fields with party created via no match in existingPartySearchNoMatchFound.
        ctrlSearch.selectedIndOrOrg = 'Individual';
        ctrlSearch.partySw.contact.FirstName = currentSlParty.First_Name__c;
        ctrlSearch.partySw.contact.LastName  = currentSlParty.Last_Name__c;
        ctrlSearch.partySw.contact.phone = currentSlParty.Phone__c;
        ctrlSearch.partySw.relationship = currentSlParty.Relationship__c;
        ctrlSearch.partySw.selectedAssociation = currentSlParty.Association__c;
        
        ctrlSearch.partySearchBtnClicked = true; 
        ctrlSearch.addPartySearchBtnClicked = false;
        ctrlSearch.doPartySearch(); 
        
        System.assertNotEquals(ctrlSearch.matchedPartySearchResults, null);
            
        ctrlSearch.partySearchBtnClicked = true;
        ctrlSearch.doAddPartySearch();          
        Pagereference pr = ctrlSearch.doCreateCase();
        

        
            
    }
     * /
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
        System.Debug(LoggingLevel.WARN, '-----------------> Case Parties Built:'+caseParties);          
    }   
    /*
    // @todo starting to pile up DML Statements.. try to instantiate and set searchLogClient on the controller as opposed to relying on an
     // update if possible.


    private static void autoSearch() {  

        //-- build client search log record
        TEST_TestObjectGeneratorUtility.TestObjectGenerator SearchLogClientGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Search_Log__c.sObjectType);    
        List<Search_Log__c> searchLogClients = SearchLogClientGenerator.GenerateTestsObjects(1, true);
        Search_Log__c searchLogClient = searchLogClients[0];
        
        PageReference pr = Page.vfIntakeSearch;
        Test.setCurrentPage(pr);
        
        //run through trafficCop()
        
        pr.getParameters().put('clientSlId',searchLogClient.id);
        ctrlIntakeSearch    ctrl = new ctrlIntakeSearch(); //- first time through pageTrafficCop fired in constructor
        
        searchLogClient.fromPage__c = 'vfCarplsHome';
        update searchLogClient;
        ctrl = new ctrlIntakeSearch(); //- 2nd 
        //rjn moved from misc method here
        ctrl.refreshSearchLogWraps();
        SearchLogWrapper slWrap = ctrl.slWraps[0];
        slWrap.isClientSlWrap();
        SearchLogWrapper sl = new SearchLogWrapper();
        ctrl.selectedClientSearchLogId = slWrap.clientSlId;
        //ctrl.doRemoveClientSl();
        //---

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
        
        
        ctrlSearch.doOnLoadSearchParties = true;
        ctrlSearch.slClient.Current_SL_Party__c = ctrlSearch.currentPartySlId;      
        Search_Log_Children__c slChild = SearchWrapper.retrieveSearchLogChild(ctrlSearch.currentPartySlId);
        slChild.marked_as_match__c = 'Yes';
        update slChild;             
        ctrlSearch.doInitActions();
        
        slChild.marked_as_match__c = 'No';
        update slChild;             
        ctrlSearch.doInitActions();          
        
    }
    */
    /*
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
        //-- rjn old spot of refresh search log wraps

        
        ctrl.getNewOrExistingItems();
        ctrl.getIndOrOrgItems();
    
        ctrl.getDisplayCreateCaseBtn();
        
        
        ctrlSearch.doClearAllSearches();            
        //intentionally blow up case party trigger; @TODO.. but how???
        

        
        
    }
     */
    
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
            // change this to Atty because Party contacts aren't found if orphans
            this.sCategory = 'Attorney';                        
        }
        public override sObject RetrieveOverwrittensObject(Integer Iterable) {          
            return new Contact( LastName = (this.TestContactName != null ? this.TestContactName : 'Test OverwrittenParty' )  + String.valueOf(Iterable),
                                Category__c = (this.sCategory != null ? this.sCategory : 'Attorney') /*Initialize other fields here*/);
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