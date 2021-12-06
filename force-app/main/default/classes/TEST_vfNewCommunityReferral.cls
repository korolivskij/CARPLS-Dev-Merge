/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * @TODO Asserts.. and.. toggle case / service status correctly.
 *
 */
@isTest(SeeAllData=false)
public class TEST_vfNewCommunityReferral {
    public static   PageReference       prCommRef			   	{ get; set; }
    public static   Referral__c			ref						{ get; set; }
    public static	ctrlReferralExt		ctrlRef			{ get; set; }
    
    public static testMethod void executeTest() {
        prCommRef = Page.vfNewCommunityReferral;
        Test.startTest();
        
        	ref = new Referral__c(Client_First_Name__c = 'Test', Client_Last_Name__C = 'TEST');
        	ctrlRef = new ctrlReferralExt(new ApexPages.StandardController(ref));
        	ctrlRef.doSave();
        
                
        Test.stopTest();
    }
}