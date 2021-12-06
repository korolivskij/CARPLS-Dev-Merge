/**
 * @File Name          : BatchUpdateCases.cls
 * @Description        : 
 * @Author             : apauk
 * @Group              : 
 * @Last Modified By   : apauk
 * @Last Modified On   : 2/13/2020, 5:16:26 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/13/2020   apauk     Initial Version
**/
global class BatchUpdateCases implements Database.Batchable<sObject>{

	global Database.QueryLocator start(Database.BatchableContext BC) {

        
        Date d = System.today();
        Date dd = d.addDays(1);
        
        Datetime dt = (DateTime)d;
        String dayOfWeek = dt.format('u');
        
        Datetime selectedDate;
        system.debug('is leap year->> '+Date.isLeapYear(date.today().year()));
        if( dayOfWeek == '7'){
            selectedDate = d.addDays(-5);
            system.debug('TEST--->This is Monday; '+dayOfWeek);
            system.debug('selected date->'+selectedDate);
            
        }else{
                selectedDate = d.addDays(-3);
                system.debug('this is not monday for leap and not leap year--->'+dayOfWeek);
                system.debug('selected date->'+selectedDate);
        }
        

        String pickListValue = 'Legal Referrals';

        String classQuery = 'SELECT Id,Dialer_Status__c  FROM Applied_Resource__c WHERE is_electronic_referral__c = false AND Type__c = :pickListValue AND createddate <= :selectedDate ';
         
        return Database.getQueryLocator(classQuery);
        
	}

	global void execute(Database.BatchableContext BC, List<Applied_Resource__c> scope) {
        
		BatchUpdateCasesHelper.updateCases(scope);
        system.debug('Batch scope->'+scope);
	}

	global void finish(Database.BatchableContext BC) {}

}