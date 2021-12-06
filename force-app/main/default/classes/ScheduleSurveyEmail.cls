//  This is really a one-time-use class.  I hardcoded the target dates rather than creating a 
// batch job.  If it needs to be rerun the dates will need to be changed.
global class ScheduleSurveyEmail implements Schedulable {

	public Set<Id> 								caseIds			{ get; set;}
	public List<Messaging.Singleemailmessage>	emails			{ get; set;}
	public Id									noReply			{ get; set; }
	
	global void execute(SchedulableContext ctx) {

		List<Consultation__c> services;
		caseIds = new Set<Id>();
		emails = new List<Messaging.Singleemailmessage>();
		// Use Organization Wide Address 
		for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
			if(owa.Address.contains('noreply')) {
				noReply = owa.id; 
			}
		}
		services = [select case__c, case__r.contact.email, case__r.contact.name, createddate, survey_sent__c 
					from consultation__c 
					where createddate >= 2014-09-28T00:00:00.000+0000
					and createddate < 2014-10-04T00:00:00.000+0000
					and case__r.last_service_date__c < 2014-10-04T00:00:00.000+0000
					and case__r.contact.email != null
					and survey_sent__c = false
					order by createddate desc
					];
		for (Consultation__c s: services) {
			// First, check if there was already a survey sent for this case.  If so, ignore it.
			// We don't want to send out surveys for multiple services after the fact - 
			// clients would be confused.
			if (!caseIds.contains(s.case__c)) {
				createEmail(s);
				caseIds.add(s.case__c);
				s.survey_sent__c = true;
			}


		}
		Messaging.sendEmail(emails);
		try {
			update services;
		} catch (Exception e) {
			System.debug('Exception in ScheduleSurveyEmail when updating services '+e);
		}
	}
	// This method will, given the service passed in, create an email and add it to the list
	public void createEmail(Consultation__c pS) {

    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
		
		List<String> emailAddrs = new List<String>();
        emailAddrs.add(pS.case__r.contact.email);
        mail.setToAddresses(emailAddrs);       
        
        String subj = 'CARPLS Legal Aid Survey';
        mail.setSubject(subj);

		String textBody = 'Dear '+pS.case__r.contact.name;
		textBody += pS.createddate.format('MM-dd-yyyy') + '. We hope that we were able ';
        textBody += 'to assist you with your legal problem.  Your feedback is important ';
        textBody += 'to us. Please follow the link below to complete a short survey and help ';
        textBody += 'us to improve our services to clients.';
        textBody += 'https://www.getfeedback.com/r/D7FK126r?ConsultationId='+pS.id;
        textBody += '&CaseId='+pS.case__c+'&Contact_Name='+pS.case__r.contact.name;
        textBody += '  Sincerely, Patricia Wrona, Director of Legal Services, CARPLS Legal Aid';
        
		mail.setPlainTextBody(textBody);   
               
        String htmlBody = 'Dear '+pS.case__r.contact.name+',<br><br>';
        htmlBody += 'Thank you for contacting CARPLS Legal Aid on ';
        htmlBody += pS.createddate.format('MM-dd-yyyy') + '. We hope that we were able ';
        htmlBody += 'to assist you with your legal problem.  Your feedback is important ';
        htmlBody += 'to us. Please follow the link below to complete a short survey and help ';
        htmlBody += 'us to improve our services to clients.<br><br>';
        htmlBody += '<a href="https://www.getfeedback.com/r/D7FK126r?ConsultationId='+pS.id;
        htmlBody += '&CaseId='+pS.case__c+'&Contact_Name='+pS.case__r.contact.name;
        htmlBody += '">';
        htmlBody += 'CARPLS Survey</a><br><br>';
        htmlBody += 'Sincerely,<br>Patricia Wrona<br>Director of Legal Services<br>CARPLS Legal Aid';                   
    
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
       	
		mail.setOrgWideEmailAddressId(noReply); 
		
		emails.add(mail);
	}
	
}