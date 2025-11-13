import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
import addProductsToOrderWithQuantities from '@salesforce/apex/AvailableProductsController.addProductsToOrderWithQuantities';

export default class AvailableProducts extends LightningElement {
    @api recordId;
    @api isOrderActivated = false;
    @track products = [];
    @track isLoading = false;
    @track error;
    @track showSuccessMessage = false;
    @track showProductTable = false;
    @track selectedProducts = [];
    @track isAddingProducts = false;
    @track expandedRows = [];
    @track searchTerm = '';
    @track isSearching = false;

    wiredProductsResult;

    productColumns = [
        {
            label: 'Product Name',
            fieldName: 'label',
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Product Code',
            fieldName: 'metatext',
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Description',
            fieldName: 'description',
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'List Price',
            fieldName: 'listPrice',
            type: 'currency',
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'Quantity in Order',
            fieldName: 'quantityInOrder',
            type: 'number',
            cellAttributes: { alignment: 'right' }
        }
    ];

    get requestParams() {
        return {
            orderId: this.recordId,
            parentName: this.searchTerm && this.searchTerm.trim().length > 0 ? this.searchTerm.trim() : null
        };
    }

    @wire(getAvailableProducts, { request: '$requestParams' })
    wiredProducts(result) {
        try {
            this.wiredProductsResult = result;
            if (result.data) {
                this.products = Array.isArray(result.data) ? result.data : [];
                this.error = undefined;
                this.showSuccessMessage = false;
                this.isSearching = false;
                this.updateExpandedRows();
            } else if (result.error) {
                console.error('Error loading products:', result.error);
                this.error = result.error;
                this.products = [];
                this.expandedRows = [];
                this.isSearching = false;
            }
        } catch (error) {
            console.error('Error in wiredProducts:', error);
            this.error = error;
            this.products = [];
            this.expandedRows = [];
            this.isSearching = false;
        }
    }

    get hasProducts() {
        return this.products && Array.isArray(this.products) && this.products.length > 0;
    }

    get hasAvailableProducts() {
        return this.treeData && Array.isArray(this.treeData) && this.treeData.length > 0;
    }

    get availableProducts() {
        try {
            if (!this.treeData || !Array.isArray(this.treeData)) {
                return [];
            }
            
            const allProducts = [];
            this.treeData.forEach(parent => {
                if (parent && parent._children && Array.isArray(parent._children)) {
                    allProducts.push(...parent._children);
                }
            });
            
            return allProducts;
        } catch (error) {
            console.error('Error in availableProducts getter:', error);
            return [];
        }
    }

    get availableProductsCount() {
        const products = this.availableProducts;
        return products && Array.isArray(products) ? products.length : 0;
    }

    get treeData() {
        try {
            if (!this.products || !Array.isArray(this.products) || this.products.length === 0) {
                return [];
            }
            
            let treeNodes = this.products
                .filter(parent => parent != null)
                .map((parent, parentIndex) => {
                    try {
                        const parentName = parent?.name || parent?.label || 'parent';
                        const parentKey = `parent_${parentIndex}_${parentName}`;
                        
                        const parentNode = {
                            name: parentName,
                            label: parent?.label || parentName,
                            productId: parentKey,
                            metatext: '',
                            listPrice: null,
                            quantityInOrder: null,
                            description: '',
                            _children: []
                        };
                        
                        if (parent?.items && Array.isArray(parent.items) && parent.items.length > 0) {
                            parentNode._children = parent.items
                                .filter(child => child != null)
                                .map(child => ({
                                    name: child?.name || child?.label || '',
                                    label: child?.label || child?.name || '',
                                    productId: child?.productId || child?.id || '',
                                    metatext: child?.metatext || child?.productCode || '',
                                    listPrice: child?.listPrice || 0,
                                    quantityInOrder: child?.quantityInOrder || 0,
                                    description: child?.description || ''
                                }))
                                .filter(child => child.productId);
                        }
                        
                        return parentNode;
                    } catch (error) {
                        console.error('Error processing parent node:', error, parent);
                        return null;
                    }
                })
                .filter(node => node != null);
            
            return treeNodes;
        } catch (error) {
            console.error('Error in treeData getter:', error);
            return [];
        }
    }
    
    get hasSearchTerm() {
        return this.searchTerm && this.searchTerm.trim().length > 0;
    }
    
    get filteredTreeDataCount() {
        return this.treeData ? this.treeData.length : 0;
    }

    get isAddProductDisabled() {
        return this.isLoading || this.isOrderActivated;
    }

    get selectedProductIds() {
        return (this.selectedProducts || []).map(product => product.productId || product.id);
    }

    get hasSelectedProducts() {
        return this.selectedProducts && this.selectedProducts.length > 0;
    }

    get selectedProductsCount() {
        return this.selectedProducts ? this.selectedProducts.length : 0;
    }

    get errorMessage() {
        if (this.error) {
            return this.error.body?.message || this.error.message || 'An error occurred';
        }
        return '';
    }

    updateExpandedRows() {
        try {
            this.expandedRows = [];
        } catch (error) {
            console.error('Error updating expanded rows:', error);
            this.expandedRows = [];
        }
    }

