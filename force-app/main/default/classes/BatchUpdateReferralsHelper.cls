//**
// Author: Ihor Onyshchenko
// Date: November 4, 2019
// Description: This is a Batch Update Referrals Helper that updates Referrals Status.
//
// This code is the property of Provisio Partners and copy or reuse is prohibited.
// Copyright @2018 Provisio Partners Illinois Ltd. All Rights Reserved.
// support@provisiopartners.org
//**

public class BatchUpdateReferralsHelper {
    public static void updateReferrals (List<Referral__c> scope){
        try{
            for(Referral__c referral: scope){
                referral.Dialer_Status__c = 'Ready';
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
			message.toAddresses = new String[] { 'aschwartz@carpls.org'};
			message.optOutPolicy = 'FILTER';
			message.subject = 'Error while updating record';
			message.plainTextBody = ex;
			Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        }
    
}