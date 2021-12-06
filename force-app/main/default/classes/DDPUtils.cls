public with sharing class DDPUtils {
    
    public static List<ContentDocument> retrieveDdpContentDocs(Id ddpId) {
        List<ContentDocument> contentDocuments = new List<ContentDocument>();
        List<Loop__DDP_File__c> ddpFiles = [select Loop__Document_ID__c from Loop__DDP_File__c where Loop__DDP__c = :ddpId];
        if(ddpFiles == null) {
            return contentDocuments;
        }
        List<Id> cDocIds = new List<ID>();

        for(Loop__DDP_File__c ddpFile : ddpFiles) {
            cDocIds.add(ddpFile.Loop__Document_ID__c);
        }
        if(cDocIds == null || cDocIds.isEmpty()) {
            return contentDocuments;
        }
        String soql = '';
        Set<Object> cDocFields = SoqlUtils.getAllFieldsSet('ContentDocument',false);
        Set<String> excludeFieldsCv = new Set<String>{'VersionData'};   
        Set<Object> cContentVersionFields = SoqlUtils.getAllRelatedFieldsSet( 'ContentVersion',false, 'LatestPublishedVersion',excludeFieldsCv );
        Set<Object> allFields = new Set<Object>();
        
        allFields.addAll(cDocFields);
        allFields.addAll(cContentVersionFields);
        
        

        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.SetCondition('id',al.Operator.INX,cDocIds));  

        soql = new al.SoqlBuilder()
            .selectx(allFields)
            .selectx((new Set<String> {'LatestPublishedVersion.CreatedBy.Name','LatestPublishedVersion.CreatedBy.communitynickname','LatestPublishedVersion.lastmodifiedby.name','LatestPublishedVersion.lastmodifiedby.communitynickname' })) 
            .fromx('ContentDocument')
            .wherex( whereC )
            .toSoql();  
  
        try { 
            System.debug(logginglevel.info,'soql='+soql);
            contentDocuments = Database.query(soql);            
        } catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return contentDocuments;
    }
    /**
     * @TODO Doc.
     * 
     */
    public static List<Loop__DDP__c> retrieveDdps( ProblemCodeWrapper pcWrap) {
        
        Boolean byPassProblemCodes = false;
        al.NestableCondition whereCAnd = new al.AndCondition();     
        
        if(pcWrap == null) {
            System.debug(logginglevel.warn, 'pcWrap parm cannot be null!');
            return null;
        }
        if(pcWrap.practiceArea == null) {
            byPassProblemCodes = true;
            System.debug(logginglevel.warn,'problem code wrapper='+pcWrap);
        }
        
        if(!byPassProblemCodes) {
            List<Id> epcIds = ProblemCodeUtils.retrieveEligibleProblemCodes(pcWrap, 'ddp__c');
            if(epcIds == null || epcIds.isEmpty()) {
                system.debug(logginglevel.warn,'<b>NO PROBLEM CODES FOUND!');
                if( (pcWrap.practiceArea =='' && pcWrap.practiceArea == '' && pcWrap.problemCode == '' && pcWrap.jurisdiction == '') || 
                     pcWrap.practiceArea == null) {
                    byPassProblemCodes = true;
                    system.debug(logginglevel.warn,'problemcode wrapper contains no values.. retrieveing all records');      
                } else {
                    return null;    
                }
            }           
            if(epcIds !=null && epcIds.size() > 0) {
                whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (epcIds )));
                //whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lAccountIds )));
            }                       
        } else {
            System.debug(logginglevel.warn, 'bypassing problem codes!');            
        }
        whereCAnd.add(new al.FieldCondition('status__c').equals('Active'));

        String soqlDdp = '';
        try {
            soqlDdp =   new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Loop__DDP__C',false)) 
                            .selectx((new Set<String> {'CreatedBy.Name','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .fromx('LOOP__DDP__c')
                            
                            .wherex( whereCAnd )
                            .orderByx(new al.OrderBy('Title__c').descending().nullsLast())
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error,'soql='+soqlDdp);
            return null;
        }
        
        List<Loop__DDP__c> ddps;
        try {   
            system.debug(logginglevel.info,'<b>DDP soqlL=</b>'+soqlddp);    
            ddps = Database.query (soqlDdp);            
        } catch (Exception e)  {
            system.debug(logginglevel.warn,e);
        }                           
        return ddps;            
    }
    public static Set<Id> retrieveDdpIdsBySubject(Id subjectId) {
        
        List<DDP_Subject_Junction__c> ddpSjs;
        Set<ID> ddpIds = new Set<ID>();
    
        al.NestableCondition whereCAnd = new al.AndCondition();
        whereCAnd.add(new al.FieldCondition('subject__c').equals(subjectId));   
        
        String soql;
        try {
            soql         =  new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('DDP_Subject_Junction__c',false)) 
                            .fromx('DDP_Subject_Junction__c')
                            .wherex( whereCAnd )
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soql);
            return ddpIds;                  
        }       
        try {   
            system.debug(logginglevel.info,'<b>DDP subject soql =</b>'+soql);   
            ddpSjs = Database.query (soql);
            if(ddpSjs!= null) {
                system.debug(logginglevel.warn,'----------------------------> retrieved '+ddpSjs.size()+' junction objects.');
                
            }
        } catch (Exception e)  {
        
            system.debug(logginglevel.warn,'<b>ERROR IN DDP by subject soql:'+e);
        }       
        if(ddpSjs != null) {
            for(DDP_Subject_Junction__c psj  : ddpSjs) {
                ddpIds.add(psj.ddp__c); 
            }
        }
        return ddpIds;
        
    }   
    
    public static Loop__DDP__c retrieveDdp(Id ddpId) {
        
        Loop__DDP__c ddp;
        
        Set<Id> ddpIds = new Set<Id>();
        ddpIds.add(ddpId);
        List<Loop__DDP__c> ddps = retrieveDdps(ddpIds,false);
        if(ddps != null && !ddps.isEmpty()) {
            ddp = ddps[0];
        }
        return ddp;
    }
    public static List<Loop__DDP__c> retrieveDdps(Set<Id> ddpIds) {
        return retrieveDdps(ddpIds, true);
    }
    public static List<Loop__DDP__c> retrieveDdps(Set<Id> ddpIds, Boolean bExcludeLargeFields) {
    
        List<Loop__DDP__c> ddps;
        String soql = '';       
        al.NestableCondition whereCAnd = new al.AndCondition();
        
        
        List<Id> lDdpIds = new List<Id>();
        for(Id id : ddpIds) {
            lDdpIds.add(id);    
        }
        whereCAnd.add(new al.SetCondition('id',al.Operator.INX, (lDdpIds)));
        
        whereCAnd.add(new al.FieldCondition('status__c').equals('Active'));
        
        Set<Object> ddpFields;
        if(bExcludeLargeFields) {
            Set<String> excludeFields = new Set<String>();
            excludeFields.add('Loop__Security__c');     
            excludeFields.add('Loop__RelatedObjects__c');
            ddpFields = SoqlUtils.getAllFieldsSet('Loop__DDP__c',false,excludeFields);          
        } else {
            ddpFields = SoqlUtils.getAllFieldsSet('Loop__DDP__c',false);
        }
        
        try {
            soql     =  new al.SoqlBuilder()
                            .selectx(ddpFields) 
                            .selectx((new Set<String> {'CreatedBy.Name','CreatedBy.communitynickname','lastmodifiedby.name','lastmodifiedby.communitynickname' })) 
                            .fromx('Loop__DDP__c')
                            .wherex( whereCAnd )
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soql);
            return null;                        
        }   
        try {   
            system.debug(logginglevel.info,'<b>DDP baseSOQL=</b>'+soql);    
            ddps = Database.query (soql);
            if(ddps!= null) {
                system.debug(logginglevel.warn,'----------------------------> retrieved '+ddps.size()+' ddps.');    
            }
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN DDP soql');
        }       
        return ddps;
    }   
}