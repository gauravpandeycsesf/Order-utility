import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getOrderItemsPaginated from '@salesforce/apex/OrderProductsController.getOrderItemsPaginated';
import canActivateOrder from '@salesforce/apex/OrderProductsController.canActivateOrder';
import activateOrder from '@salesforce/apex/OrderProductsController.activateOrder';
import getOrderStatus from '@salesforce/apex/OrderProductsController.getOrderStatus';
import updateOrderItemQuantities from '@salesforce/apex/OrderProductsController.updateOrderItemQuantities';
import deleteOrderItems from '@salesforce/apex/OrderProductsController.deleteOrderItems';

export default class OrderProducts extends LightningElement {
    @api recordId;
    @track orderItems = [];
    @track isLoading = false;
    @track canActivate = false;
    @track error;
    @track isOrderActivated = false;
    @track draftValues = [];
    @track showDeleteModal = false;
    @track itemToDelete = null;
    
    limitSize = 5;
    offset = 0;

    wiredCanActivateResult;
    wiredOrderStatusResult;

    get orderItemColumns() {
        const columns = [
            {
                label: 'Product Name',
                fieldName: 'productName',
                type: 'text'
            },
            {
                label: 'Parent Product Name',
                fieldName: 'parentProductName',
                type: 'text'
            },
            {
                label: 'Unit Price',
                fieldName: 'unitPrice',
                type: 'currency',
            },
            {
                label: 'Quantity',
                fieldName: 'quantity',
                type: 'number',
                typeAttributes: { minimum: 1, step: 1 },
                cellAttributes: { alignment: 'right' },
                editable: !this.isOrderActivated
            },
            {
                label: 'Total Price',
                fieldName: 'totalPrice',
                type: 'currency',
            }
        ];

        if (!this.isOrderActivated) {
            columns.push({
                type: 'action',
                typeAttributes: {
                    rowActions: [
                        {
                            label: 'Delete',
                            name: 'delete',
                            iconName: 'utility:delete',
                            variant: 'bare'
                        }
                    ]
                }
            });
        }

        return columns;
    }

    connectedCallback() {
        if (this.recordId) {
            this.loadData();
        }
    }

