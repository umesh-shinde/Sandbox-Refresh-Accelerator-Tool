import { LightningElement, wire, track, api } from 'lwc';
import getPickList from '@salesforce/apex/UpdateOrgDetailsMDT.getPickListValues';
import updateScheduleTime from '@salesforce/apex/UpdateOrgDetailsMDT.updateScheduleTime';
import deleteJob from '@salesforce/apex/UpdateOrgDetailsMDT.deleteScheduleJob';
import getdefaultValue from '@salesforce/apex/UpdateOrgDetailsMDT.getDefaultValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ChangeSchduleJobTimeFrame extends NavigationMixin(LightningElement) {

    @track picklist = [];
    @track value;
    @track isLoading = true;
    @track title;
    @track message;
    @track variant;
    @track error;

    @wire(getdefaultValue)
    metadatarecord({ error, data }) {
        if (data) {
            this.value = data;
        }
    }

    @wire(getPickList)
    picklists({ error, data }) {
        if (data) {
            this.isLoading = true;
            var picklist = [];
            data.forEach(ele =>{
                var item = [];
                item.push({'label' : ele,'value' : ele});
                picklist.push(item);
            });
            this.picklist = Array.prototype.concat(...picklist);
            this.isLoading = false;
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleSave(){
        this.deleteExistingJobs();
    }

    deleteExistingJobs(){
        deleteJob()
        .then(() => {
           this.scheduleJob();
        })
        .catch((error) => {
            this.title = 'Error';
            this.message = JSON.stringify(error);
            this.variant = 'error';
            this.showNotification();
        });
    }

    scheduleJob(){
        updateScheduleTime({
            duration : this.value
        })
        .then(() => {
            this.title = 'Success';
            this.message = 'Updated Schedule Job';
            this.variant = 'Success';
            this.showNotification();
        })
        .catch((error) => {
            this.title = 'Error';
            this.message = JSON.stringify(error);
            this.variant = 'error';
            this.showNotification();
        });
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    errorCallback(error, stack) {
        console.log('error '+error);
        this.error = error;
    }
}