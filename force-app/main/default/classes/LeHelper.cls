/**
 * General Local Expert Helper class.
 *
 * note: we don't need no stinkin sharing.. actually can't use it as SFDC is ultra-protective with their chatter stuff
 * and licensing.
 */
public without sharing class LeHelper {

    /**
     * Given a set of feedcommentIds returns the feedcomment record as a map.
     *
     * @param feedCommentIds
     *
     * @return a Map with the feecomment id as the key and feedcomment record as the value.
     */
    public static Map<Id, FeedComment> retrieveFeedComments(Set<Id> feedCommentIds) {

        return new Map<Id, FeedComment>([
                select  id,feeditemid, parentid, insertedbyid,
                        insertedby.usertype,commentbody,createdbyid,insertedby.name
                from    feedcomment
                where   id in :feedCommentIds
        ]);
    }
    /**
     * Finds a Collobaration group by the name field and the networkId.
     *
     * @param groupName
     * @param networkId
     *
     * @return a single collaboration group record.
     */
    public static CollaborationGroup retrieveCollaborationGroup(String groupName, Id networkId) {
        return  [
                SELECT Id, Name, NetworkId, OwnerId
                FROM CollaborationGroup
                WHERE Name = :groupName
                and networkId = :networkId
        ];
    }
    /**
     *
     *
     * @param collabGroupIds
     *
     * @return a map of collaborationgroup objects key by recordid.
     */
    public static Map<Id, CollaborationGroup> retrieveCollaborationGroups(Set<Id> collabGroupIds) {

        return new Map<Id, CollaborationGroup>([
                select id, smallphotourl
                from CollaborationGroup
                where id in :collabGroupIds]);
    }
    /**
     *
     *
     * @param userIds
     *
     * @return
     */
    public static Map<Id,User> retrieveUsers(Set<Id> userIds ) {

        return new Map<Id,User>([
                select id, smallphotourl,name,firstname,lastname,username,companyname
                from User
                where id in :userIds]);
    }
    public static Account retrieveClientAccount(Id clientId) {
        Contact c = [select id, accountId,account.name from contact where id = :clientId];
        Account a = new Account(id=c.accountId,name=c.account.name);
        return a;
    }
    /*
    public static List<FeedItem> retrieveFeedItems(Id parentId, Set<Id> caseQuestionFeedItemIds) {
        Set<Id> parentIds = new Set<Id> {parentId};
        return retrieveFeedItems(parentIds,caseQuestionFeedItemIds);
    }
    */
    /**
     *
     *
     * @param parentId
     * @param caseQuestionFeedItemIds
     *
     * @return
     */
    public static List<FeedItem> retrieveFeedItems(Set<Id> parentIds, Set<Id> caseQuestionFeedItemIds) {
        return  [
                SELECT parent.type, parent.name, createdBy.name, BestCommentId,Body,CommentCount,
                        CreatedById,CreatedDate,parent.id,Id,InsertedById,LikeCount,LinkUrl,
                        NetworkScope,ParentId,RelatedRecordId,Title,Type,Visibility,CreatedBy.Type,
                        (
                        select CommentBody,CommentType,CreatedById,CreatedDate,FeedItemId,Id,
                                InsertedById,ParentId,Status,createdby.name,CreatedBy.Type
                        from FeedComments
                        order by createddate asc),
                        (
                        select Topic.Id, Topic.Name
                        from TopicAssignments
                        order by Topic.Name asc
                        ),
                        (
                        select Id, Title, Type, FeedEntityId,RecordId
                        from FeedAttachments
                        )
                FROM FeedItem
                WHERE parentid in :parentIds
                and id in :caseQuestionFeedItemIds
                ORDER BY createddate desc
        ];
    }
    /**
    *
    *
    * @param parentId
    * @param caseQuestionFeedItemIds
    *
    * @return
    */
    public static List<FeedItem> retrieveFeedItems(Id parentId, Set<Id> caseQuestionFeedItemIds) {
        return  [
                SELECT parent.type, parent.name, createdBy.name, BestCommentId,Body,CommentCount,
                        CreatedById,CreatedDate,parent.id,Id,InsertedById,LikeCount,LinkUrl,
                        NetworkScope,ParentId,RelatedRecordId,Title,Type,Visibility,CreatedBy.Type,
                (
                        select CommentBody,CommentType,CreatedById,CreatedDate,FeedItemId,Id,
                                InsertedById,ParentId,Status,createdby.name,CreatedBy.Type
                        from FeedComments
                        order by createddate asc),
                (
                        select Topic.Id, Topic.Name
                        from TopicAssignments
                        order by Topic.Name asc
                )
                FROM FeedItem

                WHERE parentId = :parentId
                and id in :caseQuestionFeedItemIds
                ORDER BY createddate desc
        ];
    }
    /**
     * Gets a single FeedItem and child topics. exception handeling resp is on the client.
     *
     * @param fiId
     *
     * @return a single FeedItem
     */
    public static FeedItem retrieveFeedItem(Id fiId) {
        return  [
                SELECT parent.type, parent.name, createdBy.name, BestCommentId,Body,CommentCount,
                        CreatedById,CreatedDate,parent.id,Id,InsertedById,LikeCount,LinkUrl,
                        NetworkScope,ParentId,RelatedRecordId,Title,Type,Visibility,CreatedBy.Type,
                        (
                        select CommentBody,CommentType,CreatedById,CreatedDate,FeedItemId,Id,
                                InsertedById,ParentId,Status,createdby.name,CreatedBy.Type
                        from FeedComments
                        order by createddate asc
                        ),
                        (
                        select Topic.Id, Topic.Name
                        from TopicAssignments
                        order by Topic.Name asc
                        ),
                        (
                        select Id, Title, Type, FeedEntityId,RecordId
                        from FeedAttachments
                        )
                FROM FeedItem
                WHERE id = :fiId
        ];
    }

    /**
     * Retrieves the network for that passed communityName;
     * AuraEnabled in case we won't to display it somewhere in F4J although
     * it's probably best to dump it in a DTO but just in case.
     *
     * @param communityName
     * @return a Network object.
     */
    @AuraEnabled
    public static Network retrieveCommunityNetwork(String communityName) {
        Network net;
        List<Network> networks = [select id,name,status from network where name = :communityName];
        if(!networks.isEmpty()) {
            net = networks[0];
        }
        return net;
    }
    /**
     * Retrieves the network for community stored in the custom setting. ie one to use for F4j. For now... until we go
     * multiple communities then. The it  probably needs to be tied to the running user somehow. and this method may be modified/overloaded
     *
     * @return a Network object.
     */
    public static Network retrieveRunningCommunityNetwork() {
        String communityName = '';
        try {
            communityName = (String) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'running_community_name__c');
        } catch (exception e) {
            system.debug(logginglevel.error,e);
        }
        return retrieveCommunityNetwork(communityName);
    }
}