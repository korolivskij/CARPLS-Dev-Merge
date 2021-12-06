public with sharing class AppliedResourceStatusUpdateController {

    @AuraEnabled
    public static Boolean isCarplsConnect(){
        String currentCommunityName = '';
        try {
            currentCommunityName = ConnectApi.Communities.getCommunity(Network.getNetworkId()).name;
        } catch (Exception ex){
            System.debug(ex.getMessage());
        }
        if (currentCommunityName.equalsIgnoreCase('CarplsConnect')) { 
            return true;
        }   
        return false;
    }
    @AuraEnabled
    public static List<Applied_Resource__c> findRecord(String resourceId) {
        system.debug('#######,' + [SELECT id FROM Applied_Resource__c WHERE Id = :resourceId AND CCLAHD__c = true]  );

        return [SELECT id FROM Applied_Resource__c WHERE Id = :resourceId AND CCLAHD__c = true LIMIT 1];
    }


    public static Applied_Resource__c getRecord(String resourceId) {
        List<Applied_Resource__c> resources = [SELECT Applied_Resource__c.Id,
                                               Applied_Resource__c.Closing_Code__c,
                                               Applied_Resource__c.Notes__c,
                                               Applied_Resource__c.Conflict_of_Interest_IL_AFLAN__c,
                                               Applied_Resource__c.Disposition__c,
                                               Applied_Resource__c.RecordTypeId,
                                               Applied_Resource__c.Status__c,
                                               Applied_Resource__c.Negotiated_Settlement__c                              
                                               FROM Applied_Resource__c
                                               WHERE Applied_Resource__c.Id = :resourceId
                                               LIMIT 1];
        
        if(resources.size() > 0) {
            return resources[0];
        } else {
            throwAuraException('Unable to find this record in the database. ' + 
                                           'Has it been changed or removed since you loaded the page?');
            return null;
        }
    }
    
    
    private static void updateResource(Applied_Resource__c resource) {
        try {
            update resource;
        }
        catch (Exception e) {
            throwAuraException('We were unable to update this record! ' +
                                        'Please try again or contact your administrator.');
        }
    }
    
    @AuraEnabled
    public static void updateFromButtonConflict(String resourceId) {
        
        Applied_Resource__c resource = getRecord(resourceId);
        
        Id correctRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Pending').getRecordTypeId();
        Id correctRecordTypeIdCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Pending').getRecordTypeId();
        
        if((resource.RecordTypeId != correctRecordTypeId && resource.RecordTypeId != correctRecordTypeIdCclahd)
           || resource.Status__c != 'Applied') {
               throwAuraException('Something seems off with this record\'s referral status. ' +
                                              'Please try again or contact your administrator.');
               
           }
           
        Id newRecordType = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Closed').getRecordTypeId();
        Id newRecordTypeCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Closed').getRecordTypeId();
        
        resource.Closing_Code__c = 'Denied Service';
        resource.Conflict_of_Interest_IL_AFLAN__c = 'Yes';
        resource.Disposition__c = 'Conflict of Interest';
        resource.Status__c = 'Closed';
        if (resource.RecordTypeId == correctRecordTypeIdCclahd) {
            resource.RecordTypeId = newRecordTypeCclahd;
        } else {
            resource.RecordTypeId = newRecordType;
        }
        
        updateResource(resource);
        
        
    }
    
    @AuraEnabled
    public static void updateFromButtonNoConflict(String resourceId) {
        
        Applied_Resource__c resource = getRecord(resourceId);
        
        Id correctRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Pending').getRecordTypeId();
        Id correctRecordTypeIdCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Pending').getRecordTypeId();
        
        if((resource.RecordTypeId != correctRecordTypeId && resource.RecordTypeId != correctRecordTypeIdCclahd)
           || resource.Status__c != 'Applied') {
               throwAuraException('Something seems off with this record\'s referral status. ' +
                                              'Please try again or contact your administrator.');
           }
        
        Id newRecordType = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Post Conflict').getRecordTypeId();
        Id newRecordTypeCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Post-Conflict').getRecordTypeId();
        
        if (resource.RecordTypeId == correctRecordTypeIdCclahd) {
            resource.RecordTypeId = newRecordTypeCclahd;
        } else {
            resource.RecordTypeId = newRecordType;
        }
        
        updateResource(resource);
        
    }
    
    @AuraEnabled
    public static void updateFromButtonAccept(String resourceId) {
        
        Applied_Resource__c resource = getRecord(resourceId);
        
        Id correctRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Post Conflict').getRecordTypeId();
        Id correctRecordTypeIdCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Post-Conflict').getRecordTypeId();
        
        if(resource.RecordTypeId != correctRecordTypeId && resource.RecordTypeId != correctRecordTypeIdCclahd) {
            throwAuraException('Something seems off with this record\'s referral status. ' +
                                           'Please try again or contact your administrator.');
        }
        
        Id newRecordType = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Accepted').getRecordTypeId();
        Id newRecordTypeCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Accepted').getRecordTypeId();
        
        resource.Status__c = 'Accepted';
        if (resource.RecordTypeId == correctRecordTypeIdCclahd) {
            resource.RecordTypeId = newRecordTypeCclahd;
        } else {
            resource.RecordTypeId = newRecordType;
        }
        
        updateResource(resource);
        
    }
    
    @AuraEnabled
    public static void updateFromButtonReject(String resourceId, String disposition) {
        
        Applied_Resource__c resource = getRecord(resourceId);
        
        Id correctRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Post Conflict').getRecordTypeId();
        Id correctRecordTypeIdCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Post-Conflict').getRecordTypeId();
        
        if(resource.RecordTypeId != correctRecordTypeId && resource.RecordTypeId != correctRecordTypeIdCclahd) {
            throwAuraException('Something seems off with this record\'s referral status. ' +
                                           'Please try again or contact your administrator.');
        }
        
        if(disposition == '--- Please Select ---') {
            throwAuraException('Please select a disposition.');
        }
        
        Id newRecordType = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Closed').getRecordTypeId();
        Id newRecordTypeCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Closed').getRecordTypeId();
        
        resource.Status__c = 'Closed';
        resource.Closing_Code__c = 'Denied Service';
        resource.Disposition__c = disposition;
        if (resource.RecordTypeId == correctRecordTypeIdCclahd) {
            resource.RecordTypeId = newRecordTypeCclahd;
        } else {
            resource.RecordTypeId = newRecordType;
        }
        
        updateResource(resource);
        
    } 

    @AuraEnabled
    public static void updateFromButtonClose(String resourceId, String closingCode, String disposition, String negotiatedSettlement) {
        updateFromButtonClose(resourceId, closingCode, disposition, negotiatedSettlement, '');
    }
    
    @AuraEnabled
    public static void updateFromButtonClose(String resourceId, String closingCode, String disposition, String negotiatedSettlement, String completionNote) {
        
        Applied_Resource__c resource = getRecord(resourceId);
        
        Id correctRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Accepted').getRecordTypeId();
        Id correctRecordTypeIdCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Accepted').getRecordTypeId();
        
        if(resource.RecordTypeId != correctRecordTypeId && resource.RecordTypeId != correctRecordTypeIdCclahd) {
            throwAuraException('Something seems off with this record\'s referral status. ' +
                                           'Please try again or contact your administrator.');
        }
        
        if(String.isBlank(closingCode)) {
            throwAuraException('Please select a closing code.');
        }
        
        if(closingCode != 'None' 
           && String.isBlank(disposition)) {
               throwAuraException('Please select a disposition.');
        }
        
        Id newRecordType = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Closed').getRecordTypeId();
        Id newRecordTypeCclahd = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('External Closed').getRecordTypeId();
        
        resource.Status__c = 'Closed';
        if (resource.RecordTypeId == correctRecordTypeIdCclahd) {
            resource.RecordTypeId = newRecordTypeCclahd;
        } else {
            resource.RecordTypeId = newRecordType;
        }
        System.debug('Danylo ' + resource.Status__c);
        System.debug('Danylo ' + resource.Notes__c);
        
        Profile profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];
        System.debug('Danylo ' + profileName.Name);
        if(resource.Status__c == 'Closed' && (resource.Notes__c == '' || resource.Notes__c == null) && profileName.Name == 'Volunteer'){
            throw new AuraHandledException('The Notes field is required prior to closing.');
        }
        updateResource(resource);
        
        if(closingCode == 'None') {
            resource.Closing_Code__c = null;
            resource.Disposition__c = null;
        } else {
            resource.Closing_Code__c = closingCode;
            resource.Disposition__c = disposition;
        }
        resource.Completion_Note__c = completionNote;
        resource.Negotiated_Settlement__c = negotiatedSettlement;
        
        updateResource(resource);
        
    }
    
    private static void throwAuraException(String message){
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        system.debug(e);
        throw e;
    }

    @AuraEnabled
    public static List<String> getNegotiatedSettlementPicklistValues()
    {
      
       List<String> options = new List<String>();
       Schema.DescribeFieldResult fieldResult = Applied_Resource__c.Negotiated_Settlement__c.getDescribe();
       List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry pv : picklistValues)
       {
               options.add(pv.getValue());
       }     
       return options;
    }
}