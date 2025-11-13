import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderStatus from '@salesforce/apex/OrderProductsController.getOrderStatus';

export default class OrderManagement extends LightningElement {
    @api recordId; // Order ID
    @track isOrderActivated = false;

    wiredOrderStatusResult;

    @wire(getOrderStatus, { orderId: '$recordId' })
    wiredOrderStatus(result) {
        this.wiredOrderStatusResult = result;
        if (result.data) {
            this.isOrderActivated = result.data === 'Activated';
        }
    }

    // Handle product added event from availableProducts
    async handleProductAdded(event) {
        // Refresh orderProducts component
        const orderProductsComponent = this.template.querySelector('c-order-products');
        if (orderProductsComponent && orderProductsComponent.refreshData) {
            await orderProductsComponent.refreshData();
        }
    }

    // Handle order activated event from orderProducts
    async handleOrderActivated(event) {
        // Refresh order status first
        if (this.wiredOrderStatusResult) {
            await refreshApex(this.wiredOrderStatusResult);
        }
        
        // Set isOrderActivated to true (this will automatically update availableProducts via prop binding)
        this.isOrderActivated = true;
        
        // Refresh availableProducts data as well
        const availableProductsComponent = this.template.querySelector('c-available-products');
        if (availableProductsComponent && availableProductsComponent.refreshData) {
            await availableProductsComponent.refreshData();
        }
    }
}