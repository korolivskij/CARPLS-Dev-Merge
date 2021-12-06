/****
** Servio Consulting, LLC.
** Alex Grinevich
** 1/6/2018
**
****/
@isTest
private class ctrlAccountExt_Test {
    
     static   User         				uTstExecUser       { get; set; }
     static   Account					Acct			   { get; set; }   
     static   Eligible_Problem_Codes__c	newAcctPc		   { get; set; }
     static   Account					wrongRtAcct			   { get; set; }   
     static   Contact					newClient		   { get; set; } 
     static   Case						newCase			   { get; set; } 
     static   Subject__c				newSubject		   { get; set; } 
    
     static ApexPages.StandardController  stdController;
     static ctrlAccountExt accCtr;
    
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
            
            testClone();
        }
        
        Test.stopTest();
    }
    
    private static void buildTestData() {
        
        Acct = TEST_TestUtils.createAcct('Legal Referral');  
        
        wrongRtAcct = TEST_TestUtils.createAcct('Legal Referral', 'Organization');  
        
        newAcctPc = new Eligible_Problem_Codes__c();
        newAcctPc.Practice_Area__c = 'pa1';
        newAcctPc.Problem_Category__c = 'pcat1';
        newAcctPc.Problem_Code__c = 'pc1';
        newAcctPc.Account__c = Acct.id;
        insert newAcctPc;
  
        newSubject = new Subject__c();
        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'Ricks House';
        
        insert newSubject;
        
        Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
        asj.account__c = Acct.id;
        asj.subject__c = newSubject.id;
        insert asj;    	
        
        List<Zip__c> zs = new List<Zip__c>();
        Zip__c z1 = new Zip__c();
        z1.name = '66666';
        z1.City__c = 'Chicago';
        z1.Geographic_Region__c = 'Illinois';
        zs.add(z1);
        insert zs;
        
        List<Account_Zip_Junction__c> azjs = new List<Account_Zip_Junction__c>();
        
        for(Zip__c z : zs) {
            Account_Zip_Junction__c azj = new Account_Zip_Junction__c();
            azj.Account__c = Acct.id;
            azj.zip__c = z.id;
            azjs.adD(azj);    			
        }
        insert azjs;
        
    }    
    
    private static void testClone() {
        
        stdController = new ApexPages.StandardController(Acct);
        accCtr = new ctrlAccountExt(stdController);
        PageReference pr = accCtr.CloneAccountBack();
        pr = accCtr.CloneAccount();  
        
        String newAccId = pr.getUrl();
        
        System.debug('In Clone Test, URL = '+newAccId);        
        
        newAccId = newAccId.substring(1, 19);
        System.debug('In Clone Test, newAccId = '+newAccId);
        
        Id oldAccId = Acct.Id;
        
        Account acc = [select id, name from Account where id = :newAccId];
        
        System.assertEquals(Acct.Name, acc.Name, 'Acct.Name');
        
        Integer count = [select count() from Eligible_Problem_Codes__c where Account__c = :newAccId];
        Integer oldcount = [select count() from Eligible_Problem_Codes__c where Account__c = :oldAccId];
        
        System.assertEquals(oldcount, count, 'Eligible_Problem_Codes__C');
        
        count = [select count() from Account_Subject_Junction__c where Account__c = :newAccId];
        oldcount = [select count() from Account_Subject_Junction__c where Account__c = :oldAccId];
        
        System.assertEquals(oldcount, count, 'Account_Subject_Junction__c');
        
        count = [select count() from Account_Zip_Junction__c where Account__c = :newAccId];
        oldcount = [select count() from Account_Zip_Junction__c where Account__c = :oldAccId];
        
        System.assertEquals(oldcount, count, 'Account_Zip_Junction__c');
        
        
        ApexPages.StandardController contr2 = new ApexPages.StandardController(wrongRtAcct);
        ctrlAccountExt accCtr2 = new ctrlAccountExt(contr2);
        
        //try {
        PageReference pr2 = accCtr2.CloneAccount();
        //} catch(Exception e) {
        //   system.assertEquals(e.getMessage(), e.getMessage());
        //}
        
    }
    
}