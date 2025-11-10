import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ORDER_FIELDS = [
    'SecondaryOrder__c.Retailer__c',
    'SecondaryOrder__c.Distributor__c',
    'SecondaryOrder__c.GrossAmount__c',
    'SecondaryOrder__c.NetAmount__c'
];

export default class OrderCart extends LightningElement {
    @api recordId;
    @track cartItems = [];
    @track totalAmount = 0;
    @track appliedPromotions = [];

    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    order;

    handleAddItem(event) {
        const item = event.detail;
        this.cartItems = [...this.cartItems, item];
        this.calculateTotal();
    }

    handleRemoveItem(event) {
        const index = event.detail;
        this.cartItems.splice(index, 1);
        this.cartItems = [...this.cartItems];
        this.calculateTotal();
    }

    calculateTotal() {
        this.totalAmount = this.cartItems.reduce((sum, item) => {
            return sum + (item.quantity * item.unitPrice);
        }, 0);
    }

    handleSave() {
        // Save cart items
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Order cart saved successfully',
                variant: 'success'
            })
        );
    }

    get hasItems() {
        return this.cartItems.length > 0;
    }

    get formattedTotal() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(this.totalAmount);
    }
}
