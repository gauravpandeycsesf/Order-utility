public with sharing class OrderSelector extends SObjectSelector {
    
    public override Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }
    
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
    
    public Order getOrderWithItems(Id orderId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', (SELECT Id, Product2Id, Product2.Name, Quantity, UnitPrice, TotalPrice FROM OrderItems)' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id = :orderId';
        
        List<Order> orders = Database.query(query);
        return orders.isEmpty() ? null : orders[0];
    }
    
    public List<Order> getOrdersByAccount(Id accountId) {
        return selectSObjectsWhere('AccountId = :accountId', 'CreatedDate DESC');
    }
    
    public List<Order> getOrdersByStatus(String status) {
        return selectSObjectsWhere('Status = :status', 'CreatedDate DESC');
    }
}