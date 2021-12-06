public with sharing class SearchLogWrapper {
    
    public Id                       clientSlId              { get; set; }
    public Id                       partySlId               { get; set; }
    
    public String                   firstName               { get; set; }
    public String                   lastName                { get; set; }
    public String					orgName					{ get; set; }
    public String                   association             { get; set; }
    public String                   phone                   { get; set; }
    public String                   aliases                 { get; set; }
    public String                   lastFourSSN             { get; set; }
    public Date                     birthdate               { get; set; }
    public String					relationship			{ get; set; }
    public String                   clientResultState       { get; set; }
    public String                   partyResultState        { get; set; }
    public String					partyResultType			{ get; set; }
    public Contact                  contactMatched          { get; set; }
    
    public SearchLogWrapper() { 
        
    }
    public SearchLogWrapper(Search_Log__c sl) {
        this.clientSlId = sl.id;    
        this.firstName = sl.First_Name__c;
        this.lastName = sl.Last_Name__c;
        
        //RJN Search Log Mod
       	//----- xxxxxxxx this.contactMatched = sl.Contact_Reviewed__r;
        if(sl.Marked_as_Match__c == 'Yes') {
        	this.contactMatched = sl.Contact_Reviewed__r;        		
        }
        
        this.association = 'Client';
        this.phone = sl.phone__c;
        this.aliases = sl.Aliases__c;
        this.lastFourSSN = sl.Last_Four_SSN__c;
        this.birthdate = sl.Birthdate__c;   
        this.clientResultState = sl.client_result_state__c;
        this.partyResultState = sl.party_result_state__c;
        if(sl.party_result_type__c != null) {   
        	this.partyResultType = sl.party_result_type__c;
        } else {
        	this.partyResultType = 'Individual';
        } 
    }  
    
    public SearchLogWrapper(Search_Log_Children__c slc) {
        this.partySlId = slc.id;
       //xxxxx RJN Search Log Mod this.contactMatched = slc.Party_Reviewed__r;

        if(slc.Marked_as_Match__c !=null && slc.Marked_as_Match__c == 'Yes') {
        	this.contactMatched = slc.Party_Reviewed__r;
        }      
        this.firstName = slc.First_Name__c;
        if(slc.Last_Name__c == null) {
        	this.lastName = slc.Org_Name__c;
        } else  {
        	this.lastName = slc.Last_Name__c;
        }
        this.orgName = slc.org_name__c;
        this.association = slc.Association__c;
        
        this.phone = slc.Phone__c;
        this.aliases = slc.Aliases__c;
        this.lastFourSSN = slc.Last_Four_SSN__c;
        this.birthdate = slc.Birthdate__c;
    }
    public Boolean isPartySlWrap() {
        return this.partySlId != null;
    }
    public Boolean isClientSlWrap() {
        return this.clientSlId != null;
    }
    
    
}