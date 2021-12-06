@isTest
/* Changed By Sergii at 11/04/2020 */
public class CapacityCheckComponentControllerTest {
    @isTest static void checkCapacityTest() {
        Account acc = new Account(
            Name = 'test',
            Intake_Status__c = 'Open'
        );
        insert acc;

        Carplsv20Settings__c setting = new Carplsv20Settings__c();
        setting.Name = 'Test Setting';
        setting.CARPLS_Account_ID__c = acc.Id;
        insert setting;

        Boolean capacityBoolean = CapacityCheckComponentController.checkCapacity();
        System.assertEquals(true, capacityBoolean);

        acc.Intake_Status__c = 'Closed';
        update acc;
        Boolean capacityBooleanUpdated = CapacityCheckComponentController.checkCapacity();
        System.assertEquals(false, capacityBooleanUpdated);
    }
}