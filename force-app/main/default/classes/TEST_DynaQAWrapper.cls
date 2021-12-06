/**
 * Created by rnend on 11/2/2016.
 */
@IsTest
private class TEST_DynaQAWrapper {
    static testMethod void testBehavior() {
        Test.startTest();
       // new DynaQaWrapper();
        Consultation_Question__c q = new Consultation_Question__c();
        q.case_answer_field_name__c = 'Trump';
        q.Name__c = 'Clinton';
        q.question__C = 'Why is the country so fubared';
        insert q;
        DynaQaWrapper wrap = new DynaQaWrapper(q.id);
        wrap.getRequired();
        wrap.question = null;
        wrap.getRequired();

        Test.stopTest();
    }
}