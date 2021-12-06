public with sharing class ctrlCaseAttachments extends ctrlCarplesGeneric{

	
	public String						reRenderList			{ get; set; }
	public ctrlCaseDetail				ctrl					{ get; set; }
	 
	/*
	 * Transient otherwise ViewState Size limit will be exceeded 
	 * upon file upload. Damn you SFDC!
	 */
	public transient attachment			Attachment;
	
	public ctrlCaseAttachments() {
		super();
		attachment = new Attachment();
	}
	public Attachment getAttachment() {
		if(this.attachment == null) {
			this.attachment = new attachment();
		}
		return this.attachment;
	} 	
	public void setAttachment(Attachment a ) {
		this.attachment = a;
	}
	
	public pageReference doSaveAttachment() {		
		
		attachment.ParentId = ctrl.cse.id;
		
		try {
			insert Attachment;
			/*
		 	 * Refresh the parent controller vars.
		 	 */
			ctrl.refreshCaseAttachments();
			String msg = '';
			msg = 'Attachment: ' +  Attachment.name + ' uploaded successfully!';
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));  
			attachment = null;
		} catch ( DmlException ex ) {
			super.debugLog( ex.getMessage() );		
		}		
		return null;			
	} 

}