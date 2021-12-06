/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Note.. most of this stuff should already be covered but just in case test it again.
 * 
 */
@isTest(SeeAllData=false)   
public with sharing class TEST_SOQL_Utils {
    
    public static   User         uTstExecUser       { get; set; }
  
   
  /**
   * Executed by SFDC when running unit test code via GUI
   */
  public static testMethod void executeTest() {
    
    /* 
     *  Just pass blank parms for user now. This is a luxury that I wish we had but we may
     *  run out of time before we can test multiple users / roles / profiles via code.
     *  In the above scenario, a user will be created on the fly and is a system admin
     *  with no roles / permission sets applied.
     * 
     *  @TODO maybe pull testing user from custom setting.
     *  @TODO maybe create different users from different roles / profiles on the fly
     */
    coreExecution('', '', '', '');
  }
  /**
   * The core launch point for this test class.
   */
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
 
    /*
     *-- START THE actual TEST (Be ware of too many SOQL Queries / Gov Limits below!)---------------
     */  
    Test.startTest();
    
      System.runAs(uTstExecUser) {
          
        testAllUtils();

      }
        
    Test.stopTest();
    /*
     *-- STOP THE TEST ---------------------------------------------------------------------------------
     */
  }
	/**
	 *
	 */
    private static void testAllUtils() {
    	
    	String relName = 'Owner';
    	
    	List<RecordType> rts = SoqlUtils.getRTsBySobject('Account');
    	System.assert(rts!=null && !rts.isEmpty());   
    	
    	String soql = SoqlUtils.getAllFieldsSOQL('Account',false,'' );
    	System.assert(soql != null && soql != '');   
    	
    	String soql2 = SoqlUtils.getAllFieldsSOQL('Account',true,'' );
    	System.assert(!soql2.contains('createdby'));
    	
    	String soql3 = SoqlUtils.getAllFields('Account',false );
    	System.assert(soql3 != null && soql3 != '');   
    	
    	String soql4 = SoqlUtils.getAllFields('Account',true );
    	System.assert(!soql4.contains('createdby')); 
    	
		Set<String> excludeAccountFields = new Set<String>();
		excludeAccountFields.add('Website');		
	
    	String soql5 = SoqlUtils.getAllFields('Account',false,null );
    	System.assert(soql5 != null && soql5 != '');
    	
    	String soql6 = SoqlUtils.getAllFields('Account',false,excludeAccountFields );
    	System.assert(!soql6.contains('Website')); 

    	String soql7 = SoqlUtils.getAllFields('Account',true,excludeAccountFields );
    	System.assert(!soql7.contains('Website'));
    	System.assert(!soql7.contains('createdby')); 
    	
    	
    	String soql8 = SoqlUtils.getAllRelatedFields('User',true,relName );
    	//System.assert(soql8.contains(relName+'.UserName')); @TODO proper assert   	
    	String soql9 = SoqlUtils.getAllRelatedFields('User',false,relName );  	

    	
    	Set<Object> fields1 =  SoqlUtils.getAllFieldsSet('Account', false, null );
    	System.assert(fields1 !=null && !fields1.isEmpty());   
 
 		Set<Object> fields2 =  SoqlUtils.getAllFieldsSet('Account', true, null );
    	System.assert(fields2 !=null && !fields2.isEmpty());
    	System.assert(!fields2.contains('createdby'));    

 		Set<Object> fields3 =  SoqlUtils.getAllFieldsSet('Account', true, excludeAccountFields );
    	System.assert(fields3 !=null && !fields3.isEmpty());
    	System.assert(!fields3.contains('Website')); 
    	
 		Set<Object> fields4 =  SoqlUtils.getAllFieldsSet('Account', false, excludeAccountFields );
    	System.assert(fields4 !=null && !fields4.isEmpty());
    	System.assert(!fields4.contains('Website'));  
    	System.assert(!fields4.contains('createdby'));     
    	
    	Set<Object> fields5 =  SoqlUtils.getAllFieldsSet('Account', false );
    	System.assert(fields5 !=null && !fields5.isEmpty()); 
    	   	
    	Set<Object> fields6 =  SoqlUtils.getAllFieldsSet('Account', true );
    	System.assert(fields6 !=null && !fields6.isEmpty()); 
    	System.assert(!fields6.contains('createdby'));  
    	
    	
    	
    	
    	
    	Set<Object> fields7 =  SoqlUtils.getAllRelatedFieldsSet('User', false, relName );
    	System.assert(fields7 !=null && !fields7.isEmpty());    	
    	System.assert(fields7.contains(relName+'.Username'));    

    	Set<Object> fields8 =  SoqlUtils.getAllRelatedFieldsSet('User', true, relName );
    	System.assert(fields8 !=null && !fields8.isEmpty());
    	System.assert(fields8.contains(relName+'.Username'));
    	System.assert(!fields8.contains('createdby')); 	
    	
    	
    	Set<Object> fields9 = SoqlUtils.getAllRelatedFieldsSet('User',false, relName, excludeAccountFields);
    	System.assert(fields9 !=null && !fields9.isEmpty());
    	System.assert(fields9.contains(relName + '.Username'));
    	
    	Set<Object> fields10 = SoqlUtils.getAllRelatedFieldsSet('User',true, relName, excludeAccountFields);
    	System.assert(fields10 !=null && !fields10.isEmpty());
    	System.assert(fields10.contains(relName + '.Username'));    	
    	System.assert(!fields10.contains('createdby')); 	  

    	   
    }  

}