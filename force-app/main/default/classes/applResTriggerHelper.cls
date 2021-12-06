/* ELC 11/11/20: Added New Leaf Referral handling */

public class applResTriggerHelper {
    /**
     * Requirement:
     * " Buttom line, if a partner rejects a referral for any reason, it should bounce back to CARPLS for follow up.
     *  That includes referrals that time out (when we activate that feature) when partners don’t take any action in the set time – 7 days.
     *  The best way to do this is a task to the ILAFLAN POC. The subject of the task can be “IL-AFLAN Referral Rejected”.
     *  The trigger would be set on the Status=Closed; Closing Code=Denied Service."
     *
     * @param rejectedArs
     */
    public static void createRejectedAflanReferralTasks(Set<Applied_Resource__c> rejectedArs) {
        List<Task> newTasks = new List<Task>();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task', 'System_Assigned');
        //Id pocId = Activity.retrieveOnCallPersonBySupportType('AOC-IL-AFLAN');
        List<Group> grpIDLst = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AOC_IL_AFLAN' LIMIT 1];
        if (grpIDLst.isEmpty()) {
            System.debug('Creating task for rejected referral. No aoc found');
        } else {
            System.debug('Creating task for rejected referral. rt = ' + rt );
            for (Applied_Resource__c ar: rejectedArs) {
                Task t = new Task();
                t.ActivityDate = System.now().date();
                t.Subject = 'IL-AFLAN Referral Rejected';
                t.Priority = 'Normal';
                t.type = 'Task';
                t.WhatId = ar.id;
                t.OwnerId = grpIDLst[0].id;
                t.Status = 'Open';
                t.Group__c = 'POC-IL-AFLAN';
                //On second thought, we decided the Task created when an ILAFLAN referral is rejected should go to the AOC – ILAFLAN, instead of the POC-ILAFLAN. Can you pull the lever to make the changes. Thanks
                t.Group__c = 'AOC-IL-AFLAN';
                t.recordTypeId = rt.id;
                newTasks.add(t);
            }
            if(!newTasks.isEmpty()) {
                try {
                    insert newTasks;
                } catch (Exception e) {
                    system.debug(logginglevel.error,e);
                }
            }
        }
    }
    // Need another method for CC because the task will be assigned to AOC instead of AFLAN AOC
    public static void createRejectedCcReferralTasks(Set<Applied_Resource__c> rejectedArs) {
        List<Task> newTasks = new List<Task>();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task', 'System_Assigned');
        //Id aocId = Activity.retrieveOnCallPersonBySupportType('AOC');
        List<Group> grpIDLst = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AOC' LIMIT 1];
        if (grpIDLst.isEmpty()) {
            System.debug('Creating task for rejected referral. No aoc found');
        } else {
            System.debug('Creating task for rejected referral. rt = ' + rt );
            for (Applied_Resource__c ar: rejectedArs) {
                Task t = new Task();
                t.ActivityDate = System.now().date();
                t.Subject = 'Electronic Referral Rejected';
                t.Priority = 'Normal';
                t.type = 'Task';
                t.WhatId = ar.id;
                t.OwnerId = grpIDLst[0].id;
                t.Status = 'Open';
                t.Group__c = 'AOC';
                t.recordTypeId = rt.id;
                newTasks.add(t);
            }
            if(!newTasks.isEmpty()) {
                try {
                    insert newTasks;
                } catch (Exception e) {
                    system.debug(logginglevel.error,e);
                }
            }
        }
    }

    // Need another method for New Leaf because the task will be assigned to New Leaf AOC instead of AFLAN AOC
    public static void createRejectedNewLeafReferralTasks(Set<Applied_Resource__c> rejectedArs) {
        List<Task> newTasks = new List<Task>();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task', 'System_Assigned');
        //Id aocId = Activity.retrieveOnCallPersonBySupportType('AOC-New-Leaf');
        List<Group> grpIDLst = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AOC_New_Leaf' LIMIT 1];
        if (grpIDLst.isEmpty()) {
            System.debug('Creating task for rejected referral. No aoc found');
        } else {
            System.debug('Creating task for rejected referral. rt = ' + rt  + 'grpIDLst[0].id== ' + grpIDLst[0].id );
            for (Applied_Resource__c ar: rejectedArs) {
                Task t = new Task();
                t.ActivityDate = System.now().date();
                t.Subject = 'Electronic Referral Rejected';
                t.Priority = 'Normal';
                t.type = 'Task';
                t.WhatId = ar.id;
                t.OwnerId = grpIDLst[0].id;
                t.Status = 'Open';
                t.Group__c = 'NL AOC';
                t.recordTypeId = rt.id;
                newTasks.add(t);
            }
            if(!newTasks.isEmpty()) {
                try {
                    insert newTasks;
                } catch (Exception e) {
                    system.debug(logginglevel.error,e);
                }
            }
        }
    }

