@isTest
public class getSubjectInfoTest {
	@TestSetup
    static void makeData(){
        Case cs = new Case();
        insert cs;
        
        Subject__c subject = new Subject__c(
                Title__c = 'Complaint about prepaid money card',
                Practice_Area__c = 'Public Benefits/Health',
                Problem_Category__c = 'SSDI',
                Problem_Code__c = 'Application/Eligibility',
                Status__c = 'Active',
                Type__c = 'Published',
                Litigation__c = 'Pre Litigation'
        );
        insert subject;
        
        Applied_Resource__c newAs=new Applied_Resource__c(Subject__c = subject.Id, Case__c=cs.Id,Type__c='Legal Referrals');
        insert newAs;
    }
    
    @isTest
    static void subjectInfoTest(){
        Applied_Resource__c appRes = [SELECT Id, Subject__c FROM Applied_Resource__c LIMIT 1];
        
        Test.startTest();
        	Applied_Resource__c subId = getSubjectInfo.subjectInfo(appRes.Id);
        Test.stopTest();
        
        system.assertEquals(appRes.Subject__c, subId.Subject__c);
    }
}