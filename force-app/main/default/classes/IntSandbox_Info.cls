public class IntSandbox_Info {
    @AuraEnabled(cacheable=true)
    public static List<SandboxInfoWrapper> getIntegratedSandboxResponse(){ 
        /*GET /services/data/v40.0/tooling/query/?q='Select+id,SandboxName+from+SandboxInfo'*/
        HttpRequest req = new HttpRequest();
        //SandboxInfoWrapper sandboxInfo=new SandboxInfoWrapper();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        String query='Select+Id,SandboxName,LicenseType,Description,SourceId+from+SandboxInfo';
        req.setEndpoint('callout:Mcoe_SR_Tooling_API1/services/data/v52.0/tooling/query?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response=http.send(req);
        system.debug('Body:'+response.getBody());
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        List<SandboxInfoWrapper> listofSandboxInfo=new  List<SandboxInfoWrapper>();
        system.debug('results:'+results);
        List<Object> listofSandboxes = (List<Object>)results.get('records');
        system.debug('lstCustomers:'+listofSandboxes);
        for (Object sandboxRecord : listofSandboxes) {
            SandboxInfoWrapper newSandbox=new SandboxInfoWrapper();
            Map<String,Object> sandboxAttributes = (Map<String,Object>)sandboxRecord ;
            System.debug('cr ' + sandboxAttributes.keyset());
            newSandbox.Id = (String) sandboxAttributes.get('Id');
            newSandbox.SandboxName=(String) sandboxAttributes.get('SandboxName');
            newSandbox.LicenseType=(String) sandboxAttributes.get('LicenseType');
            newSandbox.Description=(String)  sandboxAttributes.get('Description');
            System.debug('newSandbox ' + newSandbox);
            listofSandboxInfo.add(newSandbox);
        }
        System.debug('listofSandboxInfo'+listofSandboxInfo);
        //sandboxInfo = (SandboxInfoWrapper) JSON.deserialize(response.getBody(),SandboxInfoWrapper.class);
        return  listofSandboxInfo;
    }
    public with sharing class SandboxInfoWrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String SandboxName;
        @AuraEnabled
        public String LicenseType;
        @AuraEnabled
        public String Description;
    }
    public static List<string> getsandboxNames(){
        /*GET /services/data/v40.0/tooling/query/?q='Select+id,SandboxName+from+SandboxInfo'*/
        HttpRequest req = new HttpRequest();
        //SandboxInfoWrapper sandboxInfo=new SandboxInfoWrapper();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        //req.setHeader('Content-Type', 'application/json');
        //httpRequest.setHeader(‘Content-Type’, ‘application/json;charset=UTF-8’);
        String query='Select+Id,ActivatedDate,RefreshAction,SandboxInfoId,SandboxName+from+SandboxProcess';
        req.setEndpoint('callout:Mcoe_SR_Tooling_API1/services/data/v52.0/tooling/query?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response=http.send(req);
        system.debug('Body:'+response.getBody());
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        system.debug('results:'+results);
        List<Object> listofSandboxes = (List<Object>)results.get('records');
        system.debug('lstCustomers:'+listofSandboxes);
        List<string> listofSandboxnames=new List<string>();
        for (Object sandboxRecord : listofSandboxes) {
            Map<String,Object> sandboxAttributes = (Map<String,Object>)sandboxRecord ;
            Date activationDate = Date.valueOf((String)sandboxAttributes.get('ActivatedDate'));
            if(activationDate<System.today() &&(String)sandboxAttributes.get('SandboxName')!=null )
                listofSandboxnames.add((String)sandboxAttributes.get('SandboxName'));
        }
        String reqestData='Batch';
        Mcoe_SRA_ToolingAPI.addStagingRecord(' ', reqestData, response.getBody(), response.getStatusCode());
        Mcoe_SRA_ToolingAPI.updateServiceRequest('', response.getBody());
        System.debug('listofSandboxnames'+listofSandboxnames);
        return listofSandboxnames;
    }
    @AuraEnabled
    public static void refreshSandbox(Map<String,String> inputparams){
        string serviceRequestId=inputparams.get('serviceRequestId');
        string sandboxName=inputparams.get('sandboxName');
        String sandboxId=inputparams.get('sandboxId');
        string requestType=inputparams.get('requestType');
        string sandboxType=inputparams.get('sandboxType');
        string serviceRequestNumber= getSandboxnumber(serviceRequestId);
        String jsonRequest= Mcoe_SRA_ToolingAPI.generateJSON('','',requestType,sandboxType);
        HttpRequest refreshRequest = new HttpRequest();
        refreshRequest.setEndpoint('callout:Mcoe_SR_Tooling_API1/services/data/v51.0/tooling/sobjects/SandboxInfo/' + sandboxId);
        refreshRequest.setHeader('Content-Type', 'application/json');
        refreshRequest.setMethod('PATCH');
        refreshRequest.setbody(jsonRequest);
        Http http = new Http();
        HTTPResponse response = http.send(refreshRequest);
        System.debug('This is statuscode '+response.getStatusCode()+' end');
        System.debug('This is respone '+response.getBody()+'this is end');
        string statusValue = string.valueOf(response.getStatusCode()).startsWith('2')?'Success':'Failure';
    }
    //This method is used to call tooling API to delete existing sandbox
    public static String getSandboxnumber(String serviceRequestId){
        // List<Mcoe_Service_Requests__c> sandboxNumber=new List<Mcoe_Service_Requests__c>();
        Mcoe_Service_Requests__c   serviceRequestRecord=[select Name from Mcoe_Service_Requests__c where Name=:serviceRequestId];
        return serviceRequestRecord.Name;
    }
}