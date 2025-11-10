import { createElement } from 'lwc';
import OrderCart from 'c/orderCart';

describe('c-order-cart', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays empty cart message when no items', () => {
        const element = createElement('c-order-cart', {
            is: OrderCart
        });
        document.body.appendChild(element);

        const emptyMessage = element.shadowRoot.querySelector('.slds-text-color_weak');
        expect(emptyMessage).not.toBeNull();
        expect(emptyMessage.textContent).toBe('No items in cart');
    });

    it('calculates total correctly', () => {
        const element = createElement('c-order-cart', {
            is: OrderCart
        });
        document.body.appendChild(element);

        element.cartItems = [
            { id: '1', name: 'Product 1', quantity: 2, unitPrice: 10 },
            { id: '2', name: 'Product 2', quantity: 3, unitPrice: 15 }
        ];
        element.calculateTotal();

        expect(element.totalAmount).toBe(65); // (2*10) + (3*15)
    });

    it('formats currency correctly', () => {
        const element = createElement('c-order-cart', {
            is: OrderCart
        });
        document.body.appendChild(element);

        element.totalAmount = 1234.56;
        const formatted = element.formattedTotal;

        expect(formatted).toContain('1,234.56');
    });
});
