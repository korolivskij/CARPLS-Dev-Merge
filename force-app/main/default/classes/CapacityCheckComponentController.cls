/** @description 
 * Class is quering Account by Id, received from "Carplsv20Settings" Custom Setting
 * Based on "Intake Status" picklist field, returns boolean to show form on Home Page
 * Changed By Sergii at 11/04/2020
*/
 public without sharing class CapacityCheckComponentController {
    @AuraEnabled
    public static Boolean checkCapacity(){

        String accountId = Carplsv20Settings__c.getInstance(UserInfo.getUserId()).CARPLS_Account_ID__c;
        Boolean booleanToReturn = false;
        List<Account> accounts = [SELECT Id, Intake_Status__c FROM Account WHERE Id = :accountId];
        
        if ( !accounts.isEmpty() ) {
            String intakeStatus = accounts.get(0).Intake_Status__c;
            if ( intakeStatus == 'Open' || intakeStatus == 'Limited' ) {
                booleanToReturn = true;
            } else if ( intakeStatus == 'Closed' ) {
                booleanToReturn = false;
            }
        }

        return booleanToReturn;
    }
}