public class ctrlGetUserId {

    @AuraEnabled
    public static Id getUserId() {
        return UserInfo.getUserId();
    }
}