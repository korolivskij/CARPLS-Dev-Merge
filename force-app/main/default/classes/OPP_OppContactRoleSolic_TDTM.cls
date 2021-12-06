/*
    Copyright (c) 2009, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.

*/
/**
* @author Salesforce.com Foundation
* @date 2011 (1.x)
* @description Provides opportunity and contact role support for all models  
* @author Erica Cox
* @date 2015
* @description Customization to create contact roles for solicitors
*/
global without sharing class OPP_OppContactRoleSolic_TDTM extends npsp.TDTM_Runnable {

    // the main entry point for TDTM to invoke our trigger handlers.
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        	
        DmlWrapper dmlWrapper = new DmlWrapper();
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
        	
    		createContactRoles((list<Opportunity>) newlist, dmlWrapper);
        }
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
        	updateContactRoles((list<Opportunity>) newlist, dmlWrapper);
        }
        
        return dmlWrapper;
    }
 
    private void createContactRoles(list<Opportunity> listOpp, DmlWrapper dmlWrapper) {
 
         List<OpportunityContactRole> CRs = new List<OpportunityContactRole>();   	
        //Create CRs.
        if (listOpp.size() > 0){

	        //Straightforward creation of opp contact role.      
	        for(Opportunity o : listOpp){
	        	if(o.Solicitor__c != null) {
	                try {
	                    CRs.add(new OpportunityContactRole(OpportunityId = o.Id, ContactId = o.Solicitor__c, Role = 'Solicitor', IsPrimary = false));
	                } catch (exception e) {
	                    o.addError(Label.npe01.Opportunity_Contact_Role_Error_Bad_Contact_Id);
	                }
	            }
	        }
        }
        if (CRs.size() > 0){
            dmlWrapper.objectsToInsert.addAll((list<SObject>) CRs); 
        }
    }


	private static void updateContactRoles(List<Opportunity> listOpp, DmlWrapper dmlWrapper) {

        Map<Id, Opportunity> oppsMap = new map<Id, Opportunity>(listOpp);   		
		List<OpportunityContactRole> CRUpdates = new List<OpportunityContactRole>();

		 //Get existing contact roles for the trigger opps. 
        List<OpportunityContactRole> CRs = [select OpportunityId, ContactId, Role, IsPrimary from OpportunityContactRole where Role = 'Solicitor' and OpportunityId in :oppsMap.keySet()];

        //Check for CR with role of solictor; save those for updates.
        if(CRs != null && CRs.size() > 0){
            for(OpportunityContactRole cr : CRs){
                if(cr.ContactId != oppsMap.get(cr.OpportunityId).solicitor__c){
                	cr.ContactId = oppsMap.get(cr.OpportunityId).solicitor__c;
 					CRUpdates.add(cr);
                }

            }
        }
        
        //Update existing CRs.
        if (CRUpdates != null && CRUpdates.size() > 0){
        	dmlWrapper.objectsToUpdate.addAll((List<SObject>)CRUpdates);
        }
	}   

         
}