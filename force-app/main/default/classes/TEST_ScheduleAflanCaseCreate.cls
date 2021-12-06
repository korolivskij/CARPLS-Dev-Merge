@isTest
private class TEST_ScheduleAflanCaseCreate {
    @TestSetup
    static void makeData(){
        Contact con = new Contact(FirstName = 'Test',LastName = 'Contact');
        insert con;
        Case cse = new Case(ContactId = con.Id);
        insert cse;
        Consultation__c cons = new Consultation__c(Case__c = cse.Id,Project__c = 'IL-AFLAN Hotline');
        insert cons;
        
    }
    @isTest
    static void testSchedulable(){
     Test.startTest();
        system.schedule('test schedule', '0 0 0 * * ?',new ScheduleAflanCaseCreate());
     Test.stopTest();
    }
}