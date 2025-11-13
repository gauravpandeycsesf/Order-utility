public with sharing class OrderItemSelector extends SObjectSelector {
    
    public override Schema.SObjectType getSObjectType() {
        return OrderItem.SObjectType;
    }
    
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OrderItem.Id,
            OrderItem.OrderId,
            OrderItem.Product2Id,
            OrderItem.Quantity,
            OrderItem.UnitPrice,
            OrderItem.TotalPrice,
            OrderItem.ListPrice,
            OrderItem.Description
        };
    }
    
    public List<OrderItem> getOrderItemsByOrder(Id orderId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', Product2.Name' +
                      ', Product2.Parent_Product__r.Name' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE OrderId = :orderId' +
                      ' ORDER BY Product2.Name';
        
        return Database.query(query);
    }
    
    public OrderItem getOrderItemByOrderAndProduct(Id orderId, Id productId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', Product2.Name' +
                      ', Product2.Parent_Product__r.Name' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE OrderId = :orderId AND Product2Id = :productId';
        
        List<OrderItem> orderItems = Database.query(query);
        return orderItems.isEmpty() ? null : orderItems[0];
    }
    
    public List<OrderItem> getOrderItemsByIds(List<Id> orderItemIds) {
        if (orderItemIds == null || orderItemIds.isEmpty()) {
            return new List<OrderItem>();
        }
        
        Set<Id> idSet = new Set<Id>(orderItemIds);
        List<SObject> records = selectSObjectsById(idSet);
        return (List<OrderItem>) records;
    }
    
    public Set<Id> getProductIdsInOrder(Id orderId) {
        List<OrderItem> orderItems = getOrderItemsByOrder(orderId);
        Set<Id> productIds = new Set<Id>();
        
        for (OrderItem item : orderItems) {
            productIds.add(item.Product2Id);
        }
        
        return productIds;
    }
    
    public Map<Id, Decimal> getProductQuantitiesInOrder(Id orderId) {
        List<OrderItem> orderItems = getOrderItemsByOrder(orderId);
        Map<Id, Decimal> productQuantities = new Map<Id, Decimal>();
        
        for (OrderItem item : orderItems) {
            if (productQuantities.containsKey(item.Product2Id)) {
                productQuantities.put(item.Product2Id, productQuantities.get(item.Product2Id) + item.Quantity);
            } else {
                productQuantities.put(item.Product2Id, item.Quantity);
            }
        }
        
        return productQuantities;
    }
    
    public List<OrderItem> getOrderItemsByOrderPaginated(Id orderId, Integer offset, Integer pageSize) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', Product2.Name' +
                      ', Product2.Parent_Product__r.Name' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE OrderId = :orderId' +
                      ' ORDER BY Product2.Name' +
                      ' LIMIT :pageSize' +
                      ' OFFSET :offset';
        
        return Database.query(query);
    }
    
    public Integer getOrderItemsCount(Id orderId) {
        return Database.countQuery('SELECT COUNT() FROM ' + getSObjectName() + ' WHERE OrderId = :orderId');
    }
}