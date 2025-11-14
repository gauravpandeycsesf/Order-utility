/**
 * Selector that centralizes SOQL used to retrieve order item data.
 */
public with sharing class OrderItemSelector extends SObjectSelector {
    
    /**
     * Identifies the SObject type handled by the selector.
     *
     * @return Schema.SObjectType for OrderItem.
     */
    public override Schema.SObjectType getSObjectType() {
        return OrderItem.SObjectType;
    }
    
    /**
     * Lists the fields that should be queried when retrieving order items.
     *
     * @return ordered list of fields used in SOQL statements.
     */
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
    
    /**
     * Retrieves all order items for a given order, including related product names.
     *
     * @param orderId order whose items should be returned.
     * @return list of OrderItem records.
     */
    public List<OrderItem> getOrderItemsByOrder(Id orderId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', Product2.Name' +
                      ', Product2.Parent_Product__r.Name' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE OrderId = :orderId' +
                      ' ORDER BY Product2.Name';
        
        return Database.query(query);
    }
    
    /**
     * Retrieves the order item for a specific product within an order.
     *
     * @param orderId order identifier.
     * @param productId product identifier.
     * @return matching OrderItem or null if none exists.
     */
    public OrderItem getOrderItemByOrderAndProduct(Id orderId, Id productId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', Product2.Name' +
                      ', Product2.Parent_Product__r.Name' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE OrderId = :orderId AND Product2Id = :productId';
        
        List<OrderItem> orderItems = Database.query(query);
        return orderItems.isEmpty() ? null : orderItems[0];
    }
    
    /**
     * Loads order items by their ids while guarding against null or empty input.
     *
     * @param orderItemIds collection of order item ids.
     * @return list of OrderItems for the ids.
     */
    public List<OrderItem> getOrderItemsByIds(List<Id> orderItemIds) {
        if (orderItemIds == null || orderItemIds.isEmpty()) {
            return new List<OrderItem>();
        }
        
        Set<Id> idSet = new Set<Id>(orderItemIds);
        List<SObject> records = selectSObjectsById(idSet);
        return (List<OrderItem>) records;
    }
    
    /**
     * Aggregates the set of product ids present on an order.
     *
     * @param orderId order identifier.
     * @return set of Product2 ids.
     */
    public Set<Id> getProductIdsInOrder(Id orderId) {
        List<OrderItem> orderItems = getOrderItemsByOrder(orderId);
        Set<Id> productIds = new Set<Id>();
        
        for (OrderItem item : orderItems) {
            productIds.add(item.Product2Id);
        }
        
        return productIds;
    }
    
    /**
     * Builds a map of product id to total quantity for the specified order.
     *
     * @param orderId order identifier.
     * @return Map<Product2Id, Decimal quantity>.
     */
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
    
    /**
     * Retrieves order items for an order with pagination support.
     *
     * @param orderId order identifier.
     * @param offset number of rows to skip.
     * @param pageSize number of rows to return.
     * @return list of paginated OrderItems.
     */
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
    
    /**
     * Counts how many order items belong to the specified order.
     *
     * @param orderId order identifier.
     * @return total number of OrderItems.
     */
    public Integer getOrderItemsCount(Id orderId) {
        return Database.countQuery('SELECT COUNT() FROM ' + getSObjectName() + ' WHERE OrderId = :orderId');
    }
}