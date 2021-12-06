@IsTest
public class LandbotFeedbackFormControllerTest {
    @IsTest
    public static void sendEmailWithLinkToFeedbackTest(){
        Landbot_Chat_Init__c lcRecord = new Landbot_Chat_Init__c();
            //lcRecord.User_Email__c = 'test@mail.com';
            lcRecord.User_Feedback__c = 'test';
            lcRecord.Rating_Stars__c = 'test';
        insert lcRecord;
        //LandbotFeedbackFormController.sendEmailWithLinkToFeedback(lcRecord);
        LandbotFeedbackFormController.updateLandbotChatRecordWithFeedback(lcRecord.id, 'test', 'test'); 
    }
}