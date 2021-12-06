/** 
**  Servio Consulting, LLC.
**	Alexander Grinevich
**	11/02/2017
**/
@isTest(SeeAllData=false)
public class trgAppliedResourceAI_TEST {
    
    public static   User         			uTstExecUser       	{ get; set; }
    public static   Contact	 				newClient			{ get; set; }
    public static   List<Contact>           newParties			{ get; set; }
    public static   Case					newCase				{ get; set; }
    
    private static Applied_Resource__c ar{ get; set; }	
    
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
        
        //-- Prepare data outside of starttest if possible.
        buildTestData(); 
        /*
        *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
        */  
        Test.startTest();
        
        System.runAs(uTstExecUser) {
            
            testAddAppliedResource();
            
            //Applied_Resource__c a = [select Case_Parties__c from Applied_Resource__c where id = :ar.Id];
            //System.debug(a.Case_Parties__c);
            
            List<Referral_Party__c> rps = [SELECT ID, Party__c FROM Referral_Party__c WHERE Referral__c = :ar.Id];
            
            System.assertEquals(3, rps.size());
            
        }
        
        Test.stopTest();
    }
    
    static void testAddAppliedResource()
    {
        ar = new Applied_Resource__c(Type__c = 'Legal Referrals', Case__c = newCase.Id);
        
        insert ar;
    }
    
    private static void buildTestData() {    
        newCase = new Case(subject='Test Case',project__c='TEST PROJECT A',Status = 'Open', Origin='TEST Origin', description = ' TEST DESC');
        insert newCase;
        
        newClient = new Contact(lastname='TEST CLIENT LAST', category__c = 'Client', Birthdate = date.today(), Phone ='12345');
        insert newClient;
        
        List<Contact> parties = new List<Contact>();
        Contact p1 = new Contact(lastname='TEST PARTY LAST1', category__c = 'Party', Birthdate = date.today(), Phone ='12345');
        parties.add(p1);
        Contact p2 = new Contact(lastname='TEST PARTY LAST2', category__c = 'Party', Birthdate = date.today(), Phone ='12345');
        parties.add(p2);
        
        insert parties;
        
        List<Case_Party__c> cps = new List<Case_Party__c>();
        
        Case_Party__C cp = new Case_Party__c();
        cp.Type__c = 'Client';
        cp.contact__C = newClient.id;
        cp.case__C = newCase.id;
        cp.Primacy__C = 'Primary';
        
        cps.add(cp);
        
        for(Contact p : parties) {
            Case_Party__C cp1 = new Case_Party__c();
            cp1.Type__c = 'Adverse Party';
            cp1.contact__c = p.id;
            cp1.case__C = newCase.id;
            cps.add(cp1);
        }	
        
        Case_Party__C cp3 = new Case_Party__c();
        cp3.Type__c = 'Interested Party';
        cp3.contact__c = p1.id;
        cp3.case__C = newCase.id;
        cps.add(cp3);
        
        
         Case_Party__C cp4 = new Case_Party__c();
        cp4.Type__c = 'Adverse Party';
        cp4.contact__c = p1.id;
        cp4.case__C = newCase.id;
        cps.add(cp4);
                
        insert cps;
    } 
}