public with sharing class eventTriggerHandler {

    public static void mapSupportTypes(List<Event> triggerNew){
        Map<String,Id> mapSupportTypeCalendarID = new Map<String,Id>();
        mapSupportTypeCalendarID = mapSupportTypeToCalendar();

        for (Event event : triggerNew){
        
                if(event.group__c != null) {
                    if(event.group__c != 'Staff') {
                        if(!mapSupportTypeCalendarID.isEmpty()) {
                            Id newOwnerId = mapSupportTypeCalendarID.get(event.group__c); 
                            
                            // if(newOwnerId!=null) {
                            //     event.OwnerId = newOwnerId;
                            // }    
                        }
                    }
                }
        }
    }

    public static void assignLeadEventToCalendar(List<Event> triggerNew){
        Set<Id> setOfIds = new Set<Id>();
        for(Event event : triggerNew){
            setOfIds.add(event.OwnerId);
        }  
        List<User> user = [SELECT Id , Name , Schedule_Map__c FROM User WHERE id IN: setOfIds AND Schedule_Map__c != null];
        
        if(user.size() != 0) {
        Id calendarID = [SELECT id,name FROM Calendar WHERE  Name=: user[0].Schedule_Map__c].Id;
        for(Event event : triggerNew){
            String relatedTo = '';
            String groupName = '';
            If(event.WhoId != null) {
                relatedTo = event.WhoId.getSObjectType().getDescribe().getName();
            }
            if(event.Group__c != null){
                groupName = event.Group__c;
            }
            if (event.New_Leaf_Appointment__c){
                event.ownerid = calendarID;
            }
            
        }
     }
    }

    private static Map<String,Id> mapSupportTypeToCalendar(){
        Map<String,Id> typeToQueue = new Map<String,Id>();
        List<Calendar> listCalendar = [SELECT Id,Name FROM Calendar  ORDER BY CreatedDate ASC];

        for(Calendar calendar: listCalendar){
            typeToQueue.put(calendar.Name,calendar.Id);
        }

        return typeToQueue;
   }
}