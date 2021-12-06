/****
** Servio Consulting, LLC.
** Alex Grinevich
** 1/6/2018
**
****/
public class ctrlZipExt {
    
    private Set<Id> Selected;
    
    public Account_Zip_Junction__c acczip {get;set;}
    
    public List<AZJItem> azjs{get; private set; }
    
    public ctrlZipExt(ApexPages.StandardSetController stdsetController) {
        
        this.Selected = (new Map<Id,SObject>((List<Zip__c>)stdsetController.getSelected())).keySet();
              
        acczip = new Account_Zip_Junction__c();
        azjs = new List<AZJItem>();
    }
    
    public PageReference CreateAccountZipJunctions()
    {
        if(Selected.size()==0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must select at least one Zip record!'));
            return null;
        }
        Id accId = acczip.Account__c;
        
        //find duplicates
        List<Account_Zip_Junction__c> exList = [SELECT Zip__c FROM Account_Zip_Junction__c WHERE Account__c = :accId AND Zip__c in :Selected];
        Set<Id> linkedZips = new Set<Id>();
        for(Account_Zip_Junction__c item: exList)
            linkedZips.add(item.Zip__c);
        
        Set<Id> zipsToJunction = new Set<Id>();
        
        for(Id item: Selected)
            if(!linkedZips.contains(item))
            	zipsToJunction.add(item);
        
        System.debug('zipsToJunction:' + zipsToJunction.size());

        //create junction objects
        List<Account_Zip_Junction__c> junctions = new List<Account_Zip_Junction__c>();

        for(Id zipid: zipsToJunction)
            junctions.add(new Account_Zip_Junction__c(Account__c = accId, Zip__c =zipid));
        
        //insert records 
        if(!junctions.isEmpty()){
            
            insert junctions;
            
            //and display results
            List<Account_Zip_Junction__c> newJuncs = [SELECT Id, Name, Account__c, Zip__c, Zip_Name__c,Account_Legacy_Id__c 
                                                      FROM Account_Zip_Junction__c
                                                      WHERE Account__c = :accId and Zip__c in :Selected];
            
            for(Account_Zip_Junction__c azj: newJuncs){
                
                AZJItem item = new AZJItem(azj);
                
                item.alreadyExists = linkedZips.contains(azj.Zip__c);
                    
                azjs.add(item);
            }
        }
        return null;
    }
    
    public PageReference DoBack(){
       if(ApexPages.currentPage().getParameters().get('retURL')!=null)
            return new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
        
        return  null;
    }

    private class AZJItem{
        public Account_Zip_Junction__c azj {get;set; }
        
        public Boolean alreadyExists {get;set; }
        
        public AZJItem(Account_Zip_Junction__c az){
            azj =az;
        }
        
        public pageReference view(){
            ApexPages.Pagereference pr = new ApexPages.Pagereference('/'+azj.Id);
            return pr;
        }
    }
}