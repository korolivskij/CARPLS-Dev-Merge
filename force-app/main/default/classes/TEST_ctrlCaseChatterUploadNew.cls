/**
 * Created by rnend on 11/6/2016.
 */

@IsTest
private class TEST_ctrlCaseChatterUploadNew {
    static testMethod void testBehavior() {



        Contact newClient = TEST_TestUtils.createContact('Client');
        newClient.email = 'support@provisiopartners.com';
        Case newCase = TEST_TestUtils.createFullClientPartyCase(newClient,'Closed');
        newCase.contactid = newClient.id;
        update newCase;

        ctrlCase ctrlCase = new ctrlCase(new ApexPages.StandardController(newCase));
        Blob fileContent = Blob.valueOf('Unit Test Document Body');
        ContentVersion cv = new ContentVersion();
        cv.Case__c = newCase.id;
        cv.versionData = fileContent;
        cv.title = 'UNIT TEST TITLE';
        cv.Description = 'Blah Unit Test CV DESC';
        cv.Custom_Type__c ='Client Document';
        cv.PathOnClient = '/test';
        List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'User Attached Documents'];
        //cv.firstPublishLocationId = CWList.get(0).Id;
        //insert cv;

        TEST.startTest();
        ctrlCaseChatterUploadNew ctrl = new ctrlCaseChatterUploadNew();
        ctrl.ctrl = ctrlCase;
        ctrl.setContentVersion(cv);
        ctrl.getContentVersion();
        ctrl.setFeedItem(new FeedItem());
        ctrl.getFeedItem();
        ctrl.getCvCustomTypeOptions();

        ctrl.fileContent = fileContent;
        ctrl.doSaveDoc();




        TEST.stopTest();


    }
}