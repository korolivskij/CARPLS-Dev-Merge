/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest
private class TEST_BatchUpdateContactTempRec {

     static testMethod void fireBatchUpdateContactTempRecTest() {
      
      List<Contact> cts = new List<Contact>();
      
      for(Integer i = 0 ; i < 199 ; i++) {
        Contact c = new Contact();
        c.LastName = 'TEST contact'+i;
        cts.add(c);
      }
      insert cts;
      
        Test.startTest();
          
          String soql = '';
          List<String> emailAddys = new List<String>();
          emailAddys.add('ericacox10@gmail.com');
          Boolean bCommitTrans = true;
          
          /**
           * Query All Records 
           */
          soql += '  SELECT   id, temp_record__c ';
          soql += '  from   Contact ';
          soql += '  where temp_record__c = true ';
          if(Test.isRunningTest()) {
            soql += ' LIMIT 199 ';
          }
    
      BatchUpdateContactTempRecord  batchUpd = 
        new BatchUpdateContactTempRecord(  soql,emailAddys,
                              bCommitTrans);
      id batchId = Database.executeBatch(batchUpd); 
      System.debug(logginglevel.info,'\n=========== Executing batch id='+batchId);
               
        Test.stopTest();    
    }
}