public with sharing class Activity {

	public static List<Activity_Assignment__c> retrieveAllActivityAssignments() {
		List<Activity_Assignment__c> aa = [select support_type__c, Current_User__c from Activity_Assignment__c];
		return aa;
	}
	public static Id retrieveOnCallPersonBySupportType(String sSupportType) {
		Activity_assignment__c aa;
		Id uId;
		try {
			aa = [
					Select a.SystemModstamp, a.Support_Type__c, a.Request_Followup_POC_Hotline__c, a.Request_Followup_POC_Desk__c,
							a.Request_Followup_AOC__c, a.OwnerId, a.Name,a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id,
							a.Delegated_User__c, a.Current_User__c, a.Current_Status__c, a.CreatedDate, a.CreatedById
					From Activity_Assignment__c a
					Where a.support_type__c = :sSupportType
			];
		} catch (Exception e) {
			system.debug(logginglevel.error, e);
		}
		if (aa != null) {
			if (aa.current_status__c == 'Available') {
				uId = aa.current_user__c;
			} else {
				uId = aa.delegated_user__c;
			}
		}
		return uId;
	}


	public static Id retrieveOnCallPersonBySupportTypeForTheCaseService(String sSupportType) {
		Id queueId;
		Group queue = [SELECT Id, Name, Type from Group WHERE Type = 'Queue' AND Name = :sSupportType];
		System.debug('queue' + queue);
		if (queue.Id != null) {
			queueId = queue.Id;
			System.debug('queueId' + queue);
		} else {
			queueId = null;
			System.debug('queueId2' + queue);

		}
		System.debug('queueIdToReturn' + queue);
		return queueId;
	}

	public static Activity_Assignment__c retrieveActivityAssignment(Id aaID) {
		Activity_assignment__c aa;

		try {
			aa = [	Select 	a.SystemModstamp, a.Support_Type__c, a.Request_Followup_POC_Hotline__c, a.Request_Followup_POC_Desk__c,
					a.Request_Followup_AOC__c, a.OwnerId, a.Name,a.LastModifiedDate,
					a.LastModifiedById, a.IsDeleted, a.Id, a.Delegated_User__c, a.Current_User__c, a.current_user__r.name,
					a.Current_Status__c, a.CreatedDate, a.CreatedById
			From 	Activity_Assignment__c a
			Where	a.id = :aaID];
		} catch (Exception e) {
			system.debug(logginglevel.error,e);
		}
		return aa;

	}
	public static List<EventRelation> retrieveUserTodaysEvents(Id userId) {
		List<EventRelation> ers;
		ers = [	Select 	e.Status, e.Response, e.Id, e.Event.Event_completed__c, e.Event.Modified_Time__c, e.Event.RecurrenceEndDateOnly,
				e.Event.SystemModstamp, e.Event.LastModifiedById, e.Event.LastModifiedDate, e.Event.CreatedById,
				e.Event.CreatedDate,
				e.Event.Type, e.Event.OwnerId, e.Event.AccountId, e.Event.Description, e.Event.EndDateTime, e.Event.StartDateTime, e.Event.DurationInMinutes, e.Event.ActivityDate,
				e.Event.ActivityDateTime,e.Event.Subject, e.Event.WhatId, e.Event.WhoId, e.Event.Id, e.EventId, e.CreatedDate
		From 	EventRelation e
		where 	e.relationId = :userId
		and e.event.activitydate = TODAY];
		return ers;
	}
	public static List<Event> retrieveUserTodaysOwnedEventsAndInvitedEvents(Id userId) {

		List<Event> allEvts = new List<Event>();
		List<Event> evts = new List<Event>();
		/* events the user is invited too but does not own.. */
		evts = [ Select e.record_vfPage__c, e.record_vfPage_Link__c, e.record_Parms__c, e.WhoId, e.WhatId,  e.Type, e.SystemModstamp,
				e.Subject, e.StartDateTime,
				e.OwnerId, e.On_Call_Assignment__c, e.Modified_Time__c, e.Location, e.LastModifiedDate, e.LastModifiedById, e.Is_Valid_Touch__c,
				e.IsDeleted, e.IsChild,  e.Id, e.GroupEventType, e.Event_completed__c, e.EndDateTime, e.DurationInMinutes, e.Description,
				e.CreatedDate, e.CreatedById, e.Assignment_Type__c, e.Activity_Time__c, e.ActivityDateTime, e.ActivityDate, e.AccountId

		From Event e
		where e.id in (select er.eventId
		from EventRelation er where er.relationId = :userId)
		and e.activitydate = TODAY

		];
		//allEvts.addAll(evts);
		Set<Id> eventIds = new Set<Id>();
		for(Event e : evts) {
			eventIds.add(e.id);
		}
		/* events the user owns.. there will be no EventRelation for the user for the events they own if they created it */
		List<Event> ownedEvts  = [ Select 	e.record_vfPage__c, e.record_vfPage_Link__c, e.record_Parms__c, e.WhoId,e.WhatId,
				e.Type, e.SystemModstamp, e.Subject, e.StartDateTime, e.ReminderDateTime,
				e.OwnerId, e.On_Call_Assignment__c, e.Modified_Time__c, e.Location, e.LastModifiedDate, e.LastModifiedById, e.Is_Valid_Touch__c,
				e.IsReminderSet, e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.IsDeleted, e.IsChild, e.IsArchived, e.IsAllDayEvent, e.Id,
				e.Event_completed__c, e.EndDateTime, e.DurationInMinutes, e.Description, e.CreatedDate, e.CreatedById, e.Assignment_Type__c,
				e.Activity_Time__c, e.ActivityDateTime, e.ActivityDate, e.AccountId
		From 	Event e
		Where	e.ownerId = :userId
		and		e.activitydate = TODAY
		order by e.StartDateTime ASC
		];
		if(ownedEvts!=null && !ownedEvts.isEmpty()) {
			for(Event ownedEvt : ownedEvts) {
				if (!eventIds.contains(ownedEvt.id)) {
					allEvts.add(ownedEvt);
					eventIds.add(ownedEvt.id);
				}
			}
		}

		return allEvts;
	}


}