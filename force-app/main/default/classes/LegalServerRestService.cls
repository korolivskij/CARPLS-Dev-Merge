/**
 * Provisio Partners
 * @author Stepan Mahdziak <stepan.mahdziak@redtag.pro>
 * @date  2020
 *
 * @description class for sending fields to the Legal Server Intergation;
 **/
public class LegalServerRestService {

    @future(callout= true)
    public static void doAction(String stringParams, Id appliedResource, String nameCredentialType) {
        Map<String, Object> params = ((Map<String, Object>)JSON.deserializeUntyped(stringParams));
        HttpRequest request = new HttpRequest();
        String parameters = '';
        for (String param :((Map<String, Object>)params).keySet()) {
            parameters += (parameters == '' ? '' : '&');
            String value = String.valueOf(((Map<String, Object>)params).get(param));
            if (!String.isBlank(value) && (value.left(1) == '{' || value.left(2) == '({')) {
                parameters += param + '=' + EncodingUtil.urlEncode(JSON.serialize(((Map<String, Object>)params).get(param)), 'UTF-8').replace('+', LegalServerConstants.URL_SIGN_ENCODER);    
            } else {
                parameters += param + '=' + ((Map<String, Object>)params).get(param);
            }
        }
        parameters = parameters.replace(' ', LegalServerConstants.URL_SIGN_ENCODER);
        if(nameCredentialType == 'Production'){
            request.setEndpoint(LegalServerConstants.LEGAL_SERVER_ENDPOINT + parameters);
        }else{
            request.setEndpoint(LegalServerConstants.LEGAL_SERVER_DEMO_ENDPOINT + parameters);
        }
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');  
        HTTPResponse response = makeCallout(request);
        createLog(response, parameters, appliedResource);
    }

    private static HTTPResponse makeCallout(HttpRequest request) {        
        Http httpClient = new Http(); 
            HTTPResponse response = httpClient.send(request);        
            return response;
        }   
          
    //method for creating and tracking exceptions
    private static void createLog(HTTPResponse response, String request, Id appliedResource) {
        Integer status = response.getStatusCode();
        String respBody = response.getBody();     
        Interface_Log__c log = new Interface_Log__c();
        log.Applied_Resource__c = appliedResource;
        log.Request__c = request;
        log.Response__c = respBody.left(32760);
        log.Result_Code__c = String.valueOf(status);
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(respBody);   
        if (status != 200) {
            log.Error__c = true;
            log.Error_message__c = response.getStatus(); 
        } else if (resp.containsKey(LegalServerConstants.RESPONSE_BODY_KEY_ERROR) && !resp.containsKey(LegalServerConstants.RESPONSE_BODY_KEY_RESULTS)) {
            log.Error_message__c = (String)resp.get(LegalServerConstants.RESPONSE_BODY_KEY_ERROR);    
        } else {
            if (resp.containsKey(LegalServerConstants.RESPONSE_BODY_KEY_RESULTS)) {
                Map<String, Object> results = (Map<String, Object>)resp.get(LegalServerConstants.RESPONSE_BODY_KEY_RESULTS);
                if (results.containsKey(LegalServerConstants.RESPONSE_BODY_KEY_UNIQUE_ID)) {
                    Applied_Resource__c toUpdate = new Applied_Resource__c(Id = appliedResource, Legal_Server_ID__c = (String)results.get(LegalServerConstants.RESPONSE_BODY_KEY_UNIQUE_ID));
                    update toUpdate;
                }
            }
        }
        insert log;
    }



    
}