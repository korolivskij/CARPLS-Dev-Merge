/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest(SeeAllData=false)

private class TEST_BatchUpdate {

    static testMethod void fireBatchUpdateTest() {
      
      List<Account> accts = new List<Account>();
      
      for(Integer i = 0 ; i < 199 ; i++) {
        Account a = new Account();
        a.Name = 'TEST acct'+i;
        accts.add(a);
      }
      insert accts;
      
        Test.startTest();
          
          String soql = '';
          List<String> emailAddys = new List<String>();
          emailAddys.add('rnendza@gmail.com');
          Boolean bCommitTrans = true;
          
          /**
           * Query All Records 
           */
          soql += '  SELECT   id ';
          soql += '  from   Account ';
          if(Test.isRunningTest()) {
            soql += ' LIMIT 199 ';
          }
    
      BatchUpdate  batchUpd = 
        new BatchUpdate(  soql,emailAddys,
                              bCommitTrans);
      id batchId = Database.executeBatch(batchUpd); 
      System.debug(logginglevel.info,'\n=========== Executing batch id='+batchId);
               
        Test.stopTest();    
    }
}