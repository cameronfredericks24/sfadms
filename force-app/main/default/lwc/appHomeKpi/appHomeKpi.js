import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class AppHomeKpi extends LightningElement {
    coverage = 0;
    hitRate = 0;
    linesPerOrder = 0;
    promoUptake = 0;

    connectedCallback() {
        // TODO: Load KPI data from Apex
        this.loadKpiData();
    }

    loadKpiData() {
        // Mock data for demo
        this.coverage = 85;
        this.hitRate = 92;
        this.linesPerOrder = 12;
        this.promoUptake = 45;
    }

    get coverageClass() {
        return this.coverage >= 80 ? 'slds-text-color_success' : 'slds-text-color_error';
    }

    get hitRateClass() {
        return this.hitRate >= 90 ? 'slds-text-color_success' : 'slds-text-color_warning';
    }
}
