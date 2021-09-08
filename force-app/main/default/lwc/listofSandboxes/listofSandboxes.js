import { LightningElement,track,wire,api} from 'lwc';

import listofAvailableSandboxes from '@salesforce/apex/IntSandbox_Info.getIntegratedSandboxResponse';
const actions = [
    { label: 'Refresh', name: 'Refresh' },
    { label: 'Delete', name: 'Delete' },
];
 
const columns = [   
    { label: 'Sandbox InfoID', fieldName: 'Id' }, 
    { label: 'Sandbox Name', fieldName: 'SandboxName' }, 
    { label: 'License Type', fieldName: 'LicenseType' },
    { label: 'Description', fieldName: 'Description' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }, 
];

export default class ListofSandboxes extends LightningElement {
    @track cases; 
    @track error; 
    @track columns = columns; 
    @wire(listofAvailableSandboxes)
    updateAccountName({ error, data }) {
        if (data) {
            this.cases=data;
            console.log('updateAccountName: ' +this.cases);
        } else {
            if(error){
                console.log('error: ', error);
            }
        }
    }
    handleRowAction( event ) {
alert('this.cases'+this.cases);
        const actionName = event.detail.action.name;
        const row = event.detail.row.Id;
        alert('row'+row);
        switch ( actionName ) {
            case 'Refresh':
                
                break;
            case 'Delete':
                
                break;
            default:
        }

    }
}