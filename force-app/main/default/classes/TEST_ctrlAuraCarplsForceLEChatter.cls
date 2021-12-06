@IsTest
private without sharing class TEST_ctrlAuraCarplsForceLEChatter {

    public static   User                uTstExecUser                    { get; set; }
    public static   PageReference       prResourses                     { get; set; }
    public static   Contact             newClient                       { get; Set; }
    public static   Search_Log__c       newSlClient                     { get; set; }
    public static   Case                newCase                         { get; Set; }
    public static   List<Case_Party__c> newCaseParties                  { get; Set; }
    public static   Subject__c          newSubject                      { get; set; }

    public static   CaseUtils			caseUtils					    { get; set; }

    static testMethod void executeTest() {
        Datetime   dtTstStart        = Datetime.now();
        caseUtils = new CaseUtils();

        //--- community user stuff?
        //String pName = 'IL-AFLAN Community User';  //has to exist in prod!! for now just use sys admin..
        String pName = 'System Administrator';
        Profile pCommunityAflan = [select id,name from profile where name = :pName];



        newClient = TEST_TestUtils.createContact('Client');
        newClient = [select id, county__c from contact where id = :newClient.id];
        newClient.county__c = 'Rock Island'; //west region.....
        update newClient;


        User userAflan = new User(alias = '123xxxx', email='test123xxxx@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = pCommunityAflan.id, country='United States',IsActive =true,
        /*ContactId = newClient.Id,*/
        timezonesidkey='America/Los_Angeles', username='xxxxxtester@noemail.com');
        insert userAflan;

        //----

        prResourses = Page.vfResources;
        Profile adminProfile = [select id from Profile where name = 'System Administrator'];
        TEST_TestUtils.SecSettings sec = new TEST_TestUtils.SecSettings('', adminProfile.id,'', '' );
        uTstExecUser = TEST_TestUtils.getUserForTest(sec, dtTstStart);
        System.debug(logginglevel.warn, ' ---------------> Running Test with User:'+uTstExecUser);

        //-- If no org level custom setting a new one will be created..
        TEST_TestUtils.ensureCustomSettingsExist(uTstExecUser);
        Carplsv20Settings__c customSetting = Carplsv20Settings__c.getInstance(uTstExecUser.id);
        System.debug(logginglevel.warn, ' ---------------> Running Test with Custom Settings:'+customSetting);


        newSubject = new Subject__c();
        newSubject.Title__c = 'Unit Test Case Subject';
        newSubject.Practice_Area__c = 'pa1';
        newSubject.Problem_Category__c = 'pcat1';
        newSubject.Problem_Code__c = 'pc1';
        newSubject.Jurisdiction__c = 'jur1';
        newSubject.Status__c = 'Active';
        newSubject.Type__c = 'Pending';
        newSubject.Litigation__c = 'Pending';
        insert newSubject;


        newSlClient = new Search_Log__c(last_name__c = 'Unit Test Last');
        insert newSlClient;
        newCase = TEST_TestUtils.createNewClientPartyCase(newClient);
        newCase.problem_code__c = 'pc1';
        update newCase;
        newCaseParties = caseUtils.retrieveCaseParties(newCase);

        Network network = [select id, name from network where name = 'IL-AFLAN'];
        system.debug('----------- network ='+network);

        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'West Region UNIT TEST';
        cg.CollaborationType = 'Private';
        cg.networkId = network.id;
        insert cg;

        //CollaborationGroupMember cgm = new CollaborationGroupMember();
        //cgm.

        system.debug('rjntestdebug newtwork='+network.id);

        List<Topic> topics = new List<Topic>();
        Topic topicPc1 = new Topic();
        topicPc1.Name = newCase.problem_code__c;
        topicPc1.Networkid = network.id;
        topics.add(topicPc1);
        insert topics;



        Test.startTest();
        System.runAs(uTstExecUser) {

            ResponseDTO  dtoCg = ctrlAuraCarplsForceLEChatter.retrieveCollaborationGroup('West Region UNIT TEST',network.id);
            system.assert( dtoCg.values.get('CollaborationGroup') != null );
            ResponseDTO dtoCgTmp = ctrlAuraCarplsForceLEChatter.retrieveCollaborationGroup('West Region UNIT TEST', network.id, newClient.id);
            //@TODO proper assert.

            ResponseDTO  dtoFail= ctrlAuraCarplsForceLEChatter.retrieveCollaborationGroup('Totally bogus name',network.id);
            system.assert( dtoFail.values.get('CollaborationGroup') == null );

            FeedItem fi = new FeedItem(title='q1', body='<b>more details body</b>',parentId=cg.id,networkscope=network.id);
            system.debug('--- test fi='+fi);
            ResponseDTO dtoFi = ctrlAuraCarplsForceLEChatter.createFeedItem(fi,newCase.id,network);
            system.assert(dtoFi.values.get('FeedItem') != null);
            //like it.
            ResponseDTO dtoLike = ctrlAuraCarplsForceLEChatter.createFeedLike( ((FeedItem)dtoFi.values.get('FeedItem')).id);
            system.assert(dtoLike.isSuccess);
            ResponseDTO dtoLikeAgain = ctrlAuraCarplsForceLEChatter.createFeedLike( ((FeedItem)dtoFi.values.get('FeedItem')).id);
            system.assert(!dtoLikeAgain.isSuccess);
            system.assert(dtoFi.values.get('Carpls_Case_Question__c') != null);



            dtoFail = ctrlAuraCarplsForceLEChatter.createFeedItem(new FeedItem(),newCase.id,network);
            system.assert(dtoFail.values.get('FeedItem') == null);
            dtoFail = ctrlAuraCarplsForceLEChatter.createFeedItem(null,newCase.id,network);
            system.assert(dtoFail.values.get('FeedItem') == null);


            FeedItem createdFi = (FeedItem)dtoFi.values.get('FeedItem');
            Carpls_Case_Question__c createdCcq = (Carpls_Case_Question__c)dtoFi.values.get('Carpls_Case_Question__c');
            List<CarplsFeedItem> cfis = ctrlAuraCarplsForceLEChatter.retrieveQuestions(cg.id, newCase.id);
            system.assert(!cfis.isEmpty());

            FeedComment fc = new FeedComment(feeditemId = createdFi.id,commentbody = '<b>comment body</b>' );
            ResponseDTO dtoFc = ctrlAuraCarplsForceLEChatter.createFeedComment(fc,null);

            system.assert(dtoFc.values.get('FeedComment') != null);

            cfis = ctrlAuraCarplsForceLEChatter.retrieveQuestions(cg.id, newCase.id);
            createdCcq.Best_Answer__c = cfis[0].fiCarplsFeedComments[0].cca.id;
            ctrlAuraCarplsForceLEChatter.updateCarplsCaseQuestion(createdCcq);
            Carpls_Case_Answer__c cca = [select id,IsBestComment__c from carpls_case_answer__c where feedcommentid__c = :cfis[0].fiCarplsFeedComments[0].fc.id];
            system.assert(cca.isbestcomment__c);

            createdFi.body = 'lets update the body';
            system.assert(ctrlAuraCarplsForceLEChatter.updateFeedItem(createdFi).isSuccess);

            //=========  Fun with topics ====================
            FeedItem fiWTopic = new FeedItem(title='q2', body='<b>qs with a topic</b>',parentId=cg.id,networkscope=network.id);
            ResponseDTO dtoFiWTopic = ctrlAuraCarplsForceLEChatter.createFeedItem(fiWTopic,newCase.id,network);
            //system.assert(dtoFiWTopic.values.get('TopicAssignments') != null);
            //no topic found
            ResponseDTO tDTOmissing = ctrlAuraCarplsForceLEChatter.assignTopics(fiWTopic, network, new List<String>{'bogus problem code'} );
            system.assert(tDTOmissing.message.contains('Count not find topic records for topic strings passed'));
            //make it blow up with an exception
            FeedItem fiBoom = new FeedItem();
            ResponseDTO tDTOex = ctrlAuraCarplsForceLEChatter.assignTopics(fiBoom, network, new List<String>{newCase.problem_code__c});
            system.assert(tDTOex.severity == 'error');

            //parent a feed item by a user and not a cg..
            FeedItem fiMe = new FeedItem(title='q3', body='<b>this is for me and not the group</b>',parentId=uTstExecUser.id,networkscope=network.id);
            ResponseDTO dtoFiMe = ctrlAuraCarplsForceLEChatter.createFeedItem(fiMe,newCase.id,network);
            system.assert(dtoFiMe.values.get('FeedItem') != null);
            CarplsFeedItem cfiMe = ctrlAuraCarplsForceLEChatter.retrieveQuestions(uTstExecUser.id,newCase.id)[0];
            system.assert(cfiMe.fiParentUser != null);

            //random bad arg passing
            List<Id> emptyList = new List<Id>();
            Set<Id> emptySet = new Set<Id>();
            ctrlAuraCarplsForceLEChatter.retrieveQuestions(emptyList, newCase.id);
            ctrlAuraCarplsForceLEChatter.retrieveQuestions(emptySet, newCase.id);
            ctrlAuraCarplsForceLEChatter.retrieveQuestions(cg.id, null);


            //fire trigger
            createdCcq.Unanswered_after_x_days__c = true;
            update createdCcq;
            
            //fire trigger
            update cfis[0].fiCarplsFeedComments[0].cca;

            //fire trigger
            delete createdCcq;



        }
        Test.stopTest();
    }
}