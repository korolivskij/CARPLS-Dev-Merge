public with sharing class ctrlSubjectArchive extends ctrlCarplesGeneric {
	
	public	Id				subjId				{ get; set; }
	public	Subject__c		subj 				{ get; set; }
	public	String			archivePracBrief	{ get; set; }
	public	String			archiveResBrief		{ get; set; }
	public	String			archiveSoln			{ get; set; }
	
	public ctrlSubjectArchive() {
		super();
		this.subjId = ApexPages.currentPage().getParameters().get('Id');
		this.archiveContent();
	}
	public ctrlSubjectArchive(ApexPages.StandardController stdController) {
		super();
		this.subj = (Subject__c)stdController.getRecord();
		this.subjId = this.subj.Id;
		this.archiveContent();
	}
	public void archiveContent() {
		this.subj = SubjectUtils.retrieveSubject(subjId);
		this.archivePracBrief = this.subj.practice_brief__c;
		this.archiveResBrief = this.subj.resource_brief__c;
		this.archiveSoln = this.subj.solutions__c;
	}
	public PageReference doSaveNewVersion() {
		this.subj.Archive_Practice_Brief__c = archivePracBrief;
		this.subj.Archive_Resource_Brief__c = archiveResBrief;
		this.subj.Archive_Solutions__c = archiveSoln;
		this.subj.version_date__c = date.today();
		this.subj.versioning_user__c = UserInfo.getUserId();
		try {
			update this.subj;
		} catch(Exception e) {
			system.debug('Error in subject update '+e);
		}
		return null;
	}
	
	public PageReference doCancelNewVersion() {
		return null;
	}
}