public class ctrlReferralExt {

    private final Referral__c ref;
    
    public ctrlReferralExt(ApexPages.StandardController stdController) {
        
        this.ref = (Referral__c)stdController.getRecord();
    }
    
    public PageReference doSave() {
        this.ref.Public_Entry_Source__c = 'Legal Aid Chicago (formerly LAF) - Central Intake II.';
        insert this.ref;
        PageReference pageRef = new PageReference('https://carpls.force.com/CarplsConnect/s/new-referral');
        pageRef.setRedirect(true);     
        return pageRef;
    }
}