import { LightningElement, wire } from 'lwc';
import getTodayBeatRoutes from '@salesforce/apex/BeatRouteService.getTodayBeatRoutes';

export default class BeatToday extends LightningElement {
    routes = [];
    error;

    @wire(getTodayBeatRoutes)
    wiredRoutes({ error, data }) {
        if (data) {
            this.routes = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.routes = [];
        }
    }

    get hasRoutes() {
        return this.routes && this.routes.length > 0;
    }

    handleCheckIn(event) {
        const routeId = event.target.dataset.routeId;
        // TODO: Implement check-in logic
    }
}
