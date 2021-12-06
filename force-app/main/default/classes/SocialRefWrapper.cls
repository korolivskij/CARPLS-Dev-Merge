/**
    * SocialRefWrapper - <description>
    * @author: Richard Nendza22
    * @version: 1.0
*/
public with sharing class SocialRefWrapper implements IRefWrapper, Comparable {
    
    public          Account         resource;
    public          Boolean         checkBox;  
    public          Integer         sortOrder;
    public          ResourceType    resType;    
    
    Public SocialRefWrapper(Account a, boolean selected){
        resource            = a;
        checkBox            = selected;
        this.resType        = ResourceType.SOCIAL;
        if(selected) { sortOrder = 1;} else { sortOrder = 0; }
    }   
    /*
    public Integer compareTo(Object oToCompare) {
        if(sortOrder > ((SocialRefWrapper)oToCompare).sortOrder) {
            return 0;
        } else {
            return 1;
        }
    }
    */
    public Integer compareTo(Object oToCompare) {
        
        Decimal iTotalArs = 0;   //instance LR wrapper
        Decimal cTotalArs = 0;   //compare to LR wrapper
        //----- Type Safety checks
        if(resource.Total_Nbr_of_Applied_Resources__c != null) {
            iTotalArs = resource.Total_Nbr_of_Applied_Resources__c;
        }
        SocialRefWrapper oCompareSrw = (SocialRefWrapper)oToCompare;
        if(oCompareSrw != null && oCompareSrw.resource != null) {           
            if(oCompareSrw.resource.Total_Nbr_of_Applied_Resources__c != null) {
                cTotalArs = oCompareSrw.resource.Total_Nbr_of_Applied_Resources__c;
            }
        }
        //--------------------------
        
        if(sortOrder > ((SocialRefWrapper)oToCompare).sortOrder) {
            // added for IL-AFLAN to float Military resources to the top
            if (resource.Military_Service__c == true && oCompareSrw.resource.Military_Service__c == false) {
                return 1;
            }
            if (resource.Military_Service__c == false && oCompareSrw.resource.Military_Service__c == true) {
                return 0;
            }
            if(iTotalArs > cTotalArs) {
                return 1;
            } else {
                return 0;
            }
        } else {
            // added for IL-AFLAN to float Military resources to the top
            if (resource.Military_Service__c == true && oCompareSrw.resource.Military_Service__c == false) {
                return 1;
            }
            if (resource.Military_Service__c == false && oCompareSrw.resource.Military_Service__c == true) {
                return 0;
            }
            if(cTotalArs > iTotalArs) {
                return 1;
            } else  {
                return 0;
            }
            
            return 1;
            
        }
    }       
    public Account  getResource()                               { return this.resource; }
    public void     setResource(Account aRes)                   { this.resource = (Account)aRes; }  
   
    public Boolean  getCheckBox()                               { return this.checkBox; }
    public void     setCheckBox(Boolean b)                      { this.checkBox = b; }
    
    public Integer  getSortOrder()                              { return this.sortOrder; }
    public void     setSortOrder(Integer i)                     { this.sortOrder = i; }
    
    public ResourceType getResType()                            { return this.resType;  }
    public void         setResType(ResourceType eType)          { this.resType = eType; }

}