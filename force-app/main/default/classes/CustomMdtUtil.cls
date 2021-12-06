public class CustomMdtUtil {
    /**
     *
     *
     * @param isActive
     * @param emailType
     *
     * @return
     */
    public static List<OutBound_Emails__mdt> getOutboundEmailsMdts(Boolean isActive, String emailType) {
        Set<String> emailTypes = new Set<String> {emailType};
        return getOutboundEmailsMdts(isActive,emailTypes);
    }
    /**
     *
     *
     * @param isActive
     * @param emailTypes
     *
     * @return
     */
    public static List<OutBound_Emails__mdt> getOutboundEmailsMdts(Boolean isActive, Set<String> emailTypes) {
        List<OutBound_Emails__mdt> emailMdts = [
                SELECT  Label,DeveloperName,Active__c,Community_Profile_Name__c,
                        Email_Opt_in_User_Field__c,Email_Template_Dev_Name__c,
                        Email_Type__c,Account_Name__c,Restrict_By_Department__c,
                        Restrict_ByDept_Acct_Ids__c,Internal_Debug_Email_Addys__c,
                        Debug_Only__c,Use_Account_Community_Activated_Checkbox__c
                FROM    Outbound_Emails__mdt
                WHERE   Active__c = :isActive
                and     Email_Type__c in :emailTypes];

        return emailMdts;
    }
    /**
     *
     *
     * @return
     */
    public static List<Department__mdt> getDepartmentsAndCountiesMdts() {
        List<Department__mdt> deptsAndCountiesMdts = [
                SELECT  Label,DeveloperName,
                        (   select developername,county_name__c,department__c
                            from Counties__r)
                FROM    Department__mdt];
        return deptsAndCountiesMdts;
    }
}