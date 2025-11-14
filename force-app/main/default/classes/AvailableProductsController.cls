/**
 * Aura controller that surfaces product availability and supports adding products to orders.
 */
public with sharing class AvailableProductsController {

    /**
     * Provides access to shared dependencies for controller logic.
     *
     * @return ApplicationDependencyProvider instance from the dependency context.
     */
    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    /**
     * Returns the product tree that matches the supplied filter criteria.
     *
     * @param request container with order, pricebook, and search parameters.
     * @return List of nodes representing available products.
     */
    @AuraEnabled(cacheable=true)
    public static List<ProductTreeNode> getAvailableProducts(AvailableProductsRequest request) {
        try {
            return OrderManagementService.getAvailableProducts(request);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving available products: ' + e.getMessage());
        }
    }
    
    /**
     * Adds or updates products on an order using the provided quantity map.
     *
     * @param request contains order id, optional pricebook id, and quantities keyed by product.
     * @return summary message indicating how many records were processed.
     */
    @AuraEnabled
    public static String addProductsToOrderWithQuantities(AddProductsRequest request) {
        try {
            if (request == null) {
                throw new AuraHandledException('Request is required');
            }
            
            if (request.orderId == null) {
                throw new AuraHandledException('Order ID is required');
            }
            
            if (request.productIdToQuantity == null) {
                throw new AuraHandledException('Product ID to Quantity map is required');
            }
            
            Map<Id, Decimal> productIdToQuantity = deserializeProductQuantityMap(request.productIdToQuantity);
            
            List<OrderItem> items;
            
            if (request.pricebookId != null) {
                items = OrderManagementService.addProductsToOrderWithQuantities(
                    request.orderId, 
                    request.pricebookId, 
                    productIdToQuantity
                );
            } else {
                Order order = dependencies().getOrderWithItems(request.orderId);
                if (order == null || order.Pricebook2Id == null) {
                    throw new AuraHandledException('Order not found or no pricebook assigned');
                }
                
                items = OrderManagementService.addProductsToOrderWithQuantities(
                    request.orderId, 
                    order.Pricebook2Id, 
                    productIdToQuantity
                );
            }
            
            return String.valueOf(items.size()) + ' product(s) added/updated successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error adding products to order: ' + e.getMessage());
        }
    }
    
    /**
     * Converts user-provided maps into a strongly typed Id to Decimal map for quantities.
     *
     * @param productIdToQuantityObj map coming from Lightning or REST payloads.
     * @return Map with Id keys and Decimal quantities.
     */
    private static Map<Id, Decimal> deserializeProductQuantityMap(Object productIdToQuantityObj) {
        if (productIdToQuantityObj == null) {
            return new Map<Id, Decimal>();
        }
        
        if (productIdToQuantityObj instanceof Map<Id, Decimal>) {
            return (Map<Id, Decimal>) productIdToQuantityObj;
        }
        
        if (productIdToQuantityObj instanceof Map<Object, Object>) {
            Map<Object, Object> genericMap = (Map<Object, Object>) productIdToQuantityObj;
            Map<Id, Decimal> result = new Map<Id, Decimal>();
            
            for (Object key : genericMap.keySet()) {
                try {
                    Id productId = Id.valueOf(String.valueOf(key));
                    Object qtyObj = genericMap.get(key);
                    Decimal quantity = convertToDecimal(qtyObj);
                    result.put(productId, quantity);
                } catch (Exception e) {
                    continue;
                }
            }
            
            return result;
        }
        
        if (productIdToQuantityObj instanceof Map<String, Object>) {
            return convertStringMapToProductQuantityMap((Map<String, Object>) productIdToQuantityObj);
        }
        
        throw new AuraHandledException('Invalid productIdToQuantity format. Expected Map<Object, Object>, Map<String, Object>, or Map<Id, Decimal>');
    }
    
    /**
     * Converts a string-keyed map into the strongly typed product quantity map.
     *
     * @param stringMap map whose keys are string versions of product ids.
     * @return Map<Id, Decimal> suitable for downstream processing.
     */
    private static Map<Id, Decimal> convertStringMapToProductQuantityMap(Map<String, Object> stringMap) {
        Map<Id, Decimal> result = new Map<Id, Decimal>();
        
        for (String key : stringMap.keySet()) {
            try {
                Id productId = Id.valueOf(key);
                Object qtyObj = stringMap.get(key);
                Decimal quantity = convertToDecimal(qtyObj);
                result.put(productId, quantity);
            } catch (Exception e) {
                continue;
            }
        }
        
        return result;
    }
    
    /**
     * Attempts to convert any supported object type into a Decimal quantity.
     *
     * @param qtyObj raw quantity supplied by client-side code.
     * @return Decimal representation of the value.
     */
    private static Decimal convertToDecimal(Object qtyObj) {
        if (qtyObj instanceof Decimal) {
            return (Decimal) qtyObj;
        } else if (qtyObj instanceof Integer) {
            return Decimal.valueOf((Integer) qtyObj);
        } else if (qtyObj instanceof Double) {
            return Decimal.valueOf((Double) qtyObj);
        } else if (qtyObj instanceof String) {
            return Decimal.valueOf((String) qtyObj);
        } else {
            return Decimal.valueOf(String.valueOf(qtyObj));
        }
    }
    
    /**
     * Request DTO for retrieving available products.
     */
    public class AvailableProductsRequest {
        @AuraEnabled public Id orderId { get; set; }
        @AuraEnabled public Id pricebookId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String parentName { get; set; }
    }
    
    /**
     * Request DTO for adding products with explicit quantities to an order.
     */
    public class AddProductsRequest {
        @AuraEnabled public Id orderId { get; set; }
        @AuraEnabled public Object productIdToQuantity { get; set; }
        @AuraEnabled public Id pricebookId { get; set; }
    }
    
    /**
     * Represents a product tree node returned to the UI.
     */
    public class ProductTreeNode {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public Decimal listPrice { get; set; }
        @AuraEnabled public Boolean isInOrder { get; set; }
        @AuraEnabled public Decimal quantityInOrder { get; set; }
        @AuraEnabled public Boolean expanded { get; set; }
        @AuraEnabled public String metatext { get; set; }
        @AuraEnabled public List<ProductTreeNode> items { get; set; }
    }
    
}