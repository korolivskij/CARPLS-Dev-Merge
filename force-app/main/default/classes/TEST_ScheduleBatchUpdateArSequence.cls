@istest
public class TEST_ScheduleBatchUpdateArSequence {
    public static   User         			newUser	       		{ get; set; }
    public static   Case					newCase				{ get; set; }
    public static   Consultation__c	 		newService			{ get; set; }
    public static   Consultation__c         newConsultation     { get; set; }
    public static   Loop__DDP__c            newDDP              { get; set; }
    public static   Account                 newAccount          { get; set; }
    public static	Subject__c				newSubject			{ get; set; }
    public static	Applied_Resource__c		newArDdp			{ get; set; }
    public static   Applied_Resource__c     newArFAQ            { get; set; }
    public static	Id						pId					{ get; set;	}


    @testSetup static void setup() {

        pId = UserInfo.getProfileId();

        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin', description = ' TEST DESC');
        insert newCase;

        newService = new Consultation__c(Case__c = newCase.id);
        insert newService;

        newUser = new User(username='testcr@carpls.org',email='testcr@carpls.org',alias='test',
                CommunityNickname='testcr',TimeZoneSidKey='America/Chicago',LocaleSidKey='en_Us',
                EmailEncodingKey='ISO-8859-1',ProfileId=pId,LanguageLocaleKey='en_US',
                lastname = 'TestUser');
        insert newUser;

        /**
         * Build new case, contact and child services and add to static var.. requery after adding services.
         */
        newSubject = new Subject__c(title__c='TEST SUBJECT');
        insert newSubject;
        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin');
        insert newCase;
        newConsultation = new Consultation__c(case__c=newCase.id);
        insert newConsultation;
        newAccount = new Account(name='TEST ACCOUNT',CARPLS_Connect__c = true);
        insert newAccount;
        newDDP = new Loop__DDP__c();
        insert newDDP;
        newArDDP = new Applied_Resource__c(case__c=newCase.id,account__c=newAccount.id,consultation__c=newConsultation.id,
                distribution__c='Applied');
        newArDDP.type__c = 'DDP';
        insert newArDDP;
        newArFAQ  = new Applied_Resource__c(case__c = newCase.id, consultation__c=newConsultation.id, type__c='FAQ',subject__c=newSubject.id);
        newArFAQ.title__c = 'faq1';
        insert newArFAQ;
        insert new Applied_Resource__c(case__c = newCase.id, consultation__c=newConsultation.id, type__c='FAQ',subject__c=newSubject.id, title__c='faq2');

        List<Applied_Resource__c> testArs = [select id, case_sequence__c, case__c from applied_resource__c];
        system.debug('working with ars='+testArs);
    }

    static testMethod void fireBatchUpdateArSequence_Scheduler() {

        Test.startTest();

        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 2);
        String ss = String.valueOf(Datetime.now().second());

        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

        ScheduleBatchUpdateArSequence s = new ScheduleBatchUpdateArSequence();
        System.schedule('AR seq update ..Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);


        Test.stopTest();
        //@tODO asserts
//        List<Applied_Resource__c> arsUpdated = [select id, case__c, type__c,title__c,case_sequence__c from applied_resource__c];
//        for(Applied_Resource__c ar : arsUpdated) {
//            if(ar.type__c == 'DDP') {
//                system.assert(ar.case_sequence__c == 1);
//            } else {
//                if(ar.title__c == 'faq1') {
//                    system.assert(ar.case_sequence__c == 1);
//                } else {
//                    system.assert(ar.case_sequence__c == 2);
//                }
//            }
//        }

    }
}