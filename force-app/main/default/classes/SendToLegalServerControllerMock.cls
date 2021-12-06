/**
 * Provisio Partners
 * @author Stepan Mahdziak <stepan.mahdziak@redtag.pro>
 * @date 11 March 2021
 *
 * @description Test Class for SendToLegalServerController class and for LegalServerRestService class ;
 **/
@isTest
global class SendToLegalServerControllerMock implements HttpCalloutMock {
    
    static String expectedEndpoint = 'callout:Legal_Server_Demo/matter/api/online_intake_import/?jsonPayload=%7B%22aflan_referral_source_640%22%3A2%2C%22aflan_employment_641%22%3A3%2C%22aflan_housing_type_647%22%3A3%2C%22aflan_disability_642%22%3A1%2C%22aflan_branch_643%22%3A11%2C%22aflan_rank_653%22%3A1%2C%22aflan_status_646%22%3A6%2C%22aflan_no__of_deployments_648%22%3A2%7D&maritalStatus=&language=&race=&ethnicity=Non-Hispanic&gender=&numberOfChildren=2&numberOfAdults=2&addressHome=%7B%22address1%22%3A%22123%20main%22%2C%22city%22%3A%22Chicago%22%2C%22state%22%3A%22Nevada%22%2C%22zip%22%3A%2260654%22%7D&email=test@aol.com&phoneHome=666-876-899&dateOfBirth=3/11/2021&lastName=TestLast&middleName=Test&firstName=TestFirst&il_aflan_id_651=&aflan_exit_date__year__650=2000&aflan_entry_date__year__649=2000&eTransferOrganization=LegalAidChicago&program=AFLAN';
    static String expectedEndpointForBadData = 'allout:Legal_Server_Demo/matter/api/online_intake_import/?jsonPayload=%7B%22aflan_referral_source_640%22%3A2%2C%22aflan_employment_641%22%3A3%2C%22aflan_housing_type_647%22%3A3%2C%22aflan_disability_642%22%3A1%2C%22aflan_branch_643%22%3A11%2C%22aflan_rank_653%22%3A1%2C%22aflan_status_646%22%3A6%2C%22aflan_no__of_deployments_648%22%3A2%7D&maritalStatus=&language=&race=&ethnicity=Non-Hispanic&gender=&numberOfChildren=2&numberOfAdults=2&addressHome=%7B%22address1%22%3A%22123%20main%22%2C%22city%22%3A%22Chicago%22%2C%22state%22%3A%22Nevada%22%2C%22zip%22%3A%2260654%22%7D&email=test@aol.com&phoneHome=666-876-899&dateOfBirth=3/11/2021&lastName=TestLast&middleName=Test&firstName=TestFirst&il_aflan_id_651=&aflan_exit_date__year__650=2000&aflan_entry_date__year__649=2000&eTransferOrganization=LegalAidChicago&program=AFLAN';

    Integer statusCode;
    String responseBody;
    Boolean isProperEndpoint;
    
    public SendToLegalServerControllerMock(Integer statusCode, String responseBody, Boolean isProperEndpoint) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.isProperEndpoint = isProperEndpoint;
    }

    global HTTPResponse respond(HTTPRequest req) {
        String endpoint = isProperEndpoint ? expectedEndpoint : expectedEndpointForBadData;
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);
        res.setStatusCode(statusCode);
        return res;
    }
}