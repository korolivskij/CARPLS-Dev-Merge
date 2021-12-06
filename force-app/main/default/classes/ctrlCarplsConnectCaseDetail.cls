public class ctrlCarplsConnectCaseDetail {

    public static final String  CC_ADMIN_NAME = 'Pat Wrona';
    public Case                 cse                             { get; set; }
    public Id                   referralAcctId                  { get; set; }
    public Account              referralAcct                    { get; set; }
    public Applied_Resource__c  applRes                         { get; set; }
    public List<Case_Party__c>  caseParties                     { get; set; }
    public List<Contact>        ctsForAcct                      { get; set; }
    public List<ContentVersionWrapper>  contentVersionWrappers              { get; set; }
    public List<NotesWrapper>           caseConsultationNotes               { get; set; }
        
    public AppliedResourceUtils arUtils                         { get; set; }
    public CaseUtils            cseUtils                        { get; set; }
    public Utilities            utils                           { get; set; }
         
    public Boolean              renderAcceptReferralComponent   { get; set; }
    public Boolean              renderRejectReferralComponent   { get; set; }
    public Boolean              renderCloseReferralComponent    { get; set; }
    public Boolean              renderPendReferralComponent     { get; set; }
    public Boolean              noConflict                      { get; set; }
    // This will be set to true for those referrals that are able to return a case to Pending status
    // currently, Section 8
    public Boolean              multiUser                       { get; set; }
    public String               refStatus                       { get; set; }
    // adding this here for now.  Remove if this class really needs to extend CarplsGeneric
    public String               selectedId                  { get; set; }

    public ctrlCarplsConnectCaseDetail(ApexPages.StandardController stdController) {
        
        this.cse = (Case)stdController.getRecord(); 
        
        arUtils = new AppliedResourceUtils();
        cseUtils = new CaseUtils();
        //utils = new Utilities();
        
        renderAcceptReferralComponent = false;
        renderRejectReferralComponent = false;
        noConflict = false;
        
    }
    public PageReference doInitCase() {
        
        /* get the applied resource record for this referral */
        String sAcctId =  ApexPages.currentPage().getParameters().get('acctId');
        this.referralAcctId = (Id)sAcctId;
        
        // get the account record for this referral
        // need this in order to exclude the generic contact from the list when there is more than 1 
        this.referralAcct = AccountUtils.retrieveAccount(this.referralAcctId);
        
        // this will render the 'Return to Pending' button for referrals with multiple users
        multiUser = this.referralAcct.name == 'Section 8 Voucher Termination Legal Aid Panel';
        
        System.debug(logginglevel.debug, 'in doInitCase - referralAcctId = '+referralAcctId+' this.cse = '+this.cse);
        this.applRes = arUtils.retrieveAppliedResource(this.cse, referralAcctId, 'Legal Referrals');
        System.debug(logginglevel.debug, 'In doInitCase, applRes = '+this.applRes);
        /* get the status passed for this referral */
        this.refStatus = ApexPages.currentPage().getParameters().get('status');
        /* get the case parties for this case */
        this.caseParties = cseUtils.retrieveCaseParties( this.cse );
        System.debug('in doInitCase - caseParties = '+caseParties);
        /* get the contectVersions for this case */
        this.contentVersionWrappers = ChatterUtils.retrieveContentVersionWrappersByCaseId(cse.id);
        System.debug('in doInitCase - contentVersionWrappers = '+contentVersionWrappers);
        /* get the service notes for this case */
        this.caseConsultationNotes = cseUtils.retrieveCaseConsultationNotesWraps(this.cse);  
        /* get the contacts for this account */
        ctsForAcct = ContactUtils.retrieveContactsByAcct(referralAcctId);
        return null;
              
    }
    
    public PageReference doAcceptReferral() {
        renderAcceptReferralComponent = true;
        return null;
    }
    public pageReference doSaveAcceptReferral() {
        
        applRes.status__c = 'Accepted';
        applRes.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Accepted').id;
        //applRes.distribution__c = 'Referral Accepted';
        update this.applRes;
        renderAcceptReferralComponent = false;
        return null;    
        
    } 
    public pageReference doCancelAcceptReferral() {
        // don't want to clear out a note made by someone else on the panel.
        if (!multiUser) {
            applRes.referral_note__c = '';
        }
        renderAcceptReferralComponent = false;
        System.debug('In doCancelAcceptReferral - renderAcceptReferralComponent = '+renderAcceptReferralComponent);
        return null;
    }
    public pageReference doRejectReferral() {
        renderRejectReferralComponent = true; 
        return null;
    } 
    public pageReference doSaveRejectReferral() {
        
        //applRes.distribution__c = 'Referral Rejected';
        applRes.status__c = 'Closed';
        applRes.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed').id;
        applRes.Closing_Code__c = 'Denied Service';
        applRes.Disposition__c = 'Other/Unknown Denied Service';
        update this.applRes;
        renderRejectReferralComponent = false;
        // ELC 2/18/2015 - now doing this through a workflow rule instead
        //sendRejectEmail();
        return null;    
        
    } 
    public pageReference doCancelRejectReferral() {
        applRes.referral_note__c = '';
        applRes.Rejected_Reason__c = '';
        renderRejectReferralComponent = false;
        return null;
    }
    public pageReference doCloseReferral() {
        renderCloseReferralComponent = true;
        return null;
    } 
    public pageReference doSaveCloseReferral() {
        
        applRes.status__c = 'Closed';
        applRes.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Closed').id;
        applRes.Closing_Code__c = 'None';       
        update this.applRes;
        renderCloseReferralComponent = false;
        return null;    
        
    } 
    public pageReference doCancelCloseReferral() {
        renderCloseReferralComponent = false;
        return null;
    }
    public PageReference doPendReferral() {
        renderPendReferralComponent = true;
        return null;
    }
    public pageReference doSavePendReferral() {
        
        //applRes.distribution__c = '';
        applRes.status__c = 'Applied';
        applRes.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c', 'E_Referral_Applied').id;
        update this.applRes;
        renderPendReferralComponent = false;
        return null;    
        
    } 
    public pageReference doCancelPendReferral() {
        renderPendReferralComponent = false;
        System.debug('In doCancelPendReferral - renderPendReferralComponent = '+renderPendReferralComponent);
        return null;
    }    
    public pageReference retrieveAppliedResource() {
        return null;
    }
    public Id getCcAdminId() {
        
        User u = UserUtils.retrieveUserByName(CC_ADMIN_NAME);
        return u.id;
    }

    /*
        Note:  Using a VF template to send the email.  It needs to be named CARPLS Connect Rejection.
        Changed this to be done via a workflow rule.
        
    public void sendRejectEmail() {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate et = [SELECT id from emailtemplate where name='CARPLS Connect Rejection']; 
        mail.setTemplateId(et.Id); 
        mail.setSaveAsActivity(false); 
        mail.setTargetObjectId(getCcAdminId());
        mail.setWhatId(this.applRes.id);
        // Use Organization Wide Address 
        for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
            if(owa.Address.contains('noreply')) {
                mail.setOrgWideEmailAddressId(owa.id); 
            }
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        
    }
    */
    public PageReference doDownloadDoc() {
        String url = '';
        url += '/sfc/servlet.shepherd/version/download/' + this.selectedId + '?asPdf=false';
        Pagereference pr = new Pagereference (url);
        String msg = 'File Download Initiated';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,msg));
        return pr;      
    }   
}