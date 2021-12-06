global class blogic_Conflict_Logs {
	
	public static void cascadePossibleConflicts(Map<id,Case> oldCases) {
         List<Possible_Conflict__c> conflictLogs = [	SELECT 	Id 
        										FROM 	Possible_Conflict__c 
        										WHERE 	Case__c in :oldCases.keySet()];
        if(conflictLogs!=null && !conflictLogs.isEmpty()) {
        	try {
        		System.debug(logginglevel.info,'Attempting to delete the following possible conflict records:'+conflictLogs);
        		delete conflictLogs;     
        	} catch (Exception ex) {        		
        		System.debug(logginglevel.warn,ex);
        	}
        }								
    	
    }		


	public static void cascadeConflictLogDeletes(Map<id,Case> oldCases) {
         List<Conflict_Log__c> conflictLogs = [	SELECT 	Id 
        										FROM 	Conflict_Log__c 
        										WHERE 	Case__c in :oldCases.keySet()];
        if(conflictLogs!=null && !conflictLogs.isEmpty()) {
        	try {
        		System.debug(logginglevel.info,'Attempting to delete the following conflict logs:'+conflictLogs);
        		delete conflictLogs;
			} catch (Exception ex) {        		
        		System.debug(logginglevel.warn,ex);
        	}        
        }								
    	
    }		
	public static void cascadePossibleConflicts(Map<id,Search_Log__c> oldSearchLogs) {
		
		Set<Id>ids = oldSearchLogs.keySet();
        List<Possible_Conflict__c> pcs = 	[	SELECT 	Id 
        										FROM 	Possible_Conflict__c
        										WHERE 	Search_Log_Client__c in :oldSearchLogs.keySet()];
        if(pcs!=null && !pcs.isEmpty()) {
        	try {
        		System.debug(logginglevel.info,'Attempting to delete pcs:'+pcs);
        		delete pcs;
			} catch (Exception ex) {        		
        		System.debug(logginglevel.warn,ex);
        	}        
        }
           	
    }		    
}