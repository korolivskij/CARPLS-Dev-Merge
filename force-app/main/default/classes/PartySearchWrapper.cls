public with sharing class PartySearchWrapper {
    public Contact  contact             { get; set; }
    
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
    
    public PartySearchWrapper() {
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
    /**
     * @TODO RJN Check this.. Added All Option. Client PL options
     *       Too afraid to remove this from the actual picklist itself for fear
     *       of other effects.
     *
     */
    public List<SelectOption> getAssociationItems() {   
        
        List<SelectOption> options =  new List<SelectOption>();
        //options.add(new SelectOption('All', 'All', false));
        List<SelectOption> tempOptions = UiUtils.retrievePlValues(new Contact(),'Type__c');
        for(SelectOption so: tempOptions) {
            String value = so.getValue();
            
            if('Adverse Party' == value || 'Interested Party' == value || 'Attorney' == value) {
                options.add(so);
            } else {
                continue;
            }
        }
        //options.addAll(UiUtils.retrievePlValues(new Contact(),'Type__c'));
              
        return options; 
        //return null;
    }
    /**
     * Retreives Search log and search log children (parties) for a given
     * search id.
     *
     */
    public static Search_Log_Children__c retrievePartySearchLog(Id pSlId) {
        if(pSlId == null) {
            return null;
        }
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('id').equals(pSlId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Search_Log_Children__c', false ))
                    .fromX('Search_Log_Children__c')
                    .wherex( whereC )
                    .toSoql();              
        
        
        Search_Log_Children__c searchLogChild;
        
        try { 
            searchLogChild = Database.query(soql);              
        } catch (Dmlexception dmlEx) {
            System.debug(logginglevel.warn,soql);
            System.debug(logginglevel.warn,dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.warn,soql);
            System.debug(logginglevel.warn,e);
        }    
        return searchLogChild;      
    }               
}