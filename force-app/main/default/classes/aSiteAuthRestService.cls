/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/site_auth/*')
global with sharing class aSiteAuthRestService {

    @HttpPost
    global static void userLogin(String username, String password, String company, String api_key) {
        ResponseWrapper responseW = new ResponseWrapper();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        try {
            String ip = request.remoteAddress;
    
            String token;
            SiteUser__c user;
    
            if(username != null && password != null) {
                user = aSiteAuthManager.UserLogin(username,password);
                if(user == null) {
                    response.statusCode = 401;
                    responseW.message = 'Username or password combination not found.';
                    response.responseBody = Blob.valueOf(JSON.serialize(responseW));
                } else {
                    token = aSiteAuthManager.OpenUserSession(user.Id,ip,company);
                    if(token == null) {
                        response.statusCode = 500;
                        responseW.message = 'Could not create a session succesfully.';
                        response.responseBody = Blob.valueOf(JSON.serialize(responseW));
                    } else {
                        response.statusCode = 200;
                        responseW.message = 'Token created succesfully.';
                        responseW.token = token;
                        response.responseBody = Blob.valueOf(JSON.serialize(responseW));
                    }
                }
            } else {
                responseW.message = 'Username and/or password are missing.';
                response.statusCode = 400;
                response.responseBody = Blob.valueOf(JSON.serialize(responseW));
            }        
        } catch (Exception e) {
            response.statusCode = 500;
            responseW.message = e.getMessage();
            response.responseBody = Blob.valueOf(JSON.serialize(responseW));
        }
    }   

    public class ResponseWrapper {
        public ResponseWrapper() {
            message = '';
            token = null;
        }
        String message;
        String token;
    }
}