    // Need another method for New Leaf because the task will be assigned to New Leaf AOC instead of AFLAN AOC
    public static void createRejectedCCLAHDReferralTasks(Set<Applied_Resource__c> rejectedArs) {
        List<Task> newTasks = new List<Task>();

        RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Task', 'System_Assigned');
        //Id aocId = Activity.retrieveOnCallPersonBySupportType('AOC-New-Leaf');

        List<Group> grpIDLst = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AOC_CCLAHD' LIMIT 1];
        if (grpIDLst.isEmpty()) {
            System.debug('Creating task for rejected referral. No aoc found');
        } else {
            System.debug('Creating task for rejected referral. rt = ' + rt  + 'grpIDLst[0].id== ' + grpIDLst[0].id);

            for (Applied_Resource__c ar: rejectedArs) {
                Task t = new Task();
                t.ActivityDate = System.now().date();
                t.Subject = 'Electronic Referral Rejected';
                t.Priority = 'Normal';
                t.type = 'Task';
                t.WhatId = ar.id;
                t.OwnerId = grpIDLst[0].id;
                t.Status = 'Open';
                t.Group__c = 'AOC-CCLAHD';
                t.recordTypeId = rt.id;
                system.debug('taskIhor: ' + t);
                newTasks.add(t);
            }
            if(!newTasks.isEmpty()) {
                try {
                    insert newTasks;
                } catch (Exception e) {
                    system.debug(logginglevel.error,e);
                }
            }
        }
    }
    /**
     * Email notifications – Al would like users to be able to self-select whether they get emails notifying them of new
     * referrals to their agency. This will need to be done with a trigger, as the WFRs only allow us to send to explicitly
     * named email addresses. Following steps will be needed:
     * 1. Addition of a checkbox to the user record accessible in community
     * 2. Trigger will select all contacts associated with the account that are users and have that box checked in their user record.
     * 3. If possible would like to send by county for Prairie State and Land of Lincoln
     *
     * whatId = AR record id.
     * whoId  = contact id.
     *
     * @param newArs newly inserted (after insert)Ars that qualify to send this email.
     */
    public static void sendReferralEmails(List<Applied_Resource__c> newArs,String IlAflanOrCarplsConnect) {
        system.debug('123');
        List<OutBound_Emails__mdt> mdtEmails = CustomMdtUtil.getOutboundEmailsMdts(true,'New Referral');
        System.debug('mdtEmails>>>' +mdtEmails );

        if(mdtEmails.isEmpty()) {
            system.debug('--- emailSend new referral no mdt found in Outbound_Email that is active and type of New Referral.. exiting');
            return;
        }
        //--- there might be more then one but for now. lets just assume 1.
        //--- modified by MK 02/26/2020, added separation for carpls connect and il-aflan referrals.
        OutBound_Emails__mdt mdtEmail;
        for(OutBound_Emails__mdt item:mdtEmails)
        {
            if(item.DeveloperName=='Carpls_Connect_New_Referral_Emails' && IlAflanOrCarplsConnect=='CARPLS Connect')
                mdtEmail=item;
                else if(item.DeveloperName=='IL_AFLAN_New_Referral_Emails' && IlAflanOrCarplsConnect=='IL-AFLAN')
                    mdtEmail=item;
                    else if(item.DeveloperName=='New_Leaf_New_Referral_Emails' && IlAflanOrCarplsConnect=='New Leaf')
                        mdtEmail=item;
                        else if(item.DeveloperName=='New_CCLAHD_Referral_Emails' && IlAflanOrCarplsConnect=='CCLAHD')
                            mdtEmail=item;
        }
        system.debug('IlAflanOrCarplsConnect->'+IlAflanOrCarplsConnect+' mtd row->'+mdtEmail);
        Set<Id> acctIds = new Set<Id>();
        Map<Id,List<Applied_Resource__c>> mAcctId_Ars = new Map<Id,List<Applied_Resource__c>>();
        //--- seperate the Applied resources by Account.
        for(Applied_Resource__c ar : newArs) {
            system.debug('line 152 parent id->'+getParentAccountId(ar.Account__c));
            system.debug('---- emailsend ar='+ar);
            if (ar.Is_IL_AFLAN_Referral__c || ar.Is_CARPLS_Connect_referral__c || ar.Is_New_Leaf_Referral__c || ar.Is_CCLAHD_Referral__c) {
                if(ar.account__c != null) {
                    acctIds.add(ar.Account__c);
                    if (!mAcctId_Ars.containsKey(ar.account__c)) {
                        mAcctId_Ars.put(ar.Account__c, new List<Applied_Resource__c> {ar});
                    }
                    else{
                        mAcctId_Ars.get(ar.account__c).add(ar);
                    }
                }
                if(getParentAccountId(ar.Account__c) != null){
                    if (!mAcctId_Ars.containsKey(getParentAccountId(ar.Account__c))) {
                        mAcctId_Ars.put(getParentAccountId(ar.Account__c), new List<Applied_Resource__c> {ar});
                    }
                    else{
                        mAcctId_Ars.get(getParentAccountId(ar.Account__c)).add(ar);
                    }
                }
                    
            }
        }
        System.debug('Danylo acctIds' + acctIds);
        if(acctIds.isEmpty()) {
            String sBody = '--- emailSend new referral. no acctIds for for newArs:'+newArs + ' exiting';
            system.debug(sBody);
            Utilities.sendEmail(new List<String>{'support@provisiopartners.com'}, 'AR Email Exit', sBody, sBody);
            return;
        }
        //??????????????????????????????????????????????????????????????
        
        List<id> contactId = new List<Id>();
        Map<id, List<id>> mAccIdContacts = new Map<id, List<id>>();
        for(AccountContactRelation acr : [SELECT id, AccountId, ContactId 
                                            FROM AccountContactRelation 
                                            WHERE AccountID IN :acctIds]){
            if(mAccIdContacts.containsKey(acr.AccountId)){
                contactId = mAccIdContacts.get(acr.AccountId);
                contactId.add(acr.ContactId);
                mAccIdContacts.put(acr.AccountId, contactId);
            }else {
                mAccIdContacts.put(acr.AccountId, new List<id> { acr.ContactId});
                contactId.add(acr.ContactId);
            }                                   


        }
        Set<Id> contactIds = new Set<Id>(contactId);
        //Map<ID, Contact> mapofContacts = new Map<ID, Contact>([SELECT Id, Related_User__c FROM Contact WHERE Id IN :contactIds]);
        system.debug('mAcctId_Contacts=Size== ' + mAccIdContacts.size());
        system.debug('mAcctId_Contacts= ' + mAccIdContacts);
        system.debug('contactIds= ' + contactIds);


        //////////////////////////////////////////////////////
       
       /* Map<Id,List<Contact>> mAcctId_Contacts = new Map<Id,List<Contact>>();
        List<Account> arsAccounts = retrieveAccountsAndContacts(acctIds);

        Set<Id> contactIds = new Set<Id>();
        //---- create a map of account id / contacts..
        for(Account a : arsAccounts) {
            Boolean useIt = false;
            if(mdtEmail.Use_Account_Community_Activated_Checkbox__c) {
                if(a.community_activated__c) {
                    useIt = true;
                } else {
                    useIt = false;
                    system.debug(logginglevel.warn,'community not activated for account.. bypassing. acct='+a.id);
                    continue;
                }
            } else {
                useIt = true;
            }
            if(a.contacts != null && !a.contacts.isEmpty()) {
                useIt = true;
                for(Contact c : a.contacts) {
                    contactIds.add(c.id);
                    if(!mAcctId_Contacts.containsKey(a.id)) {
                        mAcctId_Contacts.put(a.id,new List<Contact> {c});
                    } else {
                        List<Contact> contacts = mAcctId_Contacts.get(a.id);
                        contacts.add(c);
                    }
                }
            }
        }*/
        //////////////////>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        system.debug('-- emailSend new referral contactIds='+contactIds);
        Map<Id,User> mContactId_User = new Map<Id,User>();
        //---- map contact id to a user sObj
        List<User> users = UserUtils.retrieveUsersByContactIds(contactIds);
        if(users.isEmpty()) {
            String sBody = '---- emailSend new referral no users in acct for contactIds:'+contactIds+' that are active.';
            system.debug(sBody);
            Utilities.sendEmail(new List<String>{'stepanmahdziak@gmail.com'}, 'AR Email Exit', sBody, sBody);
            return;
        }
        for(User u : users) {
            mContactId_User.put(u.contactId,u);
        }
        system.debug('--- emailSend new referral mContactId User='+mContactId_User);

        //------------ department / county mapping
        Map<String,Set<String>> mDepartmentName_Counties = new Map<String,Set<String>>();
        List<Department__mdt> deptsAndCountiesMdts = CustomMdtUtil.getDepartmentsAndCountiesMdts();

        if(!deptsAndCountiesMdts.isEmpty()) {
            for(Department__mdt dept : deptsAndCountiesMdts) {
                List<County__mdt> mdtCounties = dept.Counties__r;
                if(mdtCounties != null && !mdtCounties.isEmpty()) {
                    for(County__mdt  mdtCounty : mdtCounties) {
                        if (!mDepartmentName_Counties.containsKey(dept.label)) {
                            mDepartmentName_Counties.put(dept.label, new Set<String>{mdtCounty.county_name__c});
                        } else {
                            Set<String> counties = (Set<String>)mDepartmentName_Counties.get(dept.label);
                            counties.add(mdtCounty.county_name__c);
                        }
                    }
                }
            }
        }
        system.debug('---- emailSend new referral mDepartmentName counties='+ mDepartmentName_Counties);

        Map<Id,Set<Id>> mWhatId_WhoIds = new Map<Id,Set<Id>>();
        List<String> restrictAcctIds = new List<String>();
        if(mdtEmail.Restrict_By_Department__c && mdtEmail.Restrict_ByDept_Acct_Ids__c != null ) {
            restrictAcctIds = mdtEmail.Restrict_ByDept_Acct_Ids__c.split('~');
        }
        system.debug('----- emailSend new referral restrictAcctIds:'+restrictAcctIds);
        system.debug('-----mAcctId_Ars ->'+mAcctId_Ars);
        //system.debug('--- mAcctId_Contacts ->'+mAcctId_Contacts);

        for (Id acctId : mAcctId_Ars.keySet()) {
            List<Applied_Resource__c> acctArs = mAcctId_Ars.get(acctId);
            for (Applied_Resource__c acctAr : acctArs) {
                if (mAccIdContacts.containsKey(acctId)) {
                    //all the contacts in the acct....
                    List<ID> contacts = (List<ID>) mAccIdContacts.get(acctId);
                    system.debug('Contacts->'+contacts);
                    for (ID c : contactIds) {
                        if (mContactId_User.containsKey(c)) {
                            //only those we should email email to
                            User u = mContactId_User.get(c);
                            //if not email enabeled that skip / continue loop
                            if (mdtEmail.Email_Opt_in_User_Field__c != null) {
                                if (u.Enable_Email_Notifications_for_Referrals__c != true) {
                                    continue;
                                }
                            }
                            if (mdtEmail.Restrict_By_Department__c == true && mdtEmail.Restrict_ByDept_Acct_Ids__c != null) {
                                if (restrictAcctIds.contains(acctAr.account__c) && (u.department != 'Administrative')) {
                                    system.debug('--- emailsend restricing for the following accts.. ' + restrictAcctIds);
                                    if (u.department != null && mDepartmentName_Counties.containsKey(u.department)) {
                                        Set<String> counties = mDepartmentName_Counties.get(u.department);
                                        if (counties.contains(acctAr.client_county__c)) {
                                            if (!mWhatId_WhoIds.containsKey(acctAr.id)) {
                                                mWhatId_WhoIds.put(acctAr.id, new Set<Id>{
                                                        c
                                                });
                                            } else {
                                                Set<Id> whoIds = mWhatId_WhoIds.get(acctAr.id);
                                                whoIds.add(c);
                                            }
                                        }
                                    } else {
                                        system.debug('--- emailsend no department match for user department.. ' + u.department);
                                    }
                                } else {
                                    if (!mWhatId_WhoIds.containsKey(acctAr.id)) {
                                        mWhatId_WhoIds.put(acctAr.id, new Set<Id>{
                                                c
                                        });
                                    } else {
                                        Set<Id> whoIds = mWhatId_WhoIds.get(acctAr.id);
                                        whoIds.add(c);
                                    }
                                }
                            } else {
                                //nothing stopping us send it.
                                if (!mWhatId_WhoIds.containsKey(acctAr.id)) {
                                    mWhatId_WhoIds.put(acctAr.id, new Set<Id>{
                                            c
                                    });
                                } else {
                                    Set<Id> whoIds = mWhatId_WhoIds.get(acctAr.id);
                                    whoIds.add(c);
                                }
                            }
                        }
                    }
                }
            }
        }

        system.debug('---- emailsend whatIds_whoIds:'+mWhatId_WhoIds);
        if(!mWhatId_WhoIds.isEmpty()) {
            // Use Organization Wide Address
            Id owaNoReplyId;
            for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
                if(owa.Address.contains('noreply')) {
                    owaNoReplyId = owa.id;
                }
            }

        // Mykhailo Kovalyov 01.27.2020, ignore not actvie Contacts or Contacts with Bounced indicator, ids to ignore are in conToIgnore set.
        Set<Id> conToIgnore= new Set<Id>();
        Set<Id> allContactsIds=new Set<Id>();
        for(Set<Id> insideSet:mWhatId_WhoIds.values()){
            for(Id item:insideSet){
                allContactsIds.add(item);
            }
        }
        List<Contact> allContacts=[SELECT IsEmailBounced, Active__c,Email,Id  FROM Contact WHERE Id IN:allContactsIds];
        for(Contact item:allContacts){
            if(!item.Active__c || item.IsEmailBounced || item.Email == null){
                conToIgnore.add(item.Id);
            }
        }
        system.debug('New referral send email ignored contacts...'+conToIgnore);
        system.debug('New referral send email whatId->whoId...'+mWhatId_WhoIds);
        //

            String templateDevName = mdtEmail.Email_Template_Dev_Name__c;
            List<EmailTemplate> ets = [select id,developername from EmailTemplate where DeveloperName = :templateDevName];
            String sDebugEmailWhoBody = '';
            if (!ets.isEmpty()) {
                EmailTemplate template = ets[0];
                List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                for (Id whatId : mWhatId_WhoIds.keySet()) {
                    Set<Id> whoIds = (Set<Id>) mWhatId_WhoIds.get(whatId);
                    if (!mdtEmail.debug_only__c) {
                        for (Id whoId : whoIds) {
                                if(!conToIgnore.contains(whoId) ){ //check if contact is not in ignored list (not active or email bounced indicator)
                                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                                    msg.setTemplateId(template.id);
                                    msg.setWhatId(whatId);
//                                    msg.setToAddresses(new List<Id>{whoId});
                                    msg.setTargetObjectId(whoId);
//                                    msg.setTargetObjectId(whoId);
                                    msg.setSaveAsActivity(true);
                                    // Use Organization Wide Address
                                    if (owaNoReplyId != null) {
                                        msg.setOrgWideEmailAddressId(owaNoReplyId);
                                    }
                                    Boolean duplicateEmail=false;
                                    for(Messaging.SingleEmailMessage item : lstMsgs){
                                        if(item.getWhatId() == msg.getWhatId() && item.getTargetObjectId() == msg.getTargetObjectId()){
                                            duplicateEmail = true;
                                        }
                                    }
                                    if(!duplicateEmail){
                                        lstMsgs.add(msg);
                                    }
                            }
                        }
                    } else {
                        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                        msg.setTemplateId(template.id);
                        //  msg.setWhatId(whatId);
                        msg.setTargetObjectId(UserInfo.getUserId());
                        msg.setSaveAsActivity(false);
                        lstMsgs.add(msg);
                        for (Id whoId : whoIds) {
                            sDebugEmailWhoBody += ' Applied Resource Id:' + whatId + '....Contact Id:' + whoId + '<br/>';
                        }
                    }
                }
                if(!lstMsgs.isEmpty()) {
                    system.debug('--- emailsend messages='+lstMsgs);
                    Messaging.sendEmail(lstMsgs);
                }
                if(mdtEmail.debug_only__c) {
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setSubject('Test Debug of New Referral');
                    msg.setToAddresses( new List<String> {'support@provisiopartners.com'});
                    String sBody = 'This is a TEST<br/><br/>';
                    sBody += 'We would have used the following template:' +template.developername + '<br/><br/>';
                    sBody += 'We would have used the following data to pass to the template:<br/><br/>';
                    sBody +=  sDebugEmailWhoBody;
                    msg.setHtmlBody(sBody);
                    msg.setPlainTextBody(sBody);
                    List<Messaging.SingleEmailMessage> lstMsgsDebug = new List<Messaging.SingleEmailMessage>();
                    lstMsgsDebug.add(msg);
                    
                    Messaging.sendEmail(lstMsgsDebug);
                }
            } else {
                system.debug('--- emailsend could not find template dev name');
            }
        } else {
            String sBody = 'could not build email mWhatId and WhoIds is empty';
            Utilities.sendEmail(new List<String>{'support@provisiopartners.com'}, 'AR Email Exit', sBody, sBody);

        }
    }
    /**
    * increment the case_sequence__c field on an Insert of an Applied resource
    * which is basically grouped by case id AND resource type.
    *
    * @TODO Note. this will currently only work for inserting 1 applied resource at a time..
    * Inserting 2 at once will end up with the same sequence number
    *
    * @param newArs the ARs before insert.
    */
    public static void incrementCaseSequence(List<Applied_Resource__c> newArs) {
        if(newArs!=null && !newArs.isEmpty()) {
            Map<Id, Map<String, List<Applied_Resource__c>>> mCaseId_mArTypeArs = new Map<Id, Map<String, List<Applied_Resource__c>>>();

            system.debug('---- increment.. newArs:'+newArs);
            for(Applied_Resource__c ar : newArs) {
                system.debug('---- increment.. newAr:'+ar.title__c);
                if (!mCaseId_mArTypeArs.containsKey(ar.case__C)) {
                    mCaseId_mArTypeArs.put(ar.case__c, new Map<String, List<Applied_Resource__c>>{
                            ar.type__c => new List<Applied_Resource__c>{ar}
                    });
                    system.debug('---- increment.. outer map in if:'+mCaseId_mArTypeArs);
                } else {
                    Map<String, List<Applied_Resource__c>> mTypeArs = (Map<String, List<Applied_Resource__c>>) mCaseId_mArTypeArs.get(ar.case__c);
                    system.debug('---- increment.. inner map in else:'+mTypeArs);
                    if (!mTypeArs.containsKey(ar.type__c)) {
                        mTypeArs.put(ar.type__c, new List<Applied_Resource__c>{ar});
                        system.debug('---- increment.. inner map in sub if:'+mTypeArs);
                    } else {
                        List<Applied_Resource__c> caseArs = (List<Applied_Resource__c>) mTypeArs.get(ar.type__c);
                        //List<Applied_Resource__c> tmpAcaseArs = new List<Applied_Resource__c>();
                        caseArs.add(ar);
                        system.debug('==== increment arType in 2nd cond in loop adding:'+ar.title__c);
                        //for(Applied_Resource__c arType : caseArs) {
                         //   system.debug('==== increment arType in 2nd cond in loop:'+arType.title__c);
                            //caseArs.add(arType);
                        //}
                    }
                }
            }


            Map<ResourceCompositeKey,List<Applied_Resource__c>> mCompKey_Ars = new Map<ResourceCompositeKey,List<Applied_Resource__c>>();
            for (Id caseId : mCaseId_mArTypeArs.keySet()) {
                Map<String, List<Applied_Resource__c>> mTypeArs = (Map<String, List<Applied_Resource__c>>) mCaseId_mArTypeArs.get(caseId);
                system.debug(mTypeArs);
                for (String arType : mTypeArs.keySet()) {
                    List<Applied_Resource__c> typeArs = mTypeArs.get(arType);
                    for (Applied_Resource__c ar : typeArs) {
                        ar.case_sequence__c = 1;
                        ResourceCompositeKey key = new ResourceCompositeKey(ar.case__c, ar.type__c);
                        if(!mCompKey_Ars.containsKey(key)) {
                            mCompKey_Ars.put(key, new List<Applied_Resource__c>{ar});
                        } else {
                            List<Applied_Resource__c> compArs = (List<Applied_Resource__c>)mCompKey_Ars.get(key);
                            compArs.add(ar);
                        }
                    }
                }
            }
            system.debug('=== increment mCompKey='+mCompKey_Ars.keySet());
            if(!mCompKey_Ars.isEmpty()) {
                Set<Id> caseIds = new Set<Id>();
                Set<String> arTypes = new Set<String>();
                for(ResourceCompositeKey key : mCompKey_Ars.keySet()) {
                    caseIds.add(key.caseId);
                    arTypes.add(key.type);
                }
                List<Applied_Resource__c> existingArs = [   select  id,case__c,type__c,case_sequence__c
                                                            from    applied_resource__C
                                                            where   case__c in :caseIds and type__c in :arTypes
                                                            order by case__c, type__c, case_sequence__c];

                if(!existingArs.isEmpty()) {
                    system.debug('--- lowerinc existingArs='+existingArs);
                    for(Id caseId : mCaseId_mArTypeArs.keySet()) {
                        Map<String,List<Applied_Resource__c>> mArTypeArs = mCaseId_mArTypeArs.get(caseId);
                        for(String arType : mArTypeArs.keySet()) {
                            List<Applied_Resource__c> ars = mArTypeArs.get(arType);
                            for(Applied_Resource__c newAr : ars) {
                                for (Applied_Resource__c existingAr : existingArs) {
                                    if(newAr.case_sequence__c == null || newAr.case_sequence__c == 0) {
                                        newAr.case_sequence__c = 1;
                                    } else {
                                        Integer prevSeq = Integer.valueOf(existingAr.case_sequence__c);
                                        if(prevSeq != null) {
                                            newAr.case_sequence__c = prevSeq +1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    /**
     *
     *
     * @param acctIds
     *
     * @return
     */

   /* public static List<Account> retrieveAccountsAndContacts(Set<Id> acctIds) {
        List<Account> accts = [
                SELECT id,community_activated__c,ParentId, (
                        select id,name,email
                        from contacts
                )
                FROM Account
                WHERE id in :acctIds
        ];
        Set<Id> parentIds=new Set<Id>();
        for(Account item:accts){
            if(item.ParentId!=null){
                parentIds.add(item.ParentId);
            }
        }
        List<Account> parentAccounts=new List<Account>();
        if(!parentIds.isEmpty()){
            parentAccounts=retrieveAccountsAndContacts(parentIds);
        }
        if(!parentAccounts.isEmpty())
        {
            accts.addAll(parentAccounts);
        }
        return accts;
    } */
    public static Id getParentAccountId(Id accId)
    {
        return [SELECT Id,ParentId from Account WHERE Id=:accId].ParentId;
    }

    @future
    public static void updateAccountTotals(Set<Id> pAcctIds) {

        Map<Id,Account>         mId_Account     = new Map<Id,Account>();
        
        if (!pAcctIds.isEmpty()) {
 
            mId_Account = new Map<id,Account>(
                [   select  a.id, a.Total_Nbr_of_Applied_Resources__c, a.carpls_connect__c                   
                    from    Account a
                    where id in :pAcctIds]);
        }
        
        AggregateResult[] ars1 = [  select  sum(Row_Counter__c) totalArs
                                        ,account__c                
                                From    applied_resource__c
                                where   account__c in :pAcctIds
                                and createddate = LAST_N_DAYS:183                                                                    
                                group by ROLLUP (account__c)
                                limit 50000];                
        List<Account> AccountsToUpdate = new List<Account>();       
        
        for(AggregateResult ar : ars1) {
            Id AccountId = string.valueOf(ar.get('Account__c')); 
            
            if(AccountId == null) {
                continue; // THE GRAND TOTAL Value will have a null account ID so skip
            }
            System.debug(logginglevel.debug, 'AccountId in loop='+AccountId);
            
                
            Double dTotalArs        = Double.valueOf(ar.get('totalArs'));

            mId_Account.get(AccountId).Total_Nbr_of_Applied_Resources__c = dTotalArs;
                    
                
            AccountsToUpdate.add(mId_Account.get(AccountId));
            System.debug(logginglevel.debug,'\n----Account:'+mId_Account.get(AccountId).id +'\n');   

        }
        if(!AccountsToUpdate.isEmpty()) {
            System.debug(logginglevel.debug,'\nin trigger updating Accounts:'+AccountsToUpdate +'\n');   
            update AccountsToUpdate;
        } else {
            // query above retrieved nothing.. means there are no account recoreds matching criteria or
            // the last one was just deleted.. zero it out.
            List<Account> Accounts = [select id, Total_Nbr_of_Applied_Resources__c from Account where id in :pAcctIds];
            for(Account c : Accounts) {
                c.Total_Nbr_of_Applied_Resources__c = 0;
            }
            update Accounts;
            System.debug(logginglevel.debug,'\n resetting total nbr of applied resources to zero for Accounts:'+Accounts +'\n');   
        }
    }
    @future
    public static void updateDDPTotals(Set<Id> pDdpIds) {
 
        Map<Id,Loop__DDP__c> mId_DDP = new Map<Id,Loop__DDP__c>();
        
        if (!pDdpIds.isEmpty()) {
            mId_DDP = new Map<id,Loop__DDP__c>(
                [   select  a.id, a.Total_Nbr_of_Applied_Resources__c                   
                    from    Loop__DDP__c a
                    where id in :pDdpIds]);
        }
        AggregateResult[] ars2 = [  select  sum(Row_Counter__c) totalArs
                                            ,ddp__c                
                                    From    applied_resource__c
                                    where   ddp__c in :pDdpIds  
                                    and createddate = LAST_N_DAYS:183                                       
                                    group by ROLLUP (ddp__c)
                                    limit 50000];
                                                   
        List<Loop__DDP__c> DdpsToUpdate = new List<Loop__DDP__c>();     
        
        for(AggregateResult ar : ars2) {
            Id DdpId = string.valueOf(ar.get('Ddp__c')); 
            
            if(DdpId == null) {
                continue; // THE GRAND TOTAL Value will have a null ddp ID so skip
            }
                
            Double dTotalArs        = Double.valueOf(ar.get('totalArs'));

            mId_DDP.get(DdpId).Total_Nbr_of_Applied_Resources__c = dTotalArs;
                    
                
            DdpsToUpdate.add(mId_DDP.get(DdpId));
            System.debug(logginglevel.debug,'\n----Ddp:'+mId_Ddp.get(DdpId).id +'\n');   

        }
        if(!DdpsToUpdate.isEmpty()) {
            System.debug(logginglevel.debug,'\nin trigger updating Ddps:'+DdpsToUpdate +'\n');   
            update DdpsToUpdate;
        } else {
            // query above retrieved nothing.. means there are no ddp recoreds matching criteria or
            // the last one was just deleted.. zero it out.
            List<Loop__DDP__c> ddps = [select id, Total_Nbr_of_Applied_Resources__c 
                                        from Loop__DDP__c 
                                        where id in :pDdpIds];
            for(Loop__DDP__c c : ddps) {
                c.Total_Nbr_of_Applied_Resources__c = 0;
            }
            update ddps;
            System.debug(logginglevel.debug,'\n resetting total nbr of applied resource to zero for ddps:'+ddps +'\n');   
        }
    }   
    @future
    public static void updateSubjectTotals(Set<Id> pSubjIds) {
 
        Map<Id,Subject__c> mId_Subject = new Map<Id,Subject__c>();
               
        if (!pSubjIds.isEmpty()) {
            mId_Subject = new Map<id,Subject__c>(
                [   select  a.id, a.Total_Nbr_of_Applied_Resources__c                    
                    from    Subject__c a
                    where id in :pSubjIds]);
        }               
        List<Subject__c> subjsToUpdate = new List<Subject__c>();     
        
        AggregateResult[] ars2 = [  select  sum(Row_Counter__c) totalArs
                                        ,subject__c                
                                From    applied_resource__c
                                where   subject__c in :pSubjIds  
                                and createddate = LAST_N_DAYS:183  
                                and type__c = 'FAQ'                                     
                                group by ROLLUP (subject__c)
                                limit 50000];
                                        
        for(AggregateResult ar : ars2) {
            Id subjId = string.valueOf(ar.get('Subject__c')); 
            
            if(subjId == null) {
                continue; // THE GRAND TOTAL Value will have a null subj ID so skip
            }
            System.debug(logginglevel.debug, 'SubjId in loop='+subjId);
            
                
            Double dTotalArs        = Double.valueOf(ar.get('totalArs'));

            mId_Subject.get(subjId).Total_Nbr_of_Applied_Resources__c = dTotalArs;
                    
                
            subjsToUpdate.add(mId_Subject.get(subjId));
            System.debug(logginglevel.debug,'\n----Subject:'+mId_Subject.get(subjId).id +'\n');   

        }
        if(!subjsToUpdate.isEmpty()) {
            System.debug(logginglevel.debug,'\nin trigger updating Subjects:'+subjsToUpdate +'\n');   
            update subjsToUpdate;
        } else {
            // query above retrieved nothing.. means there are no subject recoreds matching criteria or
            // the last one was just deleted.. zero it out.
            List<Subject__c> subjs = [select id, Total_Nbr_of_Applied_Resources__c from Subject__c where id in :pSubjIds];
            for(Subject__c s : subjs) {
                s.Total_Nbr_of_Applied_Resources__c = 0;
            }
            update subjs;
            System.debug(logginglevel.debug,'\n resetting total nbr of applied resource to zero for subjs:'+subjs +'\n');   
        }
    }
    /**
     * Req is to mark the 'account contacts' as chatter followers when an AR is accepted ie..
     * When the applied resource status is changed from '[something that's not accepted]' to accepted. this method
     * will be called.
     *
     * It will find the account(s) associated to the AR record(s).
     *
     * It will then find all the contacts associated to that account(s) which are portal users ie (have a matching user.contactId reference)
     * It will then insert a row  / rows in EntitySubscription.. ie add this record  / these records to follow on chatter.
     *
     * If they already followed the record(s).. no worries.. it will swallow that up on the insert.
     *
     * Note: You will only see this follow activity in communities chatter since a networkid is inserted here. SFDC
     * Law says you can see it in one place or the other from a follower standpoint but not both.  Now if the SFDC
     * CRM internal user is on a case that this applied resource is associated to. and this applied resource is 'Active'
     * they will see the chatter activity on the Referral subtab in the right hand Nav. (Stop the madness SFDC! geezes)
     *
     * @param arIdsAccepted a Set of Applied_Resource_c.Id s that we are processing.
     * @note. if you try to insert a dup in entity subs.. it won't do it. it doesn't throw an exception it just ignores it.
     * this method executes in the future so it could be a couple second delay but probably not much more.
     */
    @future
    public static void addArAccountContactsAsChatterFollowers(Set<Id> arIdsAccepted) {
        List<String> lEmails = new List<String>();
        Boolean bRunit = true;
        try {
            lEmails = (((String) CustomSettingsUtls.getCarplsv20Settings(UserInfo.getUserId(), 'f4j_admin_email_addys__c')).split('~'));
            bRunIt = (Boolean)CustomSettingsUtls.getCarplsv20Settings( UserInfo.getUserId(), 'Auto_Add_Acct_Contact_as_AR_follower__c');
        } catch (Exception e) {
            system.debug(logginglevel.error,' target org probably did not set custom setting f4j_edmin_email_addys__c... or Auto_Add_Acct_Contact_as_AR_follower__c 1well...set it!'+e);
        }
        if(!bRunIt) {
            system.debug(logginglevel.info, ' applResTriggerHelper.addArAccountContactsAsChatterFollowers not executing as custom setting Auto_Add_Acct_Contact_as_Ar_follower__c returning as false');
            return;
        }
        try {
            Map<Id, Set<Id>>    mAcctId_ArIds      = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>>    mContactId_ArIds   = new Map<Id, Set<Id>>();
            Map<Id, Id>         mContactId_uId     = new Map<Id, Id>();
            //--- map acctid to multiple arids.
            for (Applied_Resource__c ar : [select account__c, id from applied_resource__c where id in :arIdsAccepted]) {
                if (!mAcctId_ArIds.containsKey(ar.account__c)) {
                    mAcctId_ArIds.put(ar.account__c, new Set<Id>{ar.id});
                } else {
                    mAcctId_ArIds.get(ar.account__c).add(ar.id);
                }
            }
            //map contact id to multiple arIds
            for (Contact c : [select id,accountid from contact where accountid in :mAcctId_ArIds.keySet()]) {
                if (!mContactId_ArIds.containsKey(c.id)) {
                    mContactId_ArIds.put(c.id, mAcctId_ArIds.get(c.accountid));
                } else {
                    mContactId_ArIds.get(c.id).addAll(mContactId_ArIds.get(c.accountid));
                }
            }
            //map contactid to userid
            for (User u : [select id, contactid from user where contactid in :mContactId_ArIds.keySet()]) {
                mContactId_uId.put(u.contactId, u.id);
            }
            Network net = LeHelper.retrieveRunningCommunityNetwork();//<-- uses custom setting.. assumes this setting is correct.
            Id networkId = net != null ? net.id : null;
            //-- note the network id is important.. according to SFDC Law.. you either set it or you dont
            //-- if you set it .. the follow is active in communities but not sfdc crm.. if you don't.. the follow is active
            //-- in sfdc crm but not communities..  they need to stop this licensing bullshit and just let everyone....
            //-- ohh i don't know. maybe collaborate.. and actually talk to each other from a single location. sigh.
            List<EntitySubscription> eSubs = new List<EntitySubscription>();
            for (Id cId : mContactId_ArIds.keySet()) {
                for (Id arId : mContactId_ArIds.get(cId)) {
                    Id uId =  mContactId_uId.get(cId);
                    if(uId==null){ //contact not attached to a user maybe?
                        continue;
                    }
                    EntitySubscription es = new EntitySubscription(NetworkId = networkId, parentId = arId, subscriberid = uId);
                    eSubs.add(es);
                }
            }
            if (!eSubs.isEmpty()) {
                Database.SaveResult[]  srs = Database.insert(eSubs,false);//<---- allow individual fails in case of dup records ie they already followed but still insert the rest.
                Set<String> errMsgs = new Set<String>();
                Boolean bAnyFailed = false;
                //-- note these message typically blow as SFDC did not do this correctly.. ie they don't give you the id of record
                //-- back in the error message.. even though they print it out like they meant to... so.. we do this
                //-- in a assbackwards way to get more info.
                for(Integer i=0;i<srs.size();i++) {
                    if(!srs.get(i).isSuccess()) {
                        bAnyFailed = true;
                        errMsgs.add('<br/>record attempted to insert:'+eSubs.get(i) + '<br/>');
                        for(Database.Error err : srs.get(i).getErrors()) {
                            errMsgs.add('statuscode='+err.getStatusCode() + '..message='+err.getMessage() + '<br/>');
                        }
                    }
                }
                if(bAnyFailed) {
                    String msg = ' Some records failed when trying to insert into EntitySubscription in applResTriggerHelper note. this probably just means they already followed the chatter record... no biggie.:<br/><br/>';
                    for(String eMsg : errMsgs) {
                        msg+=eMsg;
                    }
                    if (!lEmails.isEmpty()) {
                        Utilities.sendEmail(lEmails, 'Carpls F4j Error AR Trigger', msg, msg);
                    }
                }
            }
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            //since finding stuff in SFDC debug logs is a freekin pita. send an email for now. turn this off if too many
            String msgBody = 'Exception caught in addArAccountContactsAsChatterFollowers called from trgOnAppliedResource...<br/>';
            msgBody += '<br/>Message: '+e.getMessage();
            msgBody += '<br/>Stack:' + e.getStackTraceString();
            msgBody += '<br/>Line:' +e.getLineNumber();
            msgBody += '<br/>Cause:' +e.getCause();
            if (!lEmails.isEmpty()) {
                Utilities.sendEmail(lEmails, 'Carpls F4j Error AR Trigger', msgBody, msgBody);
            }
        }
    }
    public static void updateFieldsForGeoPointe(List<Applied_Resource__c> newArs){
        Set<Id> caseIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
            for(Applied_Resource__c item : newArs){
                caseIds.add(item.Case__c);
                accIds.add(item.Account__c);
            }
        Map<Id,Case> cases = new Map<Id,Case>([SELECT Id,
                                                    Contact.MailingStreet,
                                                    Contact.MailingCity,
                                                    Contact.MailingState,
                                                    Contact.MailingPostalCode,
                                                    Practice_Area__c
                                            FROM Case 
                                            WHERE Id in:caseIds]);
        Map<Id,Account> accs = new Map<Id,Account>([SELECT Id,
                                                           Military_Service__c,
                                                           Community_Activated__c,
                                                            New_Leaf_Account__c
                                                   FROM Account 
                                                   WHERE ID IN:accIds]);
        for(Applied_Resource__c item:newArs){
                if(item.Case__c != null){
                    item.GP_Street__c = cases.get(item.Case__c).Contact.MailingStreet;
                    item.GP_City__c = cases.get(item.Case__c).Contact.MailingCity;
                    item.GP_State__c = cases.get(item.Case__c).Contact.MailingState;
                    item.GP_Zip__c = cases.get(item.Case__c).Contact.MailingPostalCode;
                    item.GP_Practice_Area__c = cases.get(item.Case__c).Practice_Area__c;
                }
                if(item.Account__c != null){
                    item.AFLAN_Referral__c = accs.get(item.Account__c).Military_Service__c;
                    item.Is_E_Referral__c = accs.get(item.Account__c).Community_Activated__c;
                    item.New_Leaf_Referral__c = accs.get(item.Account__c).New_Leaf_Account__c;
                }

            }

    }

    public class ResourceCompositeKey {
        public  Id      caseId  {get;set;}
        public  String  type    {get;set;}

        public ResourceCompositeKey() {}

        public ResourceCompositeKey(Id caseId, String type) {
            this.caseId = caseId;
            this.type   = type;
        }
    }

}