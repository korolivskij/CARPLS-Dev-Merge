/****
** Servio Consulting, LLC.
** Alex Grinevich
** 1/6/2018
**
****/
@isTest
private class ctrlZipExt_Test {
    
    static   User 		uTstExecUser       { get; set; }
    static   Account	Acct			   { get; set; }  
    
    static 	List<Zip__c> zips { get; set; }  
    
    public static testMethod void executeTest() {
        
        coreExecution('', '', '', '');
    }
    
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
        
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
        
        Acct = TEST_TestUtils.createAcct('Legal Referral');  
        
        zips = new List<Zip__c>();
        
        Zip__c z1 = new Zip__c(name = '66666', City__c = 'Chicago', Geographic_Region__c = 'Illinois');
        Zip__c z2 = new Zip__c(name = '77777', City__c = 'Chicago', Geographic_Region__c = 'Cook County');
        
        zips.add(z1);
        zips.add(z2);
        
        insert zips;
    }    
    
    private static void test() {
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(zips);
        sc.setSelected(zips);
        
        ctrlZipExt ctr = new ctrlZipExt(sc);
        PageReference pr = ctr.DoBack();
        
        ctr.acczip = new Account_Zip_Junction__c(Account__c = Acct.Id);
        
        pr = ctr.CreateAccountZipJunctions();  
        
        Id accId = Acct.Id;
        
        Integer count = [select count() from Account_Zip_Junction__c where Account__c = :accId];
        
        System.assertEquals(2, count, 'Account_Zip_Junction__c');
        
    }
}