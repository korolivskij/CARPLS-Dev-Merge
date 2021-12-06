public without sharing class ctrlAuraCarplsForceChatter {

    @AuraEnabled
    public static ResponseDTO retrieveObjectName(Id sRecordId) {
        String recordName = Utilities.findObjectNameById(sRecordId);
        ResponseDTO res = new ResponseDTO();
        if(recordName != null && recordName != '') {
            res.isSuccess = true;
            res.values.put('recordName', recordName);
            if(recordName == 'Case') {
                try {
                    Case c = [select id, casenumber,subject from case where id = :sRecordId];
                    res.values.put('case',c);
                } catch (Exception e) {
                    system.debug(e);
                }
            }
        } else {
            res.message = 'Could not find object type for passed id of..'+sRecordId;
        }
        return res;
    }
}