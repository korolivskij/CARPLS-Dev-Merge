/**
 * Created by thom on 6/28/18.
 */

public with sharing class LegalServerXmlCalloutFactory {


    public List<String> xmlOutput;
    public List<String> responseStatuses;
    public List<LegalServerXmlCallout> legalServerXmlCallouts;

    public LegalServerXmlCalloutFactory() {
        this.xmlOutput = new List<String>();
        this.responseStatuses = new List<String>();
        this.legalServerXmlCallouts = new List<LegalServerXmlCallout>();
    }

    public void collectObjects(List<Referral_Party__c> referralParties) {

        try {

            Map<Id, Id> contactIdsByAppliedResourceIds = new Map<Id, Id>();
            for (Referral_Party__c referralParty : referralParties) {
                contactIdsByAppliedResourceIds.put(
                        referralParty.Referral__c,
                        referralParty.Party__c
                );
            }

            Map<Id, Applied_Resource__c> appliedResourcesByIds
                    = new Map<Id, Applied_Resource__c>([
                            SELECT Id, Client_Name__c,
                                    Case_Problem_Category__c,
                                    IL_AFLAN_Referral_Note__c,
                                    Account__r.Name
                            FROM Applied_Resource__c
                            WHERE Id IN :contactIdsByAppliedResourceIds.keySet()
                    ]);

            Map<Id, Contact> contactsByIds
                    = new Map<Id, Contact>([
                            SELECT Id, Name, FirstName, LastName, MailingStreet, MailingCity, MailingState,
                                    MailingPostalCode, County__c, Phone, Birthdate, Email, Marital__c, Ethnicity__c,
                                    Gender__c, Language__c, Veteran_Status__c, Disability__c, Nbr_of_Adults__c,
                                    Nbr_of_Minors__c, Citizenship__c, Note__c, Housing__c
                            FROM Contact
                            WHERE Id IN :contactIdsByAppliedResourceIds.values()
                    ]);

            List<Income_Detail__c> incomeDetails
                    = [
                    SELECT Id, Contact__c, Income_Type__c, Frequency__c, Amount__c, Active__c
                    FROM Income_Detail__c
                    WHERE Contact__c IN :contactsByIds.keySet()
            ];

            Map<Id, List<Income_Detail__c>> incomeDetailListsByContactIds = new Map<Id, List<Income_Detail__c>>();
            for (Income_Detail__c incomeDetail : incomeDetails) {

                if (incomeDetail.Active__c == false) continue;
                if (incomeDetailListsByContactIds.containsKey(incomeDetail.Contact__c)) {
                    List<Income_Detail__c> eachIncomeDetailsList =
                            incomeDetailListsByContactIds.get(incomeDetail.Contact__c);
                    eachIncomeDetailsList.add(incomeDetail);
                } else {
                    List<Income_Detail__c> eachIncomeDetailsList = new List<Income_Detail__c>();
                    eachIncomeDetailsList.add(incomeDetail);
                    incomeDetailListsByContactIds.put(incomeDetail.Contact__c, eachIncomeDetailsList);
                }
            }

            // iterate by contact, as Referral_Party__c.Party__c is lookup, not Master/Detail
            for (Id appliedResourceId : appliedResourcesByIds.keySet()) {
                Applied_Resource__c eachAppliedResource = appliedResourcesByIds.get(appliedResourceId);

                Id contactId = contactIdsByAppliedResourceIds.get(appliedResourceId);
                Contact eachContact = contactsByIds.get(contactId);

                if(eachContact == null) continue;

                List<Income_Detail__c> incomeDetails2 = incomeDetailListsByContactIds.get(eachContact.Id);
                this.legalServerXmlCallouts.add(new LegalServerXmlCallout(
                        eachContact,
                        eachAppliedResource,
                        incomeDetails2
                ));
            }

        } catch (Exception e) {
            System.debug('Error at ' + e.getLineNumber() + ':' + e.getMessage());
        }
    }

    public void packageXml() {
        for (LegalServerXmlCallout legalServerXmlCallout : legalServerXmlCallouts) {
            legalServerXmlCallout.packageXml();
        }
    }

    public void send() {
        for (LegalServerXmlCallout legalServerXmlCallout : legalServerXmlCallouts) {
            legalServerXmlCallout.send();
        }
    }

    public void sendEmailNotification() {
        for (LegalServerXmlCallout legalServerXmlCallout : legalServerXmlCallouts) {

            legalServerXmlCallout.sendEmailNotification();
        }
    }
}