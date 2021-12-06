public with sharing class ctrlCarplsLoopPlus extends ctrlCarplesGeneric {
	
/* obsolete?
   // public List<LOOP__DDP__c>                       loopDdps                    { get; set; }
   // public List<Loop__DDP_Integration_Option__c>    loopDeliveryMethods         { get; set; }
    public Contact                                  client                      { get; set; }
    public String                                   selectedDdpId               { get; set; }
    public String                                   selectedDmId                { get; set; }
        
    public ctrlCarplsLoopPlus(ApexPages.StandardController stdController) {
        this.client = (Contact)stdController.getRecord();   
        this.client = this.retrieveAllClientData();
      //  this.loopDdps = this.retrieveLoopDdps('Contact');
    }
    public Pagereference doSelectDdp() {
        debugLog('doSelectDdp selected id='+selectedDdpId);
        if(selectedDdpId != null) {
          //  this.loopDeliveryMethods = this.retrieveDdpDeliveryMethods(selectedDdpId);
        }
        return null;
    }
    public Pagereference doSelectDm() {
        debugLog('doSelectDm selected id='+this.selectedDmId);
        if(selectedDmId!= null) {
            //----this.loopDeliveryMethods = this.retrieveDdpDeliveryMethods(selectedDdpId);
        }
        return null;
    }   
 //   public List<Loop__DDP_Integration_Option__c> retrieveDdpDeliveryMethods(Id ddpId) {
 //       List<Loop__DDP_Integration_Option__c> ddpDeliveryMethods = new List<Loop__DDP_Integration_Option__c>();
 //       al.NestableCondition whereC = new al.OrCondition();     
 //       whereC.add(new al.FieldCondition('Loop__DDP__c').equals( ddpId ));          
        
 //       String soql = new al.SoqlBuilder()
 //                   .selectx(SoqlUtils.getAllFieldsSet('Loop__DDP_Integration_Option__c', false ))
 //                   //.selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r' ))
 //                   .fromx  ('Loop__DDP_Integration_Option__c')
 //                   .wherex( whereC )
 //                   .toSoql();          
        
 //       try { 
 //           ddpDeliveryMethods = Database.query(soql);              
 //       } Catch (Dmlexception e) {
            
 //       }   
 //       return ddpDeliveryMethods;  

 //   }
    
 //   public List<Loop__DDP__c> retrieveLoopDdps(String rtTypeDevName) {
 //       List<Loop__DDP__c> ddps = new List<Loop__DDP__c>();
 //       
 //       al.NestableCondition whereC = new al.OrCondition();     
 //       whereC.add(new al.FieldCondition('recordtype.developerName').equals( rtTypeDevName ));          
        
 //       String soql = new al.SoqlBuilder()
 //                   .selectx(SoqlUtils.getAllFieldsSet('Loop__DDP__c', false ))
 //                   //.selectx(SoqlUtils.getAllRelatedFieldsSet('Case', false, 'case__r' ))
 //                   .fromx  ('Loop__DDP__c')
//                    .wherex( whereC )
//                    .toSoql();          
        
 //       try { 
 //           ddps = Database.query(soql);            
 //       } Catch (Dmlexception e) {
 //           
 //       }
 //       return ddps;            
        
 //   }
    public List<Selectoption> getLoopDdpsOptions() {
        List<Selectoption> options = new List<Selectoption>();
   //     if(this.loopDdps != null) {
   //         for(Loop__DDP__c ddp : loopDdps) {
   //             String sId = ddp.id;
                
   //             options.add(new SelectOption(ddp.id, ddp.name));
   //         }
   //     }
        return options; 
    }
    public List<Selectoption> getDeliveryMethodOptions() {
        List<Selectoption> options = new List<Selectoption>();
     //   if(this.loopDeliveryMethods != null) {
     //       for(Loop__DDP_Integration_Option__c io : this.loopDeliveryMethods) {
                
     //           options.add(new SelectOption(io.id, io.name));
     //       }
     //   }
        return options; 
    }
   public Contact retrieveAllClientData() {
        id cId = client.id;
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact',false))    
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'id','name','Income_Type__c','Amount__c'})
                        .fromx('Income_Details__r')) 
                    .selectx(
                        new al.SoqlBuilder()
                        .selectx(new Set<String> {'contact__c','id','Type__c','Role__c','case__r.id','case__r.last_contact__c','case__r.closedDate','case__r.reason','case__r.caseNumber','case__r.subject','case__r.problem_category__c','case__r.practice_area__c','case__r.Problem_Code__c','case__r.status'})
                        .fromx('Case_Parties__r'))
                        .wherex(new al.FieldCondition('contact__c').equals(cId))
                        //.orderByx(new List<al.OrderBy>{
                        //      new al.OrderBy('case__r.last_contact__c').ascending().nullsLast()})                                                                     
                    .fromx  ('Contact c ')
                    .wherex (new al.FieldCondition('id').equals(cId))   
                    .toSoql (new al.SoqlOptions().wildcardStringsInLikeOperators());
        
        Contact c;                                  
        try {
            c = Database.query(soql);
        } catch (Dmlexception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }      
        return c;       
    }   
*/    
}