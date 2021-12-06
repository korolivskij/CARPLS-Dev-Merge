public class PickListController {
    
    @AuraEnabled        
	public static List<String> getPickListValuesIntoList(String objectType, String selectedField, String parentValue){
    	List<String> pickListValuesList = new List<String>();
        picklistValuesList.add('--- Please Select ---');
    	Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
    	Schema.DescribeSObjectResult res = convertToObj.getDescribe();
    	Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    	for( Schema.PicklistEntry pickListVal : ple){
        	pickListValuesList.add(pickListVal.getLabel());
    	}     
    	return pickListValuesList;
	}
}