/**
* Provisio Partners
* @author David Cox <david.cox@provisiopartners.com>
* @date 10/01/2020
* @group Appointments
*
* @description Process to generate appointments  
* To Execute and generate from date for next 7 days: 
* GenerateAppts appt = new GenerateAppts(date.newInstance(2020, 10, 17),7);
*
* @history David Cox 10/01/2020 Initial Version
* @history David Cox 10/13/2020 Check for Weekdays
**/
public with sharing class GenerateAppts{
    
    //Create appointments from today and inputDays into the future
    public GenerateAppts() {
        createAppts();
    }

    //Create appointments from inputDate and inputDays into the future
   /* public GenerateAppts( List<Integer> inputDays) {
        //startDate = inputDate;
        days = inputDays;
        createAppts();
    }*/

    public void createAppts() {  
        
        
        Date firstDateNextMonth = Date.today().addMonths(1).toStartOfMonth();
        
        Integer daysInMonth = Date.daysInMonth(firstDateNextMonth.year(),firstDateNextMonth.month());
        
        Map<String, List<Date>> daysByDay = new Map<String,List<Date>>();
        daysByDay.put('Sunday' , new List<Date>());
        daysByDay.put('Monday' , new List<Date>());
        daysByDay.put('Tuesday' , new List<Date>());
        daysByDay.put('Wednesday' , new List<Date>());
        daysByDay.put('Thursday' , new List<Date>());
        daysByDay.put('Friday' , new List<Date>());
        daysByDay.put('Saturday' , new List<Date>());
        for(Integer i = 0; i<daysInMonth; i++){
            Datetime dt = DateTime.newInstance(firstDateNextMonth, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt.format('EEEE');
            switch on dayOfWeek{
                when 'Sunday'{
                    List<Date> existingSundays = daysByDay.get('Sunday');
                    existingSundays.add(dt.date());
                    daysByDay.put('Sunday' ,existingSundays);
                }
                when 'Monday' {
                    List<Date> existingMonday = daysByDay.get('Monday');
                    existingMonday.add(dt.date());
                    daysByDay.put('Monday' ,existingMonday);
                }
                when 'Tuesday'{
                    List<Date> existingTuesday = daysByDay.get('Tuesday');
                    existingTuesday.add(dt.date());
                    daysByDay.put('Tuesday' ,existingTuesday);
                }
                when 'Wednesday'{
                    List<Date> existingWednesday = daysByDay.get('Wednesday');
                    existingWednesday.add(dt.date());
                    daysByDay.put('Wednesday' ,existingWednesday);
                }
                when 'Thursday'{
                    List<Date> existingThursday = daysByDay.get('Thursday');
                    existingThursday.add(dt.date());
                    daysByDay.put('Thursday' ,existingThursday);
                }
                when 'Friday' {
                    List<Date> existingFriday = daysByDay.get('Friday');
                    existingFriday.add(dt.date());
                    daysByDay.put('Friday' ,existingFriday);
                }
                when 'Saturday' {
                    List<Date> existingSaturday = daysByDay.get('Saturday');
                    existingSaturday.add(dt.date());
                    daysByDay.put('Saturday' ,existingSaturday);
                }
            }
            firstDateNextMonth = firstDateNextMonth.addDays(1);
        }
        List<CARPLS_Appt__c> apptRecords = new List<CARPLS_Appt__c>();
        List<Generate_Appt__mdt> generateRecords = [SELECT Name__c,Start_Time__c,Status__c,Type__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c FROM Generate_Appt__mdt];
        for(Generate_Appt__mdt ga :generateRecords){
            if(ga.Monday__c){
                apptRecords.addAll(newRecordsToInsert('Monday', ga, daysByDay));
            }
            if(ga.Tuesday__c){
                apptRecords.addAll(newRecordsToInsert('Tuesday', ga, daysByDay));
            }
            if(ga.Wednesday__c){
                apptRecords.addAll(newRecordsToInsert('Wednesday', ga, daysByDay));
            }
            if(ga.Thursday__c){
                apptRecords.addAll(newRecordsToInsert('Thursday', ga, daysByDay));
            }
            if(ga.Friday__c){
                apptRecords.addAll(newRecordsToInsert('Friday', ga, daysByDay));
            }
            if(ga.Saturday__c){
                apptRecords.addAll(newRecordsToInsert('Saturday', ga, daysByDay));
            }
            if(ga.Sunday__c){
                apptRecords.addAll(newRecordsToInsert('Sunday', ga, daysByDay));
            }
        }
        insert apptRecords;
        system.debug('apptRecords : ' + apptRecords);
        /*Date startOfWeek = Date.today().toStartOfWeek();
        //system.debug('start: ' + startDate);
        //system.debug('days: ' + days);
        //Validate days not over 100
        //if(days > 100) {
          //  days = 100;
        //}     
        
        Time apptTime;
        DateTime appStartDateTime;
        DateTime appEndDateTime;
        CARPLS_Appt__c newApptRecord;      
              
        for(Generate_Appt__mdt record :generateRecords){
            List<Integer> days = new List<Integer>();
            if (record.Sunday__c) days.add(0);
			if (record.Monday__c) days.add(1);
			if (record.Tuesday__c) days.add(2);
			if (record.Wednesday__c) days.add(3);
			if (record.Thursday__c) days.add(4);
			if (record.Friday__c) days.add(5);
			if (record.Saturday__c) days.add(6);
            if(days.size() != 0){
            	for(Integer day :days){
                	Date dateOfClass = startOfWeek.addDays(day);  
            		apptTime = Time.newInstance(Integer.valueOf(record.Start_Time__c), 0, 0, 0);
            		appStartDateTime =DateTime.newInstance(dateOfClass, apptTime); 
            		newApptRecord = new CARPLS_Appt__c();
            		newApptRecord.Name = record.Name__c;
            		newApptRecord.Start_DateTime__c = appStartDateTime;
            		newApptRecord.Status__c = record.Status__c;
            		newApptRecord.Type__c = record.Type__c;
            		newApptRecord.End_DateTime__c = appStartDateTime.addHours(1);
            		apptRecords.add(newApptRecord);
            	}
            }
            
        }          
        //for (Integer i = 0; i < days; i++) {
            //Determine if weekday
            /*date weekStart = startDate.toStartofWeek();
            dayOfWeek = weekStart.daysBetween(startDate);
            If (dayofWeek != 0 && dayofWeek != 6) {          
            	for(Generate_Appt__mdt record :generateRecords){
                    apptTime = Time.newInstance(Integer.valueOf(record.Start_Time__c), 0, 0, 0);
                    appStartDateTime =DateTime.newInstance(startDate, apptTime); 
                	newApptRecord = new CARPLS_Appt__c();
                    newApptRecord.Name = record.Name__c;
                    newApptRecord.Start_DateTime__c = appStartDateTime;
                    newApptRecord.Status__c = record.Status__c;
                    newApptRecord.Type__c = record.Type__c;
                    newApptRecord.End_DateTime__c = appStartDateTime.addHours(1);
                    apptRecords.add(newApptRecord);
            	}          
            
                
        	}
            startDate = startDate.addDays(1);
            
          
		//}*/
			//insert apptRecords;
    }
    
    private static List<CARPLS_Appt__c> newRecordsToInsert (String dateValue, Generate_Appt__mdt ga, Map<String, List<Date>> daysByDay){
        system.debug('ga : ' + ga.Start_Time__c);
        List<CARPLS_Appt__c> toReturnList = new List<CARPLS_Appt__c>();
        
        List<Date> listDays = daysByDay.get(dateValue);
        	for(Date day :listDays){
                CARPLS_Appt__c newApptRecord = new CARPLS_Appt__c();
                Time apptTime = Time.newInstance(Integer.valueOf(ga.Start_Time__c), 0, 0, 0);
            	DateTime appStartDateTime =DateTime.newInstance(day, apptTime); 
                newApptRecord.Name = ga.Name__c;
            	newApptRecord.Start_DateTime__c = appStartDateTime;
            	newApptRecord.Status__c = ga.Status__c;
            	newApptRecord.Type__c = ga.Type__c;
            	newApptRecord.End_DateTime__c = appStartDateTime.addHours(1);
                toReturnList.add(newApptRecord);
            }
        return toReturnList;
    }
}