    handleShowProductTable() {
        this.showProductTable = true;
        this.selectedProducts = [];
        this.searchTerm = '';
        this.updateExpandedRows();
    }
    
    async handleSearchChange(event) {
        this.searchTerm = event.target.value || '';
        this.isSearching = true;
        if (this.wiredProductsResult) {
            try {
                await refreshApex(this.wiredProductsResult);
            } catch (error) {
                console.error('Error refreshing products:', error);
            } finally {
                this.isSearching = false;
            }
        } else {
            this.isSearching = false;
        }
        this.updateExpandedRows();
    }

    handleCloseProductTable() {
        this.showProductTable = false;
        this.selectedProducts = [];
        this.searchTerm = '';
    }

    handleProductSelection(event) {
        const selectedRows = event.detail.selectedRows || [];
        const previousValidSelection = [...(this.selectedProducts || [])];
        
        const childProducts = selectedRows.filter(row => {
            const productId = row.productId || row.id;
            return productId && !String(productId).startsWith('parent_');
        });
        
        if (this.hasMultipleChildrenFromSameParent(childProducts)) {
            this.showToast(
                'Error', 
                'You can select only one child product per parent. Please deselect one of the products from the same parent.', 
                'error'
            );
            
            this.selectedProducts = previousValidSelection;
            
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            Promise.resolve().then(() => {
                this.updateTreeGridSelection();
            });
        } else {
            this.selectedProducts = childProducts;
        }
    }
    
    buildChildToParentMap() {
        const childToParentMap = new Map();
        
        if (!this.treeData || !Array.isArray(this.treeData)) {
            return childToParentMap;
        }
        
        this.treeData.forEach(parent => {
            if (parent && parent._children && Array.isArray(parent._children)) {
                parent._children.forEach(child => {
                    if (child && child.productId) {
                        childToParentMap.set(child.productId, parent.productId);
                    }
                });
            }
        });
        
        return childToParentMap;
    }
    
    groupByParent(childIds, childToParentMap) {
        const grouped = new Map();
        
        childIds.forEach(childId => {
            const parentId = childToParentMap.get(childId);
            if (parentId) {
                if (!grouped.has(parentId)) {
                    grouped.set(parentId, []);
                }
                grouped.get(parentId).push(childId);
            }
        });
        
        return grouped;
    }
    
    hasMultipleChildrenFromSameParent(childProducts) {
        if (!childProducts || childProducts.length <= 1) {
            return false;
        }
        
        const childToParentMap = this.buildChildToParentMap();
        if (childToParentMap.size === 0) {
            return false;
        }
        
        const childIds = childProducts.map(child => child.productId || child.id).filter(id => id);
        const groupedByParent = this.groupByParent(childIds, childToParentMap);
        
        for (const children of groupedByParent.values()) {
            if (children.length > 1) {
                return true;
            }
        }
        
        return false;
    }
    
    updateTreeGridSelection() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        requestAnimationFrame(() => {
            const treeGrid = this.template.querySelector('lightning-tree-grid');
            if (treeGrid && this.selectedProductIds) {
                try {
                    treeGrid.selectedRows = [...this.selectedProductIds];
                } catch (error) {
                    console.warn('Could not update tree-grid selection programmatically:', error);
                }
            }
        });
    }

    async handleAddSelectedProducts() {
        if (!this.selectedProducts || !Array.isArray(this.selectedProducts) || this.selectedProducts.length === 0) {
            this.showToast('Warning', 'Please select at least one child product to add', 'warning');
            return;
        }

        this.isAddingProducts = true;
        this.showSuccessMessage = false;
        
        try {
            const qtyMap = {};
            
            this.selectedProducts.forEach(product => {
                const productId = product.productId || product.id;
                if (productId) {
                    qtyMap[productId] = 1;
                }
            });

            if (Object.keys(qtyMap).length === 0) {
                this.showToast('Warning', 'No valid products selected', 'warning');
                this.isAddingProducts = false;
                return;
            }

            const request = {
                orderId: this.recordId,
                productIdToQuantity: qtyMap
            };
            
            await addProductsToOrderWithQuantities({request : request});
            
            this.showSuccessMessage = true;
            this.showToast('Success', `${this.selectedProducts.length} product(s) added/updated successfully`, 'success');
            this.handleCloseProductTable();
            
            try {
                if (this.wiredProductsResult) {
                    await refreshApex(this.wiredProductsResult);
                }
            } catch (refreshError) {
                console.error('Error refreshing data:', refreshError);
            }
            
            this.dispatchEvent(new CustomEvent('productadded', {
                detail: { 
                    productIds: this.selectedProducts.map(p => p.productId || p.id),
                    quantity: 1,
                    count: this.selectedProducts.length
                }
            }));
            
            setTimeout(() => {
                this.showSuccessMessage = false;
            }, 3000);
            
        } catch (error) {
            this.showToast('Error', 'Failed to add products to order: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isAddingProducts = false;
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
        try {
            if (this.wiredProductsResult) {
                await refreshApex(this.wiredProductsResult);
            }
        } catch (error) {
            console.error('Error refreshing data:', error);
            throw error;
        }
    }
}