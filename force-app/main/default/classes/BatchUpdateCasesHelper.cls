/**
 * @File Name          : BatchUpdateCasesHelper.cls
 * @Description        : 
 * @Author             : apauk
 * @Group              : 
 * @Last Modified By   : apauk
 * @Last Modified On   : 2/13/2020, 5:17:05 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/13/2020   apauk     Initial Version
**/
public class BatchUpdateCasesHelper {
    public static void updateCases (List<Applied_Resource__c> scope){
        try{
            for(Applied_Resource__c aprs : scope){
                aprs.Dialer_Status__c = 'Ready';
            }
            update scope;
        }
        catch(Exception ex){
            String exceptionMessage = ex.getMessage();
            SendEmail(exceptionMessage);

    	}
    }
    public static void SendEmail(String ex){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //message.toAddresses = new String[] { 'aschwartz@carpls.org'};
            message.toAddresses = new String[] { 'aschwartz@carpls.org','mykhailo.kovalov@redtag.com.ua'};
			message.optOutPolicy = 'FILTER';
			message.subject = 'Error while updating record';
			message.plainTextBody = ex;
			Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        }
    
}