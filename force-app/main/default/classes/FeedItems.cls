public class FeedItems {

    public static Boolean inProcess = false; //ensure we don't have recursion.
    /**
     * Links chatter files attached to the case to the Collaboration.
     * Group 'Case Documents - Read Only' to ensure visibility to all users.
     * When a feeditem is inserted and attached to the case, a 2nd
     * one is inserted with a parentId of a collaboration group.  Essentially,
     * SFDC does it's black magic and as a parent of both the case and the group.
     *
     * Note: this is a future method.. so it may not be visibile within a second.
     *
     * @param fiIds..   A set of feed item items.
     */
    @future
    public static void linkCaseChatterFilesToOrg(Set<Id> fiIds) {

        if (inProcess) {
            return;
        }

        inProcess = true;
        List<FeedItem> feedItems = [
                select id, type, RelatedRecordId, parentId, title, body
                from FeedItem
                where id in :fiIds and type = 'ContentPost'
        ];

        if (feedItems == null || feedItems.isEmpty()) {
            return;
        }
        String caseKeyPrefix = Case.sObjectType.getDescribe().getKeyPrefix();
        List<FeedItem> caseFeedItems = new List<FeedItem>();
        for (FeedItem fi : feedItems) {
            if (fi.RelatedRecordId == null) {
                continue;
            }
            if (String.valueOf(fi.parentId).startsWith(caseKeyPrefix)) {
                caseFeedItems.add(fi);
            }
        }
        List<FeedItem> newFeedItems = new List<FeedItem>();

        if (!caseFeedItems.isEmpty()) {
            CollaborationGroup gp;

            try {
                String name = '';
                if (Test.isRunningTest()) {
                    name = 'Case Documents - Read Only - UNIT TEST';
                } else {
                    name = 'Case Documents - Read Only';
                }

                gp = [Select OwnerId, Id From CollaborationGroup Where Name = :name];
            } catch (Exception e) {
                system.debug(logginglevel.error, e);
                return;
            }

            for (FeedItem caseFi : caseFeedItems) {
                FeedItem newFi = new FeedItem();

                newFi.ParentId = gp.id;
                newFi.RelatedRecordId = caseFi.RelatedRecordId;
                newFi.Title = caseFi.title;
                newFi.Body = caseFi.body;
                newFi.Type = caseFi.Type;

                newFeedItems.add(newFi);
            }
        }
        if (!newFeedItems.isEmpty()) {
            try {
                insert newFeedItems;
                system.debug(logginglevel.debug, 'Total feeditems inserted=' + newFeedItems.size());
            } catch (Exception e) {
                system.debug(logginglevel.error, e);
            }
        }

    }
    /**
     * Find any corresponding Carpls_Case_Question.feedItem and flag as deleted but to not hard delete
     *
     * @param mFiId_FeedItem  <FeedItemId,FeedItem Object>
     * @return Integer indicating number of records flags as deleted.
     */
    public static integer flagCcqsAsDeleted(Map<Id, FeedItem> mFiId_FeedItem) {
        integer numFlagged = 0;

        Map<Id, Carpls_Case_Question__c> mCcqId_CCQ = new Map<Id, Carpls_Case_Question__c>(
                [   select  id, feeditemid__c,Chat_Deleted__c
                    from    carpls_case_question__c
                    where   feeditemid__c in :mFiId_FeedItem.keyset()
                ]);

        if(!mCcqId_CCQ.isEmpty()) {
            List<Carpls_Case_Question__c> ccqsToFlag = new List<Carpls_Case_Question__c>();

            for(id ccqId : mCcqId_CCQ.keySet()) {
                Carpls_Case_Question__c ccq = mCcqId_CCQ.get(ccqId);
                ccq.Chat_Deleted__c = true;
                ccqsToFlag.add(ccq);
            }
            try {
                update ccqsToFlag;
                numFlagged = ccqsToFlag.size();
            } catch (exception e) {
                system.debug(logginglevel.error, e);
            }
        }
        return numFlagged;
    }
}