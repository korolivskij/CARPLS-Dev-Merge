public with sharing class OutcomeSurvey {

	transient public List<Messaging.Singleemailmessage>	emails			{ get; set;}
	public Id									noReply			{ get; set; }
	transient public Set<Id>					contactIds		{ get; set; }
	public Integer								numOutcomeSurveys { get; set; }
	public Integer								numFollowUpSurveys { get; set; }
	private EmailTemplate 						outcomeTemp;
	private EmailTemplate						outcomeTempSpanish;
	private EmailTemplate						followUpTemp;
	private EmailTemplate						followUpTempSpanish;
	private Datetime 							fortyTwoDaysAgo;
	private Datetime							twentyEightDaysAgo;
	private Datetime							twentyOneDaysAgo;
	private Datetime							thirtyFiveDaysAgo;	
	private Datetime							janOneFifteen;
	
	public OutcomeSurvey() {
		doInit();
		processOutcomeSurveys();
		processFollowUpSurveys();
		
		sendCnfmEmail(null);
	}
	public void doInit() {

		// set the time vars		
		Datetime myDateTime = Datetime.now(); 
		fortyTwoDaysAgo = myDateTime.addDays(-42);
		twentyEightDaysAgo = myDateTime.addDays(-28);
		twentyOneDaysAgo = myDateTime.addDays(-21);
		thirtyFiveDaysAgo = myDateTime.addDays(-35);
	
		// Get the IDs for the 2 email templates
	 	outcomeTemp = [SELECT id from emailtemplate where name= 'Outcome Survey']; 
		followUpTemp = [SELECT id from emailtemplate where name = 'Follow Up Outcome Survey'];
	 	outcomeTempSpanish = [SELECT id from emailtemplate where name= 'Outcome Survey - Spanish']; 
		followUpTempSpanish = [SELECT id from emailtemplate where name = 'Follow Up Outcome Survey - Spanish'];
		
		// Use Organization Wide Address 
		for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
			if(owa.Address.contains('noreply')) {
				noReply = owa.id; 
			}
		}
		// initialize other variables
		emails = new List<Messaging.Singleemailmessage>();
		numOutcomeSurveys = 0;
		numFollowUpSurveys = 0;
	}
	/**
	*	This method will determine which contacts should get an initial survey and 
	*	create the emails.
	**/
	private void processOutcomeSurveys() {
							
		Integer mailCount = 0;
		List<Case> cases;
 		contactIds = new Set<Id>();
		
		// Select the cases for which an initial survey will be sent
		cases = [select id, contact.email, contact.name, contact.language__c, contact.id, survey_sent__c, survey_status__c
					from case 
					where last_service_date__c < :twentyEightDaysAgo 
					and last_service_date__c >= :fortyTwoDaysAgo
					and contact.email != null
					and contact.EmailBouncedReason = null
					// if there is no survey status then it has not been sent
					and survey_status__c = null
					//and survey_sent__c = false
					and id in 
						(select case__c from consultation__c where disposition__c = 'Legal Service'
						and createddate < :twentyEightDaysAgo
						and createddate >= :fortyTwoDaysAgo)];
						
		for (Case c:cases) {
			// The limit on the number of emails sent with singleEmailMessage is 100
			// So, if the list has gotten too big, send it and reset
			if (emails.size() > 90) {
				system.debug('list got too big - resetting now');
				numOutcomeSurveys = numOutcomeSurveys + emails.size();
				// Figure out how to handle a bad email address.  Right now it's failing, 
				// but if I swallow the error, I won't know that it failed.  Or which email
				// address caused it.
				try {
					Messaging.sendEmail(emails);
				} catch (Exception e) {
					sendCnfmEmail(e);
					return;
				}
				sendCnfmEmail(null);
				emails = new List<Messaging.Singleemailmessage>();				
			}
			// We don't want to send several emails to the same client, as they won't be able to 
			// identify the case from the email or survey 			
			if (!contactIds.contains(c.contact.id)) {
				mailCount++;
				if (c.contact.language__c == 'Spanish') {
					addEmail(c, outcomeTempSpanish);					
				} else {
					addEmail(c, outcomeTemp);
				}

				contactIds.add(c.contact.id);
			}
			// This is outside the IF so that we don't send a survey on the next run.
			// All relevant cases will be marked as sent, even though only one per client will have the 
			// survey attached. 
			c.survey_sent__c = true;
			// Set the surveyStatus field. 
			c.survey_status__c = 'Sent';
		}
		system.debug('All done with loop - sending rest now');
		numOutcomeSurveys = numOutcomeSurveys + emails.size();
		try {
			Messaging.sendEmail(emails);
		} catch (Exception e) {
			sendCnfmEmail(e);
			return;
		}
		sendCnfmEmail(null);

		try {
			update cases;
		} catch (Exception e) {
			System.debug('Exception in ScheduleSurveyEmail when updating cases '+e);
		}
						
	}
	/**
	*	This method will determine which contacts should get a follow up survey and 
	*	create the emails.
	**/
	private void processFollowUpSurveys() {	
		
		Integer mailCount = 0;
		List<Case> followUpCases;
		emails = new List<Messaging.Singleemailmessage>();			
		// Select the cases for which a Follow Up survey will be sent
		// add the null check so that it isn't looking through all cases.
		try {
			followUpCases = [select id, contact.email, contact.name, contact.id, contact.language__c, survey_sent__c, survey_status__c
					from case 
					where survey_status__c = 'Pending' 
					and contact.email != null
					and contact.EmailBouncedReason = null
					and survey_completed_time__c < :twentyOneDaysAgo
					and survey_completed_time__c > :fortyTwoDaysAgo
					and survey_completed_time__c != null];
		} catch(Exception e) {
			system.debug('Error in Outcome survey soql: '+ e);
			return;
		}
		if (followUpCases == null) {
			system.debug('No follow up surveys to send');
			return;
		}
		for (Case c:followUpCases) {
			// The limit on the number of emails sent with singleEmailMessage is 100
			// So, if the list has gotten too big, send it and reset
			if (emails.size() > 90) {
				system.debug('list got too big - resetting now');
				numFollowUpSurveys = numFollowUpSurveys + emails.size();
				try {
					Messaging.sendEmail(emails);
				} catch (Exception e) {
					sendCnfmEmail(e);
					return;
				}
				emails = new List<Messaging.Singleemailmessage>();				
			}
			// We don't want to send several emails to the same client, as they won't be able to 
			// identify the case from the email or survey 			
			if (!contactIds.contains(c.contact.id)) {
				mailCount++;
				//createEmail(c);
				if (c.contact.language__c == 'Spanish') {
					addEmail(c, followUpTempSpanish);
				} else {
					addEmail(c, followUpTemp);
				}
				contactIds.add(c.contact.id);
			}
			// This is outside the IF so that we don't send a survey on the next run.
			// All relevant cases will be marked as sent, even though only one per client will have the 
			// survey attached. 
			c.survey_sent__c = true;
			// Set the surveyStatus field. 
			c.survey_status__c = 'Follow Up Sent';
		}
		system.debug('All done with loop - sending rest now');
		numFollowUpSurveys = numFollowUpSurveys + emails.size();
		try {
			Messaging.sendEmail(emails);
		} catch (Exception e) {
			sendCnfmEmail(e);
			return;
		}

		try {
			update followUpCases;
		} catch (Exception e) {
			System.debug('Exception in ScheduleSurveyEmail when updating followUpCases '+e);
		}
	}
   	// This method will, given the case passed in, create an email and add it to the list
   	public void addEmail(Case pc, EmailTemplate pT) {
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTemplateId(pT.id); 
		mail.setSaveAsActivity(false); 
		mail.setTargetObjectId(pc.contactid);
		mail.setWhatId(pc.id);
		// Use Organization Wide Address 
		mail.setOrgWideEmailAddressId(noReply); 
		emails.add(mail);
   	}
   	/* This method will send an email to myself, either indicating successful completion and
   		the number of emails sent, or an error condition if applicable.
   	*/
   	public void sendCnfmEmail(Exception pErrorMsg) {
   		// initialize the email
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> lEmailAddrs = new List<String>{'ericacox10@gmail.com'};
        mail.setToAddresses(lEmailAddrs);
        mail.setSenderDisplayName('Carpls Salesforce Automation');
        String msg = '';
        
   		if (pErrorMsg == null) {
   			mail.setSubject('Outcome Surveys Sent');
        	msg = 'Outcome Surveys Sent = '+numOutcomeSurveys+' Follow Up Surveys Sent = '+numFollowUpSurveys;
   		} else {
   			mail.setSubject('Outcome Survey Error');
   			msg = 'The following exception was encountered in ScheduleOutcomeSurvey : ' + pErrorMsg;
   		}
   		
   		mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   	}	
}