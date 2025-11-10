import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class AppHomeKpi extends LightningElement {
    coverage = 0;
    dropSize = 0;
    linesPerOrder = 0;
    promoUptake = 0;

    connectedCallback() {
        // TODO: Fetch KPI data from Apex or Platform Events
        this.loadKpiData();
    }

    loadKpiData() {
        // Stub implementation
        this.coverage = 85;
        this.dropSize = 1250;
        this.linesPerOrder = 8.5;
        this.promoUptake = 65;
    }
}
