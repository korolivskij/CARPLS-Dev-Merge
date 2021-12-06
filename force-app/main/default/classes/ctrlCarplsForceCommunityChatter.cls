public without sharing class ctrlCarplsForceCommunityChatter {
    /**
     *
     *
     * @param networkId
     * @param cseId
     * @param groupName
     *
     * @return a ResponseTDTO with 'CollaborationGroup' and 'Applied_Resource__c' as keys in the values map.
     */
    @auraenabled
    public static ResponseDTO retrieveForceCommunityData(Id networkId, Id cseId, String groupName) {
        ResponseDTO dto = new ResponseDTO();
        dto = retrieveCollaborationGroup(groupName,networkId);
        dto.values.put('Applied_Resource__c',retrieveOpenLegalAr(cseId));
        return dto;
    }
    /**
     *
     *
     * @param cseId
     *
     * @return
     */
    @auraenabled
    public static Applied_Resource__c retrieveOpenLegalAr(Id cseId) {
        Applied_Resource__c ar;
        List<Applied_Resource__c> ars = [   select id, name,account__r.name,active__c
        from    applied_resource__c
        where   case__c = :cseId
        and     active__c = true
        and     type__c = 'Legal Referrals'];
        if(!ars.isEmpty()) {
            ar = ars[0];
        }
        return ar;
    }
    /**
     * Gets the collaboration group associated with the users region.
     *
     * @param groupName
     *
     * @return A ResponseDTO with Collaboration group in the values map.
     * @see ResponseDTO
     */
    @AuraEnabled
    public static ResponseDTO retrieveCollaborationGroup(String groupName, Id networkId) {

        ResponseDTO dto = new ResponseDTO();
        CollaborationGroup cg;
        try {
            cg = LeHelper.retrieveCollaborationGroup(groupname,networkId);
        } catch (Exception e) {
            dto.message = 'Exception querying collaboration group with arg groupname=' + groupName + '...ex=' + e.getMessage();
            dto.severity = 'error';
            system.debug(logginglevel.error, e);
        }
        if (cg != null) {
            dto.isSuccess = true;
            dto.values.put('CollaborationGroup', cg);
            dto.values.put('SelectItem',new SelectItem()); //simply to make usable in Javascript.
        } else {
            dto.message = 'No Collaboration Group found for name=' + groupName + ' and networkId='+networkId;
            dto.message+= '  .An administrator has been emailed.';
            try {
                List<String> lEmails = new List<String>(((String) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'f4j_admin_email_addys__c')).split('~'));
                String msgBody = dto.message;
                msgBody += '<br/><br/>User was attempting to hit the local expert tab in the right hand / resource nav area<br/>';
                msgBody += '<br/>UserName that triggered this... ' + UserInfo.getUserName() + '</br>';
                msgBody += '<br/>Sooooo.... go add a the private group!</br>';
                if (!lEmails.isEmpty()) {
                    Utilities.sendEmail(lEmails, 'Carpls F4j Error Local Expert', msgBody, msgBody);
                } else {
                    Utilities.sendEmail(new List<String>{
                            'rnendza@gmail.com'
                    }, 'couldnt find email', msgBody, msgBody);
                }
            } catch (Exception e) {
                system.debug(logginglevel.error, e);
            }
        }
        return dto;
    }
}