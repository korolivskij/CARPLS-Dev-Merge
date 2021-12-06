public class ctrlAuraAppliedResourceEdit {
	/**
	 *
	 *
	 * @param arId The Applied Resource ID.
	 *
	 * @return
	 */
	@AuraEnabled
	public static ResponseDTO retrieveAr(Id arId) {

		ResponseDTO dto = new ResponseDTO();
		Applied_Resource__c ar;
		try {
			ar = [select id, name, status__c, Title__c,
			      recordtype.DeveloperName, active__c, Type__c, Closing_Code__c, Disposition__c, Goal_Achieved__c
			      from applied_resource__c
			      where id = :arId];
			String rtDevName = ar.recordtype.DeveloperName;

			List<String> statusPlValues;
			List<String> Goal_Achieved;
			
			if (ar.recordtype.DeveloperName != null) {
				statusPlValues = retrieveArStatusPlValuesByRt(rtDevName, dto);
				Goal_Achieved = UiUtils.retrievePlValuesStringByRt(ar, 'Goal_Achieved__c', 'Solution');
				
				System.debug('statusPlValues ' + statusPlValues);
				/*
				 *  We have situations in dev. where the ar records have a status saved that is the recordtype setup for the ar. legacy mismatch.
				 *  just throw a warning at the ui.
				 */
				if (!statusPlValues.isEmpty() && ar.status__c != null) {
					Boolean valid = false;
					for (String sStatus : statusPlValues) {
						if (sStatus.equalsIgnoreCase(ar.status__c)) {
							valid = true;
							break;
						}
					}
					if (!valid) {
						statusPlValues.add(ar.status__c);
						dto.severity = 'warning';
						dto.message = 'Applied Resource Record ' + ar.name + ' has a status of ' + ar.status__c + ' which is not valid for its record type of ' + ar.recordtype.developername;
						dto.message += ' This means the record was updated prior to the recent implementation of recordtypes. ';
					}
				}
			} else {
				statusPlValues = retrieveArStatusPlValues();
				Goal_Achieved = UiUtils.retrievePlValuesString(ar, 'Goal_Achieved__c');
				//dispositionPlValues = UiUtils.retrievePlValuesString(ar, 'Disposition__c');
				dto.severity = 'warning';
				dto.message = 'Applied Resource Record ' + ar.name + ' has not been assigned a recordtype. Showing all available values. ';
			}
			dto.isSuccess = true;
			dto.values.put('Applied_Resource__c', ar);
			dto.values.put('StatusPlValues', statusPlValues);
			dto.values.put('Goal_Achieved__c', Goal_Achieved);
			//dto.values.put('DispositionPlValues', dispositionPlValues);
		} catch(Exception e) {
			dto.message = 'Error retrieving ar record with id=' + arId + '...' + e.getMessage() + '...stack=' + e.getStackTraceString();
			dto.severity = 'error';
		}
		return dto;
	}
	/**
	 *
	 *
	 * @param ar
	 *
	 * @return
	 */
	@AuraEnabled
	public static ResponseDTO updateAr(Applied_Resource__c ar) {
		System.debug('arrrrr '+ar);
		ResponseDTO dto = new ResponseDTO();
		try {
			ResponseDTO updateDto = doDMLUpdate(ar);
			if (updateDto.isSuccess) {
				ar = (Applied_Resource__c) updateDto.values.get('Applied_Resource__c');
				//refresh to get formula field value;
				ar = [select id, name, status__c, Title__c,
				      recordtype.DeveloperName, active__c,Type__c, Closing_Code__c, Disposition__c
				      from applied_resource__c
				      where id = :ar.Id];

				dto.isSuccess = true;
				dto.values.put('Applied_Resource__c', ar);
				dto.message = 'Applied Resource #' + ar.Name + ' has been updated successfully.';
			} else {
				dto.isSuccess = false;
				dto.severity = updateDto.severity;
				Map<StatusCode, String> mStatusCode_errorMsg = (Map<StatusCode, String>) updateDto.values.get('mErrors');
				dto.message = ' There was a problem updating the applied resource: ';
				for (StatusCode sc : mStatusCode_errorMsg.keySet()) {
					dto.message += mStatusCode_errorMsg.get(sc);
				}
			}
		} catch(Exception e) {
			dto.message = e.getMessage();
			dto.severity = 'error';
		}
		return dto;
	}
	/***
	 * Very simple wrapper on a single sobject update for now. mostly here to trap validation rule errors.
	 *
	 * @param sobj
	 *
	 * @return
	 */
	private static ResponseDTO doDMLUpdate(SObject sobj) {
		ResponseDTO saveDTO = new ResponseDTO();
		System.debug('saveDto '+saveDTO);
		DataBase.Saveresult sr = Database.update(sObj, false);
		if (sr.success) {
			saveDTO.isSuccess = true;
			saveDTO.values.put(sObj.getSObjectType().getDescribe().getName(), sObj);
		} else {
			saveDTO.isSuccess = false;
			saveDTO.severity = 'error';
			Map<System.StatusCode, String> mErrMsgs = new Map<System.StatusCode, String> ();
			for (Database.Error err : sr.getErrors()) {
				mErrMsgs.put(err.getStatusCode(), err.getMessage());
			}
			saveDTO.values.put('mErrors', mErrMsgs);
		}
		return saveDTO;
	}
	//private static String prettyValError(String )
	/**
	 * Here for graceful fallback in case the ar record does not have a record type.
	 *
	 * @return A List<String> of all status picklist values.
	 */
	@AuraEnabled
	public Static List<String> retrieveArStatusPlValues() {
		return UiUtils.retrievePlValuesString(new Applied_Resource__c(), 'Status__c');
	}
	/**
	 * New functionality to retrieve pl values only by record type.
	 * Also. in case al wants to show less values then allowed in the RT. pull custom settings.
	 * 
	 *
	 * @param rdDevName - Applied_Resource__c.recordtype.developername
	 * @return A List<String> of status picklist values by record type.
	 */
	@AuraEnabled
	public Static List<String> retrieveArStatusPlValuesByRt(String rtDevName, ResponseDTO dto) {
		List<String> lStatusByRt = UiUtils.retrievePlValuesStringByRt(new Applied_Resource__c(), 'Status__c', rtDevName);
		List<String> lFilteredStatus = new List<String> ();
		if (lStatusByRt != null && !lStatusByRt.isEmpty()) {
			Set<String> sTmp = filterArStatus(rtDevName, dto);
			System.debug('sTmp ' + sTmp);
			if (sTmp != null) {
				for (String status : sTmp) {
					lFilteredStatus.add(status);
				}
			} else {
				lFilteredStatus = lStatusByRt;
			}
		} else {
			lFilteredStatus = lStatusByRt;
		}
		return lFilteredStatus;
	}
	/**
	 *
	 *
	 * @param sType
	 *
	 * @return
	 */
	private static Set<String> filterArStatus(String rtDevName, ResponseDTO dto) {
		Set<String> filteredStatuses;
		String fieldName = 'areditstatus_' + rtDevName + '__c';

		Object obj = CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), fieldName);
		System.debug('filter ar Status obj ' + obj);
		if (obj != null) {
			String sStatus = (String) obj;
			if (sStatus != null && sStatus != '') {
				filteredStatuses = new Set<String> (sStatus.split('~'));
				dto.technicalMsg += ' custom setting statuses=' + filteredStatuses;
			}
		} else {
			dto.technicalMsg += ' no custom settings found for field name=' + fieldName;
		}
		return filteredStatuses;
	}

	@AuraEnabled
	public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName, string depfieldApiName, string recordTypeApiName) {
		String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();

		List<String> ctrlRtField = UiUtils.retrievePlValuesStringByRt(objDetail,contrfieldApiName,recordTypeApiName);
		System.debug('ctrlRtField '+ctrlRtField);
		Map<String, String> ctrlRtFieldMap = new Map<String,String>();
		for(String pl: ctrlRtField){
			ctrlRtFieldMap.put(pl,pl);
		}

		List<String> theRtField = UiUtils.retrievePlValuesStringByRt(objDetail,depfieldApiName,recordTypeApiName);
		System.debug('theRtField '+theRtField );

		Map<String, String> theRtFieldMap = new Map<String,String>();
		for(String pl: theRtField){
			theRtFieldMap.put(pl,pl);
		}

        Schema.sObjectType objType = objDetail.getSObjectType();
		System.debug('objType '+objType);
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);

        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
		System.debug('contrEntries '+contrEntries);
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
		System.debug('depEntries '+depEntries);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
			System.debug('ple '+ple);
			String label = ple.getLabel();
			objResults.put(label, new List<String>());
			controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) { 
			String label = plew.label;
			String validForBits = base64ToBits(plew.validFor);
			for (Integer i = 0; i < validForBits.length(); i++) {
				String bit = validForBits.mid(i, 1);
				if (bit == '1') {	
					objResults.get(controllingValues.get(i)).add(label);
				}
			}
        }

		Map<String,List<String>> objResultsRt = new Map<String,List<String>>();
		for(String pl: objResults.keySet()){	
			if(ctrlRtFieldMap.containsKey(pl)){
				objResultsRt.put(pl, new List<String>());	
				for(String plDep: objResults.get(pl)){
					if(theRtFieldMap.containsKey(plDep)){
						objResultsRt.get(pl).add(plDep);
					}
				}
			}
		}


        return objResultsRt;
	}

	public static String decimalToBinary(Integer val) {
		String bits = '';
		while (val> 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	public static String base64ToBits(String validFor) {
		if (String.isEmpty(validFor)) return '';

		String validForBits = '';

		for (Integer i = 0; i<validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}

	private static final String base64Chars = '' +
	'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
	'abcdefghijklmnopqrstuvwxyz' +
	'0123456789+/';


	private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
		return(List<PicklistEntryWrapper>)
		JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
	}

	public class PicklistEntryWrapper {
		public String active { get; set; }
		public String defaultValue { get; set; }
		public String label { get; set; }
		public String value { get; set; }
		public String validFor { get; set; }
		public PicklistEntryWrapper() {
		}

	}
}