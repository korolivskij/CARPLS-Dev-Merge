@isTest(SeeAllData=false)
public class TEST_TestUtils {
	
	public class SecSettings {
	
		public String us   {get; set;}	//User Id
		public String pr   {get; set;}	//Profile Id
		public String rl   {get; set;}	//Role Id
		public String pm   {get; set;}	//Permission Set Id	

		public SecSettings(String sUser, String sProf, String sRole, String sPM) {
			this.us = sUser;
			this.pr = sProf;
			this.rl = sRole;
			this.pm = sPm;
		}	
	}

	public static User getUserForTest(SecSettings secSettings, Datetime dtTstStart){
		
		list<User> lstUsr = null;
		if (secSettings.us.length() == 0 && secSettings.pr.length() == 0 && secSettings.rl.length() == 0 && secSettings.pm.length() == 0) {
			lstUsr = [select id, name, lastname from User where isactive = true and id = :UserInfo.getUserId()];
		}
		else if (secSettings.us.length() > 0) {
			lstUsr = [select id, name, lastname from User where isactive = true and id = :secSettings.us];
		}
		if (lstUsr != null) {
			System.Assert(lstUsr.size() == 1);
			return lstUsr[0];
		}
		Double x = Math.random() * 10000;
		String rd = String.valueOf(Integer.valueOf(x));
		User usr = new User();
		usr.FirstName = 'testfirstopmem';
		usr.LastName = 'testlastopmem';
		usr.EmailEncodingKey = 'ISO-8859-1';
		usr.Email = 'info@ext-it.com';
		usr.Alias = rd;
		usr.TimeZoneSidKey = 'America/Los_Angeles';
		usr.Username = 'somenam' + rd + '@ext-it.com';
		usr.LanguageLocaleKey = 'en_US';
		usr.LocaleSidKey = 'en_US';
		usr.CommunityNickname = 'somename' + rd;
		
		if (secSettings.pr.length() > 0) {
			usr.ProfileId = secSettings.pr;
		} else {
			usr.ProfileId = UserUtils.getProfileByName('System Administrator').id;
		}
		if (secSettings.rl.length() > 0)
			usr.UserRoleId = secSettings.rl;
		insert usr;
		if (secSettings.pm.length() > 0) {
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = usr.Id;
			psa.PermissionSetId = secSettings.pm;
			insert psa;
		}
		return usr;
	}
	public static Boolean userIsInProfile(String userId, String profileId) {
		list<User> lstUsers = [select id, ProfileId from User where id = :userId and ProfileId = :profileId];
		return (lstUsers.size() == 1);
	}
	public static Boolean userIsInRole(String userId, String roleId){
		list<User> lstUsers = [select id, UserRoleId from User where id = :userId and UserRoleId = :roleId];
		return (lstUsers.size() == 1);
	}
	/**
	 * If this is already an org level location in this heiracrchical custom setting,
	 * Insert a new one for the passed user.. if not just insert one at the org level.
	 */
	public static void initCustomSettings(User u) {
		//Location:Org level
		Carplsv20Settings__c setting = new Carplsv20Settings__c();
		
		String soql = SoqlUtils.getAllFieldsSOQL('Carplsv20Settings__c', false, '');
		List<Carplsv20Settings__c> currentSettings  = Database.query(soql);
		
		String 	settingName = '';
		Id 		setupOwnerId;
		if(currentSettings == null || currentSettings.isEmpty()) {
			settingName = UserInfo.getOrganizationId() + Date.today();
			setupOwnerId = UserInfo.getOrganizationId();
		} else {
			settingName = 'carplsV20Setting ' + u.id;
			setupOwnerId = u.id;
		}
		
		setting.Name = settingNAme;
		setting.clientOrphanSearchCategories__c = 'Client;Party';
		setting.clientOtherSearchCategories__c='Volunteer;Donor;Attorney;Rejected';
		setting.partyOrphanSearchCategories__c='Client;Party';
		setting.partyOtherSearchCategories__c='Volunteer;Donor;Attorney;Rejected';
		setting.Contact_Search_Limit__c = 500;
		setting.showDebugMessages__c = true;
		setting.existingClientSearchCategories__c='Client';
		setting.ResourceHeaderColor__c = 'ResourceHeaderColor__c=#ee9d5c';
		setting.SetupOwnerId = setupOwnerId;
		setting.showChatterPanel__c = false;
        setting.Auto_Add_Acct_Contact_as_AR_follower__c = true;
		
		insert setting;
		
	}	
	public static void ensureCustomSettingsExist(User usr) {
		Object oSetting = CustomSettingsUtls.getCarplsv20Settings( usr.id, 'showChatterPanel__c'); 
		System.assertEquals(oSetting,null); 
		TEST_TestUtils.initCustomSettings(usr);	//-- Init Custom Settings.
		oSetting = CustomSettingsUtls.getCarplsv20Settings( usr.id, 'showChatterPanel__c'); 
		System.assertNotEquals(oSetting,null); 	
	}
	public static Contact createContact(String sCategory) {
		Contact c = new Contact(	lastname='UT TEST Contact',category__c=sCategory, firstname='UT Test ContactFirst'
									,phone='630-310-0898',Birthdate=Date.today(), Last_Four_SSN__c='1234'
									,mailingstreet='123', aliases__c='Aliases', mailingPostalCode='66666');	
		insert c;
		
		List<Name_Equivalents__c> nes = new List<Name_Equivalents__c>();
		Name_Equivalents__c ne1 = new Name_Equivalents__c();
		ne1.Root__c = c.LastName;
		ne1.Match__c = c.lastName;
		
		Name_Equivalents__c ne2 = new Name_Equivalents__c();		
		ne2.root__c = c.lastName;
		ne2.match__c = c.lastname;
		
		nes.add(ne1);
		nes.add(ne2);
		insert nes;
		
		return c;
	}
	/** 
	 * @TODO create an acct with all the proper shit hanging off of it.
	 * Default rt is Resources;
	 */
	public static Account createAcct(String sType) {	
		return createAcct(sType, 'Resources');	
	}
	
