public with sharing class ctrlDefectSaveResults extends ctrlCarplesGeneric  {
    
    private ApexPages.StandardController    ctrl                { get; set; }
    public  Case                            cse                 { get; set; }
    private CaseUtils                       caseUtils           { get; set; }
    
    public ctrlDefectSaveResults(ApexPages.StandardController stdController) {
        this.ctrl = stdController;
        cse = (Case)stdController.getRecord();
        caseUtils = new  CaseUtils();
        this.cse = caseUtils.retrieveCaseSummaryData(cse.id);
    }
    public PageReference doInitPage() {
        String msg = 'Case: '+cse.CaseNumber + ' was added successfully';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));        
        return null;
    }
    
    public Pagereference doClose() {
        PageReference pr = new PageReference('/apex/vfDefectLauncher');
        pr.setRedirect(true);
        return pr;
    }
    public ctrlDefectSaveResults getTheController() {
        return this;
    }   
    
}