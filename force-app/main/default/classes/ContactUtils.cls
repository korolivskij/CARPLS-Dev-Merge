public with sharing class ContactUtils {
    public static List<DebugMessage>   debugMessages       { get; set; }
    static {
        debugMessages = new List<DebugMessage>();
    }


    public static List<Name_Equivalents__c> retrieveNameEquivs ( String sWhereVal ) {

        List<Name_Equivalents__c> nes;

        if( sWhereVal== null || sWhereVal == null) {
            System.debug(logginglevel.warn, 'Invalid where value passed='+sWhereVal);
            return null;
        }
        sWhereVal = sWhereVal.trim();

        al.NestableCondition whereC = new al.OrCondition();
        whereC.add(new al.FieldCondition('root__c').equals(sWhereVal));
        whereC.add(new al.FieldCondition('match__c').equals(sWhereVal));

        String soql = new al.SoqlBuilder()
                    .selectx(new Set<String> {'root__c','match__c'})
                    .fromx  ('Name_Equivalents__c')
                    .wherex ( whereC )
                    .toSoql();

        nes = Database.query(soql);
        return nes;

    }
    /**
     *
     *
     */
    public static Contact retrieveAllUserContactInfo(Id uId) {
        Contact c;
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('Related_User__c').equals( uId ));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false ))
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .toSoql();
        try {
            c = Database.query(soql);
        } catch (Dmlexception dEx) {
            System.debug(logginglevel.error, dEx);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        return c;
    }
    public static Contact retrieveAllContactInfo(Id contactId) {
        Contact c;
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('id').equals( contactId ));
        
        // This field was not being included no matter what I did. Added it manually but am excluding here to 
        // prevent another error in the future. ELC IF-LAN changes
        //-- rjn this might be from api versioning issues? was giving me the otheraddress mailingaddress bs in dev.
        //--copied this method back to ctrlResources as this was blowing up when called from there so just to be sure not to effect
        //--anything else. that was the least painful.
        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Is_Military__c');
        
        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false , excludeFields))
                  	.selectx(new Set<String> {'Is_Military__c'})                    
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .toSoql(); 
        try {

            c = Database.query(soql);
        } catch (Dmlexception dEx) {
            System.debug(logginglevel.error, dEx);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        return c;
    }

    public static List<Contact> retrieveAllContactInfo(List<Id> lContactIds) {
        List<Contact> cs;
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.SetCondition('id',al.Operator.INX, (lContactIds )));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false ))
                //  .selectx(new Set<String> {'RecordType.name'})
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .toSoql();
        try {
            cs = Database.query(soql);
        } catch (Dmlexception dEx) {
            System.debug(logginglevel.error, dEx);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        return cs;
    }

    public static List<Contact> retrieveContactInfoByName(String pName) {
        List<Contact> cs;
        system.debug('In retrieveContactInfoByName, name = '+pName);
        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('name').equals(pName ));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false ))
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .toSoql();
        try {
            cs = Database.query(soql);
        } catch (Dmlexception dEx) {
            System.debug(logginglevel.error, dEx);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        System.debug('returning cs = '+cs);
        return cs;
    }
    public static List<Income_Detail__c> retrieveContactIncomeDetails(Id contactId) {
        List<Income_Detail__c> ids;

        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('contact__c').equals( contactId ));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Income_Detail__c', false ))
                    .fromx  ('Income_Detail__c')
                    .wherex( whereC )
                    .toSoql();
        try {
            ids = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return ids;
    }
    /**
     * @TODO Make more generic! (pass in dynamic where criteria.)
     *
     */
    public static List<Contact> retrieveResourceContacts(Id acctId) {
        List<Contact> contacts;

        al.NestableCondition whereC = new al.AndCondition();
        whereC.add(new al.FieldCondition('accountId').equals( acctId ));

        String soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false ))
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .orderbyx(new al.OrderBy('last_applied_date__c').ascending())
                    .limitx(3)
                    .toSoql();
        try {
            contacts = Database.query(soql);
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        }
        return contacts;

    }
    public static List<Contact> retrieveAllContactInfo(al.NestableCondition whereC) {
        List<Contact> contacts;
        String soql = '';
        try {
            soql = new al.SoqlBuilder()
                    .selectx(SoqlUtils.getAllFieldsSet('Contact', false ))
                    .fromx  ('Contact')
                    .wherex( whereC )
                    .toSoql();

        } catch (Exception e) {
            System.debug('-- Error creating soql='+soql+'...exception='+e);
            return null;
        }
        try {
            contacts = Database.query(soql);
        } catch (Exception e) {
            System.debug(logginglevel.error, e);
        }
        return contacts;
    }
    /**
     * User OwnerID because it is a standard index as we have to try to make this query faster! removed 6/5.
     * Instead limit pending clients to those created the last 30 days (or whatever incoming parm value is)
     */
    public static List<Contact> retrieveAllContactsByStatusAndProject(Integer iNumDaysPendingClients, String parmStatus, String parmProject, Integer limitRows, Boolean bShowTempContacts) {
        List<Contact> cs;

        al.NestableCondition whereC = new al.AndCondition();
        String status = 'Pending';
        if(parmStatus != null && parmStatus != '') {
            status = parmStatus;
        }
        if(iNumDaysPendingClients == null) {
            iNumDaysPendingClients = 30;
        }

        whereC.add(new al.FieldCondition('CreatedDate',new al.DateFormula().last(iNumDaysPendingClients,al.UnitOfTime.Day)));

        whereC.add(new al.FieldCondition('status__c').equals( status ));

        if(parmProject != null && parmProject != '' && parmProject != 'All') {
            whereC.add(new al.FieldCondition('project__c').equals( parmProject));
        }
        if(bShowTempContacts) {
            whereC.add(new al.FieldCondition('temp_record__c').equals( true ));
        } else {
            whereC.add(new al.FieldCondition('temp_record__c').equals( false ));
        }
        /* limit seems to be slowing shit down!
        if(limitRows == null || limitRows == 0) {
            limitRows = 9999;
        }
        */

        //whereC.add(new al.FieldCondition('category__c').notequals('Party'));

        Set<String> sFields = new Set<String>();
        sFields.add('id');
        sFields.add('name');
        sFields.add('lastname');
        sFields.add('firstname');
        sFields.add('project__c');
        sFields.add('phone');
        sFields.add('createdDate');
        sFields.add('Creation_Age_In_Hours__c');
        sFields.add('Creation_Age_In_Minutes__c');
        sFields.add('Last_Four_SSN__c');
        sFields.add('Last_Service_Date__c');
        sFields.add('Last_Service_By__c');
        sFields.add('createdBy.name');
        sFields.add('createdBy.alias');
//      sFields.add('Created_Date_for_CST_and_CDT__c');


        String soql = new al.SoqlBuilder()
                    .selectx(sFields )
                    .fromx  ('Contact')
                    .wherex( whereC )
                    //.limitx(limitRows)
                    .orderByx(new al.OrderBy('createdDate').descending())
                    .toSoql();
        try {
            debugMessages.add(new DebugMessage('<font color=red>'+DateTime.now()+'</font><b>Contact Utils: retrieveAllContactsByStatus Before Executed.. soql=</b>'+soql));
            cs = Database.query(soql);
            debugMessages.add(new DebugMessage('<font color=red>'+DateTime.now()+'</font><b>Contact Utils: retrieveAllContactsByStatus AFTER Execute=</b>'));
        } Catch (Dmlexception e) {
            System.debug(logginglevel.error, e);
        } Catch (Exception e) {
            debugMessages.add(new DebugMessage('Exception in soql:',e.getStackTraceString()));
            System.debug(logginglevel.error, e);
        }
        return cs;
    }
    public static String stripPhone(String phone) {
        if(phone == null) {
            return null;
        }
        phone = phone.replace('(','');
        phone = phone.replace(')','');
        phone = phone.replace('-','');
        return phone;
    }
    public static al.NestableCondition processAliases(Contact c) {
        List<string> aliases;
        al.nestableCondition whereC;
        if (c.Aliases__c != null && c.Aliases__c.trim() != '') {
            aliases = c.Aliases__c.replace('  ',' ').split(' ');
        } else {
            aliases = new list<string>();
        }
        if(!aliases.isEmpty()) {
            whereC =  new al.OrCondition();
             for (string s : aliases) {
                if(s!=null && s.length() > 0){
                    // changed these from likes to equals
                    whereC.add(new al.FieldCondition('Aliases__c').equals(s));
                    //RJN new bugfix add
                    whereC.add(new al.FieldCondition('lastname').equals(s));
                // removed this to limit results TODO - ELC Check on this
                //  whereC.add(new al.FieldCondition('firstname').likeX(s));
                }
             }
        }
        return whereC;
    }

    public static al.NestableCondition processNameEquivs(Contact c) {

        List<Name_Equivalents__c> nes = ContactUtils.retrieveNameEquivs(c.lastname);
        al.NestableCondition whereC;

        if(nes!=null && nes.size() > 0) {
            whereC = new al.OrCondition();

            for (Name_Equivalents__c ne : nes) {
                if(ne.Root__c!=null) {
                    whereC.add(new al.FieldCondition('c.lastname').likex(ne.Root__c));
                }
                if(ne.match__c!=null) {
                    whereC.add(new al.FieldCondition('c.lastname').likex(ne.match__c));
                }
            }
        }

        nes = null;
        nes = ContactUtils.retrieveNameEquivs(c.firstName);
/*  Got rid of this to limit # of rows returned TODO - ELC
        if(nes!=null && nes.size() > 0) {
            if(whereC == null) {
                whereC = new al.OrCondition();
            }

            for (Name_Equivalents__c ne : nes) {
                if(ne.Root__c!=null) {
                    whereC.add(new al.FieldCondition('c.firstname').likex(ne.Root__c));
                }
                if(ne.match__c!=null) {
                    whereC.add(new al.FieldCondition('c.firstname').likex(ne.match__c));
                }
            }
        }
        */
        return whereC;
    }
    public PovertyBean retrievePoverty(Contact c){
        /*
        String intakeType = '';

        User u = [select id, intake_type__c from user where id = :UserInfo.getUserId()];
        if(u.intake_type__c != null) {
            intakeType =u.intake_type__c;            if(c.Is_Military__c ) {
                return retrieveAMIPoverty(c);
            }
        }
        */

        PovertyBean pb = new PovertyBean();

        try{
        List<poverty_levels__c> pls = [SELECT Id, Base_Income__c, Increment__c FROM Poverty_Levels__c WHERE year__c = :string.valueOf(date.today().Year()) ORDER BY CreatedDate desc];
        if(pls.size() > 0){
            pb.povertyLevel = pls[0];
            integer perIncome = 0;
            decimal adjAmount = pb.povertyLevel.base_income__c;

            if (c.Total_Residents_in_Household__c >= 1) {
                if(c.Annual_Income_realtime__c == null || c.Annual_Income_realtime__c < 0) {
                    perIncome = -2;
                } else {
                    if(c.total_residents_in_household__c > 1) {
                        adjAmount = adjAmount  + ((c.Total_Residents_in_Household__c-1) * pb.povertyLevel.increment__c);
                    }
                    //adjAmount = adjAmount  + ((c.Total_Residents_in_Household__c-1) * pb.povertyLevel.increment__c);
                    perIncome = ((c.annual_income_realtime__c * 100) /adjAmount ).intValue();
                    Decimal tempPovertyPercent = 0.00;
                    tempPovertyPercent = perIncome;
                    tempPovertyPercent = tempPovertyPercent.divide(100,2);
                    pb.povertyPct = tempPovertyPercent * 100;
                    //pb.povertyPct = tempPovertyPercent;
                    //pb.PovertyPct = perIncome / 100;
                    if(pb.povertyPct > 0) {
                        pb.povertyPct = pb.povertyPct.intValue();
                    }

                }
            } else {
                perIncome = -1;
            }


            //pb.povertyleveldesc = '<b>' ;
            // changed these levels on 9/23/14 to get ready for the OnDemand appointment service
            if(perIncome >= 0 && perIncome <= 350){
                pb.povertyLevelDesc += 'Eligible for free legal services';
                pb.containerStyleClass = 'povertyEligibleFreeLegal';
                pb.povertyResult = PovertyBean.ELIGIBLE;
  //          } else if(perIncome > 200 && perIncome <= 350) {
  //              pb.povertyLevelDesc += 'Eligible for fee services';
  //              pb.containerStyleClass = 'povertyEligibleFee';
            } else if(perIncome > 350) {
                pb.povertyLevelDesc += 'Not eligible for services';
                pb.containerStyleClass = 'povertyNotEligible';
                pb.povertyResult = PovertyBean.NOT_ELIGIBLE;
            } else if(perIncome == -1) {
                pb.povertyLevelDesc += 'Not Calculated.  No Residents in Household Entered.';
                pb.containerStyleClass = 'povertyNotCalculated';
            } else if(perIncome == -2) {
                pb.povertyLevelDesc += 'Not Calculated.  No annualized income exists.';
                pb.containerStyleClass = 'povertyNotCalculated';
            } else {
                pb.povertyLevelDesc = ' fell through conditionals ';
                pb.povertyResult = PovertyBean.NOT_PROCESSED;
            }
           // pb.povertyLevelDesc += '</b>';
        } else {
            pb.povertyLevelDesc = ' no poverty level record found';
            pb.povertyResult = PovertyBean.NOT_PROCESSED;
        }
        }catch (exception e){
            pb.povertyLevelDesc = 'Error.';
            System.debug(e);
        }
        return pb;
    }

    /**
     * Go after Poverty_Level_AMI__c as opposed to poverty_level__c. Perhaps merge this with Federal one day
     * but I don't want to risk it now.
     */
    public PovertyBean retrieveAMIPoverty(Contact c){
        PovertyBean pb = new PovertyBean();
        pb.povertyFormulaType = 'AMI';
        String sNumInHouseHold = '0';
        try {
            sNumInHouseHold = String.valueof(c.Total_Residents_in_Household__c.intValue());
        } catch (exception e) {
            system.debug(e);
            return pb;
        }
        integer perIncome = 0;

        //---- Need 100 to use as base.. and 80 to compare against. (as opposed to adjusted values and stuff)
        Set<String> pctToFind = new Set<String>();
        pctToFind.add('80');
        pctToFind.add('100');
        try{
            system.debug('------- looking for year of ' + date.today().Year());
            List<AMI_Poverty_Level__c> povLevels =
            [   select  id, House_Hold_Size__c, percent__c,Amount__c
                from    ami_poverty_level__c
                where   year__c = :date.today().year()
                and     percent__c in :pctToFind
                and     House_Hold_Size__c = :sNumInHouseHold
            ];
            if(!povLevels.isEmpty()) {
                system.debug('--- ami poverty level found.. Saving both values on povertyBean. --');
                for (AMI_Poverty_Level__c povLevel : povLevels) {
                    if (STring.valueOf(Integer.valueOf(povLevel.House_Hold_Size__c)) == sNumInHousehold) {
                        system.debug('--- ami poverty level num of households=' + sNumInHouseHold + ' match found. --');
                        if (povLevel.percent__c == '80') {
                            pb.amiPovertyLevel80 = povLevel;
                            system.debug('--- ami poverty level80 set');
                        } else if (povLevel.percent__c == '100') {
                            pb.amiPovertyLevel100 = povLevel;
                            system.debug('--- ami poverty level100 set');
                        }
                    }
                }
                if (c.Total_Residents_in_Household__c < 1) {
                    perIncome = Integer.valueof(PovertyBean.NO_HOUSEHOLD_NBR);
                    system.debug('could not find total household residents on the contact!');
                } else if ( pb.isBothAmiPovertyLevelsExist() ) {
                    if (c.Annual_Income_realtime__c == null || c.Annual_Income_realtime__c < 0) {
                        perIncome = Integer.valueOf(PovertyBean.NO_ANNUALIZED_INCOME);
                    } else {
                        decimal adjAmount = pb.amiPovertyLevel100.amount__c - pb.amiPovertyLevel80.amount__c;
                        perIncome = ((c.annual_income_realtime__c * 100) / adjAmount) .intValue();
                        Decimal tempPovertyPercent = 0.00;
                        tempPovertyPercent = perIncome;
                        tempPovertyPercent = tempPovertyPercent.divide(100, 2);
                        perIncome = perIncome * 100;
                        pb.povertyPct = ((c.annual_income_realtime__c / pb.amiPovertyLevel100.amount__c) * 100);
                        if(pb.povertyPct > 0) {
                            pb.povertyPct = pb.povertyPct.intValue();
                        }
                        if(pb.povertyPct == 0) {
                            pb.povertyPct = 0.00;
                        }
                    }
                } else {
                    perIncome = Integer.valueOf(PovertyBean.NO_AMI_LEVELS_FOUND);
                    pb.povertyLevelDesc += 'Not Calculated.  No AMI Levels Found.';
                    pb.containerStyleClass = 'povertyNotCalculated';
                    pb.povertyResult = PovertyBean.NO_AMI_LEVELS_FOUND;
                }
                pb.perIncome = perIncome;
                if(perIncome == Integer.valueOf(PovertyBean.NO_HOUSEHOLD_NBR)) {
                    pb.povertyLevelDesc += 'Not Calculated.  No Residents in Household Entered.';
                    pb.containerStyleClass = 'povertyNotCalculated';
                    pb.povertyResult = PovertyBean.NO_HOUSEHOLD_NBR;
                } else if(perIncome == Integer.valueof(PovertyBean.NO_AMI_LEVELS_FOUND)) {
                    pb.povertyLevelDesc += 'Not Calculated.  No AMI Levels Found.';
                    pb.containerStyleClass = 'povertyNotCalculated';
                    pb.povertyResult = PovertyBean.NO_AMI_LEVELS_FOUND;
                } else if(perIncome == Integer.valueOf(PovertyBean.NO_ANNUALIZED_INCOME)) {
                    pb.povertyLevelDesc += 'Not Calculated.  No annualized income exists.';
                    pb.containerStyleClass = 'povertyNotCalculated';
                    pb.povertyResult = PovertyBean.NO_ANNUALIZED_INCOME;
               // } else if(perIncome >= 0 && perIncome <= pb.amiPovertyLevel100.amount__c){
                } else if(pb.povertyPct <= 80){
                    pb.povertyLevelDesc += 'Eligible for free legal services';
                    pb.containerStyleClass = 'povertyEligibleFreeLegal';
                    pb.povertyResult = PovertyBean.ELIGIBLE;
                } else {
                    pb.povertyLevelDesc += 'Not eligible for services';
                    pb.containerStyleClass = 'povertyNotEligible';
                    pb.povertyResult = PovertyBean.NOT_ELIGIBLE;
                }
            } else {
                pb.povertyLevelDesc += 'Not Calculated.  No AMI Levels Found.';
                pb.containerStyleClass = 'povertyNotCalculated';
                pb.povertyResult = PovertyBean.NO_AMI_LEVELS_FOUND;
            }
        } catch (exception e) {
            pb.povertyLevelDesc = 'Error.';
            System.debug(e);
        }
        return pb;
    }

    /**
    * Go after Poverty_Level_AMI__c as opposed to poverty_level__c.
    * @rjn do the above in bulk mode for use in trigger inserts / updates.
    */
    public Map<Id,PovertyBean> retrieveAMIPovertyBeans(List<Contact> cs){

        Map<Id,String> m_CId_HouseHoldSize = new Map<Id,String>();
        Map<Id,Contact> m_Cid_Contact = new Map<Id,Contact>();
        Map<Id,PovertyBean> mCId_Pb = new Map<Id,PovertyBean>();

        for(Contact c : cs) {
            String sNumInHouseHold = '0';
            try {
                sNumInHouseHold = String.valueof(c.Total_Residents_in_Household__c.intValue());
                m_CId_HouseHoldSize.put(c.id,sNumInHouseHold);
            } catch (exception e) {
               m_CId_HouseHoldSize.put(c.id,'0');
            }
            m_Cid_Contact.put(c.id,c);
        }
        //---- Need 100 to use as base.. and 80 to compare against. (as opposed to adjusted values and stuff)
        Set<String> pctToFind = new Set<String>();
        //pctToFind.add('80');
        pctToFind.add('100');

         try{
            system.debug('------- looking for year of ' + date.today().Year());
            List<AMI_Poverty_Level__c> povLevels =
            [   select  id, House_Hold_Size__c, percent__c,Amount__c
            from    ami_poverty_level__c
            where   year__c = :date.today().year()
            and     percent__c in :pctToFind
            and     House_Hold_Size__c in :m_CId_HouseHoldSize.values()
            ];



            if(!povLevels.isEmpty()) {
                Map<String, AMI_Poverty_Level__c> mHhSize_PovLevel = new Map<String, AMI_Poverty_Level__c>();
                for (AMI_Poverty_Level__c povLevel : povLevels) {
                    mHhSize_PovLevel.put(povLevel.House_Hold_Size__c, povLevel);
                }
                for (Id cId : m_CId_HouseHoldSize.keySet()) {
                    String hhSize = m_CId_HouseHoldSize.get(cId);

                    AMI_Poverty_Level__c pl = mHhSize_PovLevel.get(hhSize);
                    system.debug('rjn pb - pl='+pl);
                    if (pl != null) {
                        PovertyBean pb = new PovertyBean();
                        pb.povertyFormulaType = 'AMI';
                            pb.amiPovertyLevel100 = pl;
                            system.debug('--- ami poverty level100 set');


                        Contact c = m_Cid_Contact.get(cId);
                        pb.povertyPct = ((c.annual_income_realtime__c / pb.amiPovertyLevel100.amount__c) * 100);
                        if (pb.povertyPct > 0) {
                            pb.povertyPct = pb.povertyPct.intValue();
                        }
                        if (pb.povertyPct == 0) {
                            pb.povertyPct = 0.00;
                        }
                        mCid_Pb.put(cId, pb);
                    } else {
                        PovertyBean pb = new PovertyBean();
                        mCId_Pb.put(cId,pb);
                    }

                }
            }
        } catch (exception e) {
            System.debug(e);
        }
        return mCId_Pb;
    }
    public static Boolean updateContact(SObject sObj) {
        Boolean success = false;
        try {
            success = DmlUtils.DBUpdate(sObj);
        } catch (DmlException dmlEx ) {
            System.debug(logginglevel.error,dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
        }
        return success;
    }
    public static Boolean updateIncome(List<Income_Detail__c> inc_details) {
        Boolean success = false;
        try {
            Set<Id> updatedIds = DmlUtils.DBUpdate(inc_details, true);
            success = (updatedIds!=null && !updatedIds.isEmpty());
        } catch (DmlException dmlEx ) {
            System.debug(logginglevel.error,dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
        }
        return success;
    }
    public static Boolean DeleteIncome(List<Income_Detail__c> inc_details) {
        Boolean success = false;
        try {
            Set<Id> deletedIds = DmlUtils.DBDelete(inc_details, true);
            success = (deletedIds!=null && !deletedIds.isEmpty());
        } catch (DmlException dmlEx ) {
            // swallow the error in case the user clicked delete twice in quick succession
            if (dmlEx.getDmlType(0) == StatusCode.ENTITY_IS_DELETED) {
                success = true;
            }
            System.debug(logginglevel.error,dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
        }
        return success;
    }
    public static Boolean DeleteIncome(Income_Detail__c inc_detail) {
        Boolean success = false;
        try {
            List<Income_Detail__c> ids = new List<Income_Detail__c>();
            ids.add(inc_detail);
            success = DeleteIncome(ids);
        } catch (DmlException dmlEx ) {
            System.debug(logginglevel.error,dmlEx);
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
        }
        return success;
    }
    public static Set<Id> deleteContacts(Set<Id> contactIds) {
        Set<Id> contactIdsDel;

        if(contactIds == null || contactIds.isEmpty()) {
            System.debug(logginglevel.info,'no contact Ids to delete');
            return null;
        }
        //-- Seek out Cases associated with contact....
        List<Case> delCases = [select id from case where contactId in :contactIds];
        if(delCases != null) {
            delete delCases;
        }
        //-- Seek out orphaned Cases party junction objects associated with contact....
        List<Case_Party__c> cps = [select id from case_party__c where contact__c in :contactIds];
        if(cps != null) {
            delete cps;
        }
        List<Contact> contactsToDel = [select id from contact where id in :contactIds];
        contactIdsDel = DmlUtils.DBDelete(contactsToDel, true);
        return contactIdsDel;
    }
    // Retrieve the contacts associated with an account
    public static List<Contact> retrieveContactsByAcct(Id pId) {

        List<Contact> cts = new List<Contact>();

        Set<String> excludeFields = new Set<String>();
        excludeFields.add('Description');
        excludeFields.add('Note__c');

        String soqlCs = '';
        try {
            soqlCs =     new al.SoqlBuilder()
                            .selectx(SoqlUtils.getAllFieldsSet('Contact', false, excludeFields ))
                            .fromx('Contact')
                            .wherex(new al.FieldCondition('accountid').equals(pId))
                            .toSoql();
        } catch (Exception e) {
            system.debug(logginglevel.error,e);
            system.debug(logginglevel.error, 'SOQLBase='+soqlCs);
            return null;
        }
        try {
            cts = Database.query (soqlCs);
        } catch (Exception e)  {
            system.debug(logginglevel.warn,'<b>ERROR IN retrieveContactsByAcct soqlC');
        }

        return cts;

    }
    /*
    *  Will be called by the scheduled job ScheduleAgeOutContacts
    *
    *
    */
    public static Boolean ageOutContacts() {

        Datetime myDateTime = Datetime.now();
        Datetime hundredEightyTwoDaysAgo = myDateTime.addDays(-182);
        Boolean success = true;

        List<Contact> agedContacts = [SELECT id, status__c
                                    FROM contact
                                    WHERE status__c = 'Current'
                                    AND last_service_date__c < :hundredEightyTwoDaysAgo];
        for (Contact c: agedContacts) {
            c.status__c = 'Former';
        }
        try {
            update agedContacts;
        } catch (Exception e) {
            System.debug('Exception in ScheduleContactFormer when updating cases '+e);
            success = false;
        }
        return success;
    }

}