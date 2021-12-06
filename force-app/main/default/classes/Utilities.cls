global class Utilities {
    public static Map<String, Schema.sObjectType> m_keyPrefix_sObjectType  = new Map<String, Schema.sObjectType>();
    
    static {
        for (Schema.SObjectType sObj : Schema.getGlobalDescribe().values()) {
            m_keyPrefix_sObjectType.put(sObj.getDescribe().getKeyPrefix(), sObj);
        }               
    }
    
	//Note remote site setting for local sfdc instance needed for this. 
	//@TODO you can't directly unit test this stuff have to set up mock callouts yet another SFDC hack / pita
 	public static list<map<string,object>> getFieldMetaData(string fieldName)
    {
        list<map<string,object>> results = new list<map<string,object>>();
        
        fieldName = fieldName.replace('__c','');
        string instanceURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        
        String toolingendpoint = 'https://'+instanceURL+'/services/data/v28.0/tooling/';
        
        //query for custom fields
        toolingendpoint += 'query/?q=Select+id,DeveloperName,FullName+from+CustomField+where+DeveloperName+=+\''+fieldName+'\'';
        req.setEndpoint(toolingendpoint);
        req.setMethod('GET');
        
        Http h = new Http();
        try {
        HttpResponse res = h.send(req);
        
        //convert the original data structure into a map of objects. The data we want is in the records property of this object
        map<string,object> reqData = (map<string,object>) json.deserializeUntyped(res.getBody());
        
        //now create a list of objects from the records property. This serialize/deserialize trick is the only way I know to convert a generic object
        //into something else when the source data is 'salesforce Map encoded' (no quotes around field names or values, parenthesis to denote open and close, etc)
        list<object> fieldData = (list<object>) JSON.deserializeUntyped(JSON.serialize(reqData.get('records')));    
        
        //iterate over each object in the list and create a map of string to object out of it and add it to the list
        for(object thisObj : fieldData)
        {
            map<string, object> thisFieldData =  (map<string, object>) json.deserializeUntyped(JSON.serialize(thisObj));
            results.add(thisFieldData);
        }
        } catch (Exception e) {
            system.debug(e);
        }
   
        return results;    
    }
    //Note remote site setting for local sfdc instance needed for this.
    //@TODO you can't directly unit test this stuff have to set up mock callouts yet another SFDC hack / pita	
	public static String getSpecificFieldId(String objectName, String fieldName ) {
		String fieldId = '';
		List<map<string,object>> fieldMetaData = getFieldMetaData(fieldName);
		  		
  		for(map<string,object> mString_Obj : fieldMetaData) {
         	String fullName = (String)mString_Obj.get('FullName');
         	if(fullName == objectName + '.' + fieldName) {
         		fieldId = (String)mString_Obj.get('Id');
         	}
  		}
  		if(fieldId.length() == 18) {
  			fieldId = fieldId.substring(0,15);
  		}
  		return fieldId;		
	}        
    public static Boolean doesListHaveValue(List<SObject> lSobjects) {
        if(lSobjects == null) {
            return false;
        }
        if(lSobjects.isEmpty()) {
            return false;
        }
        return true;        
    }
    public static Boolean doesListHaveValue(List<Object> lOBjects) {
        if(lObjects== null) {
            return false;
        }
        if(lObjects.isEmpty()) {
            return false;
        }
        return true;        
    }   
    public static string shortenText(string text, integer length) {
        string result = text;
        if (result.length() > length) {
            result = result.substring(0,length);
        } 
        return result;
    }
        
    public static string LEFT(string val, integer length) {
        if (val != null && val.length() <= length) {
            return val;
        } else if(val != null) {
            return val.substring(0,length);
        } else {
            return '';
        }
    }
    
    public static string spaceUnderscore(string val) {
        if(val == null) {
            return '';
        } else {
            string result = val.replace('  ','');
            result = result.replace(' ','_');
            return result;
        }
    }
    
    public static string nullString(string val){
        if(val == null) {
            return '';
        } else {
            return val;
        }
    }
    
    public static string nullString(object val){
        if(val == null) {
            return '';
        } else {
            string result = '';
            try{
                result = string.valueOf(val);
            } catch (exception e) {
                
            }
            return result;
        }
    }
    
    public static String generateRandomString(Integer numChars) {
        
        //declare local vars 
        String randomNumString = ''; 
        String returnVal = ''; 
        List <String> charArray = new String [] {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','-','$','#','!','@','+','=','%'};
        
        // determine how many random number strings we need 
        //System.debug('Number of requested characters: ' + numChars);
        
        // generate the requisite random number strings 
        for (Integer x = 0; x < 100; x++) {
            // generate a random number
            String tempStr = String.valueOf(Math.random()); 
            //System.debug('Generated random number string: ' + tempStr);
            
            // take all of the digits to the right of the decimal point
            randomNumString += tempStr.substring(2);
            //System.debug('Running random number string: ' + randomNumString);
             
            // determine if we have enough characters
            if (randomNumString.length() >= numChars) {
                //System.debug('Number string has ' + randomNumString.length() + ' chars and is long enough');
                x = 101;
            }
        }
        // trim the string if we ran over
        if (randomNumString.length() > numChars) {
            //System.debug('Generated string is too long.  Trimming...');
            randomNumString = randomNumString.substring(0,numChars);
            //System.debug('Trimming complete.  Requested Length: ' + numChars + '; Actual Length: ' + randomNumString.length());
            //System.debug('Final Random Number String: ' + randomNumString);
        }
        
        // build the random character string
        for (Integer x = 0; x < randomNumString.length(); x++) {
        
            // declare local vars
            String currentNum = '';
            String newChar = '';
            String randomNum = String.valueOf(Math.random());
            Integer ndxMultiplier = 0;
        
            // get a handle on the current character
            currentNum = randomNumString.substring(x,x+1);
            //System.debug('Current number char is: ' + currentNum);
            
            // get the multiplier from the new random number string
            for (Integer y = 2; y < randomNum.length(); y++) {
                ndxMultiplier = Integer.valueOf(randomNum.substring(y,y+1));
                if (ndxMultiplier < 8) {
                    try{
                     newChar = charArray[ndxMultiplier * Integer.valueOf(currentNum)];
                    } catch(exception e){
                        newChar = 'a';
                    }
                    y = randomNum.length();
                }
            }
            returnVal += newChar; 
        }
        //System.debug('Generated Random String: ' + returnVal);
        
        // return the random character string
        return returnVal;
    }
  public static Boolean isNotNullObject(sObject sObj) {
    return sObj != null;
  }  
  public static Boolean isBLANK(String s) {
    if (s == null) return true;
    if (s.trim().equals('')) return true;
    return false;
  }
  public static string getSelectStarSOQL (string objectTypeName) {
      return getSelectStarSOQL(Schema.getGlobalDescribe().get(objectTypeName), false);
  }
  
  public static string getSelectStarSOQL (string objectTypeName, boolean removeSystemFields) {
      return getSelectStarSOQL(Schema.getGlobalDescribe().get(objectTypeName), removeSystemFields);
  }
  public static set<string> getFieldNames(schema.SObjectType objectType){
      return objectType.getDescribe().fields.getMap().keySet();
  }
  public static string getSelectStar(string objectTypeName){
      return getSelectStar(getFieldNames(Schema.getGlobalDescribe().get(objectTypeName)));
  }
  public static string getSelectStar(Set<string> strList){
      string result = 'SELECT ';
      for (String fieldName : strList) {
            result += fieldName + ', ';
        }
        result = result .substring(0,result .length()-2);
      return result;
  }  
  public static String getSelectStarSOQL (Schema.SObjectType objectType, boolean removeSystemFields) {
  /*******************************************************************************************
  * FUNCTION - Builds a SOQL query equivelant to a SELECT * SQL statement for the SobjectType
  *            sent into the function. Useful for dynamic Deep Clone operation (in the event
  *            fields are added to objects to be deep cloned after deployment.
  * EXAMPLE USAGE -
  *            String strSOQL = getSelectStarSOQL(Custom_Object__c.getsObjectType()); 
  */
    
        String selectStarSOQL;
        Set<String> objectFieldNames = getFieldNames(objectType);

        if (removeSystemFields != null && removeSystemFields) {
            objectFieldNames.removeAll(new List<String>{'id','isdeleted','ownerid','createdbyid','createddate','lastmodifiedbyid','lastmodifieddate','systemmodstamp'});        
        }
        selectStarSOQL = getSelectStar(objectFieldNames);
        selectStarSOQL += ' FROM ' + objectType.getDescribe().getName();
    
      return selectStarSOQL;
  }
  
   // This is a simple quicksort algorithm to sort a SelectOption list (dropdown) 
    // by label alphabetically.

    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort) {
    if(ListToSort == null || ListToSort.size() <= 1) return ListToSort;

        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();

        integer pivot = ListToSort.size() / 2;

        // save the pivot and remove it from the list

        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);

        for(SelectOption x : ListToSort) {
            if (x.getLabel() <= pivotValue.getLabel()) Less.add(x);
            else /* if (x.getLabel() > pivotValue.getLabel()) */ Greater.add(x);
        }

        List<SelectOption> returnList = new List<SelectOption>();

        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));

        return returnList; 
    }
    public static Contact createContact(){
        return createContact(generateRandomString(10),generateRandomString(15), generateRandomString(4), date.newInstance(1970,1,1), generateRandomString(15), generateRandomString(10));
    }
    public static Contact createContact(string firstName, string lastName, string ssn, date dob, string addressStreet, string addressCity) {
        Contact result = new Contact();
        result.FirstName = firstName;
        result.LastName = lastName;
        result.Last_Four_SSN__c = ssn;
        result.Birthdate = dob;
        result.MailingStreet = addressStreet;
        result.MailingCity = addressCity;
        return result;
    }
    
    public static Case createCase(string contactId){
        Case result = new Case();
        result.ContactId = contactId;
        return result;
    }

    public static RecordType retrieveRecordTypeBySObjectNameAndDevNAme(String sObjectName,String sRtDevName) {
        RecordType rt;
        
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('SObjectType').equals( sObjectName ));     
        whereC.add(new al.FieldCondition('developerName').equals(sRtDevName));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('RecordType', false ))
                    .fromx  ('RecordType')
                    .wherex( whereC )
                    .toSoql();  
        try { 
            rt = Database.query(soql);              
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return rt;                          
    }
    public static List<Alert__c> retrieveAllAlertsForContact(Id contactId, String sStatus) {
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('contact__c').equals( contactId ));        
        if(sStatus != null && sStatus != '') {
            whereC.add(new al.FieldCondition('status__c').equals( sStatus ));
        }
        return retrieveAlerts(whereC);
    }
    public static List<Alert__c> retrieveAllAlertsForCase(Id caseId, String sStatus) {
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('case__c').equals( caseId ));        
        if(sStatus != null && sStatus != '') {
            whereC.add(new al.FieldCondition('status__c').equals( sStatus ));
        }
        return retrieveAlerts(whereC);
    }	
    /**
     * @TODO figure out which fields to exclude
     */
    public static List<Alert__c> retrieveAlerts(al.NestableCondition whereC) {
        List<Alert__c> alerts;
        //Set<String> contactExcludeFields = new Set<String>();
        //Set<String> caseExcludeFields = new Set<String>();

        //-----------------------------------------------
        /* RJN remove all the excess fields that this query does not need / re,pve describe calls!! seems to have an effect on cpu time limits.
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Alert__c', false ))
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Contact', false, 'contact__r',contactExcludeFields ))
                    .selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r',caseExcludeFields ))     
                    .fromx  ('Alert__c')
                    .wherex( whereC )
                    .toSoql();
        */
        String soql = new al.SoqlBuilder()
                .selectx(new Set<String> {'name','id', 'case__r.casenumber','Alert_Message__c','Status__c','contact__r.name','createddate'})
                .fromx  ('Alert__c')
                .wherex( whereC )
                .toSoql();

        try { 
            alerts = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }       
        return alerts;
    }
    public static List<RecordType> retrieveSObjectRecordTypes(String sObjectName,List<String> rtDevNames) {
        
        List<RecordType> rts;
        
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('SObjectType').equals( sObjectName ));
        if(rtDevNames != null && !rtDevNames.isEmpty()) {
            for(String sRtDevName : rtDevNames) {
                whereC.add(new al.FieldCondition('developerName').equals(sRtDevName));
            }
        }
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('RecordType', false ))
                    .fromx  ('RecordType')
                    .wherex( whereC )
                    .toSoql();  
        try { 
            rts = Database.query(soql);             
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return rts;             
    }
    public Static List<String> getPlValues(String plValues) {
        return detokenizeString(plValues,';');
    }
    public Static Boolean doesListHaveValue(List<String> lValues, String value) {
        Boolean hasIt = false;
        if(lValues == null || lValues.isEmpty()) {
            return false;
        }
        if(value == null) {
            return false;
        }
        for(String s : lValues) {
            if(value == s) {
                hasIt = true;
                break;
            }
        }
        return hasIt;
    }
    public Static List<String> detokenizeString(String s, String sDelim) {
        if(s == null || s == '') {
            System.debug(logginglevel.info, 'Nothing to detokenize.. returning null');
            return null;
        }
        if(sDelim == null || sDelim == '') {
            System.debug(logginglevel.info, 'No delim passed.. returning null');
            return null;            
        }
        List<String> listTokenStrings= s.split(sDelim,s.countMatches(sDelim)+1);
        System.debug('Number of tokenized words in the given String '+listTokenStrings.size());
        return listTokenStrings;
    }
    public Static String tokenizeString(String oldString, String newVal, String sDelim) {
        String newValue = '';
        if(oldString == null || oldString == '') {
            System.debug(logginglevel.info, 'Nothing to detokenize (no value in oldString).. returning null');
            return null;
        }
        if(newVal == null || newVal == '') {
            System.debug(logginglevel.info, 'No new string to add, returning oldString');
            return oldString;
        }       
        if(sDelim == null || sDelim == '') {
            System.debug(logginglevel.info, 'No delim passed.. returning null');
            return null;            
        }
        newValue = al.StringUtils.chomp(oldString,sDelim) + sDelim + newVal;
        return newValue;
                
    }
    public Static String findObjectNameById(String id) {
        Schema.sObjectType currsObjectType;
        String objectName = '';
        if(id!=null) {
            String currKeyPrefix = ((String)id).substring(0, 3);            
            currsObjectType = m_keyPrefix_sObjectType.get(currKeyPrefix);
            if(currsObjectType != null) {
                objectName =  currsObjectType.getDescribe().getName();
            } else {
                System.debug(LoggingLevel.WARN,'object Type is null for String Id passed='+Id);
            }
        }
        return objectName;
    }
    public Static String findObjectLabelById(String id) {
        Schema.sObjectType currsObjectType;
        String objectName = '';
        if(id!=null) {
            String currKeyPrefix = ((String)id).substring(0, 3);            
            currsObjectType = m_keyPrefix_sObjectType.get(currKeyPrefix);
            if(currsObjectType != null) {
                objectName =  currsObjectType.getDescribe().getLabel();
            } else {
                System.debug(LoggingLevel.WARN,'object Type is null for String Id passed='+Id);
            }
        }
        return objectName;
    }
    
    public Static Schema.Sobjecttype findSObjectTypeById(String id) {
        Schema.sObjectType currsObjectType;
        Schema.sObjectType sObjType;
        String objectName = '';
        if(id!=null) {
            String currKeyPrefix = ((String)id).substring(0, 3);            
            currsObjectType = m_keyPrefix_sObjectType.get(currKeyPrefix);
            if(currsObjectType != null) {
                sObjType =  currsObjectType;
            } else {
                System.debug(LoggingLevel.WARN,'object Type is null for String Id passed='+Id);
            }
        }
        return sObjType ;
    }
    /**
     * @TODO ERROR Checking!
     */
    public Static Schema.SobjectField findSObjectFieldbyId(id sObjectId, String apiFieldName) {
		Schema.sObjectType sObjType = findSObjectTypeById(sObjectId);
		Schema.DescribeSObjectResult ds = sObjType.getDescribe();
		Map<String, Schema.SObjectField> allFields = ds.fields.getMap();
		return allFields.get(apiFieldName);
		//allFields.get(apiFieldName).getDescribe().	
		//String fieldLabel = allFields.get(apiFieldName).getDescribe().getLabel();
		

		
		//Schema.SObjectTypeFields = ds.getFields();
		//Map<String, SObjectField> mNameSObjectField = ds.getFields().getMap();
		//return mNameSObjectField(apiFieldName);
		//return null;
	
    }    
	public static void sendEmail(String toAddress, String subject, String textBody, String htmlBody) {
		List<String> toAddresses = new List<String>();
		toAddresses.add(toAddress);
		sendEmail(toAddresses, subject, textBody, htmlBody);
	}
	public static void sendEmail(List<String> toAddresses, String subject, String textBody, String htmlBody) {
		sendEmail(toAddresses, subject, textBody, htmlBody, false);
	}
  	public static void sendEmail(List<String> toAddresses, String subject, String textBody, String htmlBody, Boolean noReply) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(textBody);
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        if (noReply) {
        	// Use Organization Wide Address 
			for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
				if(owa.Address.contains('noreply')) {
					mail.setOrgWideEmailAddressId(owa.id); 
				}
			}
        }
        try {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
        	System.debug(logginglevel.error,e);
        }       
    }   
    /**
    	Method: sendEmailTemplate
    	Returns:	Boolean - success
    	Args:		String - template name
    				sObject - recipient
    				sObject - related to
    	Will send the email template with the given name using the other args. 
    **/       
    public static Boolean sendEmailTemplate(String tNm, Id toId, Id wId) {
    	
    	System.debug('in sendEmailTemplate with toId = '+toId+' and wId = '+wId);
        		
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		EmailTemplate et = [SELECT id from emailtemplate where name= :tNm]; 
		mail.setTemplateId(et.Id); 
		mail.setSaveAsActivity(false); 
		mail.setTargetObjectId(toId);
		mail.setWhatId(wId);
		// Use Organization Wide Address 
		for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
			if(owa.Address.contains('noreply')) {
				mail.setOrgWideEmailAddressId(owa.id); 
			}
		}
		try {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
        	System.debug(logginglevel.error,e);
        	return false;
        }       
        return true;
    }   
}