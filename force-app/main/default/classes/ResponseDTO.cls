public with sharing class ResponseDTO {

	@AuraEnabled public Boolean isSuccess { get; set; }
	@AuraEnabled public String message { get; set; }
	@AuraEnabled public String statusCode {get;set;}
	@AuraEnabled public String severity { get; set; }
	@AuraEnabled public String title { get; set; }
	@AuraEnabled public String technicalMsg {get;set;}
	@AuraEnabled public String mode {get;set;} /*insert or edit*/
	@AuraEnabled public Map<Object, Object> values { get; set; }
	@AuraEnabled public Map<Object, List<SObject>> valuesSobjList {get;set;}

	public ResponseDTO() {
		initObj();
	}
	public ResponseDto(Boolean isSuccess, String msg, String mode) {
		this.mode = mode;
		this.isSuccess = isSuccess;
		this.message = msg;
		this.values = new Map<Object, Object>();
		this.valuesSobjList = new Map<Object, List<SObject>>();
		this.severity = '';
		this.title = '';
		this.statusCode = '';
		this.technicalMsg = '';
	}
	public ResponseDto(Boolean isSuccess, String msg){
		this.mode = 'insert';
		this.isSuccess = isSuccess;
		this.message = msg;
		this.values = new Map<Object, Object>();
		this.valuesSobjList = new Map<Object, List<SObject>>();
		this.severity = '';
		this.title = '';
		this.statusCode = '';
		this.technicalMsg = '';
	}
	private void initObj() {
		this.isSuccess = false;
		this.message = '';
		this.values = new Map<Object, Object>();
		this.valuesSobjList = new Map<Object, List<SObject>>();
		this.severity = '';
		this.title = '';
		this.statusCode = '';
		this.technicalMsg = '';
	}

}