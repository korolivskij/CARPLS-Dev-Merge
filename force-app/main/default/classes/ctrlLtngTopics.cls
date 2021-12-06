/**
 * RJN  added without sharing for display in community.
 */
public without sharing class ctrlLtngTopics {
    
    @AuraEnabled
    public static List<Topic> getRecentTopics() {
        Id comunityId = Network.getNetworkId();
		List<Topic> ts = [select Name, ID 
                      from topic 
                      where id in 
                      	(select TopicId 
                         from TopicAssignment 
                         where CreatedDate = LAST_N_DAYS:30 AND NetworkId =: comunityId) 
                      LIMIT 10];
            return ts;
    }

}