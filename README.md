# Sandbox Refresh Accelerator Tool
## Scope: 
This design helps in raising request for create new sandbox, refresh existing sandbox, delete existing sandbox to multiple prod instances.
## Process for set up:
For using this feature, we need to follow below steps-
1.	To set up prod orgs create a Connected App to get consumer key and consumer secret to use in developer sandbox org. 
2.	In sandbox org create auth provider using above consumer key and consumer secret and copy callback url generated.
3.	Update Callback url from sandbox org into connected app of prod org.
4.	Using Auth provider create named credentials with OAuth2.0 and authenticate with prod user.
5.	Update Custom Metadata Moce_SR_Activity_mdt in sandbox org to provide mapping of Orgs (Mcoe_Service_Request__c.Mcoe_Org_Name__c field) connected and Named creds for those orgs. (In case of multiple prod instances)
## Benefits:
1.	Using this feature user can send different types of requests like create new sandbox, refresh existing sandbox and delete existing sandbox. 
2.	User can request for sandbox activities of multiple prod instances from single sandbox.
3.	User can track the status of their service request under single object.
4.	All service requests will be processed only after initial approval.

* [Object and Custom Metadata Structure.xlsx](https://github.com/umesh-shinde/Sandbox-Refresh-Accelerator-Tool/files/7136315/Object.and.Custom.Metadata.Structure.xlsx) *
* [SRAT Component List.xlsx](https://github.com/umesh-shinde/Sandbox-Refresh-Accelerator-Tool/files/7136321/SRAT.Component.List.xlsx) *
* [Sandbox Refresh Accelerator Tool.docx](https://github.com/umesh-shinde/Sandbox-Refresh-Accelerator-Tool/files/7136327/Sandbox.Refresh.Accelerator.Tool.docx) *
