global class ScheduleAppts implements Schedulable{
    global void execute(SchedulableContext SC) {
        //Get current date and find 1st day of the following month 
        /*Date startDate = Date.today();
        startDate = startDate.addMonths(1);
        startDate = startDate.toStartOfMonth();
        Integer numDays = date.daysInMonth(startDate.year(), startDate.month());*/
        //Non static method cannot be referenced from a static context
        GenerateAppts appts = new GenerateAppts();
        //GenerateAppts appt = new GenerateAppts(startDate,numDays);

    }
}