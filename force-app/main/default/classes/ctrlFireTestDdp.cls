public with sharing class ctrlFireTestDdp extends ctrlCarplesGeneric {
    
    public  string                  currentRelativeUrl              { get; set; }
    public  String                  generatedUrl                    { get; set; }
    public  Loop__DDP__c            ddp                             { get; set; }
    public  Case                    cse                             { get; set; }
    public  Contact                 contact                         { get; set; }
    public  Consultation__c         currentService                  { get; set; }
    public  Applied_Resource__c     appliedResource                 { get; set; }
    public  String                  soqlDdps                        { get; set; }
    
    public  Id                      ddpIdClicked                    { get; set; }
    public  List<Loop__DDP__c>      ddps                            { get; set; }
    public  String                  jsInitDdpProcess                { get; set; }
    
    public  String                  pContactId                      { get; set; }
    public  String                  pCaseId                         { get; set; }
    public  String                  pAppliedResourceId              { get; set; }
 
    public  CaseUtils               caseUtils                       { get; set; }
    public  AppliedResourceUtils    arUtils                         { get; set; }
    
    
    public  Boolean                 showGis                         { get; set; }
    public  String                  selectedTestStatus              { get; set; }
    public  String                  selectedClientLanguage          { get; set; }
    public  String                  selectedServiceLevel            { get; set; }
    
    public ctrlFireTestddp() {
        super();
        
        this.setDataParms();    
        
        this.caseUtils          = new CaseUtils();
        this.arUtils            = new AppliedResourceUtils();       
        
        this.cse = this.retrieveCase();
        if(cse != null) {                   
            this.currentService = this.retrieveCurrentService(cse);
        } else {
            String msg = 'Could not find test case to run DDP Tests. Please ensure custom settings are configured with the proper ids.'; 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,msg));        
            System.debug(logginglevel.warn,'No case found for id:'+pCaseId);
            return;
        }
        this.contact            = this.retrieveContact();
        this.appliedResource    = this.retrieveAppliedResource();
        
        this.showGis = false;
        this.selectedTestStatus = 'All';
        this.selectedClientLanguage = 'English';
        this.selectedServiceLevel = 'All';
        soqlDdps = buildBaseSoql();
    }
    public Pagereference doUpdateAppliedResource() {    
        this.ddp = DdpUtils.retrieveDdp(ddpIdClicked);
        
        appliedResource.Flag_for_DDP__c = true;
        update appliedResource;
        ddp.test_status__c = 'Test Executed';
        ddp.last_tester__c = UserInfo.getUserId();
        update ddp;     
        this.jsInitDdpProcess = 'initDdpProcess("'+ddpIdClicked+'","'+appliedResource.id+'");';
        
        this.refreshDdpList();
        return null;
    }   
    public PageReference doInitPage() {
        if(this.cse == null) {  
            System.debug(logginglevel.warn,'No case found for id:'+pCaseId);
            return null;
        }           
        this.refreshDdpList();
        this.currentRelativeUrl = ApexPages.currentPage().getUrl();
        return null;        
    }   
    public PageReference doRefreshDdpList() {
        this.soqlDdps = this.buildBaseSoql();
        this.refreshDdpList();
        return null;
    }
    public PageReference doSelectClientLanguage() {
        this.setDataParms();
        this.cse = this.retrieveCase();
        if(cse != null) {
            this.currentService = this.retrieveCurrentService(cse);
        }
        this.contact            = this.retrieveContact();
        this.appliedResource    = this.retrieveAppliedResource();       
        return this.doRefreshDdpList();
    }
    private String buildBaseSoql() {
        al.NestableCondition whereC = new al.AndCondition();
        
        whereC.add(new al.FieldCondition('ddp_id__c').notequals( null )); //Just a placehold in case no other where criteria are added      
        if(!this.showGis) {
            whereC.add(new al.NotCondition(new al.FieldCondition('title__c').likex('GI' )));
        } 
        if(this.selectedTestStatus != 'All') {
            whereC.add(new al.FieldCondition('test_status__c').equals( this.selectedTestStatus ));
        }       
        if(this.selectedClientLanguage != 'English') {
            List<String> langs = new List<String>();
            langs.add('Spanish');
            whereC.add(new al.SetCondition('languages__c').includes( langs ));
        }        
        if(this.selectedServiceLevel != 'All') {
            whereC.add(new al.FieldCondition('service_level__c').likex(this.selectedServiceLevel ));
        }
        whereC.add(new al.FieldCondition('status__c').equals('Active' ));
        
        String soql = new al.SoqlBuilder()                       
                        .selectx(new Set<String> {'id','DDp_Id__c','name', 'Title__c', 'Loop__Description__c', 'Loop__Output_Filename__c' })
                        .selectx(new Set<String> { 'status__c','Service_Level__c', 'languages__c', 'test_status__c' })
                        .selectx(new Set<String> { 'Last_Tester__r.Name' })              
                        .fromx( 'Loop__DDP__c')
                        .wherex(whereC) 
                        .orderByx(new al.OrderBy('title__c').ascending())
                        .toSoql(new al.SoqlOptions().wildcardStringsInLikeOperators());  
                        
        return soql;        
    }   
    private Case retrieveCase() {
        String caseId = pCaseId;
        Case c = caseUtils.retrieveCaseSummaryData(caseId);
        return c;       
    }
    private Contact retrieveContact() {
        String contactId = pContactId;
        Contact c = ContactUtils.retrieveAllContactInfo(contactId);
        return c;   
    }
    private Consultation__c retrieveCurrentService( Case aCase) {
        Consultation__c service = caseUtils.retrieveCurrentCaseConsultation(aCase); 
        return service; 
    }
    private Applied_Resource__c retrieveAppliedResource() {
        String arId = pAppliedResourceId;
        
        Applied_Resource__c ar = arUtils.retrieveAppliedResource(arId);
        return ar;
    }
    private void refreshDdpList() {
        this.ddps = Database.query(this.soqlDdps);      
    }
    private void setDataParms() {
        this.pContactId         = ApexPages.currentPage().getParameters().get('contactId');
        this.pCaseId            = ApexPages.currentPage().getParameters().get('caseId');
        this.pAppliedResourceId = ApexPages.currentPage().getParameters().get('appliedResourceId');
        
        if(pContactId == null || pContactId == '') {
            String fieldName = 'DDP_Test_Contact_Id_en__c';
            if(this.selectedClientLanguage == 'Spanish') {
                fieldName = 'DDP_Test_Contact_Id_es__c';
            }
            Object oContactId = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);        
            if(oContactId!= null) {
                this.pContactId = (String)oContactId;
            }   
        }
        if(pCaseId == null || pCaseId == '') {
            String fieldName = 'DDP_Test_Case_Id_en__c';
            if(this.selectedClientLanguage == 'Spanish') {
                fieldName = 'DDP_Test_Case_Id_es__c';
            }
            Object oCaseId = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);        
            if(oCaseId!= null) {
                this.pCaseId = (String)oCaseId;
            }   
        }               
        if(pAppliedResourceId == null || pAppliedResourceId == '') {
            
            String fieldName = 'DDP_Test_Applied_Resource_Id_en__c';
            if(this.selectedClientLanguage == 'Spanish') {
                fieldName = 'DDP_Test_Applied_Resource_Id_es__c';
            }
            Object oAppliedResourceId = CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), fieldName);        
            if(oAppliedResourceId!= null) {
                this.pAppliedResourceId = (String)oAppliedResourceId;
            }   
        }
    }
    public List<SelectOption> getTestStatusOptions() {
        List<SelectOption> validOptions = new List<SelectOption>();
       
        List<SelectOption> options = UiUtils.retrievePlValues(new LOOP__Ddp__c(), 'Test_Status__c');
        validOptions.add(new SelectOption('All', 'All'));
        for(SelectOption so : options) {
            String val = so.getValue();
            validOptions.add(so);            
        }
        return validOptions;        
    }   
    public List<SelectOption> getClientLanguageOptions() {
        List<SelectOption> validOptions = new List<SelectOption>(); 
        
        validOptions.add(new SelectOption('English', 'English'));
        validOptions.add(new SelectOption('Spanish', 'Spanish'));

        return validOptions;        
    }
     public List<SelectOption> getServiceLevelOptions() {
        List<SelectOption> validOptions = new List<SelectOption>();
       
        List<SelectOption> options = UiUtils.retrievePlValues(new LOOP__Ddp__c(), 'service_level__c');
        validOptions.add(new SelectOption('All', 'All'));
        for(SelectOption so : options) {
            String val = so.getValue();
            validOptions.add(so);            
        }
        return validOptions;        
    }   
}