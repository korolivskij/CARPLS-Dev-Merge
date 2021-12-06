public with sharing class IncomeDetailWrapper {

	public Income_Detail__c	ind			{ get; set; }
	public Integer			tabindex	{ get; set; }
	
	public IncomeDetailWrapper(Income_Detail__c aInd, Integer aTi) {
		this.ind = aInd;
		this.tabindex = aTi;
	}
}