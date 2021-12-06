/*
**	This class will execute the class UpdateSubjectToArchived 
**	on a schedule if they haven't been used in 6 months. 
**	Suggestion to run as a nightly, or even weekly, scheduled job.
*/

global class ScheduleUpdateSubject implements Schedulable {
	

	global void execute(SchedulableContext sc) {

		UpdateSubjectToArchived o = new UpdateSubjectToArchived();

	}
}