import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderCart extends LightningElement {
    @track orderLines = [];
    @track totalAmount = 0;

    handleAddProduct() {
        // TODO: Implement product selection and add to cart
        this.showToast('Info', 'Product selection not yet implemented', 'info');
    }

    handleRemoveLine(event) {
        const lineId = event.detail.lineId;
        this.orderLines = this.orderLines.filter(line => line.id !== lineId);
        this.calculateTotal();
    }

    calculateTotal() {
        this.totalAmount = this.orderLines.reduce((sum, line) => {
            return sum + (line.netAmount || 0);
        }, 0);
    }

    handleApplyPromotions() {
        // TODO: Call PricingEngine via Flow/Apex
        this.showToast('Success', 'Promotions applied', 'success');
    }

    get hasOrderLines() {
        return this.orderLines && this.orderLines.length > 0;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}
