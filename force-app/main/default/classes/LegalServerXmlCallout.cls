/**
 * Created by thom on 7/9/18.
 */

public with sharing class LegalServerXmlCallout {

    public class customException extends Exception {
    }

    public Contact contactRecord;
    public Applied_Resource__c appliedResource;
    public List<Income_Detail__c> incomeDetails;
    public String xmlOutput;
    public Integer responseStatusCode;
    public String emailMessage;

    public LegalServerXmlCallout(Contact contactRecord,
            Applied_Resource__c appliedResource,
            List<Income_Detail__c> incomeDetails) {
        this.contactRecord = contactRecord;
        this.appliedResource = appliedResource;
        this.incomeDetails = incomeDetails;
    }

    public void packageXml() {
        try {

            // check required values; if any missing, continue
            String eTransferOrganization
                    = LegalServerXmlCalloutCodeTransforms.setETransferOrganization(appliedResource.Account__r.Name);
            if (contactRecord.FirstName == null ||
                    contactRecord.LastName == null ||
                    eTransferOrganization == null) {
                throw new customException('First Name and Last Name are required');
            }

            XmlStreamWriter xml = new XmlStreamWriter();
            xml.writeStartDocument(null, '1.0');
            xml.writeStartElement(null, 'matter', null);

            xml.writeStartElement(null, 'firstName', null);
            xml.writeCharacters(contactRecord.FirstName);
            xml.writeEndElement();

            xml.writeStartElement(null, 'lastName', null);
            xml.writeCharacters(contactRecord.LastName);
            xml.writeEndElement();

            // start address
            if (contactRecord.MailingCity != null
                    && contactRecord.MailingState != null) {

                xml.writeStartElement(null, 'addressHome', null);

                if (contactRecord.MailingStreet != null) {
                    xml.writeStartElement(null, 'address1', null);
                    xml.writeCharacters(contactRecord.MailingStreet);
                    xml.writeEndElement();
                }

                if (contactRecord.MailingCity != null) {
                    xml.writeStartElement(null, 'city', null);
                    xml.writeCharacters(contactRecord.MailingCity);
                    xml.writeEndElement();
                }

                String stateCode = LegalServerXmlCalloutCodeTransforms.setStateCode(contactRecord.MailingState);
                if (stateCode != null) {
                    xml.writeStartElement(null, 'state', null);
                    xml.writeCharacters(stateCode);
                    xml.writeEndElement();
                }

                if (contactRecord.MailingPostalCode != null) {
                    xml.writeStartElement(null, 'zip', null);
                    xml.writeCharacters(contactRecord.MailingPostalCode);
                    xml.writeEndElement();
                }

                String countyCode = LegalServerXmlCalloutCodeTransforms.setCountyCode(contactRecord.County__c);
                if (countyCode != null) {
                    xml.writeStartElement(null, 'county', null);
                    xml.writeCharacters(countyCode);
                    xml.writeEndElement();
                }
                xml.writeEndElement(); // end address
            }

            if (contactRecord.Phone != null) {
                xml.writeStartElement(null, 'phoneHome', null);
                xml.writeCharacters(contactRecord.Phone);
                xml.writeEndElement(); // end phoneHome
            }

            String birthdate = LegalServerXmlCalloutCodeTransforms.setBirthdate(contactRecord.Birthdate);
            if (birthdate != null) {
                xml.writeStartElement(null, 'dateOfBirth', null);
                xml.writeCharacters(birthdate);
                xml.writeEndElement(); // end dateOfBirth
            }

            if (contactRecord.Email != null) {
                xml.writeStartElement(null, 'email', null);
                xml.writeCharacters(contactRecord.Email);
                xml.writeEndElement(); // end email
            }

            String maritalStatus = LegalServerXmlCalloutCodeTransforms.setMaritalStatus(contactRecord.Marital__c);
            if (maritalStatus != null) {
                xml.writeStartElement(null, 'maritalStatus', null);
                xml.writeCharacters(maritalStatus);
                xml.writeEndElement(); // end maritalStatus
            }

            String race = LegalServerXmlCalloutCodeTransforms.setRace(contactRecord.Ethnicity__c);
            if (race != null) {
                xml.writeStartElement(null, 'race', null);
                xml.writeCharacters(race);
                xml.writeEndElement(); // end race
            }

            String gender = LegalServerXmlCalloutCodeTransforms.setGender(contactRecord.Gender__c);
            if (gender != null) {
                xml.writeStartElement(null, 'gender', null);
                xml.writeCharacters(gender);
                xml.writeEndElement(); // end gender
            }

            String language = LegalServerXmlCalloutCodeTransforms.setLanguage(contactRecord.Language__c);
            if (language != null) {
                xml.writeStartElement(null, 'language', null);
                xml.writeCharacters(language);
                xml.writeEndElement(); // end language
            }

            String isVeteran =
                    LegalServerXmlCalloutCodeTransforms.setVeteranStatus(contactRecord.Veteran_Status__c);
            if (isVeteran != null) {
                xml.writeStartElement(null, 'veteran', null);
                xml.writeCharacters(isVeteran);
                xml.writeEndElement(); // end veteran
            }

            String isDisabled = LegalServerXmlCalloutCodeTransforms.setDisabled(contactRecord.Disability__c);
            if (isDisabled != null) {
                xml.writeStartElement(null, 'disabled', null);
                xml.writeCharacters(isDisabled);
                xml.writeEndElement(); // end disabled
            }

            xml.writeStartElement(null, 'eTransferOrganization', null);
            xml.writeCharacters(eTransferOrganization);
            xml.writeEndElement();

            String legalProblemCode =
                    LegalServerXmlCalloutCodeTransforms.setLegalProblemCode(appliedResource.Case_Problem_Category__c);
            if (legalProblemCode != null) {
                xml.writeStartElement(null, 'legalProblemCode', null);
                xml.writeCharacters(legalProblemCode);
                xml.writeEndElement();
            }

            if (appliedResource.IL_AFLAN_Referral_Note__c != null) {
                xml.writeStartElement(null, 'note', null);
                xml.writeCharacters(appliedResource.IL_AFLAN_Referral_Note__c);
                xml.writeEndElement(); // end note
            }

            xml.writeStartElement(null, 'matter_xml_version', null);
            xml.writeCharacters('1');
            xml.writeEndElement();

            if (contactRecord.Nbr_of_Adults__c != null) {
                xml.writeStartElement(null, 'numberOfAdults', null);
                xml.writeCharacters(String.valueOf(contactRecord.Nbr_of_Adults__c.intValue()));
                xml.writeEndElement(); // end numberOfAdults
            }

            if (contactRecord.Nbr_of_Minors__c != null) {
                xml.writeStartElement(null, 'numberOfChildren', null);
                xml.writeCharacters(String.valueOf(contactRecord.Nbr_of_Minors__c.intValue()));
                xml.writeEndElement(); // end numberOfChildren
            }

            String isHomeless = LegalServerXmlCalloutCodeTransforms.setHomeless(contactRecord.Housing__c);
            if (isHomeless != null) {
                xml.writeStartElement(null, 'homeless', null);
                xml.writeCharacters(isHomeless);
                xml.writeEndElement(); // end homeless
            }

            String citizenshipStatus =
                    LegalServerXmlCalloutCodeTransforms.setCitizenshipStatus(contactRecord.Citizenship__c);
            if (citizenshipStatus != null) {
                xml.writeStartElement(null, 'citizenshipStatus', null);
                xml.writeCharacters(citizenshipStatus);
                xml.writeEndElement(); // end citizenshipStatus
            }

            xml.writeStartElement(null, 'externalId', null);
            xml.writeCharacters('AFLAN-' + appliedResource.Id);
            xml.writeEndElement();

            List<Income_Detail__c> incomeDetails = incomeDetails;
            if (incomeDetails != null) {
                if (incomeDetails != null && !incomeDetails.isEmpty()) {
                    for (Income_Detail__c incomeDetail : incomeDetails) {

                        String incomeType =
                                LegalServerXmlCalloutCodeTransforms.setIncomeType(incomeDetail.Income_Type__c);
                        String incomeFrequency =
                                LegalServerXmlCalloutCodeTransforms.setIncomeFrequency(incomeDetail.Frequency__c);
                        String incomeAmount =
                                LegalServerXmlCalloutCodeTransforms.setIncomeAmount(incomeDetail.Amount__c);

                        if (incomeType != null
                                && incomeFrequency != null
                                && incomeAmount != null) {

                            xml.writeStartElement(null, 'incomeType', null);
                            xml.writeCharacters(incomeType);
                            xml.writeEndElement();

                            xml.writeStartElement(null, 'incomeFrequency', null);
                            xml.writeCharacters(incomeFrequency);
                            xml.writeEndElement();

                            xml.writeStartElement(null, 'incomeAmount', null);
                            xml.writeCharacters(incomeAmount);
                            xml.writeEndElement();
                        }
                    }
                }
            } else {
                xml.writeStartElement(null, 'incomeNotProvided', null);
                xml.writeCharacters('true');
                xml.writeEndElement();
            }

            xml.writeEndElement(); //end matter
            xml.writeEndDocument();
            xmlOutput = xml.getXmlString();
            xml.close();
        } catch (Exception e) {
            System.debug('Error at ' + e.getLineNumber() + ':' + e.getMessage());
        }
    }

    public void send() {
        String endpoint = 'https://iloi.legalserver.org/modules/matter/intake_xml.php';
        try {
            System.HttpRequest request = new System.HttpRequest();

            request.setMethod('PUT');
            request.setEndpoint(endpoint);
            request.setHeader('Content-Type', 'application/xml');
            request.setHeader('Content-Length', String.valueOf(xmlOutput.length()));
            request.setBody(xmlOutput);

            System.HttpResponse response = new System.Http().send(request);


            responseStatusCode = response.getStatusCode();

            if (responseStatusCode != 200) {
                emailMessage = 'Xml packet unsuccessfully posted for ' +
                        contactRecord.FirstName + ' ' + contactRecord.LastName;
                emailMessage += 'Referral: ' + appliedResource.Name;
                emailMessage += '\n\n Status Code: ' + responseStatusCode;
                emailMessage += '\n\n XML Posted:\n\n';
                emailMessage += xmlOutput;
            }

        } catch (Exception e) {
            System.debug('Error at ' + e.getLineNumber() + ':' + e.getMessage());
        }

    }

    public void sendEmailNotification() {

        try {
            if(responseStatusCode == 200) return;

            List<String> addresses = new List<String>{
                    'kchroback@carpls.org'
            };

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(addresses);
            mail.setSenderDisplayName('Provisio Partners');

            System.debug('@@@@@emailMessage: ' + emailMessage);
            mail.setSubject('LegalServerXmlCalloutFactory: ' + responseStatusCode);

            mail.setPlainTextBody(emailMessage);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                    mail
            });
        } catch (Exception e) {
            System.debug('Error at ' + e.getLineNumber() + ':' + e.getMessage());
        }
    }
}