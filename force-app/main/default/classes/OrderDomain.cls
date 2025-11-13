public with sharing class OrderDomain extends SObjectDomain {
    
    public OrderDomain(List<Order> records) {
        super(records);
    }
    
    public OrderDomain(List<Order> records, ISObjectUnitOfWork uow) {
        super(records, uow);
    }
    
    public override void onBeforeInsert() {
        setDefaultValues();
        validateOrders();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateOrders();
    }
    
    private void validateOrders() {
        for (Order order : (List<Order>) Records) {
            if (order.AccountId == null) {
                order.addError('Account is required');
            }
        }
    }
    
    private void setDefaultValues() {
        for (Order order : (List<Order>) Records) {
            if (String.isBlank(order.Status)) {
                order.Status = 'Draft';
            }
            if (order.EffectiveDate == null) {
                order.EffectiveDate = Date.today();
            }
        }
    }
    
}