@isTest
private class TEST_ARStatusUpdateController {
    private class MyException extends Exception {}
    
    static AppliedResourceStatusUpdateController testController = new AppliedResourceStatusUpdateController();
    
    static Applied_Resource__c resourceForValidConflict = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidConflict1 = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidConflict2 = new Applied_Resource__c();
    static Applied_Resource__c resourceForValidAccept = new Applied_Resource__c();
    static Applied_Resource__c resourceForinValidAccept = new Applied_Resource__c();
    static Applied_Resource__c resourceForValidReject = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidReject1 = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidReject2 = new Applied_Resource__c();
    static Applied_Resource__c resourceForSuperInvalidReject = new Applied_Resource__c();
    static Applied_Resource__c resourceForValidClose1 = new Applied_Resource__c();
    static Applied_Resource__c resourceForValidClose2 = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidClose1 = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidClose2 = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidClose3 = new Applied_Resource__c();
    static Applied_Resource__c resourceForInvalidClose4 = new Applied_Resource__c();
    
    
    @isTest static void isCarplsConnect() {
    
        AppliedResourceStatusUpdateController.isCarplsConnect();
                 
    }
    
    
    @isTest static void findRecord() {
    
        AppliedResourceStatusUpdateController.findRecord('a0f5C000002ci4YQAQ');
                 
    }
    
