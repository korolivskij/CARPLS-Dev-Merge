public class ctrlAuraStreamer {
    /**
     * Crutch to get session id into lightning.
     * @return
     */
    @AuraEnabled
    public static String sessionId() {
        return UserInfo.getSessionId();
    }
}