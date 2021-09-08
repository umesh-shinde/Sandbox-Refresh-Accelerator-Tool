public with sharing class Mcoe_SRA_ToolingAPI {
    //public static HttpCalloutMock mock = null;
    //This method is used to invoke tooling api call based on request type
    @InvocableMethod
    public static void processServiceRequest(List<Mcoe_Service_Requests__c> serviceRequestObject){
        string jsonRequest;
        for(Mcoe_Service_Requests__c loopVarSR: serviceRequestObject){
            string sandboxName = loopVarSR.Mcoe_Request_Type__c == 'Create New Sandbox' ? loopVarSR.Mcoe_Sandbox_Name__c : loopVarSR.Mcoe_Prod_Sandbox_Names__c;
            System.debug('sandboxName ' + sandboxName);
            jsonRequest = generateJSON(sandboxName, loopVarSR.Mcoe_New_Sandbox_Description__c, loopVarSR.Mcoe_Sandbox_Type__c, loopVarSR.Mcoe_Request_Type__c);
            if(loopVarSR.Mcoe_Request_Type__c == 'Create New Sandbox')
                createSandbox(loopVarSR.Id, jsonRequest);
            else if(loopVarSR.Mcoe_Request_Type__c == 'Refresh Existing Sandbox')
                refreshSandbox(loopVarSR.Id, sandboxName, jsonRequest);
            else if(loopVarSR.Mcoe_Request_Type__c == 'Delete Existing Sandbox')
                deleteSandbox(loopVarSR.Id, sandboxName);
        }
    }
    //This method is used to call tooling API to create new sandbox
    @future(callout=true)
    public static void createSandbox(string sRId, string jsonRequest){
        string namedCred = getNamedCred(sRId) != null ? getNamedCred(sRId) : 'Mcoe_SR_Tooling_API1';
        HttpRequest createRequest = new HttpRequest();
        createRequest.setEndpoint('callout:' + namedCred + '/services/data/v51.0/tooling/sobjects/SandboxInfo/');
        createRequest.setHeader('Content-Type', 'application/json');
        createRequest.setMethod('POST');
        createRequest.setbody(jsonRequest);
        Http http = new Http();
        HTTPResponse response = new HttpResponse();
        if (Test.isRunningTest()) {
            system.debug('inside test class'+createRequest);
            Test.setMock(HttpCalloutMock.class, new Mcoe_ServiceRequestSuccessMock());
        } else {
            system.debug('Outside test class');
            response = http.send(createRequest);
        }
        System.debug('This is statuscode '+response.getStatusCode()+' end');
        System.debug('This is respone '+response.getBody()+'this is end');
        addStagingRecord(sRId, jsonRequest, response.getBody(), response.getStatusCode());
        System.debug('response body'+response.getBody());
        updateServiceRequest(sRId, response.getBody());
    }
    //This method is used to call tooling API to refresh existing sandbox
    @future(callout=true)
    public static void refreshSandbox(string sRId, string sandboxName, string jsonRequest){
        string sandboxId;
        sandboxId = getSandboxId(sandboxName);
        HttpRequest refreshRequest = new HttpRequest();
        refreshRequest.setEndpoint('callout:Mcoe_SR_Tooling_API1/services/data/v51.0/tooling/sobjects/SandboxInfo/' + sandboxId);
        refreshRequest.setHeader('Content-Type', 'application/json');
        refreshRequest.setMethod('PATCH');
        refreshRequest.setbody(jsonRequest);
        Http http = new Http();
        HTTPResponse response=new HttpResponse();
        if (Test.isRunningTest()) {
            system.debug('Outside test class refrsh');
            response = http.send(refreshRequest);
            addStagingRecord(sRId, jsonRequest, response.getBody(), response.getStatusCode());
            updateServiceRequest(sRId, response.getBody());
        } else Test.setMock(HttpCalloutMock.class, new Mcoe_ServiceRequestSuccessMock());
        System.debug('This is statuscode '+response.getStatusCode()+' end');
        System.debug('This is respone '+response.getBody()+'this is end');
    }
    //This method is used to call tooling API to delete existing sandbox
    @future(callout=true)
    public static void deleteSandbox(string sRId, string sandboxName){
        string sandboxId = getSandboxId(sandboxName);
        HttpRequest deleteRequest = new HttpRequest();
        deleteRequest.setEndpoint('callout:Mcoe_SR_Tooling_API1/services/data/v51.0/tooling/sobjects/SandboxInfo/' + sandboxId);
        deleteRequest.setHeader('Content-Type','application/json');
        deleteRequest.setMethod('DELETE');
        Http http = new Http();
        if (Test.isRunningTest()) {
            HTTPResponse response = http.send(deleteRequest);
            string reqestData = 'Delete request for ' + sandboxName;
            addStagingRecord(sRId, reqestData, response.getBody(), response.getStatusCode());
            updateServiceRequest(sRId, response.getBody());
        }else Test.setMock(HttpCalloutMock.class, new Mcoe_ServiceRequestSuccessMock());
    }
    //This method returns sandbox id from sandbox name for which refresh or delete request is raised
    public static string getSandboxId(string sandboxName) {
        System.debug('sandboxName '+sandboxName);
        HttpRequest feedRequest = new HttpRequest();
        feedRequest.setEndpoint('callout:Mcoe_SR_Tooling_API1/services/data/v51.0/tooling/query?q=Select+Id,LicenseType,SandboxName+from+SandboxInfo+where+SandboxName=\''+sandboxName+'\'');
        feedRequest.setMethod('GET');
        Http http = new Http();
        if (Test.isRunningTest()) {
            HTTPResponse feedResponse = http.send(feedRequest);
            Map<string, Object> results = (Map<string, Object>)JSON.deserializeUntyped(feedResponse.getBody());
            Map<string,Object> sandboxAttributes = new Map<string,Object>();
            for (Object sandboxRecord : (List<Object>)results.get('records'))
                sandboxAttributes = (Map<string,Object>)sandboxRecord ;
            system.debug('sandbox Id'+ sandboxAttributes.get('Id'));
            return (string) sandboxAttributes.get('Id');
        }else{
            Test.setMock(HttpCalloutMock.class, new Mcoe_ServiceRequestSuccessMock());
            return '';
        }
    }
    //This method generates JSON for tolling API based on request type
    public static string generateJSON(string sandboxName, string sandboxDescription, string sandboxType, string requestType){
        System.debug('sandboxName' +sandboxName+ 'sandboxDescription'+sandboxDescription+ 'sandboxType'+sandboxType+ 'requestType'+requestType);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(requestType == 'Create New Sandbox'){
            gen.writeStringField('SandboxName', sandboxName);
            if(sandboxDescription!=null)   gen.writeStringField('Description', sandboxDescription);
        }
        if(requestType == 'Create New Sandbox' || requestType == 'Refresh Existing Sandbox'){
            gen.writeStringField('LicenseType', sandboxType);
            gen.writeStringField('AutoActivate', 'true');
        }
        gen.writeEndObject();
        system.debug('Final Json: '+gen.getAsString());
        return gen.getAsString();
    }
    //This method create an entry in staging object for all the request sent to tooling API
    public static void addStagingRecord(string sRId, string request, string response, Integer statusValue){
        string status = string.valueOf(statusValue).startsWith('2')?'Success':'Failure';
        Mcoe_Staging__c stagingObj = new Mcoe_Staging__c();
        if(request!='Batch'){
            Mcoe_Service_Requests__c serviceRequestObj = [SELECT Name, Mcoe_Request_Type__c, Mcoe_Requestor__c FROM Mcoe_Service_Requests__c WHERE ID=:sRId];
            stagingObj.Mcoe_SR_Number__c = serviceRequestObj.Name;
            stagingObj.Mcoe_Request__c = request;
            stagingObj.Mcoe_Response__c = response;
            stagingObj.Mcoe_Status__c = status;
            stagingObj.Mcoe_Request_Type__c = serviceRequestObj.Mcoe_Request_Type__c;
        }else{
            stagingObj.Mcoe_SR_Number__c = '';
            stagingObj.Mcoe_Request__c = request;
            stagingObj.Mcoe_Response__c = response;
            stagingObj.Mcoe_Status__c = status;
            stagingObj.Mcoe_Request_Type__c = 'Batch';
        }
        if(Mcoe_Staging__c.sObjectType.getDescribe().isCreateable())
            Insert stagingObj;
    }
    //This method create an entry in staging object for all the request sent to tooling API
    public static void updateServiceRequest(string sRId, string failureReason){
        System.debug('updateServiceRequest is called '+ sRId + ' reason '+failureReason);
        Mcoe_Service_Requests__c serviceRequestObj = [SELECT Mcoe_Request_Status__c, Mcoe_Failure_Reason__c, Mcoe_Request_Type__c FROM Mcoe_Service_Requests__c WHERE ID=:sRId];
        if(string.isBlank(failureReason) || failureReason.contains('"success":true')){
            serviceRequestObj.Mcoe_Request_Status__c = 'Completed';
        }
        else if(failureReason.contains('"errorCode":')){
            serviceRequestObj.Mcoe_Request_Status__c = 'Failed to process';
            serviceRequestObj.Mcoe_Failure_Reason__c = 'Your service request failed with this reason ' + failureReason;
        }
        System.debug('SR Obj'+ serviceRequestObj);
        if(Mcoe_Service_Requests__c.sObjectType.getDescribe().isUpdateable())
            UPDATE serviceRequestObj;
    }
    public static string getNamedCred(string sRId){
        String namedCred = null;
        try{
            Mcoe_Service_Requests__c serviceRequestObj = [SELECT Mcoe_Org_Name__c FROM Mcoe_Service_Requests__c WHERE ID=:sRId AND Mcoe_Org_Name__c != NULL];
            if(serviceRequestObj!=null){
                System.debug('serviceRequestObj'+serviceRequestObj);
                Mcoe_SR_Activity__mdt sRActivityMdt = [SELECT Mcoe_Named_Cred__c, Mcoe_Org_Name__c FROM Mcoe_SR_Activity__mdt WHERE Mcoe_Org_Name__c =:serviceRequestObj.Mcoe_Org_Name__c];
                if(sRActivityMdt!=null) namedCred = sRActivityMdt.Mcoe_Named_Cred__c;
            }
        }
        Catch(Exception ex){
            System.debug('There is an exception '+ ex);
        }
        System.debug('namedCred ' + namedCred);
        return namedCred;
    }
}