	public static Account createAcct(String sType, Subject__c subj) {
		return createAcct(sType, 'Resources',subj);	
	}	
	
	/** 
	 * @TODO create an acct with all the proper shit hanging off of it.
	 * Default rt is Resources;
	 */	
	public static Account createAcct(String sType, String sRtDevName) {
		
		RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Account', sRtDevName);
		String ssCategories = 'HOUSING - Rental Search/Placement;ADVOCACY;COUNSELING - Divorce';
		Account a = new Account ( 	name='TEST Account Name1', description= 'TEST Account Desc1', type=sType, recordTypeId=rt.id
									,Social_Service__c=ssCategories);
		a.Active__c = true;		
        a.Partner_Type__c = 'Military Service';
  		insert a;
  		
  		Eligible_Problem_Codes__c epc = new Eligible_Problem_Codes__c();
  		epc.Practice_Area__c = 'pa1';
  		epc.Problem_Category__c = 'pcat1';
  		epc.Problem_Code__c = 'pc1';
  		epc.Account__c = a.id;
  		insert epc;
  
  		return a;			
		
	}
	/** 
     * Create acct, epc, subj junction
	 */	
	public static Account createAcct(String sType, String sRtDevName,Subject__c subj) {
		
		RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Account', sRtDevName);
		
		Account a = new Account ( 	name='TEST Account Name1', description= 'TEST Account Desc1', type=sType, recordTypeId=rt.id);
		a.Active__c = true;
  		insert a;
  		
  		Eligible_Problem_Codes__c epc = new Eligible_Problem_Codes__c();
  		epc.Practice_Area__c = subj.Practice_Area__c;
  		epc.Problem_Category__c = subj.Problem_Category__c;
  		epc.Problem_Code__c = subj.Problem_Code__c;
  		epc.Account__c = a.id;
  		
  		insert epc;
  
  		createAsj(a,subj);
  		return a;			
		
	}	
	public static Consultation_Question__c createQuestion(String caseFieldName, Subject__c subj, Boolean isLitigation) {
    	
    	Consultation_Question__c caseQ = new Consultation_Question__c();
    	caseQ.Case_Answer_Field_Name__c = caseFieldName;
    	caseQ.Question__c = 'Unit Test Case Question';
    	caseQ.name__c = 'Unit Test Case Question Name';
    	insert caseQ;
    	
  		Eligible_Problem_Codes__c epc = new Eligible_Problem_Codes__c();
  		epc.Practice_Area__c = subj.Practice_Area__c;
  		epc.Problem_Category__c = subj.Problem_Category__c;
  		epc.Problem_Code__c = subj.Problem_Code__c;
  		epc.Case_Question__c = caseQ.id;  	
  		insert epc;    	
  		
  		createQsj(caseQ,subj);
  		    	
    	return caseQ;		
	}
	public static Loop__DDP__c createDdp(Subject__c subj) {
		Loop__DDP__c ddp = new Loop__DDP__c();
		ddp.name = 'UT DDP';
		ddp.Status__c = 'Active';
		insert ddp;
		
		  		
  		Eligible_Problem_Codes__c epc = new Eligible_Problem_Codes__c();
  		epc.Practice_Area__c = subj.Practice_Area__c;
  		epc.Problem_Category__c = subj.Problem_Category__c;
  		epc.Problem_Code__c = subj.Problem_Code__c;
  		epc.DDP__c = ddp.id;
  		insert epc;
  		
  		createDdpSj(ddp, subj);
  		return ddp;		
	}
	
