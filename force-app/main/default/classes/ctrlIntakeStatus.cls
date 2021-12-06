public class ctrlIntakeStatus {
      
    @AuraEnabled 
    public static String getAccountStatus(String type) {
        
        Set<id> cntID = new Set<id>();       
        for(User u :[SELECT ContactId FROM User WHERE id = :Userinfo.getUserid()]){
            cntID.add(u.ContactId);
        }
        Set<id> accID = new Set<id>();
        List<AccountContactRelation> accCntList = [SELECT Id, AccountID, Account.Intake_Status__c, Account.Partner_Type__c, ContactId 
                                                   FROM AccountContactRelation 
                                                   WHERE ContactId IN :cntID]; 
        for(AccountContactRelation acc : accCntList){
            accID.add(acc.AccountID);
        }

        List<Account> accList = [SELECT id, Name, Intake_Status__c, Partner_Type__c FROM Account WHERE id IN :accID];
        ResponseJSONWrapper wrapper = new ResponseJSONWrapper();
        String response = '';
            for(Account acr: accList){
                if(acr.Partner_Type__c == type){
                    
                    wrapper.id = acr.Id;
            		wrapper.status = acr.Intake_Status__c;
                    
                    response = JSON.serialize(wrapper);
        			return response;
                
                }
            }         
        return response;
    }
    
    public class ResponseJSONWrapper {
        public Id id;
        public String status;
    }
}