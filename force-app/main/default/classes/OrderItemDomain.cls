public with sharing class OrderItemDomain extends SObjectDomain {
    
    public OrderItemDomain(List<OrderItem> records) {
        super(records);
    }
    
    public OrderItemDomain(List<OrderItem> records, ISObjectUnitOfWork uow) {
        super(records, uow);
    }
    
    public override void onBeforeInsert() {
        validateOrderItems();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateOrderItems();
    }
    
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