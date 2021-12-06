/**
 * CarplsFeedItem is meant as a wrapper for FeedItem so that we can add more information for display.
 */
global without sharing class CarplsFeedItem {
    @AuraEnabled
    global Carpls_Case_Question__c  ccq              {get;set;}
    @AuraEnabled
    global FeedItem            fi               {get;set;}
    @AuraEnabled
    global User                fiParentUser     {get;set;}
    @AuraEnabled
    global CollaborationGroup  fiParentCg       {get;set;}
    @AuraEnabled
    global Account             fiParentAcct     {get;set;}
    @AuraEnabled
    global Applied_Resource__c fiParentAr       {get;set;}  
    @AuraEnabled
    global User                fiCreatedByUser  {get;set;}
    @AuraEnabled
    global Id                  bestCommentId  {get;set;}
    @AuraEnabled
    global List<CarplsFeedComment>    fiCarplsFeedComments  {get;set;}

    global CarplsFeedItem(FeedItem  aFi) {
        this.fi = aFi;
        this.buildFeedComments(aFi.FeedComments);
    }
    /**
     * @TODO make bulk safe..
     *
     * @param fcs
     */
    private void buildFeedComments(List<FeedComment> fcs) {
        this.fiCarplsFeedComments = new List<CarplsFeedComment>();
        //try {
            if (fcs != null && !fcs.isEmpty()) {
                Set<Id> createdbyIds = new Set<Id>();
                Set<Id> fcIds = new Set<Id>();
            //}
                for (FeedComment fc : fcs) {
                    if (fc.createdby.type == 'User') {
                       createdByIds.add(fc.createdById);
                    }
                    if(fc.Id != null) {
                        fcIds.add(fc.Id);
                    }
                }

                Map<Id, Carpls_Case_Answer__c> mCcaId_CCA = new Map<Id,Carpls_Case_Answer__c> ([ select id, feedcommentid__c, carpls_case_question__c, isbestcomment__c,case__c
                from Carpls_Case_Answer__c
                where feedcommentid__c  in :fcIds]);

                Map<String, Carpls_Case_Answer__c> mFcId_CCA = new Map<String,Carpls_Case_Answer__c>();

                if(!mCcaId_CCA.isEmpty()) {
                    for(ID ccaId : mCcaId_CCA.keySet()) {
                        Carpls_Case_Answer__c cca = mCcaId_CCA.get(ccaId);
                        mFcId_CCA.put(cca.FeedCommentId__c, cca);
                    }
                }


                if (!createdbyIds.isEmpty()) {
                    //@todo really bad to run this soql in constructor we need to get this out.
                    Map<Id, User> mUid_createdByUSer = new Map<Id, User>([
                            select id, smallphotourl,name,firstname,lastname,username,companyname
                            from User
                            where id in :createdbyIds
                    ]);
                    if (!mUid_createdByUSer.isEmpty()) {
                        for (FeedComment fc : fcs) {
                            CarplsFeedComment cfc = new CarplsFeedComment(fc);
                            if(mFcId_CCA.containsKey(fc.Id)) {
                                cfc.cca = mFcId_CCA.get(fc.Id);
                            }

                            for (Id uId : mUid_createdByUSer.keySet()) {
                                if (mUid_createdByUSer.containsKey(fc.createdbyid)) {
                                    //if(fc.createdById == mUid_createdByUSer.get(fc.createdbyid)) {

                                        cfc.fcCreatedByUser = mUid_createdByUSer.get(fc.createdbyid);



                                    //if(fi.BestCommentId == cfc.fc.Id) {
                                     //   cfc.isBestComment = true;
                                    //} else {
                                    //    cfc.isBestComment = false;
                                   // }

                                        fiCarplsFeedComments.add(cfc);
                                        break;
                                    //}
                                }
                            }
                        }
                    }


                }

            }
        //} catch (exception e) {
        //    system.debug(e);
        //}
    }
}