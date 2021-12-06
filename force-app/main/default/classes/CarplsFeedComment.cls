/**
 * CarplsFeedComment is meant as a wrapper for FeedComment so that we can add more information for display.
 */
global without sharing class CarplsFeedComment {

    @AuraEnabled
    global Carpls_Case_Answer__c  cca              {get;set;}
    @AuraEnabled
    global FeedComment            fc               {get;set;}
    @AuraEnabled
    global User                   fcCreatedByUser  {get;set;}
    @AuraEnabled
    global Boolean                isBestComment    {get;set;}
    //List<FeedComment>   fiComments     {get;set;}

    global CarplsFeedComment(FeedComment  aFc) {
        this.fc = aFc;
        this.isBestComment = false;
    }
}