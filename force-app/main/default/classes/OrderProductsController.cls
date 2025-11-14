/**
 * Aura controller that exposes order item operations to the LWC layer.
 */
public with sharing class OrderProductsController {

    /**
     * Provides convenient access to shared dependencies.
     *
     * @return dependency provider instance.
     */
    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    /**
     * Returns all order items for an order, wrapped for UI consumption.
     *
     * @param orderId order identifier.
     * @return list of OrderItemWrapper rows.
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderItemWrapper> getOrderItems(Id orderId) {
        try {
            List<OrderItemWrapper> orderItems = new List<OrderItemWrapper>();
            List<OrderItem> items = OrderManagementService.getOrderItemsForDisplay(orderId);
            
            for (OrderItem item : items) {
                orderItems.add(new OrderItemWrapper(item));
            }
            
            return orderItems;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order items: ' + e.getMessage());
        }
    }
    
    /**
     * Returns a page of order items plus pagination metadata.
     *
     * @param orderId order identifier.
     * @param offset starting row offset.
     * @param pageSize rows per page.
     * @param cacheBuster unused value that forces cache refresh.
     * @return wrapper containing page data.
     */
    @AuraEnabled(cacheable=true)
    public static PaginatedOrderItemsResult getOrderItemsPaginated(Id orderId, Integer offset, Integer pageSize, Long cacheBuster) {
        try {
            PaginatedOrderItemsResult result = new PaginatedOrderItemsResult();
            List<OrderItem> items = OrderManagementService.getOrderItemsForDisplayPaginated(orderId, offset, pageSize);
            Integer totalCount = OrderManagementService.getOrderItemsCount(orderId);
            
            List<OrderItemWrapper> orderItems = new List<OrderItemWrapper>();
            for (OrderItem item : items) {
                orderItems.add(new OrderItemWrapper(item));
            }
            
            result.items = orderItems;
            result.totalCount = totalCount;
            result.hasMore = (offset + items.size()) < totalCount;
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order items: ' + e.getMessage());
        }
    }
    
    /**
     * Indicates whether the specified order can be activated.
     *
     * @param orderId order identifier.
     * @return true when activation criteria are met.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean canActivateOrder(Id orderId) {
        try {
            return OrderManagementService.canActivateOrder(orderId);
        } catch (Exception e) {
            throw new AuraHandledException('Error checking order activation status: ' + e.getMessage());
        }
    }
    
    /**
     * Activates the selected order.
     *
     * @param orderId order identifier.
     * @return success message for UI display.
     */
    @AuraEnabled
    public static String activateOrder(Id orderId) {
        try {
            OrderManagementService.activateOrder(orderId);
            return 'Order activated successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error activating order: ' + e.getMessage());
        }
    }
    
    /**
     * Retrieves the current status of an order.
     *
     * @param orderId order identifier.
     * @return status picklist value or null.
     */
    @AuraEnabled(cacheable=true)
    public static String getOrderStatus(Id orderId) {
        try {
            Order order = dependencies().getOrderWithItems(orderId);
            return order != null ? order.Status : null;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order status: ' + e.getMessage());
        }
    }
    
    /**
     * Updates line item quantities in bulk.
     *
     * @param orderItemUpdates map of order item ids to new quantities.
     * @return success message once updates complete.
     */
    @AuraEnabled
    public static String updateOrderItemQuantities(Map<Id, Decimal> orderItemUpdates) {
        try {
            OrderManagementService.updateOrderItemQuantities(orderItemUpdates);
            return 'Quantities updated successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating order item quantities: ' + e.getMessage());
        }
    }
    
    /**
     * Deletes the specified order items.
     *
     * @param orderItemIds ids of items to remove.
     * @return success message once deletion completes.
     */
    @AuraEnabled
    public static String deleteOrderItems(List<Id> orderItemIds) {
        try {
            OrderManagementService.deleteOrderItems(orderItemIds);
            return 'Order items deleted successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting order items: ' + e.getMessage());
        }
    }
    
    /**
     * Lightweight DTO that surfaces order item fields to Lightning components.
     */
    public class OrderItemWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String parentProductName { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal totalPrice { get; set; }
        @AuraEnabled public String description { get; set; }
        
        /**
         * Creates the wrapper from an OrderItem record.
         *
         * @param item order item supplying values.
         */
        public OrderItemWrapper(OrderItem item) {
            this.id = item.Id;
            this.productName = item.Product2.Name;
            this.parentProductName = item.Product2.Parent_Product__r != null ? item.Product2.Parent_Product__r.Name : null;
            this.unitPrice = item.UnitPrice;
            this.quantity = item.Quantity;
            this.totalPrice = item.TotalPrice;
            this.description = item.Description;
        }
    }
    
    /**
     * Response wrapper returned by paginated queries.
     */
    public class PaginatedOrderItemsResult {
        @AuraEnabled public List<OrderItemWrapper> items { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public Boolean hasMore { get; set; }
    }
}