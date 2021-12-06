public with sharing class LeadUtils {

	public static RecordType leadIndividualRt;
	
	static {
		leadIndividualRt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Lead', 'Inquiry');		
	}


	public static List<Contact> retrieveContactsForLeadCopy(List<Id> lContactIds) {
		List<Contact> cs;		
		al.NestableCondition whereC = new al.AndCondition();		
		whereC.add(new al.SetCondition('id',al.Operator.INX, (lContactIds )));
		  
		String soql = new al.SoqlBuilder()
                    .selectx(new Set<String> {'id', 'lastname','firstname','Email' })
                    .selectx(new Set<String> {'Birthdate','Middle_Initial_Suffix__c','SSN__c' })
                    .selectx(new Set<String> {'phone', 'last_four_SSN__c','Aliases__c' })
                    .selectx(new Set<String> {'MailingStreet', 'category__c','relationship__c','Type__c' })
					.fromx	('Contact')
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
    
    public static Set<Id> createLeads(List<Contact> contacts) {
        
        Set<Id> sLeadIdsIns = new Set<Id>();
        if(contacts == null || contacts.isEmpty()) {
            System.debug(logginglevel.info,'List of contacts passed is null.. returning null');
            return null;
        }
        List<Lead> leadsToIns = new List<Lead>();
        for(Contact c : contacts) {
            Lead l = copyContactToLead(c);
            if(l!=null){
                leadsToIns.add(l);
            }
        }
        if(leadsToIns != null) {
            sLeadIdsIns = DmlUtils.DBInsert(leadsToIns,true);
        }
        return sLeadIdsIns;     
    }
    
    public static Lead copyContactToLead(Contact c) {
       
        if(c == null) {
            System.debug(logginglevel.info,'contact passed is null.. returning null');
            return null;
        }
        Lead l = new Lead();
        
        
        
        l.recordTypeId = leadIndividualRt.id;
        l.BirthDate__c = c.birthdate;
        l.status = 'Incomplete Intake';
        l.lastname = c.lastname;
        l.firstname = c.firstname;
        l.Last_Four_SSN__c = c.Last_Four_SSN__c;
        l.phone = c.phone;
        l.Middle_Initial_Suffix__c = c.Middle_Initial_Suffix__c;
        l.Email = c.Email;
        l.Street = c.MailingStreet;
        l.company = 'Individual';
        try {
            //@TODO Contact Type Mod
            l.type__C = c.category__c; 
        } catch (Exception e) {
            System.debug(logginglevel.error,e);
        }
        l.relationship__c = c.Relationship__c;
        l.party_type__c = c.Type__c;        
        
        return l;                                   
    }
}