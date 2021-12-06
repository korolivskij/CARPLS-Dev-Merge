// ELC - 10/30/17 - added functionality to limit resources by county as well as zip code
// ELC - 4/7/2020 - changed age-checking logic to use CurrentAge rather than AgeAtIntake

public with sharing class AccountUtils {
       
    /*
     * Exists to delegate to the controller 
     */
    public  static List<String>         debugMessages   {get;set;}
    public static FINAL String          ALLZIPS = 'ALLZIPS';
    
    public static Boolean getHasDebugMessages() {
        return debugMessages != null && !debugMessages.isEmpty();

    }

    /**
     * Client objects need to be careful with this.. we don't want to be keeping too many
     * large static strings in memory for too long. if you call startDebugging, please call
     * stop debugging after your done using these messages in the controller. Granted this is
     * Poor mans debugging.
     * 
     * If you do not, you must go to church
     * and confess your sins as you are a very bad person!.
     */
    public  static void startDebugging() {
        if(debugMessages == null) {
            debugMessages = new List<String>();
        } else {
            if(!debugMessages.isEmpty()) {
                debugMessages.clear();
            }
        }
        debugMessages.add('<font color=brown>AR----Starting debugging in AccountUtils</font>');
    }
    public static void stopDebugging() {
        if(debugMessages != null) {
            debugMessages = null;
        }       
    }

    private static ContactUtils  cUtils = new ContactUtils();
    
    public static List<Account> retrieveWebLinks( Case cse ) {  
        ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(cse);
        ResourceType rt = ResourceType.WEBLINK;
        List<Account> accts = AccountUtils.retrieveAccountResources(rt, pcWrap, null,null);
        return accts;
    }
    public static List<Account> retrieveWebLinks( ProblemCodeWrapper pcWrap ) { 
        ResourceType rt = ResourceType.WEBLINK;
        List<Account> accts = AccountUtils.retrieveAccountResources(rt, pcWrap, null,null);
        return accts;
    }   
    public static List<Account> retrieveSocialRefs ( Case cse, Account acctForSSCategories) {
        ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(cse);
        ResourceType rt = ResourceType.SOCIAL;
        List<Account> accts = AccountUtils.retrieveAccountResources(rt, pcWrap, acctForSSCategories,null);
        return accts;       
    }
    public static List<Account> retrieveSocialRefs( ProblemCodeWrapper pcWrap ) {   
        ResourceType rt = ResourceType.SOCIAL;
        List<Account> accts = AccountUtils.retrieveAccountResources(rt, pcWrap, null,null);
        return accts;
    }
    public static List<Account> retrieveLegalRefs ( Case cse, Contact client) {
        ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(cse);
        ResourceType rt = ResourceType.LEGAL;
        List<Account> accts = AccountUtils.retrieveAccountResources(rt, pcWrap, null,client);
        return accts;       
    }
    public static List<Account> retrieveLegalRefs( ProblemCodeWrapper pcWrap ) {    
        ResourceType rt = ResourceType.LEGAL;
        List<Account> accts = AccountUtils.retrieveAccountResources(rt, pcWrap, null,null);
        return accts;
    }           
    public static List<Account> retrieveAccountResources(  ResourceType eType, ProblemCodeWrapper pcWrap, 
                                                            Account acctForSSCategories, Contact client) {
        
        
        Boolean byPassProblemCodes = false;
                                                                
        if(pcWrap == null) {
            System.debug(logginglevel.warn, 'ProblemCodeWrapper parm cannot be null!');
            return null;
        }
        if(pcWrap.practiceArea == null) {
            byPassProblemCodes = true;
            System.debug(logginglevel.warn,'problem code wrapper='+pcWrap);
        }
        al.NestableCondition whereCAnd = new al.AndCondition();     
        

        if(!byPassProblemCodes) {
            al.NestableCondition whereCsubAnd = new al.AndCondition();
            al.NestableCondition whereCsubOr1 = new al.OrCondition();                   
            
            whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').equals(null));  
            whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').lessThanOrEqualTo(date.today()));

            al.NestableCondition whereCsubAndInner1 = new al.AndCondition();
            if(pcWrap.practiceArea != null && pcWrap.practiceArea != '') {
                whereCsubAndInner1.add(new al.FieldCondition('Practice_Area__c').equals(pcWrap.practiceArea));  
            }
            if(pcWrap.problemCode != null && pcWrap.problemCode != '') {
                whereCsubAndInner1.add(new al.FieldCondition('Problem_Code__c').equals(pcWrap.problemCode));    
            }
            if(pcWrap.problemCategory != null && pcWrap.problemCategory != '') {
                whereCsubAndInner1.add(new al.FieldCondition('Problem_Category__c').equals(pcWrap.problemCategory)); 
            }
            /* only applicable for ddps
            if(pcWrap.jurisdiction != null && pcWrap.jurisdiction != '' && !pcWrap.jurisdiction.contains('All Jurisdictions')) {
                List<String> lJurisdictions = pcWrap.lJurisdictions;
                if(lJurisdictions != null && !lJurisdictions.isEmpty()) {
                    whereCsubAndInner1.add(new al.SetCondition('Jurisdiction__c',al.Operator.INCLUDES,lJurisdictions));
                }
            }
            */

            whereCsubAnd.add(whereCSubOr1);
            whereCsubAnd.add(whereCsubAndInner1);
            /** ----------------------------------------- **/
        
            /** ---------Run subquery to get list of account ids ---------- **/
            String soqlSub = '';
            try {
                 soqlSub = new al.SoqlBuilder()
                                .selectx(new Set<String> {'account__c'}) 
                                .fromx('Eligible_Problem_Codes__c')
                                .wherex(whereCsubAnd)
                                //.orderByx(new al.OrderBy('name').ascending().nullsLast())
                                .toSoql();
                                
                if(debugMessages != null) {
                    debugMessages.add('--retrieveAccountResources(ResourceType,ProblemCodeWrapper,Account,Contact)-- EPC SQL='+soqlSub);
                }               
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
        
            List<Eligible_Problem_Codes__c> lProblemCodes;
            try {   
                system.debug(logginglevel.info,'<b>Account Resources subSOQL=</b>'+soqlSub);    
                lProblemCodes = Database.query (soqlSub);
            
            } catch (Exception e)  {
                //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
                system.debug(logginglevel.warn,'<b>ERROR IN Account REsources subSoql');
            }   
        
            if(lProblemCodes == null || lProblemCodes.isEmpty()) {
                system.debug(logginglevel.warn,'<b>NO PROBLEM CODES FOUND! Account Resources subSOQL=</b>'+soqlSub);
                if( (pcWrap.practiceArea =='' && pcWrap.practiceArea == '' && pcWrap.problemCode == '' && pcWrap.jurisdiction == '') || 
                     pcWrap.practiceArea == null) {
                    byPassProblemCodes = true;
                    system.debug(logginglevel.warn,'problemcode wrapper contains no values.. retrieveing all accounts of proper type');      
                } else {
                    return null;    
                }
            
                //return null;
            }
            
        
            List<Id> lAccountIds = new List<Id>();
        
            for(Eligible_Problem_Codes__c pc : lProblemCodes) {
                Id pcAccountId = pc.Account__c;
                lAccountIds.add(pcAccountId);
            }
            /** -------------------------------------------------------------- **/
        
            
            if(lProblemCodes !=null && !lProblemCodes.isEmpty()) {
                whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lAccountIds )));
            }
            
        } else {
            System.debug(logginglevel.warn, 'bypassing problem codes!');    
        }
        
        List<Account> accounts;
        String soqlAccts = '';
        //whereCAnd.add(new al.FieldCondition('Active__c').equals(true));
        
        //------
        if(eType == resourceType.WEBLINK) {
            whereCAnd.add(new al.FieldCondition('Type').equals('WebLink'));
        }
        if(eType == resourceType.SOCIAL) {
            //whereCAnd.add(new al.FieldCondition('Type').equals('Social Referral'));
            al.NestableCondition whereCSocialOr = new al.OrCondition();
            whereCSocialOr.add(new al.FieldCondition('Type').equals('Social Service Referral'));
            whereCSocialOr.add(new al.FieldCondition('Type').equals('Social Referral'));       
            whereCAnd.add(whereCSocialOr);
            if (acctForSSCategories != null && acctForSSCategories.Social_Service__c != null){
                //searchAccount is a multi select picklist
                List<String> ssCategories = Utilities.detokenizeString(acctForSSCategories.social_service__c, ',');
                if(ssCategories != null && !ssCategories.isEmpty()) {
                    whereCAnd.add(new al.SetCondition('Social_Service__c',al.Operator.INCLUDES, (ssCategories )));
                }
            }
        }
        if(eType == resourceType.LEGAL) {
            whereCAnd.add(new al.FieldCondition('Type').equals('Legal Referral'));
        }
        // Added for IL-AFLAN hotline
        if(client != null && client.is_military__c == false) {
            whereCAnd.add(new al.FieldCondition('Military_Service__c').equals(false));
        }         
        // Although most social service agencies don't have these kind of conditions, we still should
        // filter on them - code added ELC TODO - USE THIS CODE
        if (eType == resourceType.LEGAL || eType == resourceType.SOCIAL) {
            if(client != null) {
                //---rjn check if military and then use vdisablity field if applicable
                if(!client.is_military__c) {
                    if (client.disability__c == null || client.disability__c == 'None') {
                        al.NestableCondition whereCOrDisabled = new al.OrCondition();
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(null));
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(false));
                        whereCAnd.add(whereCOrDisabled);
                    }
                } else {
                    if (client.VDisablity__c == null || client.VDisablity__c == 'None') {
                        al.NestableCondition whereCOrDisabled = new al.OrCondition();
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(null));
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(false));
                        whereCAnd.add(whereCOrDisabled);
                    }
                }

                List<String> language = new List<String>();
                if(client.language__c != null) {                
                    language.add(client.language__c);
                } else {
                    language.add('English');    
                }
                whereCAnd.add(new al.SetCondition('Languages__c',al.Operator.INCLUDES, (language )));
        
                if (client.Birthdate != null) {
                    Integer value = Integer.valueOf(string.valueOf(math.floor(client.Birthdate.daysBetween(date.today())/365)));
                    al.NestableCondition whereCLegalOr1 = new al.OrCondition();
                    whereCLegalOr1.add(new al.FieldCondition('minimum_age__c').equals(null));
                    whereCLegalOr1.add(new al.FieldCondition('minimum_age__c').lessthanorequalto(value));                       
                    whereCAnd.add(whereCLegalOr1);
                }               
 
                /*if (client.Annual_Income_Realtime__c != null && client.Annual_Income_Realtime__c > 0){
                    //rjn my head is spinning.
                    PovertyBean pb = cUtils.retrievePoverty(client);
                    if(client.is_military__c) {
                        pb = cUtils.retrieveAMIPoverty(client);
                    } else {
                        pb = cUtils.retrievePoverty(client);
                    }
                    system.debug(logginglevel.info,'<b>Rick clients povertylevel = '+pb.povertyPct);
                    if(pb!=null && pb.povertyPct != null && pb.povertyPct > 0) {    
                        whereCAnd.add(new al.FieldCondition('min_poverty_level_pct__c').greaterthanorequalto(pb.povertyPct));
                        whereCAnd.add(new al.FieldCondition('max_poverty_level_pct__c').lessthanorequalto(pb.povertyPct));
                    }
                }*/          
            }
        }
        if (client != null) {
            // Changed this filter to apply to ALL resources, including weblinks because of IL-AFLAN hotline    
            /* only pull those accounts valid for client's zip code */
            system.debug(logginglevel.info,'ERICA clients zip = '+client.MailingPostalCode);
            system.debug(logginglevel.info,'ERICA clients county = '+client.county__c);
                        
            String zip5 = '00000';
            String county = '';
            if (client != null) {
                zip5 = client.MailingPostalCode;
                county = client.county__c;
            }
            if (client.MailingPostalCode != null) {
                // ELC - changed this to truncate the zip searched to 5 digits - 9 digit zips were messing this up 
                zip5 = client.MailingPostalCode.substring(0, Math.min(5, client.MailingPostalCode.length()));
            }
            system.debug(logginglevel.info,'ERICA zip 5 = '+zip5);
            List<ID> zids = new List<ID>();
            List<Zip__c> zs = new List<Zip__c>();
            
            try {
                zs = [select ID from Zip__c where name in (:zip5, :county)];
                if (zs.size() > 0) {
                
                } else {
                    system.debug(logginglevel.info,'Client Zip not found2.  Zip = '+zip5);
                }
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
            for (Zip__c z:zs) {
                zids.add(z.id);
            }
            // now add the value for those accounts not restricted by zip code
            zs = null;
            try {
                zs = [select ID from Zip__c where name = :ALLZIPS];
                if (zs.size() > 0) {
                
                } else {
                    system.debug(logginglevel.info,'ALLZIP not found.');
                }
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
            for (Zip__c z:zs) {
                zids.add(z.id);
            }
            
            String soqlSub2 = '';
            try {
                soqlSub2 = new al.SoqlBuilder()
                            .selectx(new Set<String> {'account__c'}) 
                            .fromx('Account_Zip_Junction__c')
                            .wherex(new al.SetCondition('zip__c',al.Operator.INX,(zids)))                                //.wherex(new al.FieldCondition('zip__c').equals(zipId))
                            .toSoql();
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
            List<Account_Zip_Junction__c> lAccountZips;
            debugMessages.add('lAccountZips'+lAccountZips);
            try {   
                system.debug(logginglevel.info,'<b>Account Resources subSOQL2=</b>'+soqlSub2);  
                lAccountZips = Database.query (soqlSub2);
            } catch (Exception e)  {
                system.debug(logginglevel.warn,'<b>ERROR IN Account REsources subSoql2');
            }   
            List<Id> lazAccountIds = new List<Id>();
    
            for(Account_Zip_Junction__c az : lAccountZips) {
                Id azAccountId = az.Account__c;
                lazAccountIds.add(azAccountId);
            }
            
            // will return null if there are no results, because no accounts meet the criteria
            if(lazAccountIds !=null && !lazAccountIds.isEmpty()) {
                whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lazAccountIds )));
            } else {
                return null;
            }
            /* end zip code addition *************/
        }
        
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Case_Acceptance_Guidelines__c');
        excludeFields.add('Income_Criteria__c');
        excludeFields.add('Description');
        whereCAnd.add(new al.FieldCondition('active__c').equals(true));
        
        try {
            soqlAccts =     new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Account',false,excludeFields)) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .fromx('Account')
                            .wherex( whereCAnd )
                            // IL-AFLAN wants military resources on top but sorted elsewhere by resource usage
                            //.orderByx(new List<al.OrderBy>{
                            //  new al.OrderBy('Military_Service__c').descending(),
                            //  new al.OrderBy('name').descending().nullsLast()})
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soqlAccts);
            return null;                        
        }
        
        
        try {   
            system.debug(logginglevel.info,'<b>Account Resources baseSOQL1=</b>'+soqlAccts);
            accounts = Database.query (soqlAccts);
            if(accounts!= null) {
                system.debug(logginglevel.warn,'----------------------------> retrieved '+accounts.size()+' accounts.');    
            }
        } catch (Exception e)  {
            //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
            system.debug(logginglevel.warn,'<b>ERROR IN Account REsources baseSoql');
        }                           
                                    
        return accounts;                            
    }
    
    public static Set<Id> retrieveAcctIdsBySubject(Id subjectId, String sType) {
        ResourceType rt;
        List<Account_Subject_Junction__c> asjs;
        Set<ID> acctIds = new Set<ID>();
        
        if('WEBLINK'.equalsIgnoreCase(sType)) {
            rt = ResourceType.WEBLINK;
        }
        if('LEGAL'.equalsIgnoreCase(sType)) {
            rt = ResourceType.LEGAL;
        }   
        if('SOCIAL'.equalsIgnoreCase(sType)) {
            rt = ResourceType.SOCIAL;
        }
        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('subject__c').equals(subjectId));
        if(rt == resourceType.WEBLINK) {
            whereCAnd.add(new al.FieldCondition('Account_Type__c').equals('WebLink'));
        }       
        if(rt == resourceType.LEGAL) {
            whereCAnd.add(new al.FieldCondition('Account_Type__c').equals('Legal Referral'));
        }       
        if(rt == resourceType.SOCIAL) {
            al.NestableCondition whereCSocialOr = new al.OrCondition();
            whereCSocialOr.add(new al.FieldCondition('Account_Type__c').equals('Social Service Referral'));
            whereCSocialOr.add(new al.FieldCondition('Account_Type__c').equals('Social Referral'));        
            whereCAnd.add(whereCSocialOr);
        }
        String soql;
        try {
            soql         =  new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Account_Subject_Junction__c',false)) 
                            .fromx('Account_Subject_Junction__c')
                            .wherex( whereCAnd )
                            .toSoql(); 
            if(debugMessages != null) {
                debugMessages.add('AccountUtils -- ASJ Soql='+soql);
            }                           
        } catch (Exception e) {
            if(debugMessages != null) {
                debugMessages.add(e.getStackTraceString());
            }
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soql);
            return acctIds;                 
        }       
        try {   
            system.debug(logginglevel.info,'<b>Account by subject soql =</b>'+soql);    
            asjs = Database.query (soql);
            if(asjs!= null) {
                system.debug(logginglevel.warn,'----------------------------> retrieved '+asjs.size()+' junction objects.');    
            }
        } catch (Exception e)  {
            if(debugMessages != null) {
                debugMessages.add(e.getStackTraceString());
            }       
            system.debug(logginglevel.warn,'<b>ERROR IN Account by subject soql:'+e);
        }       
        if(asjs != null) {
            for(Account_Subject_Junction__c asj  : asjs) {
                acctIds.add(asj.account__c);    
            }
        }
        return acctIds;
        
    }
    public static Set<Id> retrieveAcctIdsBySubject(Id subjectId, ResourceType eType) {
        ResourceType rt = eType;
        List<Account_Subject_Junction__c> asjs;
        Set<ID> acctIds = new Set<ID>();

        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('subject__c').equals(subjectId));
        if(rt == resourceType.WEBLINK) {
            whereCAnd.add(new al.FieldCondition('Account_Type__c').equals('WebLink'));
        }       
        if(rt == resourceType.LEGAL) {
            whereCAnd.add(new al.FieldCondition('Account_Type__c').equals('Legal Referral'));
        }       
        if(rt == resourceType.SOCIAL) {
            al.NestableCondition whereCSocialOr = new al.OrCondition();
            whereCSocialOr.add(new al.FieldCondition('Account_Type__c').equals('Social Service Referral'));
            whereCSocialOr.add(new al.FieldCondition('Account_Type__c').equals('Social Referral'));        
            whereCAnd.add(whereCSocialOr);
        }
        
        String soql;
        try {
            soql         =  new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Account_Subject_Junction__c',false)) 
                            .fromx('Account_Subject_Junction__c')
                            .wherex( whereCAnd )
                            .toSoql(); 
            if(debugMessages != null) {
                debugMessages.add('AccountUtils ASJ Soql='+soql);
            }                           
        } catch (Exception e) {
            if(debugMessages != null) {
                debugMessages.add(e.getStackTraceString());
            }           
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soql);
            return acctIds;                 
        }       
        try {   
            system.debug(logginglevel.info,'<b>Account by subject soql =</b>'+soql);    
            asjs = Database.query (soql);
            if(asjs!= null) {
                system.debug(logginglevel.warn,'----------------------------> retrieved '+asjs.size()+' junction objects.');    
            }
        } catch (Exception e)  {
            if(debugMessages != null) {
                debugMessages.add(e.getStackTraceString());
            }       
            system.debug(logginglevel.warn,'<b>ERROR IN Account by subject soql:'+e);
        }       
        if(asjs != null) {
            for(Account_Subject_Junction__c asj  : asjs) {
                acctIds.add(asj.account__c);    
            }
        }
        return acctIds;
        
    }
    public static Account retrieveAccount(Id acctId) {
        Account a;
        String soqlAcct = '';       
        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('id').equals(acctId));

        
        try {
            soqlAcct =  new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Account',false)) 
                            .selectx((new Set<String> {'CreatedBy.Name','CreatedBy.communitynickname','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .fromx('Account')
                            .wherex( whereCAnd )
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soqlAcct);
            return null;                        
        }   
        try {   
            system.debug(logginglevel.info,'<b>Account SOQL=</b>'+soqlAcct);    
            a = Database.query (soqlAcct);

        } catch (Exception e)  {
            //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
            system.debug(logginglevel.warn,'<b>ERROR IN Account soql');
        }       
        return a;       
            
    }   
    public static Account retrieveAccountWoLongText(Id acctId) {
        Account a;
        String soqlAcct = '';       
        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('id').equals(acctId));
        
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Case_Acceptance_Guidelines__c');
        excludeFields.add('Income_Criteria__c');
        excludeFields.add('Description');
        
        try {
            soqlAcct =  new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Account',false, excludeFields))         
                            .selectx((new Set<String> {'CreatedBy.Name','CreatedBy.communitynickname','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .fromx('Account')
                            .wherex( whereCAnd )
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soqlAcct);
            return null;                        
        }   
        try {   
            system.debug(logginglevel.info,'<b>Account SOQL=</b>'+soqlAcct);    
            a = Database.query (soqlAcct);

        } catch (Exception e)  {
            //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
            system.debug(logginglevel.warn,'<b>ERROR IN Account soql');
        }       
        return a;       
            
    }   
    public static List<Account> retrieveAccounts(Set<Id> accountIds, ResourceType eType, Contact client) {
    
        List<Account> accounts;
        List<Account> filteredAccounts = new List<Account>();
        String soqlAccts = '';      
        al.NestableCondition whereCAnd = new al.AndCondition();
        
        
        List<Id> lAccountIds = new List<Id>();
        for(Id id : accountIds) {
            lAccountIds.add(id);    
        }
        whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lAccountIds)));

        system.debug(logginglevel.info,'RICK resource type = '+eType);
        system.debug(logginglevel.info,'RICK client = '+client);



        if (eType == resourceType.LEGAL || eType == resourceType.SOCIAL) {
            if(client != null) {
                //---rjn check if military and then use vdisablity field if applicable
                //-- moved to post query processing so as not to already filter out possible records
                //-- if resource record as age_disability_logic = OR
                /*
                if(!client.is_military__c) {

                    if (client.disability__c == null || client.disability__c == 'None') {
                        al.NestableCondition whereCOrDisabled = new al.OrCondition();
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(null));
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(false));
                        whereCAnd.add(whereCOrDisabled);
                    }
                } else {
                    if (client.VDisablity__c == null || client.VDisablity__c == 'None') {
                        al.NestableCondition whereCOrDisabled = new al.OrCondition();
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(null));
                        whereCOrDisabled.add(new al.FieldCondition('Serves_Only_Disabled__c').equals(false));
                        whereCAnd.add(whereCOrDisabled);
                    }
                }
                */
                
                List<String> language = new List<String>();
                if(client.language__c != null) {                
                    language.add(client.language__c);
                } else {
                    language.add('English');    
                }
                al.NestableCondition whereCLangOr = new al.OrCondition();
                whereCLangOr.add(new al.FieldCondition('Languages__c').equals(null));
                whereCLangOr.add(new al.SetCondition('Languages__c',al.Operator.INCLUDES, (language )));
                whereCAnd.add(whereCLangOr);
                /*-- rjn moved to age/disability post query for loop so as not to overide or criteria.
                if (client.Birthdate != null) {
                    Integer value = Integer.valueOf(string.valueOf(math.floor(client.Birthdate.daysBetween(date.today())/365)));
                    al.NestableCondition whereCLegalOr1 = new al.OrCondition();
                    whereCLegalOr1.add(new al.FieldCondition('minimum_age__c').equals(null));
                    whereCLegalOr1.add(new al.FieldCondition('minimum_age__c').lessthanorequalto(value));                       
                    whereCAnd.add(whereCLegalOr1);
                }
                */
 
               /* if (client.Annual_Income_Realtime__c != null && client.Annual_Income_Realtime__c > 0){
                    ///PovertyBean pb = cUtils.retrievePoverty(client);
                    //Max_Poverty_Level
                    PovertyBean pb;// = cUtils.retrievePoverty(client);
                    if(client.is_military__c) {
                        pb = cUtils.retrieveAMIPoverty(client);
                    } else {
                        pb = cUtils.retrievePoverty(client);
                    }

                    system.debug(logginglevel.info,'<b>ERICA clients povertylevel = '+pb.povertyPct);
                    if(pb!=null && pb.povertyPct != null && pb.povertyPct > 0) {    
                        al.NestableCondition whereCPvtyOr1 = new al.OrCondition();
                        al.NestableCondition whereCPvtyOr2 = new al.OrCondition();
                        // rjn i don't understand this.
                        whereCPvtyOr1.add(new al.FieldCondition('min_poverty_level_pct__c').equals(null));
                        whereCPvtyOr1.add(new al.FieldCondition('min_poverty_level_pct__c').lessthanorequalto(pb.povertyPct));
                        whereCPvtyOr2.add(new al.FieldCondition('max_poverty_level_pct__c').equals(null));
                        whereCPvtyOr2.add(new al.FieldCondition('max_poverty_level_pct__c').greaterthanorequalto(pb.povertyPct));
                        whereCAnd.add(whereCPvtyOr1);
                        whereCAnd.add(whereCPvtyOr2);
                        
                        whereCPvtyOr1.add(new al.FieldCondition('min_poverty_level_pct__c').equals(null));
                        whereCPvtyOr1.add(new al.FieldCondition('min_poverty_level_pct__c').greaterThanorequalTo(pb.povertyPct));
                        whereCPvtyOr2.add(new al.FieldCondition('max_poverty_level_pct__c').equals(null));
                        whereCPvtyOr2.add(new al.FieldCondition('max_poverty_level_pct__c').lessthanorequalto(pb.povertyPct));
                        whereCAnd.add(whereCPvtyOr1);
                        whereCAnd.add(whereCPvtyOr2);
                        
                    }
                }*/
                
            }
        }           
        // Added for IL-AFLAN hotline
        if (client != null) {
            if(client.is_military__c == false) {
                whereCAnd.add(new al.FieldCondition('Military_Service__c').equals(false));
            }   
            // zip code filter now applies to all resources including weblinks - IL-AFLAN             
            String zip5 = '00000';
            String county = '';
            /* only pull those accounts valid for client's zip code */
            if (client != null) {
                zip5 = client.MailingPostalCode;
                county = client.county__c;
            }
            if(client != null && client.mailingPostalCode != null) {
                system.debug(logginglevel.info,'ERICA clients zip = '+client.MailingPostalCode);
                // ELC - changed this to truncate the zip searched to 5 digits - 9 digit zips were messing this up 
                zip5 = client.MailingPostalCode.substring(0, Math.min(5, client.MailingPostalCode.length()));
            }               

            List<Zip__c> zs = new List<Zip__c>(); 
            List<ID> zids = new List<ID>();
            system.debug(logginglevel.info,'ERICA zip 5 = '+zip5);
            try {
                zs = [select ID from Zip__c where name in (:zip5,:county)];
                if (zs.size() > 0) {
                    
                } else {
                    system.debug(logginglevel.info,'Client Zip not found.  Zip = '+client.mailingPostalCode);
                }
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
            for (Zip__c z:zs) {
                zids.add(z.id);
            }
            // now add the value for those accounts not restricted by zip code
            zs = null;
            try {
                zs = [select ID from Zip__c where name = :ALLZIPS];
                if (zs.size() > 0) {
                
                } else {
                    system.debug(logginglevel.info,'ALLZIP not found.');
                }
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
            for (Zip__c z:zs) {
                zids.add(z.id);
            }
            
            String soqlSub2 = '';
            try {
                soqlSub2 = new al.SoqlBuilder()
                            .selectx(new Set<String> {'account__c'}) 
                            .fromx('Account_Zip_Junction__c')
                            .wherex(new al.SetCondition('zip__c').inx(zids))
                            .toSoql();
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
            List<Account_Zip_Junction__c> lAccountZips;
            try {       
                lAccountZips = Database.query (soqlSub2);
            } catch (Exception e)  {
                system.debug(logginglevel.warn,'<b>ERROR IN Account REsources subSoql2');
            }   
            List<Id> lazAccountIds = new List<Id>();
    
            for(Account_Zip_Junction__c az : lAccountZips) {
                Id azAccountId = az.Account__c;
                lazAccountIds.add(azAccountId);
            }
            system.debug(logginglevel.info,'<b>ERICA # accts for zip = '+lazAccountIds.size());
            // will return null if there are no results, because no accounts meet the criteria
            if(lazAccountIds !=null && !lazAccountIds.isEmpty()) {
                whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lazAccountIds )));
            } else {
                return null;
            }
            /* end zip code addition *************/
          
        }
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Case_Acceptance_Guidelines__c');
        excludeFields.add('Income_Criteria__c');
        excludeFields.add('Description');
        whereCAnd.add(new al.FieldCondition('active__c').equals(true));
        
        try {
            soqlAccts =     new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Account',false,excludeFields)) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .fromx('Account')
                            .wherex( whereCAnd )
                            // IL-AFLAN wants military resources on top but sorted elsewhere by resource usage
                            //.orderByx(new List<al.OrderBy>{
                            //  new al.OrderBy('Military_Service__c').descending(),
                            //  new al.OrderBy('name').descending().nullsLast()})
                            .toSoql();
             //-- damn this is intense.. welcome to carpls lol
                                   
        } catch (Exception e) {
            //was at some point not locking 'shippingaddress' column had to update all classes
            //in the call stack to an api version 30 or over
            if(debugMessages != null) {
                debugMessages.add('<font color="red">------ ERROR! soqlAccts for retrieveAccounts '+e + ' soql= '+soqlAccts + '</font>' );
            }  
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soqlAccts);
            return null;                        
        }   
        try {   
            system.debug(logginglevel.info,'<b>Account Resources baseSOQL2=</b>'+soqlAccts);
            accounts = Database.query (soqlAccts);

            if(accounts!= null) {
                system.debug(logginglevel.warn,'----------------------------> retrieved '+accounts.size()+' accounts.');
                //--- rjn probably can be cleaned up... this is a first try...
                //-- age/disability thing filter out of already queried results
                //-- role through result set and filter out values if account fields indicate would should further eval.
                //---note we can't do a list.remove(i) because we are iterating a collection and saleforce will not allow that
                //--- we have have do dump good records in another list.
                if(!accounts.isEmpty()) {
                    for(Account a : accounts) {
                        Boolean incomePassed = false;
                        if(client.poverty_level_ami__c == null) client.poverty_level_ami__c = 0.0;
                        if(client.poverty_level__c == null) client.poverty_level__c = 0.0;
                        if(a.poverty_formula__c == 'AMI'){
                            if( (a.min_poverty_level_pct__c == null || a.min_poverty_level_pct__c <= client.poverty_level_ami__c) &&
                                 (a.max_poverty_level_pct__c == null || a.max_poverty_level_pct__c >= client.poverty_level_ami__C) ){
                                     incomePassed = true;
                            }
                        }
                        else {
                            if( (a.min_poverty_level_pct__c == null || a.min_poverty_level_pct__c <= client.poverty_level__c) &&
                                    (a.max_poverty_level_pct__c == null || a.max_poverty_level_pct__c >= client.poverty_level__c ) ){
                                        incomePassed = true;
                                        
                            }
                            
                        }



                        //============================= AGE Disability Logic picklist has a value =============================================
                        //incomePassed = true;
                        if(a.Age_Disability_Logic__c != null && a.age_disability_logic__c != 'None' && a.Age_Disability_Logic__c != '') {

                            //--------- OR Logic
                            if(a.Age_Disability_logic__C == 'OR') {
                                if(a.Minimum_Age__c != null && a.Minimum_Age__c != 0) {
                                    if(client.Current_Age__c != null ) {
                                        if(a.minimum_age__C == null) a.minimum_age__C = 0;
                                        Decimal clientAge = client.Current_Age__c;
                                        if(clientAge >= a.minimum_age__C && incomePassed) {
                                            filteredAccounts.add(a);

                                        } else {
                                            if(client.is_military__C) {
                                                if(client.VDisablity__c !=null && client.VDisablity__c != 'None' && incomePassed) {
                                                    filteredAccounts.add(a);
                                                }
                                            } else {
                                                if(client.Disability__c !=null && client.Disability__c != 'None' && incomePassed) {
                                                    filteredAccounts.add(a);
                                                    
                                                }
                                            }
                                        }
                                     
                                    } else {
                                        if(incomePassed){
                                        	filteredAccounts.add(a);
                                        }
                                    }
                                }
                            }
                            //--------- AND Logic
                            if(a.Age_Disability_logic__C == 'AND') {
                                boolean ageFailed = false;
                                boolean disabilityFailed = false;
                                if(a.Minimum_Age__c != null && a.Minimum_Age__c != 0) {
                                    if(client.Current_Age__c != null) {
                                        Decimal clientAge = client.Current_Age__c;
                                        if(clientAge < a.minimum_age__C) {
                                            ageFailed = true;
                                        }
                                    }
                                }
                                if(client.is_military__C) {
                                    if(client.VDisablity__c ==null || client.VDisablity__c == 'None') {
                                        disabilityFailed = true;
                                    }
                                } else {
                                    if(client.Disability__c ==null || client.Disability__c == 'None') {
                                        disabilityFailed = true;
                                    }
                                }
                                if(!ageFailed && !disabilityFailed && incomePassed) {
                                    filteredAccounts.add(a);


                                }
                            }
                        } 
                        
                        
                        
                        
                        else {
                            Boolean failedAgeCheck = false;
                            Boolean failedServesOnlyCheck = false;
                            if(a.minimum_age__C != null && a.minimum_age__C != 0) {
                                if(client.Current_Age__c != null) {
                                    if(client.Current_Age__C < a.minimum_age__C) {
                                        failedAgeCheck = true;
                                    }
                                }
                            }
                            if(a.serves_only_disabled__c) {
                                if(client.is_military__c) {
                                    if(client.VDisablity__c == null || client.VDisablity__c == 'None') {
                                        failedServesOnlyCheck = true;
                                    }
                                } else {
                                    if(client.Disability__c == null || client.Disability__c == 'None') {
                                        failedServesOnlyCheck = true;
                                    }
                                }
                            }
                            
                            if(!failedAgeCheck && !failedServesOnlyCheck && incomePassed) {
                                filteredAccounts.add(a);

                            }
                        }
                    }
                }
            }

        } catch (Exception e)  {
            //super.debugLog('<b>ERROR IN CONTACT SOQL '+e.getMessage()+'</b>');
            if(debugMessages != null) {
                debugMessages.add('<font color="red">------ ERROR! soqlAccts for retrieveAccounts '+e + ' soql= '+soqlAccts + '</font>' );
            }              
            system.debug(logginglevel.warn,'<b>ERROR IN Account REsources baseSoql');
        }       
        //return accounts;
        System.debug('filtered Accounts >>.'+ filteredAccounts);
        return filteredAccounts;

    }
    // added to support the NPSP and the new account model
    public static Account buildNewOrgAccount(Contact c) {

        if (c == null) {
            system.debug('null contact passed to buildNewOrgAccount');
            return null;
        }
        // get the id for the Organization record type for Account
        List<RecordType> RtList = [select id from recordtype where name = 'Org Party'];
        Id rtId = RtList[0].Id;

        Account acct = new Account();
        acct.name = c.org_name__c;
        acct.billingstreet = c.mailingstreet;
        acct.phone = c.phone;
        acct.recordTypeId = rtId;
        
        return acct;
        
    }
    
   
    
}