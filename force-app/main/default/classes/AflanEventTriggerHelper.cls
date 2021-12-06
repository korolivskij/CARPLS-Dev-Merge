public with sharing class AflanEventTriggerHelper {
    public static void updateCountyAddressFields(List<IL_AFLAN_Events__c> events){
        Set<String> counties = new Set<String>();
        Map<String,List<County_Address__c>> countyAddress= new Map<String,List<County_Address__c>>();
        for(IL_AFLAN_Events__c event : events){
            counties.add(event.County__c);
        }
        List<County_Address__c> caList = [SELECT Id,County__c,Street__c,City__c,State__c,Zip__c 
                                          FROM County_Address__c 
                                          WHERE County__c in :counties
                                          ORDER BY CreatedDate DESC];
        if(!caList.isEmpty()){
            for(County_Address__c ca : caList){
                if(!countyAddress.containsKey(ca.County__c)){
                    countyAddress.put(ca.County__c,new List<County_Address__c>());
                    countyAddress.get(ca.County__c).add(ca);
                } 
                else {
                    countyAddress.get(ca.County__c).add(ca);
                }
            }
            for(IL_AFLAN_Events__c event : events){
                if(countyAddress.get(event.County__c)[0] != null){
                    County_Address__c ca = countyAddress.get(event.County__c)[0];
                    event.Street__c = ca.Street__c;
                    event.City__c = ca.City__c;
                    event.State__c = ca.State__c;
                    event.Zip__c = ca.Zip__c;
                }
            }
        }
    }
}