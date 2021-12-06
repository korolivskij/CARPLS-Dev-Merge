/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Get, Upsert and Delete relevent sObject declared in the Lightning and Community Builder
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Randy Grewal   <rgrewal@salesfore.com>
* @modifiedBy     Randy Grewal   <rgrewal@salesfore.com>
* @maintainedBy   Randy Grewal   <rgrewal@salesfore.com>
* @version        1.1
* @created        2017-05-01
* @modified       2017-06-12
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            rgrewal@salesfore.com
* 2017-06-08     	Added option to filter query by logged in user and removed System.debug logs
* 2017-06-12		Security Review Fixes:
*					Added isAccessible(), isCreateable(), isDeletable() for CRUD/FLS Enforcement fix
*					Added Typecasting to all injected field API names for SOQL Injection fix
*					Added "with sharing" keyword to Class for Sharing Violation Fix
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class AnyEventCalCtrl {
    @AuraEnabled
    public static List<EventObj> getEvents(String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String locationField, String typeField, String countyField, String userField, Boolean filterByUserField, String eventCommunityField, String eventCommunityPicklistValue){
        System.debug('locationField '+locationField);
        system.debug('countyField '+countyField );
        system.debug('typeField '+typeField);
        System.debug('eventCommunityField == ' + eventCommunityField);
        System.debug('eventCommunityPicklistValue == ' + eventCommunityPicklistValue);
        System.debug('sObjectName == ' + sObjectName);
        
        String q = 'SELECT Id,' + 
            String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +
            String.valueOf(locationField) + ',' +
            String.valueOf(countyField) + ',' +
            String.valueOf(typeField) + ',' +
            String.valueOf(eventCommunityField) + ',' +
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName) + ' WHERE ' + 
            String.valueOf(userField) + ' = \'' + UserInfo.getUserId() + '\'' + ' AND ' +
            String.valueOf(eventCommunityField) + ' =\'' + String.valueOf(eventCommunityPicklistValue) + '\'';
        if (!filterByUserField) {
            q = 'SELECT Id,' + 
                String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +
            String.valueOf(locationField) + ',' +
            String.valueOf(countyField) + ',' +
            String.valueOf(typeField) + ',' +
            String.valueOf(eventCommunityField) + ',' +
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName) + ' WHERE ' +
            String.valueOf(eventCommunityField) + ' = \'' + String.valueOf(eventCommunityPicklistValue) + '\'';
        } 
       
        

        List<sObject> sObjectList = Database.query(q);
        system.debug('sObjectList == ' + sObjectList);
		List<EventObj> eventRecords = new List<EventObj>();        
        if(isAccessible(sObjectName)) {
            for (sObject obj : sObjectList) {
                EventObj newEv = new EventObj(obj.Id,
                                              String.valueOf(obj.get(titleField)),
                                              DateTime.valueOf(obj.get(startDateTimeField)),
                                              DateTime.valueOf(obj.get(endDateTimeField)),
                                              String.valueOf(obj.get(descriptionField)),
											  String.valueOf(obj.get(locationField)),
                                              String.valueOf(obj.get(userField)),
                                              String.valueOf(obj.get(typeField)),
                                              String.valueOf(obj.get(countyField)),
                                              String.valueOf(obj.get(eventCommunityField))
                                             );
                eventRecords.add(newEv);
            }
        }
        
        return eventRecords;
    }
    @AuraEnabled
    public static List<String> getTypePickListValues(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = IL_AFLAN_Events__c.Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> getCountyPickListValues(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = IL_AFLAN_Events__c.County__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    @AuraEnabled
    public static List<String> getEventCommunityPickListValues(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = IL_AFLAN_Events__c.Event_Community__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

	@AuraEnabled
	public static Map<Id, Event_Attendees__c> getEventAttendees(){
		Map<Id, Event_Attendees__c> eventAttendeesByContactId = new Map<Id, Event_Attendees__c>();

		User oUser = [select Name, ContactId FROM User Where id =: userInfo.getUserId()];
		
		List<Event_Attendees__c> eventAttendees = [SELECT Id, Status__c, AFLAN_Event__c, Contact__c FROM Event_Attendees__c WHERE Contact__c =: oUser.ContactId ]; 
		System.debug(eventAttendees);
		for(Event_Attendees__c eventAttendee: eventAttendees){
			eventAttendeesByContactId.put(eventAttendee.AFLAN_Event__c, eventAttendee);
		}
		return eventAttendeesByContactId;
    }
    @AuraEnabled
    public static List<Event_Attendees__c> getAttendeesList(String eventId){
        List<Event_Attendees__c> eventAttendees = [SELECT Id,Owner.Name,Contact__r.Name, Status__c FROM Event_Attendees__c WHERE AFLAN_Event__c =: eventId ];
        return eventAttendees;
    }

	@AuraEnabled
	public static Event_Attendees__c createEventAttendees(String eventId, String status){
		User oUser = [select Name, ContactId FROM User Where id =: userInfo.getUserId()];

		Event_Attendees__c eventAttendee = new Event_Attendees__c();
		eventAttendee.AFLAN_Event__c = eventId;
		eventAttendee.Contact__c = oUser.ContactId;
		eventAttendee.Status__c = status;

		try{
			insert eventAttendee;
			Event_Attendees__c eventAttendeeNew = new Event_Attendees__c();
			eventAttendeeNew.Id = eventAttendee.Id;
			eventAttendeeNew.AFLAN_Event__c = eventAttendee.AFLAN_Event__c;
			eventAttendeeNew.Contact__c = eventAttendee.Contact__c;
			eventAttendeeNew.Status__c = eventAttendee.Status__c;

			return eventAttendeeNew;

		} catch (Exception ex){
			System.debug('Exeption: '+ex.getMessage());
			return null;
		}
	}

	@AuraEnabled
	public static Event_Attendees__c updateEventAttendees(String eventId, String status, String eventAttendeeId){
		User oUser = [select Name, ContactId FROM User Where id =: userInfo.getUserId()];
		
		Event_Attendees__c eventAttendee = new Event_Attendees__c();
		eventAttendee.Id = eventAttendeeId;
		eventAttendee.AFLAN_Event__c = eventId;
		eventAttendee.Contact__c = oUser.ContactId;
		eventAttendee.Status__c = status;

		try{
			update eventAttendee;
			Event_Attendees__c eventAttendeeNew = new Event_Attendees__c();
			eventAttendeeNew.Id = eventAttendee.Id;
			eventAttendeeNew.AFLAN_Event__c = eventAttendee.AFLAN_Event__c;
			eventAttendeeNew.Contact__c = eventAttendee.Contact__c;
			eventAttendeeNew.Status__c = eventAttendee.Status__c;
			
			return eventAttendeeNew;

		} catch (Exception ex){
			System.debug('Exeption: '+ex.getMessage());
			return null;
		}
	}
    
    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String locationField,String typeField,String countyField, String userField, String eventCommunityField){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        sObject newRecord = Schema.getGlobalDescribe().get(sObjectName).newSObject();
        system.debug('SobjectName '+sObjectName); 
        if (upsertingEvent.Id != null && isAccessible(sObjectName,'Id')){
            newRecord.put('Id',upsertingEvent.Id);
        } 
        if (isAccessible(sObjectName,titleField)) {
            newRecord.put(titleField, upsertingEvent.title);
        }
        if (isAccessible(sObjectName,startDateTimeField)) {
            newRecord.put(startDateTimeField, upsertingEvent.startDateTime);
        }
        if (isAccessible(sObjectName,endDateTimeField)) {
            newRecord.put(endDateTimeField, upsertingEvent.endDateTime);
        }
        if (isAccessible(sObjectName,descriptionField)) {
            newRecord.put(descriptionField, upsertingEvent.description);
        }
        if (isAccessible(sObjectName,locationField)) {
            newRecord.put(locationField, upsertingEvent.locationf);
        }
        if (isAccessible(sObjectName,typeField)) {
            newRecord.put(typeField, upsertingEvent.type);
        }
        if (isAccessible(sObjectName,countyField)) {
            newRecord.put(countyField, upsertingEvent.county);
        }
        System.debug('newRecord====' + newRecord);
        if (isAccessible(sObjectName,eventCommunityField)) {
            newRecord.put(eventCommunityField, upsertingEvent.eventCommunity);
        }
        System.debug('newRecord====' + newRecord);
        try {
            upsert newRecord;
            EventObj newEv = new EventObj(newRecord.Id,
                                  String.valueOf(newRecord.get(titleField)),
                                  DateTime.valueOf(newRecord.get(startDateTimeField)),
                                  DateTime.valueOf(newRecord.get(endDateTimeField)),
                                  String.valueOf(newRecord.get(descriptionField)),
								  String.valueOf(newRecord.get(locationField)),
                                  String.valueOf(newRecord.get(userField)),
                                  String.valueOf(newRecord.get(typeField)),
                                  String.valueOf(newRecord.get(countyField)),
                                  String.valueOf(newRecord.get(eventCommunityField))
                                 );
            return newEv;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
            return null;
        }
        
    }
    @AuraEnabled
    public static String deleteEvent(String eventId, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String locationField, String userField){
        String q = 'SELECT Id,' + 
                titleField + ',' + 
                startDateTimeField + ',' +
                endDateTimeField + ',' +
                descriptionField + ',' +
				locationField + ',' +
                userField + ' FROM ' + 
                sObjectName + ' WHERE Id = \'' + eventId  + '\'';
        List<sObject> sObjectList = Database.query(q);
        try {
            if(isDeletable(sObjectName)) {
                delete sObjectList;
            }
            return eventId;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
    }
    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
		@AuraEnabled
        public String locationf {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String county {get;set;}
        @AuraEnabled
        public String eventCommunity {get;set;}
        
        public EventObj(String i,String t, DateTime s, DateTime e, String d, String l, String o, String tp,String c, String ec){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
			this.locationf = l;
            this.owner = o;
            this.type = tp;
            this.county = c;
            this.eventCommunity = ec;
        }
        
    }
    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }
    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }
    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }
    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }

}