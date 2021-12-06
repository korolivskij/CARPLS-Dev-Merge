public with sharing class UserUtils {
     
        
    public static Profile getProfileByName(String name) {
        Profile p;
        List<Profile> profiles = [select id, name from Profile where name=:name];
        if(profiles != null && !profiles.isEmpty()) {
            p = profiles.get(0);
            System.debug( 'getProfileByName found id='+p.id + ' name='+ p.name);
        } else {
             System.debug( ' NO Profile FOUND!');
        }
        return p;
    }  
    public static String getProfileNameByUserId(Id userId) {
        User u = [Select u.Profile.Name, u.Profile.Id From User u where id = :userId];
        return u.profile.name;
    }       
    public static List<User> getUsersByProfileId(Id pId) {
        List<User> users;

        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('ProfileId').equals( pId ));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('User', false ))
                    .fromx  ('User')
                    .wherex( whereC )
                    .toSoql();
        try {
            users = Database.query(soql);           
        } catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }       
        return users;
    }
    public static List<User> retrieveAllUsers(Id excludeUserId) {
        List<User> users;
        
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('IsActive').equals( true ));
        whereC.add(new al.FieldCondition('id',al.Operator.NOT_EQUALS,excludeUserId));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('User', false ))
                    .fromx  ('User')
                    .wherex( whereC )
                    .orderByx(new al.OrderBy('LastNAme').ascending().nullsLast())
                    .toSoql();  
        try { 
            users = Database.query(soql);           
        } catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }       
        return users;
    }
    
    public static List<Profile> retrieveAllOrgProfiles() {
        List<Profile> profiles;
        
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Profile', false ))
                    .fromx  ('Profile')
                    .toSoql();  
        try { 
            profiles = Database.query(soql);            
        } catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }       
        return profiles;
        
    }
    public static List<Contact> retrieveUserOwnedContacts(Id userId) {
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('ownerId').equals( userId ));
        //return ContactUtils.retrieveAllContactInfo(whereC);   
        return retrieveAllContactInfo(whereC);  
    }
    
    //@TODO Merge with ContactUtils.retrieveAllContactInfo(whereC); 
    //--copied here so we don't have to rely on moving ContactsUtils class to move triggers only
    public static List<Contact> retrieveAllContactInfo(al.NestableCondition whereC) {
        List<Contact> contacts;
        String soql = '';
        try {
            soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false ))  
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .toSoql();  
                    
        } catch (Exception e) {
            System.debug('-- Error creating soql='+soql+'...exception='+e);
            return null;
        }
        try {
            contacts = Database.query(soql);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        return contacts;
    }   
    
    public static List<Task> getUsersTasks(Id uId, String status, Integer limitNum) {
        List<Task> tasks;
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('OwnerId').equals( uId ));
        whereC.add(new al.FieldCondition('Status').equals(status));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Task', false ))
                    .selectx(new Set<String> {'what.name','what.id','what.type','who.name','who.id'})       
                    .fromx  ('Task')
                    .wherex( whereC )
                    .orderByx(new al.OrderBy('ActivityDate').descending().nullsLast())
                    .limitx(limitNum)
                    .toSoql();  
    //  try { 
            tasks = Database.query(soql);           
    //  } catch (Dmlexception e) {
    //      System.debug(logginglevel.error, e);
    //  }       
        return tasks;       
                
    }
    public static User retrieveUserById(Id uId) {
        User user;
        
        al.NestableCondition whereC = new al.OrCondition();     
        whereC.add(new al.FieldCondition('Id').equals( uId ));
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('User', false ))
                    .fromx  ('User')
                    .wherex( whereC )
                    .toSoql();  
        try { 
            user = Database.query(soql);            
        } catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }       
        return user;
    }   
    public static User retrieveUserByName(String uName) {
        User user;
        List<User> users;
        
        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('Name').equals( uName ));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('User', false ))
                    .fromx  ('User')
                    .wherex( whereC )
                    .toSoql();
        try { 
            users = Database.query(soql);           
        } catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }       
        if (users.size() > 1) {
            System.debug('In retrieveUserByName -- more than 1 user returned');
            return null;
        }
        return users[0];
    }   
    /**
     * @TODO for future use. SFDC needs to enable TYPE of SOQL.
     * As of winter 13, they will only enable this in Sandboxes and not production.
     * Their statement was that that might enable this in prodtion in 'Future Releases'.
     * Based on past experience, that is way to broad to ensure it will be usable any time soon.
     *
     */
     /*
    public static List<PolyTask> getUsersPolyTasks(Id uId, String status, Integer limitNum) {
        
        List<Task> tasks;
        List<PolyTask> polyTasks;
        String soql = '';
        
        Set<String> taskWhatTypes = new Set<String>();
        taskWhatTypes.add('Account');
        taskWhatTypes.add('Case');
        
        Id ownerId = uId;
        String sStatus = status;
        Integer iLimitNum = limitNum;
        
        soql += 'SELECT '   +  SoqlUtils.getAllFields('Task',false );
        soql += '           ,what.Name, what.id, who.Name ';
        soql += '       ,TYPEOF What ';
        soql += '           WHEN Account Then Name, id, accountnumber, phone ';     
        soql += '           WHEN Case THEN id, casenumber, subject, priority ';
        soql += '           ELSE Name ';
        soql += '       END ';
        soql += 'FROM   Task ';
        soql += 'WHERE  What.Type IN :taskWhatTypes ';
        soql += ' and   ownerId = :ownerId ';
        soql += ' and   status  = :sStatus ';
        soql += ' ORDER BY ActivityDate DESC ';
        soql += ' LIMIT :iLimitNum ';

        try { 
            tasks = Database.query(soql);           
        } catch (Dmlexception e) {          
            System.debug(logginglevel.error, e);
            return null;
        }
        if(tasks!=null) {
            polyTasks = new List<PolyTask>();
            for(Task t : tasks) {
                polyTasks.add( new polyTask(t));    
            }
        }
        return polyTasks;   
        
        return null;
    }
    */
    
    public static List<ServicedClientWrapper> retrieveTodaysServicedClients(Id uId) {
        List<ServicedClientWrapper> servicedClients = new List<ServicedClientWrapper>();
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('Last_Service_By__c').equals(uId));
        whereC.add(new al.FieldCondition('Last_Service_Date__c',new al.DateFormula().todayx()));    

		// ELC added because of weird exception being thrown with mailingAddress
		Set<String> ExcludeFields = new Set<String>();
		excludeFields.add('MailingAddress');
		excludeFields.add('OtherAddress');
        //@TODO what about clients where the last service date was set but.. the underlying case was deleted?
        //screw it for now.. no time with these roaming requirments.
        String soql = 
            new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Contact', false, excludeFields ))              
                .selectx(
                        new al.SoqlBuilder()
                        .selectx(SoqlUtils.getAllFieldsSet('Case',false))  
                        .fromx('Cases')
                        .limitx(1)
                        .orderByx(new al.OrderBy('Last_Contact__c').descending().nullsLast() )
                        )   
                .fromx  ('Contact')
                .wherex( whereC )               
                .orderByx(new al.OrderBy('Last_Service_Date__c').descending().nullsLast() )
                .limitx(100)
                .toSoql();  
        List<Contact> contacts; 
        System.debug(logginglevel.debug,soql);  
        try {
            contacts = Database.query(soql);
        } catch (Dmlexception e) {
            System.debug(logginglevel.error,e);
            return null;
        }   
        //rjn nov14 add
        /* doesn't really get to the root of the problem but should prevent a thrown exception*/
        try {            
        	if(contacts!=null && !contacts.isEmpty()) {	
            	for(Contact c : contacts) {
                	List<Case> cases;
                	Case latestCase;
                	if(c.cases != null && !c.cases.isEmpty() && (c.cases.size() > 0)) {
                    	cases = c.cases;
                    	latestCase = cases[0];
                	}
                		ServicedClientWrapper scWrap = new ServicedClientWrapper(c,latestCase);
                		servicedClients.add(scWrap);
            	}
        	}
        } catch (Exception e) {
        	String msg = ' Error in UserUtils.retrieveTodaysServicedClients for User: ' + UserInfo.getUserName();
        	String msgContacts = ' contacts = '+contacts;
        	Utilities.sendEmail('rnendza@gmail.com',msg + ' ' +Datetime.now(), '<br/>cause='+e.getCause() + '<br/>stacktracestring='+ e.getStackTraceString() + '<br/> query results='+ msgContacts
        						,'<br/>cause='+e.getCause() + '<br/>stacktracestring='+ e.getStackTraceString() + '<br/> query results='+ msgContacts);
        	System.debug(logginglevel.error, e);
        }   
        return  servicedClients;        
                
    }
 
    /**
     *
     *  
     */
    public static List<Case> retrieveCases(String lastServicedBy, String status, String rtDevName, Integer limitRows) {
        
        al.NestableCondition whereC = new al.AndCondition();        
        if(lastServicedBy != null && lastServicedBy != '-1') {
            whereC.add(new al.FieldCondition('Last_Service_By__c').equals(lastServicedBy));
        }
        whereC.add(new al.FieldCondition('status').equals(status));
        whereC.add(new al.FieldCondition('recordType.developername').equals(rtDevName));
        
        Set<String> sFields = new Set<String> {'id','casenumber','subject','contact.name','last_service_by__c','last_service_date__c','createdDate'};
        
        
        String soql = 
            new al.SoqlBuilder()
                .selectx(sFields)
                .fromx  ('Case')
                .wherex( whereC )
                .orderByx(new al.OrderBy('Last_service_date__c').descending().nullsLast())
                .limitx(limitRows)
                .toSoql();
        
        List<Case> cases;           
        try {
            cases = Database.query(soql);
        } catch (Dmlexception e) {
            System.debug(logginglevel.error,e);
        }                       
        return cases;
    }
    public static User retrieveUserTypeAndProfile(Id userId) {
        User u;
        List<User> users = [select id, type__c, profile.id, profile.name from User where id = :userId];
        if(!users.isEmpty()) {
            u = users[0];
        }
        return u;
    }
    public static List<News_Item__c> retrieveNewsItems(Integer limitRows) {
        List<News_Item__c> newsItems;
        Id currentUserId = UserInfo.getUserId();
        List<String> possibleTypes = new List<String>();
        possibleTypes.add('All');
        User u = [select id, type__c from user where id = :currentUserId];
        if(u.type__c != null) {
            possibleTypes.add(u.type__c);
        } else {

        }

        try {
            al.NestableCondition whereCOr = new al.OrCondition();

            whereCOr.add(new al.SetCondition('Type__c',al.Operator.INCLUDES, (possibleTypes )));
            whereCOr.add(new al.SetCondition('Type__c',al.Operator.INCLUDES, (new List<String>{'All'} )));

            String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('News_Item__c', false ))
                    .selectx((new Set<String> {'owner.name','createdby.name','lastmodifiedby.communitynickname' }))
                    .fromx  ('News_Item__c')
                    .wherex( whereCOr )
                    .orderByx(new al.OrderBy('CreatedDate').descending())
                    .limitx(limitRows)


                    .toSoql();
            newsItems = Database.query(soql);
            //newsItems = [   select  id, Description__c, End_Date__c,Is_Title_A_Link__c,Profile__c,Short_Desc__c,Title__c,Title_Url__c,Type__c,Urgent__c,View_More__c,owner.name,createdby.name
            //                from    News_Item__c
            //                where   type includes :possibleTypes ];

        } catch (Dmlexception e) {
            System.debug(logginglevel.error,e);
        }           
        return newsItems;
    }
    @future
    public static void insertContactFromUser(Id userId) {
        // This will be called from the trigger on User.  I could not do the insert inide of the trigger
        // because of mixed DML operations
        // @ELC TODO - Make this bulk safe??  But how??
        
        User u = [select lastName, firstName, Email, type__c from User where id = :userId];
        
        // if no type, don't create contact
        if (u.type__c == null) {
        	return;
        }
        
        Contact c = new Contact();
        
        c.lastName = u.LastName;
        c.FirstName = u.FirstName;
        c.Email = u.Email;
        // @ELC TODO - change this to look at profile and assign accordingly
        if (u.type__c.equals('Attorney') || u.type__c.equals('Paralegal') || u.type__c.equals('Supervisor') || u.type__c.equals('Staff')) {
        	c.Category__c = 'Staff';
        } else {
        	c.Category__c = 'Volunteer';
        }
        //c.Type__c = 'Attorney';
        c.Temp_Record__c = false;
        insert c;

    }
    /**
     *
     *
     * @param contactIds
     *
     * @return
     */
    public static List<User> retrieveUsersByContactIds(Set<Id> contactIds) {
        List<User> users = [SELECT  id, division,department,contactId,profile.name,
                                    Enable_Email_Notifications_for_Referrals__c
                            FROM    User
                            WHERE   contactId in :contactIds
                            and     isActive   =  true];
        return users;
    }

}