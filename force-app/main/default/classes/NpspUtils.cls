/**********
//  This class will provide some utilities classes to deal with the Non Profit Starter Pack.
//	
***********/

public with sharing class NpspUtils {


    /** @description Property to populate with the NPSP Trigger Handler default records. **/
    public List<npsp__Trigger_Handler__c> tdtmConfig { public get; public set; }
 

       
    /** @description Constructor that populates the NPSP Trigger Handler records property. **/
    /** pTHS - a list of custom trigger handler rows to be added **/
    public NpspUtils(List<npsp__Trigger_Handler__c> pTHs) {
        tdtmConfig = npsp.TDTM_Config_API.getDefaultRecords();
        if (pTHs != null) {
        	for (npsp__Trigger_Handler__c th: pTHs) { 
        		tdtmConfig.add(th);
        	}
        }
        upsert tdtmConfig;
    }
      /** @description Constructor version with no parameters for backwards compatibility. **/
    /** pTHS - a list of custom trigger handler rows to be added **/
    public NpspUtils() {
		this(null);
    }   
    
    /** @description Action method that makes all NPSP Trigger Handlers active. **/
    public PageReference makeAllTriggersActive() {
        for(npsp__Trigger_Handler__c handler : tdtmConfig) {
            handler.npsp__Active__c = true;
        }
        upsert tdtmConfig;
        return null;
    }
    
    /** @description Action method that makes all NPSP Trigger Handlers inactive. **/
    public PageReference makeAllTriggersInactive() {
        for(npsp__Trigger_Handler__c handler : tdtmConfig) {
            handler.npsp__Active__c = false;
        }
        upsert tdtmConfig;
        return null;
    }
}