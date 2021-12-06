// ELC 10/18/2017 - added a new buildAppliedResource method for IL-AFLAN Referrals
// ELC 11/5/2017 - changed initial status value for account-based resources to Pending rather than Applied to be consistent with terminology in IL-AFLAN referrrals

public with sharing class AppliedResourceUtils {
    public  List<String>            debugMessages   {get;set;}
    
    public AppliedResourceUtils() {
        debugMessages = new List<String>();
    }
    public Applied_Resource__c retrieveAppliedResource(Id arId) {
        Applied_Resource__c ar;
        al.NestableCondition whereC = new al.AndCondition();        
        whereC.add(new al.FieldCondition('id').equals( arId )); 
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Applied_Resource__c', false ))
                    .selectx(new Set<String> {'createdby.name','createdby.communitynickname', 'createdby.createddate'}) 
                    .fromx  ('Applied_Resource__c')
                    .wherex( whereC )
                    .toSoql();  
        try { 
            ar = Database.query(soql);              
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        return ar;                                      
    }
    public Applied_Resource__c retrieveAppliedResource(Case cse, Id pId, String ptype) {
        Applied_Resource__c ar;
        if(cse == null) {
            String msg = 'Invalid parm cse='+cse;
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        Id cseId = cse.id;      
        whereC.add(new al.FieldCondition('case__c').equals( cseId ));   
        if (ptype == 'DDP') {
      		whereC.add(new al.FieldCondition('ddp__c').equals( pId));
        } else if (ptype == 'Legal Referrals' || ptype == 'Social Referrals') {
        	whereC.add(new al.FieldCondition('account__c').equals( pId));
        }
        List<al.OrderBy> lOrder = new List<al.OrderBy>{
        	new al.OrderBy('createdDate').descending().nullsLast()
        };               
        List<Applied_Resource__c> ars = this.retrieveAppliedResources(whereC,lOrder);
        if(ars != null && !ars.isEmpty()) {
            ar = ars[0];
            
        }
        return ar;
    }
    /** TODO - remove this one */
    public Applied_Resource__c retrieveAppliedResource(Case cse, Id ddpId) {
        Applied_Resource__c ar;
        if(cse == null) {
            String msg = 'Invalid parm cse='+cse;
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        Id cseId = cse.id;      
        whereC.add(new al.FieldCondition('case__c').equals( cseId ));   
        whereC.add(new al.FieldCondition('ddp__c').equals( ddpId));
        List<Applied_Resource__c> ars = this.retrieveAppliedResources(whereC,50000);
        if(ars != null && !ars.isEmpty()) {
            ar = ars[0];
            
        }
        return ar;
    }
    
    /**
     *@TODO merge with the below.
     */
    public List<Applied_Resource__c> retrieveAppliedResources(Case cse, List<al.OrderBy> orderByList) {
        if(cse == null) {
            String msg = 'Invalid parm cse='+cse;
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        Id cseId = cse.id;      
        whereC.add(new al.FieldCondition('case__c').equals( cseId ));   
        return this.retrieveAppliedResources(whereC,orderByList);       
    }
        
    public List<Applied_Resource__c> retrieveAppliedResources(Case cse) {
        if(cse == null) {
            String msg = 'Invalid parm cse='+cse;
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        Id cseId = cse.id;      
        whereC.add(new al.FieldCondition('case__c').equals( cseId ));   
        return this.retrieveAppliedResources(whereC,1000);       
    }
    public List<Applied_Resource__c> retrieveAppliedResources(Case cse, Consultation__c cons) {
        if(cse == null) {
            String msg = 'Invalid parm cse='+cse;
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        Id cseId = cse.id;      
        whereC.add(new al.FieldCondition('case__c').equals( cseId ));
        if(cons != null) {
            Id consId = cons.id;
            whereC.add(new al.FieldCondition('consultation__c').equals( consId ));
        }   
        return this.retrieveAppliedResources(whereC,1000);       
    }
    public List<Applied_Resource__c> retrieveAppliedResources(Subject__c subject) {
        if(subject == null) {
            String msg = 'Invalid parm subject='+subject;
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
        al.NestableCondition whereC = new al.AndCondition();
        Id subjectId = subject.id;      
        whereC.add(new al.FieldCondition('subject__c').equals( subjectId ));
        return this.retrieveAppliedResources(whereC,1000);           
    }
    
    
    
    public List<Applied_Resource__c> retrieveAppliedResources(al.NestableCondition whereC, Integer iMaxRows) {
        

        List<Applied_Resource__c> ars = new List<Applied_Resource__c>();        
        
        String soql = '';
        try {
            soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Applied_Resource__c', false ))
                    .selectx(new Set<String> {'createdby.name','createdby.communitynickname', 'createdby.createddate','case__r.casenumber'})    
                    .fromx  ('Applied_Resource__c')
                    .wherex( whereC )
                    .limitx(iMaxRows)
                    .toSoql();
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
            return null;
        }   
        try { 
            ars = Database.query(soql);             
        } catch (Dmlexception dmlEx) {
            System.debug(logginglevel.error, dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        system.debug(logginglevel.info,' # of applies resource retrieved = '+ars.size());
        system.debug(logginglevel.info,' soql='+soql);
        return ars;                                         
    }
    /**
     * @TODO Merge with the above!!!
     */
    public List<Applied_Resource__c> retrieveAppliedResources(al.NestableCondition whereC,List<al.OrderBy> orderByList) {
        

        List<Applied_Resource__c> ars = new List<Applied_Resource__c>();        
        
        String soql = '';
        try {
            soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Applied_Resource__c', false ))
                    .selectx(new Set<String> {'createdby.name','createdby.communitynickname', 'createdby.createddate','case__r.casenumber','consultation__r.name'})    
                    .fromx  ('Applied_Resource__c')
                    .wherex( whereC )
                    .orderbyx(orderByList)
                    /*
                    .orderbyx(
                        new List<al.OrderBy>{
                            new al.OrderBy('total_nbr_of_applied_resources__c').descending().nullsLast()
                            ,new al.OrderBy('createdDate').descending().nullsLast()
                        }                   
                    )
                    */
                    
                    .toSoql();
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
            return null;
        }   
        try { 
            ars = Database.query(soql);             
        } catch (Dmlexception dmlEx) {
            System.debug(logginglevel.error, dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        system.debug(logginglevel.info,' # of applies resource retrieved = '+ars.size());
        system.debug(logginglevel.info,' soql='+soql);
        return ars;                                         
    }   
                                

    /**
     * note.. requires RecordType.developername
     * @TODO Doc.
     */
    public id createAppliedResource(Subject__c aSubject, Case cse, Consultation__c currentConsultation) {
        Id arId;
        
        if(cse == null || aSubject == null || currentConsultation == null) {
            String msg = 'Invalid parm';
            debugMessages.add(msg);
            System.debug(logginglevel.error, msg);
            return null;
        }
            
        Applied_Resource__c ar = new Applied_Resource__c();
        ar.Account__c = cse.AccountId;
        ar.Case__c = cse.id;

        if(ar.type__c == 'FAQ') {
            ar.service_form_guid__c = cse.service_form_guid__c; //need to ensure a Subject does not (eventually) get assigned to the wrong svc
        }

        //No longer an MD relationship as we are not 'preinserting' blank service records.
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;

            // sigh.. SFDC we could use a Switch statement you DBs
            Boolean updateSvc = false;
            if(ar.type__C == 'Legal Referrals' && ar.account_sub_type__c == 'Legal Aid') {
                currentConsultation.legal_referral__c = true;
                updateSvc = true;
            } else if( ar.type__c == 'Web Links') {
                currentConsultation.weblink__c = true;
                updateSvc = true;
            } else if (ar.type__c == 'DDP') {
                currentConsultation.publication__c = true;
                updateSvc = true;
            } else if (ar.type__c == 'Social Referrals') {
                currentConsultation.social_referral__c = true;
                updateSvc = true;
            } else if (ar.type__C == 'FAQ') {
                currentConsultation.faq__c = true;
                updateSvc = true;
            }
            if (updateSvc) {
                try {
                    update currentConsultation;
                } catch (Exception e) {
                    system.debug(logginglevel.error,e);
                }
            }

        }
        ar.subject__c = aSubject.id;
        ar.Status__c = 'Applied';
        ar.Type__c = aSubject.RecordType.developername;
        ar.title__c = aSubject.title__c;
        try { 
            insert ar;
            arId = ar.id;           
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }   
        return ar.id;
    }
    public Applied_Resource__c buildAppliedResource(IRefWrapper iRefWrap, Case cse, Consultation__c currentConsultation) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.Account__c = iRefWrap.getResource().id;
        ar.Case__c = cse.id;
        //No longer an MD relationship as we are not 'preinserting' blank service records.
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;
        }
        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        
        If(iRefWrap.getResType() == ResourceType.LEGAL) {
            ar.type__c = 'Legal Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Manual_Referral').id;
        }
        If(iRefWrap.getResType() == ResourceType.SOCIAL) {
            ar.type__c = 'Social Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Social').id;            
        }
        If(iRefWrap.getResType() == ResourceType.WEBLINK) {
            ar.type__c = 'Web Links';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Web').id;            
        }
        ar.title__c = iRefWrap.getResource().Name;
        
        return ar;
    }
    public Applied_Resource__c buildAppliedResource(Account a, Case cse, Consultation__c currentConsultation) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.Account__c = a.id;
        ar.Case__c = cse.id;
        //No longer an MD relationship as we are not 'preinserting' blank service recordss
        //service_form_guid is a way to track that last time a service form was opened on the case so that
        //the service id can be updated at a later time
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;
        } else {
            ar.service_form_guid__C = cse.service_form_guid__c;
        }

        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        
        if(a.Type == 'Legal Referral') {
            ar.type__c = 'Legal Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Manual_Referral').id;            
        }
        if(a.Type == 'Social Service Referral' || a.Type == 'Social Referral') {
            ar.type__c = 'Social Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Social').id;            
        }       
        if(a.Type == 'WebLink') {
            ar.type__c = 'Web Links';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Web').id;            
        }
        ar.title__c = a.Name;
        
        return ar;
    }
    public Applied_Resource__c buildAppliedResource(Account a, Case cse, Consultation__c currentConsultation, Boolean cltApprovedRef) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.Account__c = a.id;
        ar.Case__c = cse.id;
        //No longer an MD relationship as we are not 'preinserting' blank service records.
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;
        }
        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        ar.clt_approved_referral__c = true;
        
        if(a.Type == 'Legal Referral') {
            ar.type__c = 'Legal Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Pending').id; 
            ar.closing_code__c = 'None';           
        }
        if(a.Type == 'Social Service Referral' || a.Type == 'Social Referral') {
            ar.type__c = 'Social Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Social').id;            
        }       
        if(a.Type == 'WebLink') {
            ar.type__c = 'Web Links';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Web').id;            
        }
        ar.title__c = a.Name;
        
        return ar;
    }
    // Will be used for Il-AFLAN referrals
    public Applied_Resource__c buildAppliedResource(Account a, Case cse, Consultation__c currentConsultation, String refReason) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.Account__c = a.id;
        ar.Case__c = cse.id;
        //No longer an MD relationship as we are not 'preinserting' blank service records.
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;
        }
        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        ar.il_aflan_referral_note__c = refReason;
        
        if(a.Type == 'Legal Referral') {
            ar.type__c = 'Legal Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Pending').id;    
            ar.closing_code__c = 'None';           
        }
        if(a.Type == 'Social Service Referral' || a.Type == 'Social Referral') {
            ar.type__c = 'Social Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Social').id;            
        }       
        if(a.Type == 'WebLink') {
            ar.type__c = 'Web Links';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Web').id;            
        }
        ar.title__c = a.Name;
        
        return ar;
    } 

    public Applied_Resource__c buildAppliedResource(Account a, Case cse, Consultation__c currentConsultation, String refReason, Date caseMngCourDate, String courtCase, String courtDistrict) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.Account__c = a.id;
        ar.Case__c = cse.id;
        //No longer an MD relationship as we are not 'preinserting' blank service records.
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;
        }
        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        ar.il_aflan_referral_note__c = refReason;
        ar.Case_Management_Court_Date__c = caseMngCourDate ;
        ar.Court_Case__c = courtCase;
        ar.Court_District__c = courtDistrict;
        
        if(a.Type == 'Legal Referral') {
            ar.type__c = 'Legal Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','E_Referral_Pending').id;    
            ar.closing_code__c = 'None';           
        }
        if(a.Type == 'Social Service Referral' || a.Type == 'Social Referral') {
            ar.type__c = 'Social Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Social').id;            
        }       
        if(a.Type == 'WebLink') {
            ar.type__c = 'Web Links';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','Web').id;            
        }
        ar.title__c = a.Name;
        
        return ar;
    }

    public Applied_Resource__c buildAppliedResourceCCLAHD(Account a, Case cse, Consultation__c currentConsultation, String refReason, Date caseMngCourDate, String courtCase, String courtDistrict) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.Account__c = a.id;
        ar.Case__c = cse.id;
        //No longer an MD relationship as we are not 'preinserting' blank service records.
        if(currentConsultation!=null) {
            ar.Consultation__c = currentConsultation.id;
        }
        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        ar.referral_note__c = refReason;
        ar.Case_Management_Court_Date__c = caseMngCourDate ;
        ar.Court_Case__c = courtCase;
        ar.Court_District__c = courtDistrict;
        ar.First_Name__c = cse.Contact.FirstName;
        ar.Last_Name__c = cse.Contact.LastName;
        ar.Client_DOB__c = cse.Contact.Birthdate;
        ar.Zip__c = cse.Contact.MailingPostalCode;
        ar.Phone__c = cse.Contact.Phone;
        ar.Email__c = cse.Contact.Email;
        ar.Language__c = cse.Contact.Language__c;
        if(cse.Contact.Age_at_intake__c >= 60){
            ar.Senior_60__c = TRUE;
        }else{
            ar.Senior_60__c = False;
        }
        if(cse.Contact.Disability__c == 'None'){
            ar.Disabled__c = FALSE;
        }else {
            ar.Disabled__c = TRUE;
        }
        if(a.Type == 'Legal Referral') {
            ar.type__c = 'Legal Referrals';
            ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','External_Pending').id;    
            ar.closing_code__c = 'None';           
        }
       
        ar.title__c = a.Name;
        
        return ar;
    }

    public Applied_Resource__c buildAppliedResource(Loop__DDP__c ddp, Case cse, Consultation__c currentConsultation) {
        Applied_Resource__c ar = new Applied_Resource__c();
        
        ar.DDP__c = ddp.id;
        ar.Case__c = cse.id;
        if(currentConsultation != null) {
            ar.Consultation__c = currentConsultation.id;
        } else {
           // System.debug(LoggingLevel.WARN,'Note the current consultation for Case:'+cse.casenumber + ' is null.. this should not happen');
        }
        ar.subject__c = cse.Selected_Subject__c;
        ar.Status__c = 'Applied';
        ar.type__c = 'DDP';
        ar.title__c = ddp.title__c;
        ar.flag_for_DDP__c = true;
        ar.recordtypeid = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Applied_Resource__c','DDP').id;  
        
        return ar;
    }       
}