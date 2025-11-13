public with sharing class AvailableProductsController {

    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProductTreeNode> getAvailableProducts(AvailableProductsRequest request) {
        try {
            return OrderManagementService.getAvailableProducts(request);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving available products: ' + e.getMessage());
        }
    }
    
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
    
    public class AvailableProductsRequest {
        @AuraEnabled public Id orderId { get; set; }
        @AuraEnabled public Id pricebookId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String parentName { get; set; }
    }
    
    public class AddProductsRequest {
        @AuraEnabled public Id orderId { get; set; }
        @AuraEnabled public Object productIdToQuantity { get; set; }
        @AuraEnabled public Id pricebookId { get; set; }
    }
    
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