/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 1/6/2018
****/
public class ctrlAccountExt {

     private final Account acc;
     
    public ctrlAccountExt(ApexPages.StandardController stdController) {
        
        this.acc = (Account)stdController.getRecord();
    }
    
     public PageReference CloneAccount()
    {
        SavePoint sp = Database.setSavePoint();
        
        try
        {
           //Id newAccId = AccountUtils.AccountClone(this.acc.Id);
            Id newAccId = AccountClone(this.acc.Id);
           PageReference pageRef =  new PageReference('/'+newAccId+'/e?retURL=%2F'+newAccId+'&saveURL=%2F'+newAccId);
           pageRef.setRedirect(true);     
           
           return pageRef;
       
       }catch(Exception e)
       {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An unexpected error has occurred: ' + e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }
    
    public pagereference CloneAccountBack()
    {
        PageReference pageRef = new PageReference('/'+this.acc.Id);
        pageRef.setRedirect(true);     
        return pageRef;
    }
    
     //AG
    public static Id AccountClone(Id accId) {
        
        Account a = AccountUtils.retrieveAccount(accId);
        
        List<RecordType> rt = [SELECT DeveloperName FROM RecordType where id = :a.RecordTypeId];
        
        if(rt.IsEmpty() || rt[0].DeveloperName !='Resources')
             throw new ApplicationException('Wrong record type! The Clone action is only allowed for \'Resources\' record type!');
        
        //Account info
        Account ca = new Account(RecordTypeId = a.RecordTypeId);
        ca.Name = a.Name;
        
        ca.ParentId = a.ParentId;
        ca.Phone = a.Phone;
        ca.Fax = a.Fax;
        ca.Website = a.Website;
        ca.Contact_Email_Address__c = a.Contact_Email_Address__c;
        ca.Intake_Status__c = a.Intake_Status__c;
        
        ca.Active__c = a.Active__c;
        ca.Type = a.Type;

        ca.Sub_Type__c = a.Sub_Type__c;
        ca.Total_Nbr_of_Applied_Resources__c = a.Total_Nbr_of_Applied_Resources__c;//?
        //Address info
        if(a.BillingStreet != null){
            ca.BillingCity = a.BillingCity;
            ca.BillingCountry = a.BillingCountry;
            ca.BillingPostalCode = a.BillingPostalCode;
            ca.BillingState = a.BillingState;
            ca.BillingStreet = a.BillingStreet;
            ca.Billing_Address_Type__c = a.Billing_Address_Type__c;
            //ca.BillingGeocodeAccuracy = a.BillingGeocodeAccuracy;
            //ca.BillingLatitude = a.BillingLatitude;
            //ca.BillingLongitude = a.BillingLongitude;
        }
        
        if(a.ShippingStreet != null){
            ca.ShippingCity = a.ShippingCity;
            ca.ShippingCountry = a.ShippingCountry;
            ca.ShippingPostalCode = a.ShippingPostalCode;
            ca.ShippingState = a.ShippingState;
            ca.ShippingStreet = a.ShippingStreet;
            ca.Shipping_Address_Type__c = a.Shipping_Address_Type__c;
            //ca.ShippingGeocodeAccuracy = a.ShippingGeocodeAccuracy;
            //ca.ShippingLatitude = a.ShippingLatitude;
            //ca.ShippingLongitude = a.ShippingLongitude;
        }
        
        //Additional info
        ca.Languages__c = a.Languages__c;
        ca.Min_Poverty_Level__c = a.Min_Poverty_Level__c;
        ca.Max_Poverty_Level__c = a.Max_Poverty_Level__c;
        ca.Poverty_Formula__c = a.Poverty_Formula__c;
        
        ca.CARPLS_Connect__c = a.CARPLS_Connect__c;
        ca.Minimum_Age__c = a.Minimum_Age__c;
        ca.Serves_Only_Disabled__c = a.Serves_Only_Disabled__c;
        ca.Military_Service__c = a.Military_Service__c;
        ca.Age_Disability_Logic__c = a.Age_Disability_Logic__c;
        ca.Social_Service__c = a.Social_Service__c;
        //Description info
        ca.Description = a.Description;
        ca.Description_255__c = a.Description_255__c;
        ca.Case_Acceptance_Guidelines__c = a.Case_Acceptance_Guidelines__c;
        
        Id caId = DmlUtils.DBInsert(ca);
        
        if(caId!=null)
        {
            /////////////////////Eligible_Problem_Codes__c
            List<Eligible_Problem_Codes__c> epc =[ Select e.Status__c, e.Problem_Code__c,
                                                  e.Problem_Code_Heirarchy__c, e.Problem_Code_Closed__c, 
                                                  e.Problem_Category__c, e.Problem_Category_Closed_Until_Date__c, 
                                                  e.Practice_Area__c, e.Obsolete_Jurisdiction__c, 
                                                  e.Name, e.Legal_Issue__c, e.Id, e.DDP__c, e.DDP_Legacy_Id__c, e.Comment__c,
                                                  e.Case_Question__c, e.Account__c, e.Account_Type__c, e.Account_Name__c
                                                  From Eligible_Problem_Codes__c e
                                                  WHERE  Account__c = :accId];
            
            for(Eligible_Problem_Codes__c item: epc){
                item.Id = NULL;
                item.Account__c = caId;
            }
            
            DmlUtils.DBInsert(epc, true);
            //////////////////////////Account_Subject_Junction__c
            List<Account_Subject_Junction__c> asj =[Select  a.Subject__c, a.Subject_Legacy_Id__c, a.Name, a.Id,  
                                                    a.Account__c, a.Account_Type__c
                                                    From Account_Subject_Junction__c a
                                                    WHERE  Account__c = :accId];
            
            for(Account_Subject_Junction__c item: asj){
                item.Id = NULL;
                item.Account__c = caId;
            }
            
            DmlUtils.DBInsert(asj, true);
            //////////////////////////Account_Zip_Junction__c
            List<Account_Zip_Junction__c> azj =[Select a.Zip__c, a.Zip_Name__c, a.Name, a.Id,  a.Account__c, a.Account_Legacy_Id__c 
                                                From Account_Zip_Junction__c a
                                                WHERE  Account__c = :accId];
            
            for(Account_Zip_Junction__c item: azj){
                item.Id = NULL;
                item.Account__c = caId;
            }
            
            DmlUtils.DBInsert(azj, true);
            //////////////////////////
        }
        
        return caId;
    }
}