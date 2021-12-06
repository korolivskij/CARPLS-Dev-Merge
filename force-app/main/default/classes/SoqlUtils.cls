/**
 * SoqlUtils is a class which provides for utitlity Soql operations
 * @TODO is it possible to eliminate managedpackage fields on the below call so we don't have to loop over fields we don't need?
 *  ie we getting all kinds of crap for the dozen managed packages we are using that we don't need!
 *  Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
 */
public with sharing class SoqlUtils {
    
    static Map<String,Schema.Sobjecttype> mSchemaGlobal; 
    
    static {
        mSchemaGlobal = Schema.getGlobalDescribe();
    }

    /**
     * Gets a list of record types for the passed sObject.
     */
    public static List<RecordType> getRTsBySobject(String sObj) {
        RecordType rt = null;
        List<RecordType> rts = [Select  r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId 
                                From    RecordType r 
                                where   sObjectType = :sObj
                                and     r.isActive = true];
        return rts;
    }

    
    // Returns a dynamic SOQL statement for the whole object, 
    // if isOnlyCreatableFields = true then includes only creatable fields
    /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static string getAllFieldsSOQL(String objectName, Boolean isOnlyCreatableFields , String otherRelationshipFields ){
 
        String selects = '';
 
        // Get a map of field name and field token
        //-----------Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
       Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
       
       // list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if(!isOnlyCreatableFields) {
                    //selectFields.add(fd.getName());
                    selects += fd.getName() + ',';
                } else if (fd.isCreateable()) {
                    selects += fd.getName() + ',';
                    //selectFields.add(fd.getName());
                }
            }
        }
 
        //if (!selectFields.isEmpty()){
        if(selects !='') {
            /*
            for (string s:selectFields){
                selects += s + ',';
            }
            */
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
 
        }
 
        return 'SELECT ' + otherRelationshipFields + ' ' + selects + ' FROM ' + objectName;
 
    }

    // Returns a selectable fields in a string comma delimeted
    // if isOnlyCreatableFields = true then includes only creatable fields
    /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static string getAllFields(String objectName, Boolean isOnlyCreatableFields ){
 
        String selects = '';
        // Get a map of field name and field token
        //-----------Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
         
        //list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if(!isOnlyCreatableFields) {
                    //selectFields.add(fd.getName());
                    selects += fd.getName() + ',';
                } else if (fd.isCreateable()) {
                    selects += fd.getName() + ',';
                    //selectFields.add(fd.getName());
                }
            }
        }
 
      //  if (!selectFields.isEmpty()){
        if(selects != '') {
            /*
            for (string s:selectFields){
                selects += s + ',';
            }
            */
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
 
        } 
        return selects;
    }
    // Returns a selectable fields in a string comma delimeted
    // if isOnlyCreatableFields = true then includes only creatable fields
    /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static string getAllFields(String objectName, Boolean isOnlyCreatableFields,Set<String> excludeFields ){
 
        String selects = '';
        // Get a map of field name and field token
        //---------Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
       // list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                Boolean excludeField = false;
                if(excludeFields != null && excludeFields.contains(fd.getName())) {
                    excludeField = true;
                }
                if(!isOnlyCreatableFields && !excludeField) {
                    //selectFields.add(fd.getName());
                    selects += fd.getName() + ',';
                } else if (fd.isCreateable() && !excludeField) {
                    //selectFields.add(fd.getName());
                    selects += fd.getName() + ',';
                }
            }
        }
 
        //if (!selectFields.isEmpty()){
        if(selects != '') {
            /*
            for (string s:selectFields){
                selects += s + ',';
            }
            */
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
 
        } 
        return selects;
    }
    // Returns a selectable fields in a string comma delimeted
    // if isOnlyCreatableFields = true then includes only creatable fields
     /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static Set<Object> getAllFieldsSet(String objectName, Boolean isOnlyCreatableFields, Set<String> excludeFields ){
 
        Set<Object> columns = new Set<Object>();
        // Get a map of field name and field token
        //--Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        //list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                Boolean excludeField = false;
                if(excludeFields != null && excludeFields.contains(fd.getName())) {
                    excludeField = true;
                }
                if(!isOnlyCreatableFields && !excludeField) {                   
                    //selectFields.add(fd.getName());
                    columns.add(fd.getName());
                } else if (fd.isCreateable() && !excludeField) {
                    //selectFields.add(fd.getName());
                    columns.add(fd.getName());
                }
            }
        }
        /*
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                columns.add(s);
            }
        }
        */
        return columns;
    }
    // Returns a selectable fields in a string comma delimeted
    // if isOnlyCreatableFields = true then includes only creatable fields
     /**
     * RJN CPU Time Limit patch 12/30/16... get rid of otheraddress / mailingaddress to account for api version weirdness
     */
    public static Set<Object> getAllFieldsSet(String objectName, Boolean isOnlyCreatableFields ){

        Set<String> excludeFields = new Set<String>();
        excludeFields.add('OtherAddress');
        excludeFields.add('MailingAddress');

        Set<Object> columns = new Set<Object>();
        // Get a map of field name and field token
        //------------Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();        
        //list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                Boolean excludeField = false;
                if(excludeFields != null && excludeFields.contains(fd.getName())) {
                    excludeField = true;
                    continue;
                }

                if(!isOnlyCreatableFields) {
                    columns.add(fd.getName());
                   // selectFields.add(fd.getName());
                } else if (fd.isCreateable()) {
                    //selectFields.add(fd.getName());
                    columns.add(fd.getName());
                }
            }
        }
        /*
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                columns.add(s);
            }
        }
        */
        return columns;
    }
     /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static Set<Object> getAllRelatedFieldsSet(String objectName, Boolean isOnlyCreatableFields, String relName ){
        Set<Object> columns = new Set<Object>();
        // Get a map of field name and field token
        
        
        //----Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('OtherAddress');
        excludeFields.add('MailingAddress');

        //list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                Boolean excludeField = false;
                if(excludeFields != null && excludeFields.contains(fd.getName())) {
                    excludeField = true;
                    continue;
                }


                if(!isOnlyCreatableFields) {
                    //selectFields.add(relName+'.'+fd.getName());
                    columns.add(relName+'.'+fd.getName());
                } else if (fd.isCreateable()) {
                    columns.add(relName+'.'+fd.getName());
                    //selectFields.add(relName+'.'+fd.getName());
                }
            }
        }


        /* RJN CPU Time Limit tune
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                columns.add(s);
            }
        }
        */
        return columns;
    }
     /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static Set<Object> getAllRelatedFieldsSet(String objectName, Boolean isOnlyCreatableFields, String relName, Set<String> excludeFields ){
        Set<Object> columns = new Set<Object>();
        // Get a map of field name and field token
        //Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        // list<string> selectFields = new list<string>();

        if (fMap != null){
            Boolean bAddIt = false;
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                Boolean excludeField = false;

                if(excludeFields != null && excludeFields.contains(fd.getName())) {
                    excludeField = true;
                }
                if(!isOnlyCreatableFields  && !excludeField) {
                    columns.add(relName+'.'+fd.getName());
                    //selectFields.add(relName+'.'+fd.getName());
                } else if (fd.isCreateable()  && !excludeField) {
                    columns.add(relName+'.'+fd.getName());
                    // selectFields.add(relName+'.'+fd.getName());
                }
            }
        }
        /* RJN CPU Time Limit tune
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                columns.add(s);
            }
        }
        */
        return columns;
    }
    // Returns a selectable fields in a string comma delimeted
    // if isOnlyCreatableFields = true then includes only creatable fields
     /**
     * RJN CPU Time Limit patch 12/30/16
     */
    public static string getAllRelatedFields(String objectName, Boolean isOnlyCreatableFields, String relName ){
 
        String selects = '';
        // Get a map of field name and field token
       // Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = mSchemaGlobal.get(objectName.toLowerCase()).getDescribe().Fields.getMap();        
        //list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if(!isOnlyCreatableFields) {
                   // selectFields.add(relName+'.'+fd.getName());
                    selects += relName+'.'+fd.getName();
                } else if (fd.isCreateable()) {
                    selects += relName+'.'+fd.getName();
                   // selectFields.add(relName+'.'+fd.getName());
                }
            }
        }
 
        //if (!selectFields.isEmpty()){
        if(selects != '') {
            /*
            for (string s:selectFields){
                selects += s + ',';
            }
            */
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
 
        } 
        return selects;
    }    
}