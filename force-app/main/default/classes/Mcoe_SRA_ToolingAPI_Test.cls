@isTest
public class Mcoe_SRA_ToolingAPI_Test {
    @isTest
    static void testProcessServiceRequest(){
        Contact newContact = new Contact(LastName='Test User');
        Insert newContact;
        Mcoe_Service_Requests__c createSandboxSuccess = new Mcoe_Service_Requests__c(Mcoe_Requestor__c = newContact.Id, Mcoe_Request_Type__c = 'Create New Sandbox', Mcoe_Sandbox_Name__c = 'CreateScs', Mcoe_Request_Status__c = 'Approved', Mcoe_Request_Priority__c = 'Medium', Mcoe_New_Sandbox_Description__c = 'Create New Sandbox Success', Mcoe_Sandbox_Type__c = 'Developer');
        Mcoe_Service_Requests__c refreshSandboxSuccess = new Mcoe_Service_Requests__c(Mcoe_Requestor__c = newContact.Id, Mcoe_Request_Type__c = 'Refresh Existing Sandbox', Mcoe_Prod_Sandbox_Names__c = '26te', Mcoe_Request_Status__c = 'Approved', Mcoe_Request_Priority__c = 'Medium', Mcoe_Sandbox_Type__c = 'Developer');
        Mcoe_Service_Requests__c deleteSandboxSuccess = new Mcoe_Service_Requests__c(Mcoe_Requestor__c = newContact.Id, Mcoe_Request_Type__c = 'Delete Existing Sandbox', Mcoe_Prod_Sandbox_Names__c = '26te', Mcoe_Request_Status__c = 'Approved', Mcoe_Request_Priority__c = 'Medium');
        List<Mcoe_Service_Requests__c> listofsr=new List<Mcoe_Service_Requests__c>();
        listofsr.add(createSandboxSuccess);
        listofsr.add(refreshSandboxSuccess);
        listofsr.add(deleteSandboxSuccess);
        insert listofsr;
        Test.startTest();
        Mcoe_SRA_ToolingAPI.processServiceRequest(listofsr);
        Test.StopTest();
    }
}