	public static Account_Subject_Junction__c createAsj(Account acct, Subject__c subj) {
		Account_Subject_Junction__c asj = new Account_Subject_Junction__c();
		asj.Account__c = acct.id;
		asj.Subject__c = subj.id;
		insert asj;
		return asj;		
	}
	public static DDP_Subject_Junction__c createDdpSj(Loop__DDP__C ddp, Subject__c subj) {
		DDP_Subject_Junction__c ddpSj = new DDP_Subject_Junction__c(); 
		ddpSj.DDP__c = ddp.id;
		ddpSj.Subject__c = subj.id;
		insert ddpSj;
		return ddpSj;		
	}	
	public static Question_Subject_Junction__c createQsj(Consultation_Question__c caseQ, Subject__c subj) {
		Question_Subject_Junction__c qsj = new Question_Subject_Junction__c();
		qsj.Case_Question__c = caseQ.id;
		qsj.Subject__c = subj.id;
		insert qsj;
		return qsj;		
	}
	/**
	 * RJN we need a way to get the RT Set in test code. just build the object for now. let the client bulk insert it.
	 *
	 * @param a
	 * @param cse
	 * @param svc
	 *
	 * @return
	 */
	public static Applied_Resource__c buildAr(Account a, Case cse, Consultation__c svc) {
		return new AppliedResourceUtils().buildAppliedResource(a,cse,svc);
	}

	public static Applied_Resource__c createAr(Id caseId, Id serviceId, Account acct) {
		Applied_Resource__c ar = new Applied_Resource__c( case__c = caseId, consultation__c=serviceId, Account__c = acct.id);
		String acctType = acct.Type;
		/*
		if()
		
		t | Del	Social Referrals	Not Checked	Assigned dynamically	Richard Nendza, 3/13/2014 8:22 PM
Edit | Del	Legal Referrals	Not Checked	Assigned dynamically	Richard Nendza, 3/13/2014 8:22 PM
Edit | Del	Web Links	Not Checked	Assigned dynamically	Richard Nendza, 3/13/2014 8:22 PM
Edit | Del	FAQ	Not Checked	Assigned dynamically	Richard Nendza, 3/13/2014 8:22 PM
Edit | Del	DDP
*/
		ar.Status__c = 'Active';
		
		insert ar;
		return ar;
	}
	public static Applied_Resource__c createAr(Id caseId, Id serviceId, Loop__DDP__c ddp) {
		Applied_Resource__c ar = new Applied_Resource__c( case__c = caseId, consultation__c=serviceId,  DDP__C=ddp.id);
		ar.Type__c = 'DDP';
		ar.Status__c = 'Applied';
		insert ar;
		return ar;
	}	
	
	
	/** 
	 * @TODO create a ddp with all the proper shit hanging off it
	 */
	public static Loop__DDP__c createDdp() {
		
		//@TODO Set account type. set rt
		Loop__DDP__c ddp = new Loop__DDP__c ( name='UT DDP');
  		insert ddp;
  		
  		Eligible_Problem_Codes__c epc = new Eligible_Problem_Codes__c();
  		epc.Practice_Area__c = 'pa1';
  		epc.Problem_Category__c = 'pcat1';
  		epc.Problem_Code__c = 'pc1';
  		epc.DDP__c = ddp.id;
  		insert epc;
  		
  		return ddp;			
	}
	//Create a case with no data yet. (for new case problem code seletion)
	public static Case createNewClientPartyCase(Contact client) {
    	Case cse;
    	
    	Subject__c subj = new Subject__c(title__c = 'TEST SUBJECT');
    	insert subj;
			
		List<Contact> parties = new List<Contact>();
    	Contact p1 = new Contact(lastname='TEST PARTY LAST1', category__c = 'Party');
    	parties.add(p1);
    	
		Contact p2 = new Contact(lastname='TEST PARTY LAST2', category__c = 'Party');
    	parties.add(p2);			
		insert parties;
			
		RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');         
		cse = new Case(	ContactId = client.id,subject='Test Case',project__c='TEST PROJECT A', Origin='TEST Origin', 
						description = ' TEST DESC', recordtypeId=rt.id);	
		
		cse.status = 'Open';				
        insert cse;
		
		List<Case_Party__c> cps = buildCasePartyRecords(client,parties,cse);
		insert cps;
		
		CaseUtils caseUtils = new CaseUtils();
		/*
		List<Income_Detail__c> ids = new List<Income_Detail__c>();
		ids.add(new Income_Detail__c(active__c=true, amount__c=100,contact__c=client.id,frequency__c='Monthly',income_type__c='Income - Employment'));
		ids.add(new Income_Detail__c(active__c=true, amount__c=200,contact__c=client.id,frequency__c='Monthly',income_type__c='Income - Employment'));
		insert ids;
		*/
		return cse;				
	}	
	
