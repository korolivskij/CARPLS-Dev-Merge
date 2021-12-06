public with sharing class SearchWrapper {
    
    public Contact  contact             { get; set; }
    // don't think pcontact does anything - it isn't referenced anywhere else that I can tell - ELC
    public Contact  pcontact            { get; set; }
      
    public Case     cse                 { get; set; }
    public Case_Party__c cp             { get; set; }
    
    
    public String   caseNumber          { get; set; }
    
    public String   caseOrContactNumber { get; set; }
    public String   contactIdentifier   { get; set; }

    public String   selectedAssociation { get; set; }
    public String   relationship        { get; set; }

    public Set<string> sFirstTerms      { get; set; }
    public Set<string> sLastTerms       { get; set; }
    public Set<string> skipSearch       { get; set; }

    public List<string> sMIWhere        { get; set; }
    public List<string> sLastNameWhere  { get; set; }
    public List<string> sFirstNameWhere { get; set; }
    public List<string> sAliasWhere     { get; set; }
    public List<string> sAddWhere       { get; set; }
    public List<string> sOtherWhere     { get; set; }
    
    public SearchWrapper() {
        this.initObjects();     
    } 
    
    private void initObjects() {
        
        this.contact = new Contact();
        this.cp = new Case_Party__c();      
        this.sFirstTerms        =   new Set<string>();
        this.sLastTerms         =   new Set<string>();
        this.skipSearch         =   new set<string>{'north','south','east','west','street','avenue','s','e','w','n','road','rd','st','blvd','boulevard','way','place','pl','wy','court','ct','lane','ln','nw','ne','se','sw'};
        
        this.sMIWhere           =   new List<string>();
        this.sLastNameWhere     =   new List<string>();
        this.sFirstNameWhere    =   new List<string>();
        this.sAliasWhere        =   new List<string>();
        this.sAddWhere          =   new List<string>();
        this.sOtherWhere        =   new List<string>(); 
        this.relationship       =   '';         
    }
    public List<SelectOption> getAssociationItems() {   
        UiUtils ui = new UiUtils();
        List<SelectOption> options = UiUtils.retrievePlValues(new Case_Party__c(),'Type__c');
        //List<SelectOption> options = new List<SelectOption>(); 
        //options.add(new SelectOption('Adverse','Adverse')); 
           
        return options; 
    }
    public static Search_Log__c getLatestSearchLog( id userId ) {
        if(userId == null) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('user__c').equals(userId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log__c', false ))
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Contact_Reviewed__r' ))
                    // ELC 2/6/2015 added support for ContactCreated
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Contact_Created__r' ))                    
                    .fromx  ('Search_Log__c')
                    .wherex( whereC )
                    .orderByx(new al.OrderBy('lastmodifieddate').descending())
                    .limitx(1)
                    .toSoql();          
        
        Search_Log__c searchLog;
        
        try { 
            searchLog = Database.query(soql);           
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn,e);
        } Catch (Exception e) {
            System.debug(logginglevel.warn,e);
        } 
        return searchLog;   
    }
    public static Search_Log_Children__c getLatestSearchLogChild( id userId ) {
        if(userId == null) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('user__c').equals(userId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log_Children__c', false ))
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Party_Reviewed__r' ))
                    // ELC 2/6/2015 added support for ContactCreated
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Party_Created__r' ))                    
                    .fromx  ('Search_Log_Children__c')
                    .wherex( whereC )
                    .orderByx(new al.OrderBy('lastmodifieddate').descending())
                    .limitx(1)
                    .toSoql();          
        
        Search_Log_Children__c searchLogChild;
        
        try { 
            searchLogChild = Database.query(soql);           
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn,e);
        } Catch (Exception e) {
            System.debug(logginglevel.warn,e);
        } 
        return searchLogChild;   
    }    
    public static List<Search_Log__c> retrieveUserSearchLogs( id userId, Integer limitRows ) {
        if(userId == null) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('user__c').equals(userId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log__c', false ))
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Contact_Reviewed__r' ))
                     // ELC 2/6/2015 added support for ContactCreated
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Contact_Created__r' ))                    .fromx  ('Search_Log__c')
                    .fromx  ('Search_Log__c')
                    .wherex( whereC )
                    .orderByx(new al.OrderBy('lastmodifieddate').descending())
                    .limitx(limitRows)
                    .toSoql();          
        
        List<Search_Log__c> searchLogs;
        
        try { 
            searchLogs = Database.query(soql);              
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn,e);
        } Catch (Exception e) {
            System.debug(logginglevel.warn,e);
        }
        return searchLogs;      
    }   
    /**
     * Retreives Search log and search log children (parties) for a given
     * search id.
     *
     */
    public static Search_Log__c retrieveSearchLog(Id slId) {
        if(slId == null) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('id').equals(slId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log__c', false ))
                    .selectx(
                            new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Search_Log_Children__c', false ))
                            .fromX('Search_Log_Children__r'))
                    .fromX('Search_Log__c')
                    .wherex( whereC )
                    .limitx(100)
                    .toSoql();              
        
        
        Search_Log__c searchLog;
        
        try { 
            searchLog = Database.query(soql);           
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn,e);
        } Catch (Exception e) {
            System.debug(logginglevel.warn,e);
        } 
        return searchLog;       
    } 
    /**
     * Retreives a search log child (party) for a given
     * search id.
     *
     */
    public static Search_Log_Children__c retrieveSearchLogChild(Id slId) {
        if(slId == null) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('id').equals(slId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log_Children__c', false ))
                    .fromX('Search_Log_Children__c')
                    .whereX(whereC)
                    .toSoql();              
        
        
        Search_Log_Children__c searchLog;
        
        try { 
            searchLog = Database.query(soql);           
        } Catch (Dmlexception e) {
            System.debug(logginglevel.warn,e);
        } Catch (Exception e) {
            System.debug(logginglevel.warn,e);
        } 
        return searchLog;       
    }
    /**
     * CPU MAX TIME LIMIT EXCEEDED FIX Part II
     * A continuation of 2016 Christmas efforts..
     * 1/23/2018
     *
     * @param slId
     *
     * @return
     */
    public static List<SearchLogWrapper> retrieveSearchLogWrappersPerfTuned(Id slId) {
        if(slId == null) {
            return null;
        }
        List<SearchLogWrapper> slWraps = new List<SearchLogWrapper>();

        List<Search_Log__c> searchLogs =  [
                SELECT  AddPartyFromCase__c,Aliases__c,Association__c,Birthdate__c,Client_ClientNumber__c,Client_Result_State__c,
                        Contact_Created__c,Contact_Reviewed__c,CreatedById,CreatedDate,Current_SL_Party__c,First_Name__c,Id,
                        Last_Four_SSN__c,Last_Name__c,Marked_as_Match__c,Name,Party_Result_State__c,Party_Result_Type__c,
                        Phone__c,Relationship__c,Street_Address_Line_1__c,User__c,
                        Contact_Reviewed__r.Id,Contact_Reviewed__r.Name, contact_created__r.Name, contact_created__r.id,
                        Contact_Reviewed__r.FirstName, Contact_Reviewed__r.LastName,
                        Contact_Created__r.FirstName, Contact_Created__r.LastName
                FROM    Search_Log__c
                WHERE   id = :slId
        ];
        if(searchLogs.isEmpty()) {
            return slWraps;
        }
        Search_Log__c searchLog = searchLogs[0];
        slWraps.add( new SearchLogWrapper(searchLog) );
        Map<Id,Search_Log_Children__c> mSearchLogChildren = new Map<Id,Search_Log_Children__c>( [
                SELECT  Aliases__c,Association__c,Birthdate__c,Client_ClientNumber__c,Client_Search_Log__c,Contact_type__c,
                        First_Name__c,Id,Last_Four_SSN__c,Last_Name__c,Marked_as_Match__c,Name,Org_Name__c,Party_Created__c,
                        Party_Reviewed__c,Phone__c,Relationship__c,Result_Contact_Ids_No_Match__c,Street_Address_Line_1__c,User__c,
                        party_reviewed__r.name, party_reviewed__r.lastname, party_reviewed__r.firstname
                FROM    Search_Log_Children__c
                WHERE   Client_Search_Log__c = :searchLog.Id
                AND     Marked_as_Match__c = 'Yes'
                ORDER BY LastModifiedDate ASC
                LIMIT   100
        ]);
        if(!mSearchLogChildren.isEmpty()) {
            for(Id slChildId : mSearchLogChildren.keySet()) {
                Search_Log_Children__c slChild = mSearchLogChildren.get(slChildId);
                if('Yes'.equalsIgnoreCase(slChild.marked_as_match__c)) {
                    slWraps.add(new SearchLogWrapper(slChild) );
                }
            }
        }
        return slWraps;
    }
    public static List<SearchLogWrapper> retrieveSearchLogWrappers(Id slId) {
        return retrieveSearchLogWrappersPerfTuned(slId);
        /*
        if(slId == null) {
            return null;
        }
        
        List<SearchLogWrapper> slWraps = new List<SearchLogWrapper>();
        
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('id').equals(slId));
        
        al.NestableCondition whereSubAnd = new al.AndCondition();       
        whereSubAnd.add(new al.FieldCondition('marked_as_match__c').equals('Yes'));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log__c', false ))
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'contact_reviewed__r'))
                    // ELC 2/6/2015 added support for ContactCreated
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'Contact_Created__r' ))                    .fromx  ('Search_Log__c')
                    .selectx(
                            new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Search_Log_Children__c', false ))
                            .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'party_reviewed__r'))
                            .fromX('Search_Log_Children__r'))
                            .whereX( whereSubAnd )
                            .orderByx(new al.OrderBy('LastModifiedDate').ascending())
                    .fromX('Search_Log__c')
                    .wherex( whereC )
                    .limitx(100)
                    .toSoql();              
        
        
        Search_Log__c searchLog;
        
        try { 
            searchLog = Database.query(soql); 
                        
        } catch (Dmlexception e) {
            System.debug(logginglevel.warn,e);
        }  catch (Exception ex) {
            System.debug(logginglevel.warn,ex);
        }
        if(searchLog != null && searchLog.Id != null) {
            slWraps.add( new SearchLogWrapper(searchLog) );
            List<Search_Log_Children__c> slChildren = searchLog.search_log_children__r;
            if(slChildren != null && !slChildren.isEmpty()) {
                for(Search_Log_Children__c slChild : slChildren) {
                    if('Yes'.equalsIgnoreCase(slChild.marked_as_match__c)) {
                        slWraps.add(new SearchLogWrapper(slChild) );
                    }
                }
            }
        }       
        return slWraps;
        */

    }                   
}