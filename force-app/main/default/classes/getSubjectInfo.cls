public class getSubjectInfo {
	@AuraEnabled
    public static Applied_Resource__c subjectInfo(Id appResId){
        Applied_Resource__c appRes = [SELECT Id, Subject__r.Resource_Brief__c, Subject__r.Practice_Brief__c, Subject__r.Solutions__c FROM Applied_Resource__c WHERE Id = :appResId LIMIT 1];
        return appRes;
    }
}