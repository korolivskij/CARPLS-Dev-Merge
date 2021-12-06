public with sharing class DynaQaWrapper {
    public Id questionId                                        {   get; set; }
    public Consultation_Question__c question                    {   get; set; }
    public Schema.SObjectField sObjfield                        {   get; set; }
    public Schema.DescribeFieldResult sObjectfieldDescribe      {   get; set; }
    public String apiFieldName                                  {   get; set; }
    
    
    public DynaQaWrapper(Id qId) {
        this.questionId = qId;  
        
    }
    public Boolean getRequired() {
        Boolean req = false;
        if(question != null) {
            req = question.Required__c;
        }
        return req;
    }
    
}