    @isTest static void dynamicPickListCoverage() {
    
        AppliedResourceStatusUpdateController.getNegotiatedSettlementPicklistValues();
                 
    }
    

    
    @isTest static void getInvalidRecordTest() {
        try { 
            AppliedResourceStatusUpdateController.getRecord('I am not a record Id!');
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Unable to find this record in the database.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest static void updateFromButtonConflictTest() {
        buildTestData();
        Test.startTest();
        AppliedResourceStatusUpdateController.updateFromButtonConflict(resourceForValidConflict.Id);
        resourceForValidConflict = AppliedResourceStatusUpdateController.getRecord(resourceForValidConflict.Id);
        System.assertEquals(resourceForValidConflict.Closing_Code__c, 'Denied Service');
        try {  
            AppliedResourceStatusUpdateController.updateFromButtonConflict(resourceForInvalidConflict1.Id);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        try { 
            AppliedResourceStatusUpdateController.updateFromButtonConflict(resourceForInvalidConflict2.Id);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
        
    @isTest static void updateFromButtonNoConflictTest() {
        buildTestData();
        Test.startTest();
        AppliedResourceStatusUpdateController.updateFromButtonNoConflict(resourceForValidConflict.Id);
        resourceForValidConflict = AppliedResourceStatusUpdateController.getRecord(resourceForValidConflict.Id);
        Id postConflictRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Post Conflict').getRecordTypeId();
        System.assertEquals(resourceForValidConflict.RecordTypeId, postConflictRecordTypeId);
        
        try { 
            AppliedResourceStatusUpdateController.updateFromButtonNoConflict(resourceForInvalidConflict1.Id);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        try { 
            
            AppliedResourceStatusUpdateController.updateFromButtonNoConflict(resourceForInvalidConflict2.Id);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
        
    @isTest static void updateFromButtonAcceptTest() {
        buildTestData();
        Test.startTest();
        AppliedResourceStatusUpdateController.updateFromButtonAccept(resourceForValidAccept.Id);
        resourceForValidAccept = AppliedResourceStatusUpdateController.getRecord(resourceForValidAccept.Id);
        System.assertEquals('Accepted', resourceForValidAccept.Status__c);
            
        
        try { 
            AppliedResourceStatusUpdateController.updateFromButtonAccept(resourceForInvalidAccept.Id);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
            
    }
        
    @isTest static void updateFromButtonRejectTest() {
        buildTestData();
        String validDisposition = 'Out of Service Area';
        String invalidDisposition = '--- Please Select ---';
        String superInvalidDisposition = 'crazy bones!';
        Test.startTest();
        AppliedResourceStatusUpdateController.updateFromButtonReject(resourceForValidReject.Id, validDisposition);
        resourceForValidReject = AppliedResourceStatusUpdateController.getRecord(resourceForValidReject.Id);
        System.assertEquals('Closed', resourceForValidReject.Status__c);
        System.assertEquals('Denied Service', resourceForValidReject.Closing_Code__c);
        
        try { 
            AppliedResourceStatusUpdateController.updateFromButtonReject(resourceForInvalidReject1.Id, validDisposition);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try { 
            AppliedResourceStatusUpdateController.updateFromButtonReject(resourceForInvalidReject2.Id, invalidDisposition);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Please select a disposition.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try { 
            AppliedResourceStatusUpdateController.updateFromButtonReject(resourceForSuperInvalidReject.Id, superInvalidDisposition);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('We were unable to update this record!') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
        
    @isTest static void updateFromButtonCloseTest() {
        buildTestData();
        String validClosingCode = 'Legal Service';
        String validDisposition = 'Brief_Service';
        String invalidDisposition = 'Denied Service';
        String validnegotiatedSettlement = 'Yes';
        
        Test.startTest();
        AppliedResourceStatusUpdateController.updateFromButtonClose(resourceForValidClose1.Id, validClosingCode, validDisposition, validnegotiatedSettlement);
        resourceForValidClose1 = AppliedResourceStatusUpdateController.getRecord(resourceForValidClose1.Id);
        System.assertEquals('Closed', resourceForValidClose1.Status__c);
        System.assertEquals(validClosingCode, resourceForValidClose1.Closing_Code__c);
        System.assertEquals(validDisposition, resourceForValidClose1.Disposition__c);
        
        AppliedResourceStatusUpdateController.updateFromButtonClose(resourceForValidClose2.Id, 'None', validnegotiatedSettlement, '');
        resourceForValidClose2 = AppliedResourceStatusUpdateController.getRecord(resourceForValidClose2.Id);
        System.assertEquals('Closed', resourceForValidClose2.Status__c);
        System.assertEquals(null, resourceForValidClose2.Closing_Code__c);
        System.assertEquals(null, resourceForValidClose2.Disposition__c);
        
        
        try {
            AppliedResourceStatusUpdateController.updateFromButtonClose(resourceForInvalidClose1.Id, validClosingCode, validDisposition, validnegotiatedSettlement);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Something seems off') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try {
            AppliedResourceStatusUpdateController.updateFromButtonClose(resourceForInvalidClose2.Id, '', validDisposition, validnegotiatedSettlement);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Please select a closing code.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try {
            AppliedResourceStatusUpdateController.updateFromButtonClose(resourceForInvalidClose3.Id, validClosingCode, '', validnegotiatedSettlement);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Please select a disposition.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try {
            AppliedResourceStatusUpdateController.updateFromButtonClose(resourceForInvalidClose4.Id, validClosingCode, invalidDisposition, validnegotiatedSettlement);
            throwMyException();
        } catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('We were unable to update this record!') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }
    
    static void buildTestData() {
        Id pendingRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Pending').getRecordTypeId();
        Id postConflictRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Post Conflict').getRecordTypeId();
        Id acceptedRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Accepted').getRecordTypeId();
        Id closedRecordTypeId = Schema.SObjectType.Applied_Resource__c.getRecordTypeInfosByName().get('E Referral Closed').getRecordTypeId();
        
        Account acct = new Account();
        acct.name = 'BOOOGIE MAN';
        acct.sub_type__c = 'Legal Aid';
        acct.Partner_Type__c = 'Military Service';
        //acct.Military_Service__c= true;
        acct.Community_Activated__c = true;
        insert acct;

        Contact acctContact = new Contact();
        acctContact.lastname = 'BOOGIE MAN CONTACT';
        acctContact.AccountId = acct.id;
        insert acctContact;
        
        Id p = [select id from profile where name='Referral Partner'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = acctContact.Id,Enable_Email_Notifications_for_Referrals__c = true,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        resourceForValidConflict.RecordTypeId = pendingRecordTypeId;
        resourceForValidConflict.Status__c = 'Applied';
        resourceForInvalidConflict1.RecordTypeId = postConflictRecordTypeId;
        resourceForInvalidConflict1.Status__c = 'Applied';
        resourceForInvalidConflict2.RecordTypeId = pendingRecordTypeId;
        resourceForInvalidConflict2.Status__c = 'Closed';
        
        resourceForValidAccept.RecordTypeId = postConflictRecordTypeId;
        resourceForValidAccept.Account__c = acct.Id;
        resourceForInvalidAccept.RecordTypeId = pendingRecordTypeId;
        
        resourceForValidReject.RecordTypeId = postConflictRecordTypeId;
        resourceForInvalidReject1.RecordTypeId = pendingRecordTypeId;
        resourceForInvalidReject2.RecordTypeId = postConflictRecordTypeId;
        resourceForSuperInvalidReject.RecordTypeId = postConflictRecordTypeId;
        
        resourceForValidClose1.RecordTypeId = acceptedRecordTypeId;
        resourceForValidClose2.RecordTypeId = acceptedRecordTypeId;
        resourceForInvalidClose1.RecordTypeId = pendingRecordTypeId;
        resourceForInvalidClose2.RecordTypeId = acceptedRecordTypeId;
        resourceForInvalidClose3.RecordTypeId = acceptedRecordTypeId;
        resourceForInvalidClose4.RecordTypeId = acceptedRecordTypeId;
        
        List<Applied_Resource__c> resourcesToInsert = new List<Applied_Resource__c>();
        resourcesToInsert.add(resourceForValidConflict);
        resourcesToInsert.add(resourceForInvalidConflict1);
        resourcesToInsert.add(resourceForInvalidConflict2);
        resourcesToInsert.add(resourceForValidAccept);
        resourcesToInsert.add(resourceForInvalidAccept);
        resourcesToInsert.add(resourceForValidReject);
        resourcesToInsert.add(resourceForInvalidReject1);
        resourcesToInsert.add(resourceForInvalidReject2);
        resourcesToInsert.add(resourceForSuperInvalidReject);
        resourcesToInsert.add(resourceForValidClose1);
        resourcesToInsert.add(resourceForValidClose2);
        resourcesToInsert.add(resourceForInvalidClose1);
        resourcesToInsert.add(resourceForInvalidClose2);
        resourcesToInsert.add(resourceForInvalidClose3);
        resourcesToInsert.add(resourceForInvalidClose4);
        
        insert resourcesToInsert;
    }
    
    private static void throwMyException() {
        throw new MyException('An exception should have been thrown by the trigger but was not.');
    }

}