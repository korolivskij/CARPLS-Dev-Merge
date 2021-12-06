global class CustomSettingsUtls {
    global static String DEBUGNAME = '\r--- CustomSettingsUtils ---\r';
    
	/**
	 * Gets SFDC Custom Setting (Carplsv20Settings__c). 
	 * This is a hierarchical setting and using the running user profile id (or userId) for this setting 
	 * is crucial as the different profiles / users may have different values.
	 * 
	 * Note: It is the responsibility of the calling method to do type conversion.
	 *
	 * @param	userProfileId	The Running user profile id. 
	 * @param	fieldName		The api name of the custom setting.
	 */
    global static object getCarplsv20Settings( Id userOrProfileId, string fieldName ) {
    	object value;
    	System.debug(DEBUGNAME + ' passed userOrProfileId ------------>'+userOrProfileId);
    	Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(userOrProfileId);
        
        if(null == customSetting) {
        	System.debug(DEBUGNAME + ' Carplsv20Settings__c Could not be located!');
        	return '';
        }
        
        try {
        	value = customSetting.get(fieldName); 
        } catch (Exception e) {
        	System.debug(logginglevel.error,e);
        } 
        
		System.debug(DEBUGNAME + '** Carplsv20Settings__c.' +fieldName + '='+ value);        
        return  value;          	
    }
	/**
	 * Gets SFDC Custom Setting (TriggerSettings__c). 
	 * This is a hierarchical setting and using the running user profile id for this setting 
	 * is crucial as the different profiles may have different values.
	 * 
	 * Note: It is the responsibility of the calling method to do type conversion.
	 *
	 * @param	userProfileId	The Running user profile id. 
	 * @param	fieldName		The api name of the custom setting.
	 */       
    global static object getTriggerSettings( Id userProfileId, string fieldName ) {
    	object value;
    	System.debug(DEBUGNAME + ' passed userProfileId ------------>'+userProfileId);
    	TriggerSettings__c customSetting = TriggerSettings__c.getInstance(userProfileId);
		//TriggerSettings__c customSetting = TriggerSettings__c.getOrgDefaults();     
        if(null == customSetting) {
        	System.debug(DEBUGNAME + ' TriggerSettings__c Could not be located!');
        	return '';
        }        
        try {
        	value = customSetting.get(fieldName); 
        } catch (Exception e) {
        	System.debug(logginglevel.error,e);
        } 
        
		System.debug(DEBUGNAME + '** TriggerSettings__c' +fieldName + '='+ value);        
        return  value;          	
    }
    global static boolean isDisableTrigger( String customSettingName ) {
    	Boolean disableTrigger = false;
    	try {
    		Object o = CustomSettingsUtls.getTriggerSettings( UserInfo.getProfileId(), customSettingName );
    		if(o != null) { // if it's null ie.. for some reason not found.. don't convert the type or Boom.
    			disableTrigger = (Boolean)o;
    		}    
    	} catch (Exception e) {
    		system.debug(logginglevel.error, ' cant find triggersettings__c.'+customSettingName+':' + e);
    	}
    	
    	if(disableTrigger) {
        	System.debug(logginglevel.warn, ' Custom Setting TriggerSettings__c.'+customSettingName +' is telling us not to run this trigger.');
    	}
    	return disableTrigger;   	
    }	    
}