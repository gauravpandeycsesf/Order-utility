public with sharing class OrderProductsController {

    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
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
    
    @AuraEnabled(cacheable=true)
    public static Boolean canActivateOrder(Id orderId) {
        try {
            return OrderManagementService.canActivateOrder(orderId);
        } catch (Exception e) {
            throw new AuraHandledException('Error checking order activation status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String activateOrder(Id orderId) {
        try {
            OrderManagementService.activateOrder(orderId);
            return 'Order activated successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error activating order: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getOrderStatus(Id orderId) {
        try {
            Order order = dependencies().getOrderWithItems(orderId);
            return order != null ? order.Status : null;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateOrderItemQuantities(Map<Id, Decimal> orderItemUpdates) {
        try {
            OrderManagementService.updateOrderItemQuantities(orderItemUpdates);
            return 'Quantities updated successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating order item quantities: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String deleteOrderItems(List<Id> orderItemIds) {
        try {
            OrderManagementService.deleteOrderItems(orderItemIds);
            return 'Order items deleted successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting order items: ' + e.getMessage());
        }
    }
    
    public class OrderItemWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String parentProductName { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal totalPrice { get; set; }
        @AuraEnabled public String description { get; set; }
        
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
    
    public class PaginatedOrderItemsResult {
        @AuraEnabled public List<OrderItemWrapper> items { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public Boolean hasMore { get; set; }
    }
}