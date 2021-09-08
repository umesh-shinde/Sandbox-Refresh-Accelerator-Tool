import { LightningElement, wire } from 'lwc';
import { getAnalyticsLimits } from 'lightning/analyticsWaveApi';

export default class AnalysticsWaveAPI extends LightningElement {
    @wire(getAnalyticsLimits, {
        licenseType: 'EinsteinAnalytics',
        types: ['Dataset​Queries']
    })
    onGetAnalyticsLimits({data, error}) {
       if (error) {
         console.log('getAnaltyicsLimits ERROR:', error);
       } else if (data) {
         console.log('getAnaltyicsLimits RESPONSE:', data.limits);
       }
    }
}