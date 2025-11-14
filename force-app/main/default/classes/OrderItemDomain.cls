/**
 * Domain logic that validates order item records before persistence.
 */
public with sharing class OrderItemDomain extends SObjectDomain {
    
    /**
     * Creates a domain instance for the supplied order items.
     *
     * @param records order items to manage.
     */
    public OrderItemDomain(List<OrderItem> records) {
        super(records);
    }
    
    /**
     * Creates a domain instance backed by a unit of work for coordinated commits.
     *
     * @param records order items to manage.
     * @param uow unit of work coordinating DML.
     */
    public OrderItemDomain(List<OrderItem> records, ISObjectUnitOfWork uow) {
        super(records, uow);
    }
    
    /**
     * Validates order items prior to insert.
     */
    public override void onBeforeInsert() {
        validateOrderItems();
    }
    
    /**
     * Validates order items prior to update.
     *
     * @param existingRecords map of existing order items.
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateOrderItems();
    }
    
    /**
     * Applies business validations for required fields, quantities, and pricing.
     */
    private void validateOrderItems() {
        for (OrderItem item : (List<OrderItem>) Records) {
            if (item.OrderId == null) {
                item.addError('Order is required');
            }
            if (item.Product2Id == null) {
                item.addError('Product is required');
            }
            if (item.Quantity == null || item.Quantity <= 0) {
                item.addError('Quantity must be greater than 0');
            }
            if (item.UnitPrice == null || item.UnitPrice < 0) {
                item.addError('Unit Price must be greater than or equal to 0');
            }
        }
    }
}