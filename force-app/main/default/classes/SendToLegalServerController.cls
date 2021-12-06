/**
 * Provisio Partners
 * @author Stepan Mahdziak <stepan.mahdziak@redtag.pro>
 * @date  2020
 *
 * @description class for Legal Server Intergation;
 **/
public class SendToLegalServerController {
    private static Map<String, Map<String, Integer>> mapPicklistValues;
    public static Map<String, String> mapCustomMetadataFields = new Map<String, String>();

    @AuraEnabled
    public static void sendToLegalServer(Id recordId){
        Applied_Resource__c appRes = [
            SELECT 
                Client_First_Name__c,
                Client_Last_Name__c,
                Client_Middle_Initial__c,
                Client_Birthdate__c,
                Client_Phone__c,
                Client_Email__c,
                Client_Street__c,
                Client_City__c,
                Client_County__c,
                Client_State__c,
                Client_Zip__c,
                Number_of_Adults__c,
                Number_of_Minors__c,
                Client_Gender__c,
                Client_Ethnicity__c,
                Client_Language__c,
                Client_IL_AfLAN_ID__c,
                Client_Marital_Status__c,
                Case__r.ContactId,
                Client_Last_Four_SSN__c,
                Referral_Source__c,
                Client_Employment__c,
                Client_Housing__c,
                Client_Military_Service__c,
                Client_Branch__c,
                Client_Rank__c,
                Client_No_of_Deployments__c,
                Client_Entry_Date__c,
                Client_Exit_Date__c,
                Client_Military_Status__c,
                Client_VDisability__c,
                Account__r.Name,
                Account__r.Server_Name__c,
                Client_Education__c,
                Account__r.Legal_Server_Status__c,
                Type__c
            FROM Applied_Resource__c
            WHERE Id = :recordId AND Type__c ='Legal Referrals' AND Account__r.Legal_Server_Status__c IN ('Test','Production')
        ];

        mapPicklistValues = generateCustomPicklistValueMap(appRes.Account__r.Server_Name__c);

        Map<String, Object> addressHome = new Map<String, Object>();
        addressHome.put(LegalServerConstants.ADDRESS1, getValueFromFieldAndCheckNull(appRes.Client_Street__c));
        addressHome.put(LegalServerConstants.CITY, getValueFromFieldAndCheckNull(appRes.Client_City__c));
        addressHome.put(mapCustomMetadataFields.get(appRes.Client_County__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_County__c), appRes.Client_County__c)); 
        addressHome.put(LegalServerConstants.STATE, getValueFromFieldAndCheckNull(appRes.Client_State__c));
        addressHome.put(LegalServerConstants.ZIP, getValueFromFieldAndCheckNull(appRes.Client_Zip__c));
        if(addressHome.containsKey(null)){
            addressHome.Remove(null);
        }

