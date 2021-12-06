public class TreeViewController extends ctrlCarplesGeneric {
    /*--- @TODO For Future Use... (Als backend VF page admin stuff)
    
    public Boolean                          selectable                          { get; set; }
    public Boolean                          classInitialized                    { get; set; }
    public Id                               sObjectId;
    public String                           selectedValues;
    public List<Id>                         sObjectCurrentEpcIds                { get; Set; }
    public List<Eligible_Problem_Codes__c>  sObjectCurrentEpcs                  { get; Set; }
    
    public void setSObjectId(Id pId) {
        sObjectId = pId;            
    }
    public Id getSObjectId() {
        return this.sObjectId;
    }
    public String getSelectedValues() {
        debugLog('---- calling getSelectedValues().. returning:'+this.selectedValues);
        return selectedValues;  
    }
    public void setSelectedValues(String values) {
        debugLog('---- calling setSelectedValues with values='+values);
        this.selectedValues = values;   
    }
    
    
    public TreeViewController() {
        debugLog('TreeViewController Constructor');
        sObjectCurrentEpcIds = new List<Id>();
        selectedValues = '';
        this.sObjectCurrentEpcs = new List<Eligible_Problem_Codes__c>();
        this.classInitialized = false; 
    }
    
    public PageReference doInitTreeView() {
        debugLog('----- in doInitTreeView!!!');
        
        if(this.classInitialized) {
            debugLog('----- in doInitPreview.. Boolean shows class is already initted exiting method from top ---');
            return null;            
        }   
        debugLog('TreeViewController setSObjectId=... sObjectId passed='+sObjectId);
        String sObjectType = PcTreeUtil.getSObjectTypeById(sObjectId);
        String sLookupFieldName = '';
        debugLog('TreeViewController setSObject Type = ' + sObjectType);
        if(sObjectType != null && sObjectType.equalsIgnoreCase('Account')) {
            sLookupFieldName = 'account__c';
        }
        
        Map<Id,List<Eligible_Problem_Codes__c>> mPchId_EpcRecords = new Map<Id,List<Eligible_Problem_Codes__c>>();
        
        if(sLookupFieldName != '') {        
            this.sObjectCurrentEpcs  =  ProblemCodeUtils.retrieveEligibleProblemCodes(sObjectId,sLookupFieldName);
            debugLog('current epc records for objecttype='+sObjectType + '\n\n'+ sObjectCurrentEpcs);
            if(sObjectCurrentEpcs != null && !sObjectCurrentEpcs.isEmpty()) {
                for(Eligible_Problem_Codes__c epc : sObjectCurrentEpcs) {
                    Id pchId = epc.Problem_Code_Heirarchy__c;
                    if(!mPchId_EpcRecords.containsKey(pchId)) {                     
                        mPchId_EpcRecords.put(pchId,new List<Eligible_Problem_Codes__c> {epc});
                    } else {
                        List<Eligible_Problem_Codes__c> epcs = mPchId_EpcRecords.get(pchId);
                        epcs.add(epc);
                        mPchId_EpcRecords.put(pchId,epcs);
                        
                    }
                }
            }
            
        }
        
        
        this.JsonData = PcTreeUtil.getTreeJSON(mPchId_EpcRecords);
        this.classInitialized = true;
        
        return null;
    }
    
    public String selectNodeKeys {get; set;}

    {
        selectable = false;
        selectNodeKeys = 'No value selected';
    }
    
    public String JsonData {get; set;}
    
    public String roleOrUserId {get; set;}
    
    public String getJsonString() {   
        if(jsonData == null) {
            this.doInitTreeView();
        }
        return JsonData;
    }
    public pageReference doClearDebugMessages() {
        debugMessages = new List<DebugMessage>();       
        return null;
    }
    */
}