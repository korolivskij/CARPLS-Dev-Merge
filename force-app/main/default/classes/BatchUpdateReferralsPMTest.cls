@isTest
public class BatchUpdateReferralsPMTest {
@testSetup static void initialize() {
        
        Date today = Date.today();
		Referral__c referralTest = new Referral__c(Client_First_Name__c= 'TestReferral', Preferred_Call_Back_Date__c  = today, Preferred_Call_Back_Time__c  = 'PM_1_5');
        insert referralTest;
    }
    
    @isTest
    static void startBatchAttandanceCreateTest() {
        List<Referral__c> cls = [Select Id from Referral__c where Client_First_Name__c = 'TestReferral' limit 1];
        Test.startTest();
        BatchUpdateReferralsPM obj = new BatchUpdateReferralsPM();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }

}