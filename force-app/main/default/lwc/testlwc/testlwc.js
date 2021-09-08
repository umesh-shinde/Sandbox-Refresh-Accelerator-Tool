import { LightningElement } from 'lwc';

export default class RadioGroupBasic extends LightningElement {
    value = '';

    get options() {
        return [
            { label: 'Sales', value: 'option1' },
            { label: 'Force', value: 'option2' },
        ];
    }

    submit(){
      var input = this.template.querySelectorAll('legend');
      input.forEach(function(element){
     // element.setAttribute('legend','test');
        element.classList.add('slds-has-error');
      });
    }
}