    loadData(cacheBuster = 0) {
        if (!this.recordId) {
            return Promise.resolve();
        }
        
        this.isLoading = true;
        
        return getOrderItemsPaginated({ 
            orderId: this.recordId, 
            offset: this.offset, 
            pageSize: this.limitSize,
            cacheBuster: cacheBuster
        })
        .then(result => {
            if (result && result.items && result.items.length > 0) {
                this.orderItems = [...this.orderItems, ...result.items];
                this.offset += result.items.length;
                this.error = undefined;
            }
        })
        .catch(error => {
            this.error = error;
            console.error('Error loading order items:', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    @wire(canActivateOrder, { orderId: '$recordId' })
    wiredCanActivate(result) {
        this.wiredCanActivateResult = result;
        if (result.data !== undefined) {
            this.canActivate = result.data;
        }
    }

    @wire(getOrderStatus, { orderId: '$recordId' })
    wiredOrderStatus(result) {
        this.wiredOrderStatusResult = result;
        if (result.data) {
            this.isOrderActivated = result.data === 'Activated';
        }
    }

    get hasOrderItems() {
        return this.orderItems && this.orderItems.length > 0;
    }

    get totalAmount() {
        return this.orderItems.reduce((total, item) => total + (item.totalPrice || 0), 0);
    }

    get orderItemsWithFormattedPrices() {
        return this.orderItems.map(item => ({
            ...item,
            unitPrice: item.unitPrice || 0,
            totalPrice: item.totalPrice || 0
        }));
    }

    get errorMessage() {
        if (this.error) {
            return this.error.body?.message || this.error.message || 'An error occurred';
        }
        return '';
    }

    handleLoadMore(event) {
        if (this.isLoading) {
            if (event && event.target) {
                event.target.isLoading = false;
            }
            return;
        }
        
        const previousCount = this.orderItems.length;
        
        this.loadData().then(() => {
            if (this.orderItems.length === previousCount) {
                if (event && event.target) {
                    event.target.isLoading = false;
                }
            } else {
                setTimeout(() => {
                    if (event && event.target) {
                        event.target.isLoading = false;
                    }
                }, 0);
            }
        });
    }

    async handleActivateOrder() {
        this.isLoading = true;
        
        try {
            await activateOrder({ orderId: this.recordId });
            
            this.showToast('Success', 'Order activated successfully', 'success');
            
            await Promise.all([
                refreshApex(this.wiredCanActivateResult),
                refreshApex(this.wiredOrderStatusResult)
            ]);
            
            this.offset = 0;
            this.orderItems = [];
            this.loadData();
            
            this.dispatchEvent(new CustomEvent('orderactivated', {
                detail: { orderId: this.recordId }
            }));
            
        } catch (error) {
            this.showToast('Error', 'Failed to activate order: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    @api
    async refreshData() {
        if (this.wiredCanActivateResult) {
            await refreshApex(this.wiredCanActivateResult);
        }
        if (this.wiredOrderStatusResult) {
            await refreshApex(this.wiredOrderStatusResult);
        }
        this.offset = 0;
        this.orderItems = [];
        await this.loadData(Date.now());
    }

    async handleSaveQuantity(event) {
        if (this.isOrderActivated) {
            this.showToast('Error', 'Cannot edit quantity for activated orders', 'error');
            this.draftValues = [];
            return;
        }

        const updatedFields = event.detail.draftValues;
        const updates = {};

        updatedFields.forEach(item => {
            if (item.quantity !== undefined && item.quantity !== null) {
                if (item.quantity < 1) {
                    this.showToast('Error', 'Quantity must be at least 1', 'error');
                    this.draftValues = [];
                    return;
                }
                updates[item.id] = item.quantity;
            }
        });

        if (Object.keys(updates).length === 0) {
            this.draftValues = [];
            return;
        }

        this.isLoading = true;

        try {
            await updateOrderItemQuantities({ orderItemUpdates: updates });
            
            this.orderItems = this.orderItems.map(item => {
                if (updates[item.id] !== undefined) {
                    const newQuantity = updates[item.id];
                    return {
                        ...item,
                        quantity: newQuantity,
                        totalPrice: (item.unitPrice || 0) * newQuantity
                    };
                }
                return item;
            });
            
            this.showToast('Success', 'Quantity updated successfully', 'success');
            this.draftValues = [];
            
            this.offset = 0;
            this.orderItems = [];
            await this.loadData(Date.now());
            
        } catch (error) {
            this.showToast('Error', 'Failed to update quantity: ' + (error.body?.message || error.message), 'error');
            this.draftValues = [];
            console.error('Error updating quantity:', error);
        } finally {
            this.isLoading = false;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'delete') {
            this.handleDeleteRow(row);
        }
    }

    handleDeleteRow(row) {
        this.itemToDelete = row;
        this.showDeleteModal = true;
    }

    handleCancelDelete() {
        this.showDeleteModal = false;
        this.itemToDelete = null;
    }

    async handleConfirmDelete() {
        if (!this.itemToDelete) {
            return;
        }

        this.isLoading = true;
        this.showDeleteModal = false;

        try {
            await deleteOrderItems({ orderItemIds: [this.itemToDelete.id] });
            
            this.showToast('Success', 'Order item deleted successfully', 'success');
            
            this.orderItems = this.orderItems.filter(item => item.id !== this.itemToDelete.id);
            
            this.offset = 0;
            this.orderItems = [];
            await this.loadData(Date.now());
            
            this.itemToDelete = null;
            
        } catch (error) {
            this.showToast('Error', 'Failed to delete order item: ' + (error.body?.message || error.message), 'error');
            console.error('Error deleting order item:', error);
        } finally {
            this.isLoading = false;
        }
    }
}