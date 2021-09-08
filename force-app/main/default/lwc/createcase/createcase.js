import { LightningElement,track,wire,api} from 'lwc';
//import sendSandboxRequest from '@salesforce/apex/IntSandbox_Info.sendSandboxRequest';
import refreshSandbox from '@salesforce/apex/IntSandbox_Info.refreshSandbox';
import listofAvailableSandboxes from '@salesforce/apex/SandboxRequests.availableSandboxes';
import getsandboxNames from '@salesforce/apex/IntSandbox_Info.getsandboxNames';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const actions = [
    { label: 'Refresh', name: 'Refresh' },
    { label: 'Delete', name: 'Delete' },
];
 
const columns = [   
    { label: 'SandboxName', fieldName: 'SandboxName' }, 
    { label: 'LicenseType', fieldName: 'LicenseType' },
    { label: 'Description', fieldName: 'Description' },

    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }, 
];
let i=0;
export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
    @track value = ''; 
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track cases; 
    @track sandboxCreation=false;
    @track cancellationReason=false;
    @track rejectionReason=false;
    @track error; 
    @track columns = columns; 
    @track status;
    @track origin;
    @track inputparam;
    @api recordId;
    @track sandboxNames;
    createNewSandbox=true;
    @track items = []; 
    @track sandboxtype;
    @track selectedSandbox;
    @track requestedType;
    @track mapofsandboxes=[];
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    @wire(getsandboxNames)
    wiredContacts({ error, data }) {
        if (data) {
            var conts = data;
            
            for(var key in conts){
                console.log(key);
                console.log(conts[key] );
                this.items = [...this.items ,{value: conts[key] , label: conts[key]}];
                //this.mapofsandboxes.set(conts[key],key)
                this.mapofsandboxes.push({key:conts[key],value:key}); //Here we are creating the array to show on UI.
            }
            console.log(data);
            //value=data;
           /* for(i=0; i<data.length; i++) {
                console.log('id=' + data[i]);
                this.items = [...this.items ,{value: data[i] , label: data[i]}];                                   
            }  */             
            this.error = undefined;
        
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
    get sandboxOptions() {
        console.log(this.items);
        return this.items;
    }
    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedSandbox=event.detail.value;
        console.log('selectedOption=' +  this.selectedSandbox);

    }
    requestTypeChange(event){
        const selectedValue=event.target.value;
        alert('selectedValue'+selectedValue);
        this.requestedType=selectedValue;
        if(selectedValue=='Create New Sandbox'){
            this.createNewSandbox=true;
            this.sandboxCreation= true;
            this.sandboxtype=true;
            
            console.log('inside');
        }else{
            this.sandboxCreation=false;
            this.sandboxNames=true;
        }
        console.log('outside');
    }
    requestStatusChange(event){
        const selectedStatusValue=event.target.value;
        if(selectedStatusValue=='Rejected'){
            this.rejectionReason=true;
        }
        if(selectedStatusValue=='Cancelled'){
            this.cancellationReason=true;
        }
    }
    showtoastmethod(msg, variant) {
        const evt = new ShowToastEvent({
            message: msg,  // move this to label.
            variant: variant // move this to label.
        });
        this.dispatchEvent(evt);
    }

    handleSandboxCreated(event){
        this.isModalOpen = false;
            alert('created');
            this.recordId=event.detail.id;
            alert(this.recordId);
            //console.log('Map');
           // console.log(this.mapofsandboxes[0]);
            alert(JSON.stringify(this.mapofsandboxes));
            alert(this.selectedSandbox);
            alert(this.mapofsandboxes[this.selectedSandbox]);
            if(this.requestedType=='Refresh Existing Sandbox')
            {
                this.inputparam = { 'serviceRequestId':this.recordId,'sandboxName': this.selectedSandbox, 'sandboxType':this.sandboxType,'requestType':this.requestedType};
                refreshSandbox({inputparams:this.inputparam}).then(result => {
            if(result){
                console.log(result);
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
                
            }
            this.showtoastmethod('New Sandbox created and send for approval', "success");
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: event.detail.id,
                    objectApiName:"Mcoe_Service_Requests__c", // objectApiName is optional
                    actionName: "view"
                }
            });
        }
        handleErrorfromTrigger(event) {
            this.showtoastmethod(event.detail.detail, "error");
            console.log(event.detail.detail);  // create a toast message as well
        }
    handleSubmit(event) {
        event.preventDefault();
       
        if(this.createNewSandbox==true)
        {
            this.template.querySelector("[data-field='Mcoe_Request_Status__c']").value ='Created';
        }
        alert( this.template.querySelector("[data-field='Mcoe_Sandbox_Names__c']").value);
        this.template.querySelector("[data-field='Mcoe_Sandbox_Names__c']").value =this.selectedSandbox;
    alert( this.template.querySelector("[data-field='Mcoe_Sandbox_Names__c']").value);
        const fields = event.detail.fields;
        //this.template.querySelector("lightning-record-edit-form").submit(fields);
       
        
        //console.log('Fields'+fields);
        this.template.querySelector("lightning-record-edit-form").submit(fields);
        
        this.sandboxType=this.template.querySelector("[data-field='Sandbox Type']").value;
        //this.description=this.template.querySelector("[data-field='Mcoe_New_Sandbox_Description__c']").value;
        

        }
        
        
    
    handleRowAction( event ) {
    const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'Refresh':
                
                break;
            case 'Delete':
                
                break;
            default:
        }

    }
}