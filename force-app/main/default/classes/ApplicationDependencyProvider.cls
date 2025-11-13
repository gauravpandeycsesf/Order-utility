public virtual class ApplicationDependencyProvider {

    public virtual Order getOrderWithItems(Id orderId) {
        OrderSelector selector = new OrderSelector();
        return selector.getOrderWithItems(orderId);
    }

    public virtual Set<Id> getProductIdsInOrder(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getProductIdsInOrder(orderId);
    }

    public virtual Map<Id, Decimal> getProductQuantitiesInOrder(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getProductQuantitiesInOrder(orderId);
    }

    public virtual List<Product2> getProductsByName(String productName, Id pricebookId) {
        ProductSelector selector = new ProductSelector();
        return selector.getProductsByName(productName, pricebookId);
    }

    public virtual List<Product2> getAvailableProductsForOrder(Id pricebookId, Set<Id> orderItemProductIds) {
        return ProductDomain.getAvailableProductsForOrder(pricebookId, orderItemProductIds);
    }

    public virtual List<Product2> getOrderProducts(Set<Id> orderItemProductIds) {
        ProductSelector selector = new ProductSelector();
        return selector.getOrderProducts(orderItemProductIds);
    }

    public virtual List<OrderItem> getOrderItemsByOrder(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsByOrder(orderId);
    }

    public virtual List<OrderItem> getOrderItemsByOrderPaginated(Id orderId, Integer offset, Integer pageSize) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsByOrderPaginated(orderId, offset, pageSize);
    }

    public virtual Integer getOrderItemsCount(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsCount(orderId);
    }

    public virtual List<OrderItem> getOrderItemsByIds(List<Id> orderItemIds) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsByIds(orderItemIds);
    }

    public virtual List<OrderItem> queryExistingOrderItems(Id orderId, Set<Id> productIds) {
        return [
            SELECT Id, OrderId, Product2Id, Quantity, UnitPrice, PricebookEntryId
            FROM OrderItem
            WHERE OrderId = :orderId AND Product2Id IN :productIds
        ];
    }

    public virtual Map<Id, PricebookEntry> queryActivePricebookEntries(Id pricebookId, Set<Id> productIds) {
        Map<Id, PricebookEntry> productIdToPbe = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [
            SELECT Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId AND Product2Id IN :productIds AND IsActive = true
        ]) {
            productIdToPbe.put(pbe.Product2Id, pbe);
        }
        return productIdToPbe;
    }

    public virtual void insertOrderItems(List<OrderItem> itemsToInsert) {
        insert itemsToInsert;
    }

    public virtual void updateOrderItems(List<OrderItem> itemsToUpdate) {
        update itemsToUpdate;
    }

    public virtual void deleteOrderItems(List<Id> orderItemIds) {
        if (orderItemIds != null && !orderItemIds.isEmpty()) {
            delete [SELECT Id FROM OrderItem WHERE Id IN :orderItemIds];
        }
    }

    public virtual void updateOrder(Order orderToUpdate) {
        update orderToUpdate;
    }

    public virtual Order insertOrder(Order orderToInsert) {
        insert orderToInsert;
        return orderToInsert;
    }

    public virtual List<OrderItem> getOrderItemsForOrder(Id orderId) {
        return [
            SELECT Id, OrderId, Product2Id, Quantity, UnitPrice
            FROM OrderItem
            WHERE OrderId = :orderId
        ];
    }

    public virtual void activateOrder(Id orderId) {
        Order order = getOrderWithItems(orderId);
        
        if (order != null && order.Status != 'Activated') {
            order.Status = 'Activated';
            updateOrder(order);
        }
    }
}