        Map<String, Object> customFields = new Map<String, Object>();
        customFields.put(mapCustomMetadataFields.get(appRes.Referral_Source__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Referral_Source__c), appRes.Referral_Source__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Employment__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Employment__c), appRes.Client_Employment__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Housing__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Housing__c), appRes.Client_Housing__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_VDisability__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_VDisability__c), appRes.Client_VDisability__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Military_Service__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Military_Service__c), appRes.Client_Military_Service__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Branch__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Branch__c), appRes.Client_Branch__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Rank__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Rank__c), appRes.Client_Rank__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Military_Status__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Military_Status__c), appRes.Client_Military_Status__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_No_of_Deployments__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_No_of_Deployments__c), appRes.Client_No_of_Deployments__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Last_Four_SSN__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Last_Four_SSN__c), appRes.Client_Last_Four_SSN__c));
        customFields.put(mapCustomMetadataFields.get(appRes.Client_Education__c), getCustomPicklistValue(mapCustomMetadataFields.get(appRes.Client_Education__c), appRes.Client_Education__c));
        customFields.put(getValueFromFields(LegalServerConstants.CLIENT_ENTRY_DATE), getValueFromFieldAndCheckNull(appRes.Client_Entry_Date__c));
        customFields.put(getValueFromFields(LegalServerConstants.CLIENT_EXIT_DATE), getValueFromFieldAndCheckNull(appRes.Client_Exit_Date__c));
        customFields.put(getValueFromFields(LegalServerConstants.CLIENT_IL_AFLAN_ID), getValueFromFieldAndCheckNull(appRes.Client_IL_AfLAN_ID__c));
    
		
        Map<String, Object> customFieldsWithoutNullValues = new Map<String, Object>();
        for (String key : customFields.keySet()) {
            if (key!=null && customFields.get(key) != null && !key.contains('null') && key !='') {
                customFieldsWithoutNullValues.put(key, customFields.get(key));
            }
        }

        Map<String, Object> params = new Map<String, Object>();
        params.put(LegalServerConstants.PROGRAM, LegalServerConstants.AFLAN);
        params.put(LegalServerConstants.E_TRANSFER_ORGANIZATION, appRes.Account__r.Server_Name__c);
        params.put(LegalServerConstants.FIRST_NAME, getValueFromFieldAndCheckNull(appRes.Client_First_Name__c));
        params.put(LegalServerConstants.MIDDLE_NAME, getValueFromFieldAndCheckNull(appRes.Client_Middle_Initial__c));
        params.put(LegalServerConstants.LAST_NAME, getValueFromFieldAndCheckNull(appRes.Client_Last_Name__c));
        params.put(LegalServerConstants.DATE_OF_BIRTH, getValueFromFieldAndCheckNull(appRes.Client_Birthdate__c.format()));
        params.put(LegalServerConstants.PHONE_HOME, getValueFromFieldAndCheckNull(appRes.Client_Phone__c));
        params.put(LegalServerConstants.EMAIL, getValueFromFieldAndCheckNull(appRes.Client_Email__c));
        params.put(LegalServerConstants.ADDRESS_HOME, addressHome);
        params.put(LegalServerConstants.NUMBER_OF_ADULTS, appRes.Number_of_Adults__c);
        params.put(LegalServerConstants.NUMBER_OF_CHILDREN, appRes.Number_of_Minors__c);
        //params.put('incomes', incomeTypes);
        params.put(LegalServerConstants.GENDER, getGender(appRes.Client_Gender__c));
        params.put(LegalServerConstants.ETHNICITY, (appRes.Client_Ethnicity__c == 'Latino') ? 'Hispanic' : 'Non-Hispanic');
        params.put(LegalServerConstants.RACE, getRace(appRes.Client_Ethnicity__c));
        params.put(LegalServerConstants.LANGUAGE, getLanguage(appRes.Client_Language__c));
        params.put(LegalServerConstants.MATIRIAL_STATUS, getMaritalStatus(appRes.Client_Marital_Status__c));
        params.put(LegalServerConstants.JSON_PAYLOAD, customFieldsWithoutNullValues);

        Map<String, Object> paramsWithoutNullValues = new Map<String, Object>();
        for (String key : params.keySet()) {
            if (key != null && params.get(key) != null && !key.contains('null') && key !='') {
                paramsWithoutNullValues.put(key, params.get(key));
            }
        }
        if(appRes.Account__r.Server_Name__c != null && appRes.Account__r.Server_Name__c != '') {
            String jsonString = SYSTEM.JSON.serialize(paramsWithoutNullValues,true);
            LegalServerRestService.doAction(jsonString, recordId ,  appRes.Account__r.Legal_Server_Status__c);
        }

        
    }

    private static String getValueFromFieldAndCheckNull(String inputString) {
        return inputString == null || inputString =='' ? '' : inputString;
    }

    

    private static String getMaritalStatus(String maritalStatus) {
        Map<String, String> mapStatuses = new Map<String, String>{
            'Civil Union' => 'Common Law',
            'Divorced' => 'Divorced',
            'Married' => 'Married',
            'Separated' => 'Separated',
            'Single' => 'Single',
            'Widowed' => 'Widowed',
            'Unknown' => 'Unknown'
        };
        if (String.isBlank(maritalStatus) || !mapStatuses.containsKey(maritalStatus)) {
            return '';
        } else {
            return mapStatuses.get(maritalStatus);
        }
    }

    private static String getGender(String gender) {
        Map<String, String> mapGenders = new Map<String, String>{
            'Female' => 'Female',
            'Male' => 'Male',
            'Transgender' => 'Transgender',
            'Other' => 'Other'
        };
        if (String.isBlank(gender) || !mapGenders.containsKey(gender)) {
            return '';
        } else {
            return mapGenders.get(gender);
        }
    }

    private static String getLanguage(String language) {
        Map<String, String> mapLanguages = new Map<String, String>{
            'English' => 'English',
            'Spanish' => 'Spanish',
            'Japanese' => 'Japanese',
            'Korean' => 'Korean',
            'Mandarin' => 'Mandarin',
            'Polish' => 'Polish',
            'Russian' => 'Russian',
            'Sign' => 'Sign languages',
            'Vietnamese' => 'Vietnamese',
            'Other' => ''
        };
        if (String.isBlank(language) || !mapLanguages.containsKey(language)) {
            return '';
        } else {
            return mapLanguages.get(language);
        }
    }

    private static String getRace(String race) {
        Map<String, String> mapRaces = new Map<String, String>{
            'African/American' => 'Black',
            'Asian/Pacific Islander' => 'Asian',
            'Latino' => 'Unknown',
            'Native American' => 'American Indian or Alaska Native',
            'White' => 'White',
            'Other/Unknown' => 'Unknown'
        };
        if (String.isBlank(race) || !mapRaces.containsKey(race)) {
            return '';
        } else {
            return mapRaces.get(race);
        }
    }

   
    // private static String generateIlAflanId(Date dob, String lastFourSSN) {
    //     String id = '';
    //     if (dob == null) {
    //         id = LegalServerConstants.ID;
    //     } else {
    //         id = '' + ('0' + dob.month()).right(2) + ('0' + dob.day()).right(2);
    //     }
    //     if (String.isBlank(lastFourSSN)) {
    //         id = id + LegalServerConstants.ID;
    //     } else {
    //         id = id + lastFourSSN;
    //     }
    //     return id;
    // }

 
    private static Integer getCustomPicklistValue(String fieldName, String value) {
        if(value != null && fieldName != null){
        if (mapPicklistValues.containsKey(fieldName)) {
            if (mapPicklistValues.get(fieldName).containsKey(value)) {
                return mapPicklistValues.get(fieldName).get(value);
            }   
        }
      }
        return null;
    }

    private static String getValueFromFields(String apiName){
              return mapCustomMetadataFields.get(apiName);
    }


    private static Map<String, Map<String, Integer>> generateCustomPicklistValueMap(String serverName) {
        Map<String, Map<String, Integer>> mapToReturn = new Map<String, Map<String, Integer>>();
        List<Legal_Server_Picklist_Value__mdt> LSPicklistValues = [
            SELECT Id, Field__c, Value__c, LS_Value__c , Server_Name__c
            FROM Legal_Server_Picklist_Value__mdt 
            WHERE Server_Name__c = :serverName
        ];
        LSPicklistValues.addAll([ SELECT Id, Field__c, Value__c, LS_Value__c , Server_Name__c FROM Legal_Server_Picklist_Value__mdt WHERE Field__c ='county']);
        for (Legal_Server_Picklist_Value__mdt LSPicklistValue :LSPicklistValues) {
                mapCustomMetadataFields.put(LSPicklistValue.Value__c,LSPicklistValue.Field__c);
            if (!mapToReturn.containsKey(LSPicklistValue.Field__c)) {
                mapToReturn.put(LSPicklistValue.Field__c, new Map<String, Integer>());
            }  
            mapToReturn.get(LSPicklistValue.Field__c).put(LSPicklistValue.Value__c, (Integer)LSPicklistValue.LS_Value__c);
        }
        return mapToReturn;

    }
}


  // List<Income_Detail__c> incomes = [
        //     SELECT Amount__c, Frequency__c, Income_Type__c 
        //     FROM Income_Detail__c 
        //     WHERE Contact__c = :appRes.Case__r.ContactId
        //         AND Active__c = TRUE];
        // List<Map<String, Object>> incomeTypes = new List<Map<String, Object>>();
        // for (Income_Detail__c incomeDetail : incomes) {
        //     Map<String, Object> incomeType = new Map<String, Object>();
        //     incomeType.put('type', getIncomeType(incomeDetail.Income_Type__c));
        //     incomeType.put('frequency', checkNull(incomeDetail.Frequency__c));
        //     incomeType.put('amount', checkNull(incomeDetail.Income_Type__c));  
        //     incomeTypes.add(incomeType);
        // }


         // private static String getIncomeType(String incomeType) {
    //     if (String.isBlank(incomeType) ) {
    //         return '';
    //     } else {
    //         return incomeType.replace('Income - ', '');
    //     }
    // }