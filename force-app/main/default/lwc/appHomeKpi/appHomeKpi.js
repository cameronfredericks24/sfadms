import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getKpiData from '@salesforce/apex/KpiController.getKpiData';

export default class AppHomeKpi extends LightningElement {
    kpiData;
    error;

    @wire(getKpiData)
    wiredKpiData({ error, data }) {
        if (data) {
            this.kpiData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.kpiData = undefined;
        }
    }

    get coverage() {
        return this.kpiData?.coverage || 0;
    }

    get dropSize() {
        return this.kpiData?.dropSize || 0;
    }

    get linesPerOrder() {
        return this.kpiData?.linesPerOrder || 0;
    }

    get promoUptake() {
        return this.kpiData?.promoUptake || 0;
    }

    handleRefresh() {
        return refreshApex(this.wiredKpiData);
    }
}
