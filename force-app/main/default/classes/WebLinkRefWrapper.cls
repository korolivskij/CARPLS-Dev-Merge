/**
    * WebLinkRefWrapper - <description>
    * @author: Richard Nendza22
    * @version: 1.0
*/
public with sharing class WebLinkRefWrapper implements IRefWrapper, Comparable {
    
    public          Account         resource;
    public          Boolean         checkBox;  
    public          Integer         sortOrder;
    public          ResourceType    resType;    
    
    Public WebLinkRefWrapper(Account a, boolean selected){
        resource            = a;
        checkBox            = selected;
        this.resType        = ResourceType.WEBLINK;
        if(selected) { sortOrder = 1;} else { sortOrder = 0; }
    }   
    public Integer compareTo(Object oToCompare) {
        if(sortOrder > ((WebLinkRefWrapper)oToCompare).sortOrder) {
            WebLinkRefWrapper oCompareWl = (WebLinkRefWrapper)oToCompare;
            // added for IL-AFLAN to float Military resources to the top
            if (resource.Military_Service__c == true && oCompareWl.resource.Military_Service__c == false) {
                return 1;
            }
            if (resource.Military_Service__c == false && oCompareWl.resource.Military_Service__c == true) {
                return 0;
            }
            return 0;
        } else {
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