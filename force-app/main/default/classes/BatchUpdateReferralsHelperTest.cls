@isTest
public class BatchUpdateReferralsHelperTest {
    @testSetup static void testSetup(){
        Date today = Date.today();
		Referral__c referralTest = new Referral__c(Client_First_Name__c= 'TestReferral', Preferred_Call_Back_Date__c  = today, Preferred_Call_Back_Time__c  = 'AM_9_12');
        insert referralTest;
    }
    @isTest static void updateReferrals(){
        String expected = 'Ready';
        List<Referral__c> referrals = [SELECT Dialer_Status__c FROM Referral__c WHERE Client_First_Name__c ='TestReferral' LIMIT 1];
        BatchUpdateReferralsHelper.updateReferrals(referrals);
        System.assertEquals(expected, referrals.get(0).Dialer_Status__c);
    }
    @isTest static void sendEmailTest(){
        String expected = 'Ready';
        List<Referral__c> referrals = [SELECT Dialer_Status__c FROM Referral__c WHERE Client_First_Name__c ='TestReferral' LIMIT 1];
        BatchUpdateReferralsHelper.updateReferrals(referrals);
        {
        	Test.StartTest();
        	BatchUpdateReferralsHelper.SendEmail('Test');
        	Integer invocations = Limits.getEmailInvocations();
        	Test.stopTest();
 
        	System.assertEquals(1, invocations, 'An email has not been sent');
    }
    }
}