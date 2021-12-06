public with sharing class GroupUtils {
	public static Boolean isGroupMember(String groupName) {
		Boolean isIt = false;
		Group g= GroupUtils.retrieveGroupByName(groupName);
		if(g!=null) {
			Set<Id> groupUserIds = GroupUtils.getUserIdsFromGroup(new Set<Id> {g.id});
			if(groupUserIds != null && !groupUserIds.isEmpty()) {
				if(groupUserIds.contains(UserInfo.getUserId())) {
					isIt = true;
				}
			}
		}
		return isIt;
	}
    public static Group retrieveGroupByName(String name) {
        Group g;
        
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('Name').equals(name));
        List<Group> groups = GroupUtils.retrieveGroups(whereC);     
        if(groups == null || groups.size() == 0) {
            return g;
        } 
        return groups[0];
    }
    public static List<User> retrieveGroupUsers( Group g) {
    	List<User> users;
    	
    	// elc 4/15/15
    	System.debug('in retrieveGroupUsers, group = '+g);
        if(g == null) {
            System.debug(logginglevel.warn, 'group parm cannot be null!');
            return null;
        }
        Set<Id> sUserIds =  getUserIdsFromGroup(new Set<Id> {g.id});
        List<Id> lUserIds = new List<Id>();
        if(sUserIds != null && !sUserIds.isEmpty()) {
        	for(ID uid : sUserIds) {
        		lUserIds.add(uid);
        	}
        }
        if(luserIds == null || luserIds.size() == 0) {
        	System.debug(logginglevel.warn, '--- No users belong to group:'+g.name);
        	return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.SetCondition('id',al.Operator.INX, (lUserIds)));
          
		String soql = new al.SoqlBuilder()
                        .selectx(SoqlUtils.getAllFieldsSet('User',true)) 
                        .fromx('User')
                        .wherex(whereC)
                        .toSoql();  
        try {
        	users  = Database.query (soql);           
        } catch (Exception e)  {
            system.debug(logginglevel.warn,'<b>ERROR IN User Soql..'+e.getMessage());
        }
        return users;     	
    }
    private static List<Group> retrieveGroups(  al.NestableCondition whereC ) {
        
        if(whereC == null) {
            System.debug(logginglevel.warn, 'whereC parm cannot be null!');
            return null;
        }
        List<Group> groups = new List<Group>();
        // ELC 4/15/15 - changed the isCreatableFields parameter to false.  The CARPLS Standard
        // User profile was tightened to not allow group creation, which caused this to fail when the 
        // parameter was true.
        system.debug('Field Set = '+ SoqlUtils.getAllFieldsSet('Group', false));
        String soql = '';
        try {
             soql = new al.SoqlBuilder()
                        .selectx(SoqlUtils.getAllFieldsSet('Group',false)) 
                        .fromx('Group')
                        .wherex(whereC)
                        .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            return null;
        }
        
        try {   
            system.debug(logginglevel.info,'<b>Group SOQL=</b>'+soql);  
            groups = Database.query (soql);         
        } catch (Exception e)  {
            system.debug(logginglevel.warn,'<b>ERROR IN Group Soql');
        }
        return groups;
    }
    
	public static Set<id> getUserIdsFromGroup(Set<Id> groupIds) {
    	// store the results in a set so we don't get duplicates
    	Set<Id> result=new Set<Id>();
    	String userType = Schema.SObjectType.User.getKeyPrefix();
    	String groupType = Schema.SObjectType.Group.getKeyPrefix();
    	
    	
    	Set<Id> groupIdProxys = new Set<Id>();
    	// Loop through all group members in a group
    	System.debug(logginglevel.warn, 'running soql with groupids='+groupIds);
    	
    	for(GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId in :groupIds]) {
        	// If the user or group id is a user
        	if(((String)m.UserOrGroupId).startsWith(userType)) {
        		System.debug(logginglevel.warn, 'id is of type user!');
	            result.add(m.UserOrGroupId);
    	    }
	        // If the user or group id is a group
    	    // Note: there may be a problem with governor limits if this is called too many times
	        else if (((String)m.UserOrGroupId).startsWith(groupType)) {
	        	System.debug(logginglevel.warn, 'id is of type group');
    	        // Call this function again but pass in the group found within this group
    	        
        	    groupIdProxys.add(m.UserOrGroupId);
        	} else {
        		System.debug(logginglevel.warn, 'what type is this id??'+m.userOrGroupId);
        	}
    	}
    	
    	
    	if(groupIdProxys.size() > 0) {
    		Set<Id> proxyIds = getUserIdsFromGroup(groupIdProxys);
    		if(proxyIds != null && proxyIds.size() > 0) {
        		result.addAll(proxyIds);
    		} else {
    			//for now assume we are going after roles!! WARNING DANGEROUS
    			List<Group> groups = [select id, relatedId, type from group where id in :groupIdProxys];
    			List<Id> roleIds = new List<Id>();
    			if(groups != null) {
    				for(Group g : groups) {
    					roleIds.add(g.relatedId);
    				}
    				if(!roleIds.isEmpty()) {
    					List<USer> users = [select id from user where userRoleId in :roleIds];
    					for(User u : users) {
    						result.add(u.id);
    					}
    				}
    				
    			}    		
    		}
    	}
    	return result;  
	}    

}