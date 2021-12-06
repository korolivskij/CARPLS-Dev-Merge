global class AflanCaseCreateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'SELECT Id,CreatedDate,AFLAN_Case_Created__c, Case__r.Contact.County__c,Case__r.Contact.MailingPostalCode,Case__r.Practice_Area__c,Case__r.Contact.Gender__c,Case__r.Contact.Military_Service__c '+
            'FROM Consultation__c '+
            'WHERE Project__c = \'IL-AFLAN Hotline\' AND AFLAN_Case_Created__c = FALSE'
            );
    }
    global void execute(Database.BatchableContext bc, List<Consultation__c> scope){
        List<AFLAN_Case__c> casesToInsert = new List<AFLAN_Case__c>();
        for(Consultation__c item : scope){
            AFLAN_Case__c newCase = new AFLAN_Case__c();
            newCase.Date__c = Date.valueOf(item.CreatedDate);
            newCase.County__C = item.Case__r.Contact.County__c;
            newCase.Zip__c = item.Case__r.Contact.MailingPostalCode;
            newCase.Practice_Area__c = item.Case__r.Practice_Area__c;
            newCase.Gender__c = item.Case__r.Contact.Gender__c;
            newCase.Military_Service__c = item.Case__r.Contact.Military_Service__c;
            casesToInsert.add(newCase);
            }
        insert casesToInsert;
        for(Consultation__c cons : scope){
           cons.AFLAN_Case_Created__c = true;
        }
        update scope;
    }
    global void finish(Database.BatchableContext bc){
        
    }
}