public with sharing class ProblemCodeWrapper {

	
    public Id           pcId                { get; set; }
    public String       practiceArea        { get; set; }
    public String       problemCategory     { get; set; }
    public String       problemCode         { get; set; }
    public String       jurisdiction        { get; Set; }
    public List<String> lJurisdictions      { get; set; } 
    public Case         cse                 { get; Set; }
    
    public String		searchTerm			{ get; set; }
    
    public Static Final String ALL_JURISDICTIONS = 'All Jurisdictions'; 
    
    public ProblemCodeWrapper() {
      
    }
    public ProblemCodeWrapper(Eligible_Problem_Codes__c epc) {
        if(epc != null) {
            this.practiceArea       = epc.Practice_Area__c;
            this.problemCategory    = epc.Problem_Category__c;
            this.problemCode        = epc.Problem_Code__c;   
            this.pcID = epc.Id;
        }
    }
    /*--- @TODO For Future Use... (Als backend VF page admin stuff)
    public ProblemCodeWrapper(Problem_Code_Heirarchy__c pch) {
        if(pch != null) {
            this.practiceArea       = pch.grandparent_name__c;
            this.problemCategory    = pch.Parent_Name__c;
            this.problemCode        = pch.Problem_Code_Name__c;   
            this.pcID = pch.Id;
        }
    }
    */
    public ProblemCodeWrapper(Case cse) {
        if(cse != null) {
            this.cse = cse;
            this.practiceArea       = cse.Practice_Area__c;
            this.problemCategory    = cse.Problem_Category__c;
            this.problemCode        = cse.Problem_Code__c;  
            this.jurisdiction       = cse.Jurisdiction__c;
            if(this.jurisdiction != null) {
            	lJurisdictions = jurisdiction.split(';');
            } 
        }
    }
    public ProblemCodeWrapper(Subject__c subject) {
        if(subject != null) {
            this.practiceArea       = subject.Practice_Area__c;
            this.problemCategory    = subject.Problem_Category__c;
            this.problemCode        = subject.Problem_Code__c;  
            this.jurisdiction       = subject.Jurisdiction__c;
            if(jurisdiction != null) {
                lJurisdictions = jurisdiction.split(';');
            }
        }
    }

}