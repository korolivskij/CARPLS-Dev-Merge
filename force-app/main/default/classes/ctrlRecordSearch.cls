public virtual class ctrlRecordSearch extends ctrlCarplsSearch {
    /*  
    public  String                      searchTitle                 { get; set; }
    public  Id                          parentRecordId;             

    public  String                      parentRecordApiName         { get; set; }
    public  String                      subjectOfSearch             { get; set; }
    public  SObject                     parentRecord                { get; set; }
    public  String                      rerenderList                { get; set; }
    
    //public  String                      customPageMessage           { get; set; }
    
    //public  Boolean                     displayCustomPageMessage    { get; set; }
    
    //public  String                      customPageMessageSeverityStyleClass { get; set; }
    
      
    public ctrlRecordSearch() {     
        super();
        super.debugLog('<b>Constructor CtrlRecordSearch..</b></br>');
        getObjects();       
    }
    
    public virtual override void getObjects() {
        super.getObjects();
        this.searchTitle = '';
        displayCustomPageMessage = true;
        customPageMessage = '';
        customPageMessageSeverityStyleClass = 'infoM4';
        customPageMessage = 'Please select your filter by field and then start typing your search text. The applicable results will appear as you type.';
    }

    public virtual Id getParentRecordId() {
        return this.parentRecordId;
    }
    public virtual void setParentRecordId( Id pRecordId ) {
        this.parentRecordId = pRecordId;    
        super.debugLog('<b>ctrlRecordSearch setParentRecordId with component parm passed=</b>' + pRecordId);
                    
        this.parentRecordApiName  = super.findObjectNameForId( parentRecordId );
        
        Set<String> commonFieldNames = new Set<String>();
        commonFieldNames.add('id');
        commonFieldNames.add('name');
        String soql = new al.SoqlBuilder()
                    .selectx(commonFieldNames)                  
                    .fromx(parentRecordApiName).limitx(1)
                    .wherex(new al.FieldCondition('id').equals(this.parentRecordId))                    
                    .toSoql();
        parentRecord = Database.query(soql);            
        super.debugLog('<b>ctrlRecordSearch setParentRecordId parentRecord found =</b>' + parentRecord);
    }
    */
}