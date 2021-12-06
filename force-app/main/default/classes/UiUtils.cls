public class UiUtils {

    /**
     * Fire A platform event indicating the state of the case has changed.
     *
     * @param cse The case to fire the event with.
     * @return true if all publishes were a success, otherwise false.
     */
    public static Boolean firePlatformCaseEvent(Case cse) {
        Boolean allSuccess = false;
        if (cse == null) {
            system.debug(logginglevel.info, 'no cse record to fire SFDC PE with. exiting..');
            return allSuccess;
        }
        List<CaseStatusChanged__e> caseStatusChangedEvents = new List<CaseStatusChanged__e>();
        caseStatusChangedEvents.add(new CaseStatusChanged__e(caseid__c = cse.id, status__c = cse.status, ownerId__c = cse.ownerId));

        List<Database.SaveResult> results = EventBus.publish(caseStatusChangedEvents);

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published case status changed event.');
                allSuccess = true;
            } else {
                allSuccess = false;
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
        return allSuccess;
    }


    public Static List<SelectOption> retrievePlValues(SObject sObj, String plFieldName) {    
            
        List<selectOption> options = new List<selectOption>();
        Schema.DescribeSObjectResult sobject_describe = sObj.getsObjectType().getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(plFieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add(new selectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
        }
        return options; //return the List
    }  
    public Static List<String> retrievePlValuesString(SObject sObj, String plFieldName) {    
            
        List<String> values = new List<String>();
        Schema.DescribeSObjectResult sobject_describe = sObj.getsObjectType().getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(plFieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            values.add(a.getValue());
        }
        return values; //return the List
    }
    /**
     *
     * @param sObj               - the SObjectType that we are dealing with.
     * @param plFieldName        - the api name of the pl field
     * @param recordTypeFullName - RecordType developername.
     *
     * @return  a List<String> contains all picklist values for passed record type.
     * @see     readPicklists
     * @see     MetadataService
     *
     * @TODO there is no error checking going on here so pass the right shit for now!
     * @TODO override the shit out of this so we can pass multiple sObjects, fieldnames, recordtypes etc.
     * @TODO for now we are going to have to forgo some test coverage but metadataservicetest should boost us.
     *       in a unit test just return all pl values regardless of recordtype.
     *
     */
    public Static List<String> retrievePlValuesStringByRt(SObject sObj, String plFieldName, String recordTypeFullName){
        String sObjectName = sObj.getSObjectType().getDescribe().getName();

        String[] recordTypeFullNames = new String[] { sObjectName+'.'+recordTypeFullName };
        List<String> plValues;
        if(!Test.isRunningTest()) {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();

            Map<String, Map<String, Map<String, List<String>>>> mSobj = readPicklists(service, recordTypeFullNames);
            Map<String, Map<String, List<String>>> mRtType = mSobj.get(sObj.getSObjectType().getDescribe().getName());
            Map<String, List<String>> mFields = mRtType.get(recordTypeFullName);
            plValues = mFields.get(plFieldName);
        } else {
            plValues = UiUtils.retrievePlValuesString(sObj, plFieldName);
        }
        return plValues;
    }


    /**
     * The big boy.. this will get all picklist values for passed record types.
     *
     * @param service
     * @param recordTypeFullNames
     *
     * @return sObjMap Map<String, Map<String, Map<String, ListString>>>>
     *         format:
     *         outer key = String sObjectName
     *            2nd map Key = String RecordTypeName
     *               3rd map key = Field Name
     */
    private static Map<String, Map<String, Map<String, List<String>>>> readPicklists(   MetadataService.MetadataPort service,
                                                                                        String[] recordTypeFullNames) {
        Map<String, Map<String, Map<String, List<String>>>> sobMap = new Map<String, Map<String, Map<String, List<String>>>>();
        for (MetadataService.RecordType rt : (MetadataService.RecordType[]) service.readMetadata('RecordType', recordTypeFullNames).getRecords()) {
            MetadataService.RecordTypePicklistValue[] values = rt.picklistValues;
            if (rt.fullName != null && rt.picklistValues != null) {
                String[] parts = rt.fullName.split('\\.');
                String sobjectType = parts[0];
                String recordType = parts[1];
                Map<String, Map<String, List<String>>> rtMap = sobMap.get(sobjectType);
                if (rtMap == null) {
                    rtMap = new Map<String, Map<String, List<String>>>();
                    sobMap.put(sobjectType, rtMap);
                }
                Map<String, List<String>> fieldMap = rtMap.get(recordType);
                if (fieldMap == null) {
                    fieldMap = new Map<String, List<String>>();
                    rtMap.put(recordType, fieldMap);
                }
                for (MetadataService.RecordTypePicklistValue picklist : rt.picklistValues) {
                    if (picklist.values != null) {
                        List<String> valueList = fieldMap.get(picklist.picklist);
                        if (valueList == null) {
                            valueList = new List<String>();
                            fieldMap.put(picklist.picklist, valueList);
                        }
                        for (MetadataService.PicklistValue value : picklist.values) {
                            valueList.add(value.fullName);
                        }
                    }
                }
            }
        }
        return sobMap;
    }
    public Static List<SelectOption> retrievePlValues(SObject sObj, String plFieldName,RecordType rt) {    
                    
        List<selectOption> options = new List<selectOption>();
        SObject sObjRtFiltered = sObj.getSObjectType().newSObject(rt.Id,true);  
        
        Schema.DescribeSObjectResult sobject_describe = sObjRtFiltered.getSObjectType().getDescribe(); //describe the RT Filtered sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(plFieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add(new selectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
        }
        
        return options; //return the List
    }   
    public Static Map<String, Schema.SObjectfield> getSObjectFieldsMap(SObject sObj) {
        Schema.DescribeSObjectResult sobject_describe = sObj.getsObjectType().getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        return field_map;
    } 
    public Static Schema.SObjectField  getSObjectField(Map<String,Schema.SObjectField> mSObjectfields, String apiName) {
        return mSObjectFields.get(apiName);
    }   

    public static Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(pObjName))
            return objResults;
        //get the type being dealt with
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
            return objResults;     
        //get the control values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        //iterate through the values and get the ones valid for the controlling field name
        Bitset objBitSet = new Bitset();
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){           
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = ctrl_entry.getLabel();
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
        }
        //cater for null and empty
         objResults.put('',new List<String>());
         objResults.put(null,new List<String>());
        //check the dependent values
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){          
            //get the pointer to the dependent index
            Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            //get the valid for
            String pEntryStructure = JSON.serialize(dep_entry);                
            TPicklistEntry objDepPLE = (TPicklistEntry)JSON.deserialize(pEntryStructure, TPicklistEntry.class);
            //if valid for is empty, skip
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //iterate through the controlling values
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
                if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){                   
                    //get the label
                    String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    objResults.get(pControllingLabel).add(objDepPLE.label);
                }
            }
        } 
        return objResults;
    }


}