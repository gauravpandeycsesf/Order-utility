/**
 * Central provider that encapsulates all data-access and persistence
 * behaviors required by the order management application.
 */
public virtual class ApplicationDependencyProvider {

    /**
     * Retrieves the specified order together with all related order items.
     *
     * @param orderId identifier of the order to load.
     * @return Order populated with child OrderItems or null when not found.
     */
    public virtual Order getOrderWithItems(Id orderId) {
        OrderSelector selector = new OrderSelector();
        return selector.getOrderWithItems(orderId);
    }

    /**
     * Returns the set of product ids that exist on the provided order.
     *
     * @param orderId identifier of the parent order.
     * @return Set of Product2 ids referenced by the order's OrderItems.
     */
    public virtual Set<Id> getProductIdsInOrder(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getProductIdsInOrder(orderId);
    }

    /**
     * Builds a mapping of product id to quantity for the given order.
     *
     * @param orderId identifier of the order to inspect.
     * @return Map where the key is Product2Id and the value is ordered quantity.
     */
    public virtual Map<Id, Decimal> getProductQuantitiesInOrder(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getProductQuantitiesInOrder(orderId);
    }

    /**
     * Searches for active products whose names match the provided text.
     *
     * @param productName name fragment used for filtering.
     * @param pricebookId pricebook that scopes the available products.
     * @return List of Product2 records that match the search criteria.
     */
    public virtual List<Product2> getProductsByName(String productName, Id pricebookId) {
        ProductSelector selector = new ProductSelector();
        return selector.getProductsByName(productName, pricebookId);
    }

    /**
     * Determines which products can be added to an order by excluding
     * those already referenced by existing order items.
     *
     * @param pricebookId pricebook that limits product availability.
     * @param orderItemProductIds product ids already present on the order.
     * @return List of Product2 records the user can add to the order.
     */
    public virtual List<Product2> getAvailableProductsForOrder(Id pricebookId, Set<Id> orderItemProductIds) {
        return ProductDomain.getAvailableProductsForOrder(pricebookId, orderItemProductIds);
    }

    /**
     * Retrieves the products that correspond to the provided order items.
     *
     * @param orderItemProductIds set of product ids that need details.
     * @return List of Product2 records associated with the ids.
     */
    public virtual List<Product2> getOrderProducts(Set<Id> orderItemProductIds) {
        ProductSelector selector = new ProductSelector();
        return selector.getOrderProducts(orderItemProductIds);
    }

    /**
     * Loads all OrderItem records that belong to the given order.
     *
     * @param orderId parent order id.
     * @return List of OrderItems sorted per selector defaults.
     */
    public virtual List<OrderItem> getOrderItemsByOrder(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsByOrder(orderId);
    }

    /**
     * Retrieves a subset of OrderItems for pagination scenarios.
     *
     * @param orderId parent order id.
     * @param offset number of rows to skip.
     * @param pageSize maximum rows to return.
     * @return List of OrderItems within the requested window.
     */
    public virtual List<OrderItem> getOrderItemsByOrderPaginated(Id orderId, Integer offset, Integer pageSize) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsByOrderPaginated(orderId, offset, pageSize);
    }

    /**
     * Counts how many OrderItems exist for the specified order.
     *
     * @param orderId parent order id.
     * @return Total number of OrderItems.
     */
    public virtual Integer getOrderItemsCount(Id orderId) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsCount(orderId);
    }

    /**
     * Fetches OrderItems by their ids.
     *
     * @param orderItemIds list of OrderItem ids to retrieve.
     * @return List of matching OrderItems.
     */
    public virtual List<OrderItem> getOrderItemsByIds(List<Id> orderItemIds) {
        OrderItemSelector selector = new OrderItemSelector();
        return selector.getOrderItemsByIds(orderItemIds);
    }

    /**
     * Queries any existing OrderItems for an order that match the supplied products.
     *
     * @param orderId parent order id.
     * @param productIds set of product ids to filter on.
     * @return List of existing OrderItems matching the products.
     */
    public virtual List<OrderItem> queryExistingOrderItems(Id orderId, Set<Id> productIds) {
        return [
            SELECT Id, OrderId, Product2Id, Quantity, UnitPrice, PricebookEntryId
            FROM OrderItem
            WHERE OrderId = :orderId AND Product2Id IN :productIds
        ];
    }

    /**
     * Builds a map of product id to active PricebookEntry for the provided ids.
     *
     * @param pricebookId pricebook that scopes the entries.
     * @param productIds products whose pricebook entries should be loaded.
     * @return Map keyed by Product2Id with the corresponding PricebookEntry.
     */
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

    /**
     * Inserts the supplied OrderItems in a single DML operation.
     *
     * @param itemsToInsert order items to persist.
     */
    public virtual void insertOrderItems(List<OrderItem> itemsToInsert) {
        insert itemsToInsert;
    }

    /**
     * Updates OrderItems in a single DML statement.
     *
     * @param itemsToUpdate order items to persist.
     */
    public virtual void updateOrderItems(List<OrderItem> itemsToUpdate) {
        update itemsToUpdate;
    }

    /**
     * Deletes order items identified by the provided ids.
     *
     * @param orderItemIds ids of OrderItems to delete.
     */
    public virtual void deleteOrderItems(List<Id> orderItemIds) {
        if (orderItemIds != null && !orderItemIds.isEmpty()) {
            delete [SELECT Id FROM OrderItem WHERE Id IN :orderItemIds];
        }
    }

    /**
     * Persists updates to the supplied Order record.
     *
     * @param orderToUpdate order instance with modifications.
     */
    public virtual void updateOrder(Order orderToUpdate) {
        update orderToUpdate;
    }

    /**
     * Inserts a new Order and returns the same instance with the id populated.
     *
     * @param orderToInsert order to create.
     * @return Order that was inserted.
     */
    public virtual Order insertOrder(Order orderToInsert) {
        insert orderToInsert;
        return orderToInsert;
    }

    /**
     * Retrieves all OrderItems for the given order. Used when order activation
     * needs the full collection of related line items in memory.
     *
     * @param orderId parent order id.
     * @return List of OrderItems for the order.
     */
    public virtual List<OrderItem> getOrderItemsForOrder(Id orderId) {
        return [
            SELECT Id, OrderId, Product2Id, Quantity, UnitPrice
            FROM OrderItem
            WHERE OrderId = :orderId
        ];
    }

    /**
     * Sets the order status to Activated when it is not already activated.
     *
     * @param orderId identifier of the order to activate.
     */
    public virtual void activateOrder(Id orderId) {
        Order order = getOrderWithItems(orderId);
        
        if (order != null && order.Status != 'Activated') {
            order.Status = 'Activated';
            updateOrder(order);
        }
    }
}