/*
**	This class will send emails with links to the Outcome Survey.
**	This survey is at the case level and is temporary until Applied Resource based surveys can be implemented.
**  Emails will be generated for all cases with LastServiceDates betweeen 28 and 42 days ago and 
**  that had service created in that timeframe with a disposition of Legal Service and
**  for which a survey has not already been sent.
**
**  A check is also performed to ensure that the client has an email address. 
**
*/
 global class ScheduleOutcomeSurvey implements Schedulable {


	global void execute(SchedulableContext ctx) {
	
		OutcomeSurvey o = new OutcomeSurvey();
	}
	
}