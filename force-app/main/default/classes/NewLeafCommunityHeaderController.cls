public class NewLeafCommunityHeaderController {
    @AuraEnabled
    public static String getURL() {
        return Network.getLoginUrl(Network.getNetworkId()).replace('login', '');        
    }
}