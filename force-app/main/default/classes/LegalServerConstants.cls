/**
 * Provisio Partners
 * @author Stepan Mahdziak <stepan.mahdziak@redtag.pro>
 * @date  2020
 *
 * @description class for including all global variables that are using in the Legal Server integration;
 **/
public with sharing class LegalServerConstants {
    
    //fields which will go to LEGAL SERVER
    public static final String E_TRANSFER_ORGANIZATION = 'eTransferOrganization';
    public static final String PROGRAM = 'program';
    public static final String AFLAN = 'AFLAN';
    public static final String ADDRESS1 = 'address1';
    public static final String CITY = 'city';
    public static final String STATE = 'state';
    public static final String ZIP = 'zip';
    public static final String FIRST_NAME = 'firstName';
    public static final String MIDDLE_NAME = 'middleName';
    public static final String LAST_NAME = 'lastName';
    public static final String DATE_OF_BIRTH = 'dateOfBirth';
    public static final String PHONE_HOME = 'phoneHome';
    public static final String EMAIL = 'email';
    public static final String ADDRESS_HOME = 'addressHome';
    public static final String NUMBER_OF_ADULTS = 'numberOfAdults';
    public static final String NUMBER_OF_CHILDREN = 'numberOfChildren';
    public static final String GENDER = 'gender';
    public static final String ETHNICITY = 'ethnicity';
    public static final String RACE = 'race';
    public static final String LANGUAGE = 'language';
    public static final String MATIRIAL_STATUS = 'maritalStatus';
    public static final String JSON_PAYLOAD = 'jsonPayload';
    public static final String ID = '0000';
    
    //Endpoint and response parameters for LegalServerRestService class
    public static final String URL_SIGN_ENCODER = '%20';
    public static final String LEGAL_SERVER_ENDPOINT = 'callout:Legal_Server/matter/api/online_intake_import/?';
    public static final String LEGAL_SERVER_DEMO_ENDPOINT = 'callout:Legal_Server_Demo/matter/api/online_intake_import/?';
	public static final String RESPONSE_BODY_KEY_RESULTS = 'results';
	public static final String RESPONSE_BODY_KEY_ERROR = 'error';
	public static final String RESPONSE_BODY_KEY_UNIQUE_ID = 'unique_id';
    public static final String CLIENT_ENTRY_DATE = 'Client_Entry_Date__c';
    public static final String CLIENT_EXIT_DATE = 'Client_Exit_Date__c';
    public static final String CLIENT_IL_AFLAN_ID = 'Client_IL_AfLAN_ID__c';





}