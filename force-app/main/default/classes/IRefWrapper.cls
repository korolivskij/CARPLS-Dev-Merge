/**
    * IRefWrapper - <description>
    * @author: Richard Nendza22
    * @version: 1.0
*/
public Interface IRefWrapper {
    
    Account getResource();
    void setResource(Account res);
    
    Boolean getCheckBox(); 
    void setCheckBox(Boolean b);
    
    Integer getSortOrder();
    void setSortOrder(Integer i);
    
    ResourceType getResType();
    void setResType(ResourceType eType);
    

}