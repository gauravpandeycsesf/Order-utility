/**
 * Selector that encapsulates reusable queries for Order records.
 */
public with sharing class OrderSelector extends SObjectSelector {
    
    /**
     * Identifies the SObject type handled by this selector.
     *
     * @return Schema.SObjectType for Order.
     */
    public override Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }
    
    /**
     * Lists the fields that should be queried whenever orders are retrieved.
     *
     * @return list of Order fields.
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Order.Id,
            Order.OrderNumber,
            Order.AccountId,
            Order.EffectiveDate,
            Order.Status,
            Order.Type,
            Order.Pricebook2Id,
            Order.TotalAmount,
            Order.CreatedDate,
            Order.LastModifiedDate
        };
    }
    
    /**
     * Retrieves an order by id along with its related order items.
     *
     * @param orderId identifier of the order.
     * @return Order populated with child OrderItems or null.
     */
    public Order getOrderWithItems(Id orderId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', (SELECT Id, Product2Id, Product2.Name, Quantity, UnitPrice, TotalPrice FROM OrderItems)' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id = :orderId';
        
        List<Order> orders = Database.query(query);
        return orders.isEmpty() ? null : orders[0];
    }
}