public with sharing class ctrlApplResEdit {

	public Applied_Resource__c			applRes		{ get; set; }
	Public String						roaLabel	{ get; set; }
	Public String						ratingLabel { get; set; }
	Public String						selectedDist {get; set; }
	Public List<SelectOption>			distOpts	{ get; set; }
	
    public ctrlApplResEdit(ApexPages.StandardController stdController) {          
        this.applRes            = (Applied_Resource__c)stdController.getRecord(); 
        AppliedResourceUtils arUtils = new AppliedResourceUtils(); 
        this.applRes			= arUtils.retrieveAppliedResource(applRes.id);
    }
	public void doInitPage() {
		if (this.ApplRes.type__c == 'Legal Referrals' || this.ApplRes.type__c == 'Social Referrals') {
			roaLabel = 'Did the referral accept your case?';
			ratingLabel = 'On a scale of 1 to 5 how helpful was the referral in resolving your case?';
		} else if (this.applRes.type__c == 'DDP') {
			roaLabel = 'Did you follow through on the self-help packet?';
			ratingLabel = 'On a scale of 1 to 5, how helpful was the self-help packet in resolving your case?';
		} else {
			roaLabel = 'You have reached this page in error';
			ratingLabel = 'Please close the tab to return to the case';
		}
		distOpts = getDistributionValues(this.applRes.type__c);
	}
	private List<SelectOption> getDistributionValues(String pType) {
		List<SelectOption> options = UiUtils.retrievePlValues(new Applied_Resource__c(), 'Distribution__c');
		List<SelectOption> retOptions = new List<SelectOption>();
		for (SelectOption so: options) {
			if (pType == 'DDP') {
				if (so.getValue() == 'Email' || so.getValue() == 'Mail' || so.getValue() == 'Local Printer') {
					retOptions.add(so);
				}
			} else {
				if (so.getValue() == 'Manual' || so.getValue() == 'Auto') {
					retOptions.add(so);
				}
			}
		}
		return retOptions;
	}
	public void doSaveAr() {
		try {
			applRes.Distribution__c = selectedDist;
			update applRes;
		} catch(Exception e) {
			System.debug('Error updating applied resource: '+e);
		}

	}
	public void doCancelAr() {
		
	}
}