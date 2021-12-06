/****
**    Servio Consulting, LLC.
** Alex Grinevich
** 2016/31/10
**
** Description: test triggers:
** - trgUpdateContactFromEvent
** - trgUpdateContactFromTask
** - trgUpdateEventTimeField
** - trgUpdateTaskTimeField
****/
@isTest(SeeAllData=false)
public class TEST_trgTaskFromInContact {
    
 	public static   User                uTstExecUser                { get; set; }
    
    static Task newTask;
    static Task newTask2;
    static List<Task> taskList = new List<Task>();
    static List<Task> tasksToUpdate = new List<Task>();
    static Contact newContact; 
    
     public static testMethod void executeTest() {
        coreExecution('', '', '', '');
    }
    
    public static void coreExecution(String sUserId, String sProfileId, String sRoleId, String sPermSetId) {
        
        Datetime   dtTstStart        = Datetime.now();
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings(sUserId, sProfileId,sRoleId, sPermSetId );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);
        
        //-- If no org level custom setting a new one will be created.. 
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);
        
        buildTestData(); //<--- Build Any needed Contacts / caseparties...
        
        Test.startTest();
        Integer c = 0;
        
        System.runAs(uTstExecUser) {  
            
            newTask.CallDurationInSeconds = 20;
            tasksToUpdate.add(newTask);
            newTask2.CallDurationInSeconds = 25;
            tasksToUpdate.add(newTask2);
            update tasksToUpdate;
            
            newTask=[select CallDurationInSeconds from task where id = :newTask.id];
            newTask2=[select CallDurationInSeconds from task where id = :newTask2.id];            
			System.assertEquals(1, newTask.CallDurationInSeconds);
			System.assertEquals(25, newTask2.CallDurationInSeconds);            
        }
        Test.stopTest();
       
        System.debug(logginglevel.error,'\n\n\n--------> UNIT TEST TOTAL SOQL QUERIES='+Limits.getQueries());   
    }
    
    private static void buildTestData()
    {
        newContact = TEST_TestUtils.createContact('Client');
                
        Date dTomorrow = Date.today().addDays(1);
  	    newTask = new Task(activityDate = dTomorrow, WhoId = newContact.Id, CallDurationInSeconds=1, Subject='Test task 1');
        newTask2 = new Task(activityDate = dTomorrow, WhoId = newContact.Id, CallDurationInSeconds=1, Subject='Call 01/01/1900');
        
        taskList.add(newTask);
        taskList.add(newTask2);
        insert taskList;          
    }
}