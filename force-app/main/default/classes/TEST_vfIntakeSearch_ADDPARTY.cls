/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 */
@isTest(SeeAllData=false)
public class TEST_vfIntakeSearch_ADDPARTY {

    public static   User                uTstExecUser            { get; set; }
    public static   ctrlIntakeSearch    ctrlStatic              { get; set; }
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
                ctrlStatic = new ctrlIntakeSearch(); //used if we need to share between methods
				addPartyClickedFromCase();
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
        System.Debug(LoggingLevel.WARN, '-----------------> Parties Built:'+String.valueOf(newPartiesBuilt));
        
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
    private static void addPartyClickedFromCase() {  

        //-- build client search log record
        TEST_TestObjectGeneratorUtility.TestObjectGenerator SearchLogClientGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Search_Log__c.sObjectType);    
        List<Search_Log__c> searchLogClients = SearchLogClientGenerator.GenerateTestsObjects(1, true);

        
        PageReference pr = Page.vfIntakeSearch;
        Test.setCurrentPage(pr);
        pr.getParameters().put('fromCaseId',newCasesBuilt[0].id);
        pr.getParameters().put('fromPage','vfCaseDetail_AddParty');
        ctrlIntakeSearch    ctrl = new ctrlIntakeSearch(); //- first time through pageTrafficCop fired in constructor
        ctrl.doInitActions();
  		
  		
  		// party exists in database.. a match from the search results was found.
  		ctrl.selectedIndOrOrg = 'Individual';
        ctrl.partySw.contact.FirstName = 'Rick';
        ctrl.partySw.contact.LastName  = 'Test Party1'; 
        ctrl.partySw.contact.phone = '6305551212'; 
        ctrl.partySw.relationship = 'God';
        ctrl.partySw.selectedAssociation = 'Adverse Party';

		ctrlCarplesGeneric.staticIsSoslPartySearch = true;        
        ctrl.partySearchBtnClicked = true;
        ctrl.addPartySearchBtnClicked = false;
        //rjn all of the sudden randomly throwing NPE.. doesn't make sense @TODO RJN Investigate when time is available
        try {
            ctrl.doPartySearch();
        } catch (Exception e) {
            system.debug(e);
        }
        
        
          
        
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
        private String					 	contactType			{ get; set; }
        private String						status				{ get; set; }
        
        public PartyOverwrite (String TestName) {
            this.TestContactName = TestName;
            this.sCategory = 'Party';                        
            this.contactType = 'Individual';
        }
        public override sObject RetrieveOverwrittensObject(Integer Iterable) {          
            return new Contact( LastName = (this.TestContactName != null ? this.TestContactName : 'Test OverwrittenParty' )  + String.valueOf(Iterable),
                                Category__c = (this.sCategory != null ? this.sCategory : 'Party'), contact_type__c = (this.contactType != null ? this.contactType : 'Individual'),
                                status__c = (this.status != null ? this.status : 'Current'));
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