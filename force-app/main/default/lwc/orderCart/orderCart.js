import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderCart extends LightningElement {
    @api orderId;
    @track orderLines = [];
    @track totalAmount = 0;
    @track promoApplied = false;

    connectedCallback() {
        this.loadOrderLines();
    }

    loadOrderLines() {
        // TODO: Load order lines from Apex
        this.orderLines = [
            { Id: '1', ProductName: 'Product 1', Qty: 10, UnitPrice: 100, LineTotal: 1000 },
            { Id: '2', ProductName: 'Product 2', Qty: 5, UnitPrice: 200, LineTotal: 1000 }
        ];
        this.calculateTotal();
    }

    calculateTotal() {
        this.totalAmount = this.orderLines.reduce((sum, line) => sum + line.LineTotal, 0);
    }

    handleAddLine() {
        // TODO: Add order line
        this.showToast('Success', 'Order line added', 'success');
    }

    handleRemoveLine(event) {
        const lineId = event.detail.lineId;
        this.orderLines = this.orderLines.filter(line => line.Id !== lineId);
        this.calculateTotal();
        this.showToast('Success', 'Order line removed', 'success');
    }

    handleApplyPromo() {
        // TODO: Apply promotions via PricingEngine
        this.promoApplied = true;
        this.showToast('Success', 'Promotions applied', 'success');
    }

    handleSubmit() {
        // TODO: Submit order
        this.showToast('Success', 'Order submitted', 'success');
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
