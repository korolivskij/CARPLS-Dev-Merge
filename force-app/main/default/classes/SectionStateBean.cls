public with sharing class SectionStateBean {
    
    public String                           sectionId               { get; set; }
    public String                           cssStyleClass           { get; set; }
    public String                           msg                     { get; set; }
    public Boolean                          showIt                  { get; set; }
    public Boolean                          allDataValidated        { get; set; }
    public Boolean                          required                { get; set; }
    
    public SectionStateBean() {
        this.sectionId              =   '';
        this.cssStyleClass          =   '';
        this.msg                    =   '';
        this.showIt                 =   false;
        this.allDataValidated       =   false;
        this.required               =   false;
    }   
    public SectionStateBean(String s, Boolean bShowSection){
        this.sectionId              = s;
        this.cssStyleClass          =   '';
        this.msg                    =   '';
        this.showIt                 = bShowSection;
        this.allDataValidated       = false;
        this.required               = false;
            
    }   
    public SectionStateBean(String s, Boolean bShowSection, Boolean bAllDataValidated ){
        this.sectionId              = s;
        this.showIt                 = bShowSection; 
        this.cssStyleClass          =   '';
        this.msg                    =   '';     
        this.allDataValidated       = bAllDataValidated;
        this.required               =   false;
    }   
    public SectionStateBean(String secId, String aCssStyleClass, String aMsg, Boolean aShowIt ){
        this.sectionId              = secId;
        this.showIt                 = aShowIt;
        this.cssStyleClass          = aCssStyleClass;
        this.msg                    = aMsg; 
        this.allDataValidated       = false;
        this.required               =   false;
    }
}