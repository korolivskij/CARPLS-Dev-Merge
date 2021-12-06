global with sharing class ScheduleAflanCaseCreate implements Schedulable{
    global void execute(SchedulableContext sc)
    {
        database.executebatch(new AflanCaseCreateBatch(),200);
    }
}