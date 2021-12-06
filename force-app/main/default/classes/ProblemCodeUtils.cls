public with sharing class ProblemCodeUtils { 
    /*--- @TODO For Future Use... (Als backend VF page admin stuff)
    public static List<Eligible_Problem_Codes__c> retrieveAllEligibleProblemCodes(Integer iLimit) {
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('problem_code_heirarchy__c').equals(null)); 
        
        String soqlSub = '';
        try {
            soqlSub = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Eligible_Problem_Codes__c',false)) 
                .fromx('Eligible_Problem_Codes__c') 
                .wherex(whereC)
                .limitx(iLimit)
                .toSoql();
        } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
        }
        List<Eligible_Problem_Codes__c> elProblemCodes;
        try {   
            system.debug(logginglevel.info,'<b>EPC SOQL=</b>'+soqlSub); 
            elProblemCodes = Database.query (soqlSub);
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
        }       
            
        return elProblemCodes;
    }
    */
    /*--- @TODO For Future Use... (Als backend VF page admin stuff)
    public static List<Problem_Code_Heirarchy__c> retrieveAllProblemCodeHeirarchys() {
        al.NestableCondition whereCsubAnd = new al.AndCondition();
        whereCsubAnd.add(new al.FieldCondition('grandparent_name__c').notequals(null));     
        
        String soqlSub = '';
        try {
            soqlSub = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Problem_Code_Heirarchy__c',false)) 
                .fromx('Problem_Code_Heirarchy__c')     
                .wherex(whereCsubAnd)
                .toSoql();
        } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
        }
        List<Problem_Code_Heirarchy__c> ePcs;
        try {   
            system.debug(logginglevel.info,'<b>EPC SOQL=</b>'+soqlSub); 
            ePcs = Database.query (soqlSub);
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
        }       
            
        return ePcs;
    }   
    */
    /**
     * Takes a set of ProblemCodeWrappers and the lookup field name on Eligible_Problem_Codes 
     *  ie ['account__c' or ddp__c'] and queries the Eligible Problem codes object.
     *
     *  @param      pcWrap              -   A list of ProblemCodeWrappers.
     *  @param      sLookupFieldName    -   The id field to return from Eligible_Problem_Code.
     *
     *  @returns    A List of Id fields
     *  @TODO Unit test code.
     */ 
    public static List<Eligible_Problem_Codes__c> retrieveEligibleProblemCodes(Id sObjectId, String sLookupFieldName) {
        List<Id> epcIds = new List<Id>();

        if(sLookupFieldName == null || sLookupFieldName.length() == 0) {
            System.debug(logginglevel.info, '------> retrieveEligibleProblemCodes().. sLookupFieldName may not be null or empty... HARD exit.');                
            return null;
        }       

        al.NestableCondition whereC = new al.AndCondition();
        al.NestableCondition whereCor = new al.OrCondition();
        
        whereCor.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').equals(null));  
        whereCor.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').lessThanOrEqualTo(date.today()));       
        //whereC.add(new al.FieldCondition(sLookupFieldName,al.Operator.EQUALS,sObjectId));
        whereC.add(new al.FieldCondition(sLookupFieldname).equals(sObjectId));  
        whereC.add(whereCor);
        String soqlSub = '';
        try {
            soqlSub = new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Eligible_Problem_Codes__c',false)) 
                .fromx('Eligible_Problem_Codes__c')
                .wherex(whereC)             
                .toSoql();
        } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
        }
        List<Eligible_Problem_Codes__c> elProblemCodes;
        try {   
            system.debug(logginglevel.info,'<b>EPC SOQL=</b>'+soqlSub); 
            elProblemCodes = Database.query (soqlSub);
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
        }   
        /*
        if(elProblemCodes != null && elProblemCodes.size() > 0 ) {
            for(Eligible_Problem_Codes__c epc : elProblemCodes) {
                epcIds.add((Id)epc.get(sLookupFieldName));  
            }
        }               
        return epcIds;
        */
        return elProblemCodes;
    }
    
    /**
     * Takes a set of ProblemCodeWrappers and the lookup field name on Eligible_Problem_Codes 
     *  ie ['account__c' or ddp__c'] and queries the Eligible Problem codes object.
     *
     *  @param      pcWrap              -   A list of ProblemCodeWrappers.
     *  @param      sLookupFieldName    -   The id field to return from Eligible_Problem_Code.
     *
     *  @returns    A List of Id fields
     *  @TODO Unit test code.
     */ 
    public static List<Id> retrieveEligibleProblemCodes(List<ProblemCodeWrapper> pcWraps, String sLookupFieldName) {
        List<Id> epcIds = new List<Id>();
        
        if(pcWraps == null) {
            System.debug(logginglevel.info, '------> retrieveEligibleProblemCodes().. list of pcWraps may not be null... HARD exit.');              
            return null;
        }
        if(sLookupFieldName == null || sLookupFieldName.length() == 0) {
            System.debug(logginglevel.info, '------> retrieveEligibleProblemCodes().. sLookupFieldName may not be null or empty... HARD exit.');                
            return null;
        }       
        List<String> lPracticeAreas             =   new List<String>();
        List<String> lProblemCategories         =   new List<String>();
        List<String> lProblemCodes              =   new List<String>();
        //List<String> lJurisdictions           =   new List<String>();
        
        Integer numProcessed = 0;
        for(ProblemCodeWrapper pcwrap : pcWraps) {
            if(pcWrap != null) {
                lPracticeAreas.add(pcWrap.practiceArea);
                lProblemCategories.add(pcWrap.problemCategory);
                lProblemCodes.add(pcWrap.problemCode);
                //lJurisdictions.add(pcWrap.jurisdiction);
                numProcessed ++;
            }
        }
        System.debug(logginglevel.info, '------> retrieveEligibleProblemCodes().. processed '+numProcessed + ' ProblemCodeWrapper objects.');
        if(numProcessed == 0) {
            System.debug(logginglevel.info, '------> retrieveEligibleProblemCodes().. no problemcodewrappers that were not null.. HARD exit.');     
        }
        al.NestableCondition whereCsubAnd = new al.AndCondition();
        al.NestableCondition whereCsubOr1 = new al.OrCondition();       
        al.NestableCondition whereCsubAndInner1 = new al.AndCondition();
        
        
        whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').equals(null));  
        whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').lessThanOrEqualTo(date.today()));       

        if(lPracticeAreas != null && !lPracticeAreas.isEmpty() ) {
            whereCsubAndInner1.add(new al.SetCondition('Practice_Area__c',al.Operator.INX,lPracticeAreas));
        }
        if(lProblemCategories != null && !lProblemCategories.isEmpty() ) {
            whereCsubAndInner1.add(new al.SetCondition('Problem_Category__c',al.Operator.INX,lProblemCategories));
        }
        if(lProblemCodes != null && !lProblemCodes.isEmpty() ) {
            al.NestableCondition whereCsubOrInnerPc = new al.OrCondition();     
            whereCsubOrInnerPc.add(new al.SetCondition('Problem_Code__c',al.Operator.INX,lProblemCodes));
            whereCsubOrInnerPc.add(new al.FieldCondition('Problem_Code__c').equals(null));
            whereCsubAndInner1.add(whereCsubOrInnerPc);
        }   
        /*
        if(lJurisdictions != null && !lJurisdictions.isEmpty() ) {
            whereCsubAndInner1.add(new al.SetCondition('Jurisdiction__c',al.Operator.INX,lJurisdictions));
        }
        */
        whereCsubAnd.add(whereCSubOr1);
        whereCsubAnd.add(whereCsubAndInner1);
        whereCSubAnd.add(new al.FieldCondition(sLookupFieldName,al.Operator.NOT_EQUALS,null));
            
        String soqlSub = '';
        try {
            soqlSub = new al.SoqlBuilder()
                .selectx(new Set<String> {sLookupFieldName}) 
                .fromx('Eligible_Problem_Codes__c')
                .wherex(whereCsubAnd)               
                .toSoql();
        } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
        }
        List<Eligible_Problem_Codes__c> elProblemCodes;
        try {   
            system.debug(logginglevel.info,'<b>EPC SOQL=</b>'+soqlSub); 
            elProblemCodes = Database.query (soqlSub);
        } catch (Exception e)  {            
            system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
        }       
        if(elProblemCodes != null && elProblemCodes.size() > 0 ) {
            for(Eligible_Problem_Codes__c epc : elProblemCodes) {
                epcIds.add((Id)epc.get(sLookupFieldName));  
            }
        }               
        return epcIds;
    }
    
    
    /**
     * @TODO Rewire for re-use.
     *
     */
    public static List<Eligible_Problem_Codes__c> retrieveEligibleProblemCodes(Account a, Case cse) {
        List<Eligible_Problem_Codes__c> epcs;
        
        //al.SetCondition whereCIn = new al.SetCondition('id',al.Operator.INX,epcIds);
        al.NestableCondition whereCsubAnd = new al.AndCondition();
        al.NestableCondition whereCsubOr1 = new al.OrCondition();
        al.NestableCondition whereCsubJuris = new al.OrCondition(); 
        al.NestableCondition whereCsubAndInner1 = new al.AndCondition();                
        
        whereCsubAnd.add(new al.FieldCondition('account__c').equals(a.id));
        whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').equals(null));  
        whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').lessThanOrEqualTo(date.today()));

        
        ProblemCodeWrapper pcWrap = new ProblemCodeWrapper(cse);
        if(pcWrap.practiceArea != null && pcWrap.practiceArea != '') {
            whereCsubAndInner1.add(new al.FieldCondition('Practice_Area__c').equals(pcWrap.practiceArea));  
        }
        if(pcWrap.problemCode != null && pcWrap.problemCode != '') {
            al.NestableCondition whereCsubOrInnerPc = new al.OrCondition();     
            whereCsubOrInnerPc.add(new al.FieldCondition('Problem_Code__c').equals(pcWrap.problemCode));
            whereCsubOrInnerPc.add(new al.FieldCondition('Problem_Code__c').equals(null));
            whereCsubAndInner1.add(whereCsubOrInnerPc);
        }
        if(pcWrap.problemCategory != null && pcWrap.problemCategory != '') {
            whereCsubAndInner1.add(new al.FieldCondition('Problem_Category__c').equals(pcWrap.problemCategory)); 
        }
        
        Boolean bUseJurisOrClause = false;

        if(bUseJurisOrClause) {             
            whereCsubAndInner1.add(whereCsubJuris);
        }
        whereCsubAnd.add(whereCSubOr1);
        whereCsubAnd.add(whereCsubAndInner1);       
        
        
        String soql = '';
        try {
            soql= new al.SoqlBuilder()
                .selectx(SoqlUtils.getAllFieldsSet('Eligible_Problem_Codes__c',false)) 
                .fromx('Eligible_Problem_Codes__c')
                .wherex(whereCSubAnd)
                .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            return null;
        }       
            try {   
                system.debug(logginglevel.info,'<b>EPC SOQL=</b>'+soql);    
                epcs = Database.query (soql);
            
            } catch (Exception e)  {            
                system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
            }
        if(epcs == null || epcs.isEmpty() ) {
            System.debug('----- DATA ERROR ---> no problem codes matched for Account='+a.Name + ' Case = '+cse.CaseNumber);
            System.debug('----- soql = ' + soql);
        }
        return epcs;
        
    }
    
    
    /**
     *
     *
     */
    public static List<Id> retrieveEligibleProblemCodes(ProblemCodeWrapper pcWrap, String sLookupFieldName) {
            List<Id> epcIds = new List<Id>();

            al.NestableCondition whereCsubAnd = new al.AndCondition();
            al.NestableCondition whereCsubOr1 = new al.OrCondition();   
            al.NestableCondition whereCsubJuris = new al.OrCondition();             
            
            whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').equals(null));  
            whereCsubOr1.add(new al.FieldCondition('Problem_Category_Closed_Until_Date__c').lessThanOrEqualTo(date.today()));

            al.NestableCondition whereCsubAndInner1 = new al.AndCondition();
            if(pcWrap.practiceArea != null && pcWrap.practiceArea != '') {
                whereCsubAndInner1.add(new al.FieldCondition('Practice_Area__c').equals(pcWrap.practiceArea));  
            }
            if(pcWrap.problemCode != null && pcWrap.problemCode != '') {
                al.NestableCondition whereCsubOrInnerPc = new al.OrCondition();     
                whereCsubOrInnerPc.add(new al.FieldCondition('Problem_Code__c').equals(pcWrap.problemCode));
                whereCsubOrInnerPc.add(new al.FieldCondition('Problem_Code__c').equals(null));
                whereCsubAndInner1.add(whereCsubOrInnerPc);
            }
            if(pcWrap.problemCategory != null && pcWrap.problemCategory != '') {
                whereCsubAndInner1.add(new al.FieldCondition('Problem_Category__c').equals(pcWrap.problemCategory)); 
            }
            Boolean bUseJurisOrClause = false;

            if(bUseJurisOrClause) {             
                whereCsubAndInner1.add(whereCsubJuris);
            }
            whereCsubAnd.add(whereCSubOr1);
            whereCsubAnd.add(whereCsubAndInner1);
            //whereCsubAndInner1.add(new al.FieldCondition('Problem_Category__c').equals(pcWrap.problemCategory));
            whereCSubAnd.add(new al.FieldCondition(sLookupFieldName,al.Operator.NOT_EQUALS,null));
            /** ----------------------------------------- **/
        
            /** ---------Run subquery to get list of publication ids ---------- **/
            String soqlSub = '';
            try {
                 soqlSub = new al.SoqlBuilder()
                                .selectx(new Set<String> {sLookupFieldName}) 
                                .fromx('Eligible_Problem_Codes__c')
                                .wherex(whereCsubAnd)
                                .toSoql();
            } catch (Exception e) {
                system.debug(logginglevel.error,e);
                return null;
            }
        
            List<Eligible_Problem_Codes__c> lProblemCodes;
            try {   
                system.debug(logginglevel.info,'<b>EPC SOQL=</b>'+soqlSub); 
                lProblemCodes = Database.query (soqlSub);
            
            } catch (Exception e)  {            
                system.debug(logginglevel.warn,'<b>ERROR IN Soql'+e);
            } 
    
            if(lProblemCodes != null && lProblemCodes.size() > 0 ) {
                for(Eligible_Problem_Codes__c epc : lProblemCodes) {
                    //@TODO Make reference of field name below dynamic!
                    
                    epcIds.add((Id)epc.get(sLookupFieldName));  
                }
            }
            return epcIds;
    }
}