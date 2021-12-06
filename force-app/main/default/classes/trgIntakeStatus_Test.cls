/****
** Servio Consulting, LLC.
** Alex Grinevich
** 1/7/2018
**
****/
@isTest
private class trgIntakeStatus_Test {
    
    static   User         				uTstExecUser       { get; set; }
    static   Account					Acct			   { get; set; }   
    
    public static testMethod void executeTest() {
        
        coreExecution('', '', '', '');
    }
    
    static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
        
        Datetime   dtTstStart        = Datetime.now();
        //-- Get testing user ---
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);   
        buildTestData(); 
        
        Test.startTest();
        
        System.runAs(uTstExecUser) {      	
            
            test();
        }
        Test.stopTest();
    }
    
    private static void buildTestData() {
        
        Acct = TEST_TestUtils.createAcct('Legal Referral');  // acc + pc 
        
        Eligible_Problem_Codes__c pc1 = new Eligible_Problem_Codes__c();
        pc1.Practice_Area__c = 'pa1';
        pc1.Problem_Category__c = 'pcat1';
        pc1.Problem_Code__c = 'pc1';
        pc1.Account__c = Acct.id;
        
        insert pc1;
    }    
    
    private static void test() {
        
        List<Eligible_Problem_Codes__c> AcctPcs = [SELECT Problem_Code_Closed__c, Account__c From Eligible_Problem_Codes__c WHERE Account__c = :Acct.Id];
        
        assert(null);
        
        System.debug('test open:');
        AcctPcs[0].Problem_Code_Closed__c = false;
        update AcctPcs;
        assert('Open');
        
        System.debug('test limited:');
        AcctPcs[0].Problem_Code_Closed__c = true;
        update AcctPcs;
        assert('Limited');
        
        System.debug('test closed:');
        AcctPcs[1].Problem_Code_Closed__c = true;
        update AcctPcs;
        assert('Closed');
    }
    
    static void assert(String status)
    {
        Account acc = [SELECT Intake_Status__c FROM Account WHERE Id = :Acct.Id];
        System.assertEquals(status, acc.Intake_Status__c);
    }
}