public virtual class ctrlCarplsSearch extends ctrlCarplesGeneric {
	/*
    public List<SelectOption> searchFieldOptions;   
     
    public  String      searchFieldSelected {get;set;}
    public  String      searchString        {get;set;}
    public  Integer     numberOfResults     {get;set;}
    public  Boolean     displaySearchPanel  {get;set;}   
    public  Boolean     didAjaxSearchRun    {get;set;}
    public  Boolean     doAnyResultsExist   {get;set;}
    public  Boolean     searchedAtLeastOnce {get;set;}
    public  String      defaultSortField    {get;set;}
    public  String      defaultSortDir      {get;set;}
    
    public String       selectedSearchField {get;set;}
    public String       selectedSearchValue {get;set;}
    
    public String       sortDir;    
    public String       sortField;
    
    public List<SObject>  results;      
        
    public ctrlCarplsSearch() {
        super();
        debugLog('<b>Constructor CtrlCarplsSearch..</b>.');
        this.getObjects();
    }
    
    public virtual void runQuery() {
            
    }
    
    public virtual List<SObject> getResults( ) {
        return this.results;
    }
    public virtual void setResults( List<SObject> sObjs) {
        this.results = sObjs;
    }
    
    public virtual override void getObjects() {
        this.sortDir = 'asc';
        this.doAnyResultsExist = false;
        this.defaultSortDir = 'asc';
        this.defaultSortField = 'name';     
        this.displaySearchPanel = true;
        this.searchedAtLeastOnce = false;
        this.numberOfResults = 0;
        this.results = new List<SObject>();
    }
    
    public virtual PageReference doSelectRecord() {
        super.debugLog('<b># SELECTED RECORD ID<b><br/>' + selectedId);
        return null;
    }
    
    public virtual String getSortDir() {
        if (sortDir == null) {  sortDir = this.defaultSortDir; } return sortDir;        
    }
    public virtual void setSortDir(String sSortDir) {
        this.sortDir = sSortDir;
    }
    public virtual String getSortField() {
        if (sortField == null) {  sortField = this.defaultSortField; } return sortField;        
    }
    public virtual void setSortField(String sSortField) {
        this.sortField = sSortField;
    }       
    public virtual Boolean getDoAnyResultsExist() {
         return (results != null && results.size() >0 );
    }
    public virtual void setDoAnyResultsExist(Boolean doThey) {
        this.doAnyResultsExist  = doThey;
    }
    
    //toggles the sorting of query from asc<-->desc
    public virtual void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
    }
    public virtual List<SelectOption> getSearchFieldOptions() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('', 'None'));
        super.debugLog('<b>ctrlCarplsSearch getSearchFieldOptions.. options=</b><br/>' + options);
        return options;
    } 
    public virtual void setSearchFieldOptions(List<SelectOption> lSelectOptions ) {
        this.searchFieldOptions = lSelectOptions;
    }       
    */
}