	/**
	 *  Overload of createFullClientPartyCase(Contact,String) to support existing calls. Assume Default Status of Open.
	 */
	public static Case createFullClientPartyCase(Contact client)  {
		return createFullClientPartyCase(client,'Open');     		
	}
	/**
	 * Build a variety of Cases, Contacts (clients and parties) and case party records.
	 *
	 */
	public static Case createFullClientPartyCase(Contact client, String caseStatus) {
    	Case cse;
    	
    	Subject__c subj = new Subject__c(title__c = 'TEST SUBJECT');
    	subj.Practice_Area__c = 'pa1';
    	subj.Problem_Category__c = 'pcat1';
    	subj.Problem_Code__c = 'pc1';
    	insert subj;
			
		List<Contact> parties = new List<Contact>();
    	Contact p1 = new Contact(lastname='TEST PARTY LAST1', category__c = 'Party');
    	parties.add(p1);
    	
		Contact p2 = new Contact(lastname='TEST PARTY LAST2', category__c = 'Party');
    	parties.add(p2);			
		insert parties;
			
		RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');         
		cse = new Case(	ContactId = client.id,subject='Test Case',project__c='TEST PROJECT A', Origin='TEST Origin', 
						description = ' TEST DESC', recordtypeId=rt.id, selected_subject__c=subj.id);	
		cse.Practice_Area__c = 'pa1';
		cse.Problem_Category__c = 'pcat1';
		cse.Problem_Code__c = 'pc1';	
		if('Open' == caseStatus) {
			cse.start_it__c = true;
			cse.Left_Open__c = true;	
			cse.status = 'Open';	
		} else {
			cse.Left_Open__c = false;
			cse.start_it__c = false;
			cse.status = caseStatus;
		}			
        insert cse;
		
		List<Case_Party__c> cps = buildCasePartyRecords(client,parties,cse);
		insert cps;
		
		CaseUtils caseUtils = new CaseUtils();
		//Add 1 service.
		Consultation__C service = caseUtils.buildNewService(cse); 
		if('Closed' == caseStatus) {
			service.Status__c = 'Closed';
		}
		
		insert service;
		
		List<Income_Detail__c> ids = new List<Income_Detail__c>();
		ids.add(new Income_Detail__c(active__c=true, amount__c=100,contact__c=client.id,frequency__c='Monthly',income_type__c='Income - Employment'));
		ids.add(new Income_Detail__c(active__c=true, amount__c=200,contact__c=client.id,frequency__c='Monthly',income_type__c='Income - Employment'));
		insert ids;
		return cse; 		
	}
	public static List<Case_Party__c> buildCasePartyRecords(Contact client, List<Contact> parties, Case cse) {
		List<Case_Party__c> cps = new List<Case_Party__c>();
    	
    	Case_Party__C cp = new Case_Party__c();
    	cp.Type__c = 'Client';
    	cp.contact__C = client.id;
    	cp.case__C = cse.id;
    	cp.Primacy__C = 'Primary';   	
    	
    	cps.add(cp);
		
    	for(Contact p : parties) {
    		Case_Party__C cp1 = new Case_Party__c();
			cp1.Type__c = 'Adverse Party';		
			cp1.contact__c = p.id;
			cp1.case__C = cse.id;
			cps.add(cp1);
    	}		
		return cps;		
		
	}
	/**
	 * @TODO beef up.. below very brittle.
	 */	
	public static Contact retrieveContactWithCaseParties(Contact c) {
		Contact contact;
		
                al.NestableCondition whereCand = new al.AndCondition();
			//rjn no idea why you have to do this but there is some api diffs when jumping to 30 that seems to only affect test code.
			// there must be 30 in the chain somewhere. yes another issue the sfdc gods decided to throw on ice.false
			// https://success.salesforce.com/issues_view?id=a1p30000000T3FOAA0
			// note i would say care should be taken when bumping the api to 30 plus.. ie. i noticed via expermenation that then you might
		    // start seeing the error in the ui.. i'd tend to guess they should all be 38 but not sure we have time to fully test that.
			Set<String> excludeFields = new Set<String>();
			excludeFields.add('OtherAddress');
		    excludeFields.add('MailingAddress');
   				
   				whereCand.add(new al.FieldCondition('id').equals(c.id));
                String soql = new al.SoqlBuilder()
					.selectx(SoqlUtils.getAllFieldsSet('Contact', false,excludeFields ))
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'id','name','type__c','case__r.id','case__r.subject' })
                        .selectx(new Set<String> {'case__r.contact.id','case__r.contact.name' })
                        .fromx('Case_Parties__r'))              
                    .fromx  ('Contact c ')
                    .wherex (whereCand)
                    .orderByx(new List<al.OrderBy>{
                        new al.OrderBy('type__c').descending().nullsLast()
                        ,new al.OrderBy('phone').ascending().nullsLast()
                        ,new al.OrderBy('last_four_SSN__c').ascending().nullsLast()
                        ,new al.OrderBy('aliases__c').ascending().nullsLast()
                        ,new al.OrderBy('lastname').ascending()
                        ,new al.OrderBy('firstname').ascending().nullsLast()
                    })
                   
                    .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators());                
        
    
         contact = Database.query (soql);
         return contact;
	
	}
	public static Search_Log__c createSearchLog(Contact client, List<Contact> lParties, User uTstExecUser ) {
		if(client == null) {
			return null;
		}
		Search_Log__c sl = new Search_Log__c();
		sl.Last_Name__c = client.LastName;
		sl.User__c = uTstExecUser.id;
		insert sl;
		
		if(lParties != null && !lParties.isEmpty()) {
			List<Search_Log_Children__c> slcToInsert = new List<Search_Log_Children__c>();
			for(Contact party : lParties) {
				Search_Log_Children__c slParty = new Search_Log_Children__c();
				slParty.Last_Name__c = party.lastName;
				slParty.User__c = uTstExecUser.id;
				slParty.Client_Search_Log__c = sl.id;
				slcToInsert.add(slParty);
			}
			insert slcToInsert;
		}
		return SearchWrapper.retrieveSearchLog(sl.id);
	}	
	
	/**
	 * @TODO Write utility (in a utils class) to send apex email.
	 * ie.. test approaching too many soql queries gov limits.. maybe send at 85
	 */
	public static void sendEmail() {
		
	}
	 
	public static void debugSObj(SObject sObj) {
		String s = '';
		String sName = 'Null object';
		if(sObj != null) {
			if(sObj.id != null) {
				sName = Utilities.findObjectNameById(sObj.id); 
			} else {
				sName = 'No Id in SObj';
			}
		}		
		s+='\n------------------------- UNIT TEST DEBUG '+sName+' ----------------------------\n';
		s+='\n '+sObj;
		s+= '\n\n---------------------------------------------------------------------------\n';
		System.debug(LoggingLevel.WARN, s);				
	}	
	/**
	 * Don't try to get tricky and pass a list of different types of sObjects. this is just quick
	 * test debugging code and not built for that.
	 */
	public static void debugSObjs(List<SObject> sObjs) {
		String s = '';
		String sName = 'Null object';
		if(sObjs != null && !sObjs.isEmpty() ) {
			SObject sObj = sObjs[0];
			if(sObj.id != null) {
				sName = Utilities.findObjectNameById(sObj.id); 
			} else {
				sName = 'No Id in SObj';
			}
		}		
		s+='\n------------------------- UNIT TEST DEBUG '+sName+' LIST ----------------------------\n';
		for(Sobject sObj : sObjs) {
			s+='\n '+sObj + '\n';	
		}
		s+= '\n\n---------------------------------------------------------------------------\n';
		System.debug(LoggingLevel.WARN, s);				
	}	
	
}