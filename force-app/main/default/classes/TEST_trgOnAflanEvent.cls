@isTest
private class TEST_trgOnAflanEvent {
    @isTest
    static void testTriggerAndHelper(){
        County_Address__c ca = new County_Address__c(County__c = 'Cook',
                                                     Street__c = 'CookStreet',
                                                     City__c = 'CookCity',
                                                     State__c = 'CookState',
                                                     Zip__c = 'CookZip');
        County_Address__c ca2 = new County_Address__c(County__c = 'Adams',
                                                     Street__c = 'AdamsStreet',
                                                     City__c = 'AdamsCity',
                                                     State__c = 'AdamsState',
                                                     Zip__c = 'AdamsZip');
        insert ca;
        insert ca2;
        IL_AFLAN_Events__c event = new IL_AFLAN_Events__c (County__c = 'Cook');
        insert event;
        event.County__c = 'Adams';
        update event;

    }
}