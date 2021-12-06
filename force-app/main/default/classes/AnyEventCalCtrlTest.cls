/**
 * @File Name          : AnyEventCalCtrlTest.cls
 * @Description        : 
 * @Author             : sergiy.korolivskyi
 * @Group              : 
 * @Last Modified By   : sergiy.korolivskyi
 * @Last Modified On   : 1/27/2020, 5:16:42 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/27/2020   sergiy.korolivskyi     Initial Version
**/
@isTest(seeAllData=true)
public class AnyEventCalCtrlTest {
	static testMethod void getEventsTest() {
        AnyEventCalCtrl.getEvents('IL_AFLAN_Events__c', 'Name', 'Start_DateTime__c', 'End_DateTime__c', 'Description__c', 'Location__c','Type__c','County__c','OwnerId', true, 'Event_Community__c', 'New Leaf');
        AnyEventCalCtrl.getEvents('IL_AFLAN_Events__c', 'Name', 'Start_DateTime__c', 'End_DateTime__c', 'Description__c', 'Location__c','Type__c','County__c', 'OwnerId', false, 'Event_Community__c', 'New Leaf');
    }
    static testMethod void upsertEventsTest() {
        AnyEventCalCtrl.EventObj eo = AnyEventCalCtrl.upsertEvents('{"title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd", "locationf":"aoeu"}', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'Location','Location','Location', 'OwnerId', 'ActivityDate');
    	AnyEventCalCtrl.upsertEvents('{"id":"'+eo.id+'","title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd", "locationf":"aoeu"}', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'Location','Location','Location', 'OwnerId', 'ActivityDate');
    }
    static testMethod void deleteEventTest() {
        AnyEventCalCtrl.deleteEvent('00U41000006bFIA', 'IL_AFLAN_Events__c', 'Name', 'Start_DateTime__c', 'End_DateTime__c', 'Description__c', 'Location__c', 'OwnerId');
    }
    static testMethod void crudSecurityTest() {
        AnyEventCalCtrl.isAccessible('IL_AFLAN_Events__c');
        AnyEventCalCtrl.isAccessible('IL_AFLAN_Events__c','Name');
        AnyEventCalCtrl.isCreateable('IL_AFLAN_Events__c');
        AnyEventCalCtrl.isDeletable('IL_AFLAN_Events__c');
    }

    static testmethod void getEventAttendeesTest(){
		IL_AFLAN_Events__c ilAflanEvent = new IL_AFLAN_Events__c();
		ilAflanEvent.Name = 'testName';
		insert ilAflanEvent;
		
		Event_Attendees__c eventAttendeeTest = new Event_Attendees__c();
		eventAttendeeTest.Status__c='Attended';
		insert eventAttendeeTest;

		AnyEventCalCtrl.getEventAttendees();
        AnyEventCalCtrl.getAttendeesList(ilAflanEvent.Id);
		AnyEventCalCtrl.createEventAttendees(ilAflanEvent.Id, eventAttendeeTest.Status__c);
		AnyEventCalCtrl.updateEventAttendees(ilAflanEvent.Id, eventAttendeeTest.Status__c, eventAttendeeTest.id);
        AnyEventCalCtrl.getTypePickListValues();
        AnyEventCalCtrl.getCountyPickListValues();
	}
}