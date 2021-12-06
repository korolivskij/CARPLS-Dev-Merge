public without sharing class LandbotFeedbackFormController {
    public static void sendEmailWithLinkToFeedback(Landbot_Chat_Init__c landbotChatRecord){
/*
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { landbotChatRecord.User_Email__c };
            message.optOutPolicy = 'FILTER';
            message.subject = 'CARPLS Help Feedback';
            message.setHtmlBody('<p>Thank you for using our ChatBot! Please, leave us a feedback about provided help.</p><p><a href="https://uat2020-carpls.cs90.force.com/employ/s/landbot-feedback?rec='+ landbotChatRecord.Id +'">Link to the form</a></p><p><a target="_blank" href="https://carpls.force.com/employ/s/solution/'+landbotChatRecord.Solution_Record__c  +'/">Link to the solution record</a></p>');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
*/    
    }
    @AuraEnabled
    public static void updateLandbotChatRecordWithFeedback(Id idOfLandbotChatRecord, String feedbackText, String rate){
        List<Landbot_Chat_Init__c> listOfLandbotChatRecords = [SELECT Id FROM Landbot_Chat_Init__c WHERE Id=: idOfLandbotChatRecord];
        List<Landbot_Chat_Init__c> listOfLandbotChatRecordsToUpdate = new List<Landbot_Chat_Init__c>();



        for(Landbot_Chat_Init__c lchatItr : listOfLandbotChatRecords){
            lchatItr.User_Feedback__c = feedbackText;
            lchatItr.Rating_Stars__c = rate;
            listOfLandbotChatRecordsToUpdate.add(lchatItr);
        }

        try{
            update listOfLandbotChatRecordsToUpdate;
        } catch(Exception e){
            throw new AuraHandledException('Something went wrong, please try again');
        }
    }
}