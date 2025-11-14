/**
 * Domain layer responsible for enforcing order defaulting and validation rules.
 */
public with sharing class OrderDomain extends SObjectDomain {
    
    /**
     * Initializes the domain with the provided order records.
     *
     * @param records order instances to manage.
     */
    public OrderDomain(List<Order> records) {
        super(records);
    }
    
    /**
     * Initializes the domain with a unit of work to support coordinated persistence.
     *
     * @param records order instances to manage.
     * @param uow unit of work used for DML coordination.
     */
    public OrderDomain(List<Order> records, ISObjectUnitOfWork uow) {
        super(records, uow);
    }
    
    /**
     * Applies defaults and validation before insert operations.
     */
    public override void onBeforeInsert() {
        setDefaultValues();
        validateOrders();
    }
    
    /**
     * Runs validation prior to update operations to ensure required data remains present.
     *
     * @param existingRecords map of existing orders keyed by id.
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateOrders();
    }
    
    /**
     * Ensures each order references an account before DML.
     */
    private void validateOrders() {
        for (Order order : (List<Order>) Records) {
            if (order.AccountId == null) {
                order.addError('Account is required');
            }
        }
    }
    
    /**
     * Populates default field values for status and effective date when missing.
     */
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