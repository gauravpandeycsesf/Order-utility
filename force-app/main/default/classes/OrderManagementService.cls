public with sharing class OrderManagementService {
    
    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    public static List<Product2> getAvailableProductsForOrder(Id orderId) {
        Order order = dependencies().getOrderWithItems(orderId);
        if (order == null || order.Pricebook2Id == null) {
            return new List<Product2>();
        }
        
        Set<Id> orderItemProductIds = dependencies().getProductIdsInOrder(orderId);
        return dependencies().getAvailableProductsForOrder(order.Pricebook2Id, orderItemProductIds);
    }
    
    public static List<Product2> getOrderProducts(Id orderId) {
        Set<Id> orderItemProductIds = dependencies().getProductIdsInOrder(orderId);
        if (orderItemProductIds.isEmpty()) {
            return new List<Product2>();
        }
        
        return dependencies().getOrderProducts(orderItemProductIds);
    }
    
    public static List<OrderItem> getOrderItemsForDisplay(Id orderId) {
        return dependencies().getOrderItemsByOrder(orderId);
    }
    
    public static List<OrderItem> getOrderItemsForDisplayPaginated(Id orderId, Integer offset, Integer pageSize) {
        return dependencies().getOrderItemsByOrderPaginated(orderId, offset, pageSize);
    }
    
    public static Integer getOrderItemsCount(Id orderId) {
        return dependencies().getOrderItemsCount(orderId);
    }
    
    public static List<OrderItem> addProductsToOrderWithQuantities(Id orderId, Map<Id, Decimal> productIdToQuantity) {
        Order order = dependencies().getOrderWithItems(orderId);
        if (order == null || order.Pricebook2Id == null) {
            throw new OrderManagementServiceException('Order not found or no pricebook assigned');
        }
        
        return addProductsToOrderWithQuantities(orderId, order.Pricebook2Id, productIdToQuantity);
    }
    
    public static List<OrderItem> addProductsToOrderWithQuantities(Id orderId, Id pricebookId, Map<Id, Decimal> productIdToQuantity) {
        if (productIdToQuantity == null || productIdToQuantity.isEmpty()) {
            return new List<OrderItem>();
        }

        if (pricebookId == null) {
            throw new OrderManagementServiceException('Pricebook ID is required');
        }

        Order order = dependencies().getOrderWithItems(orderId);
        if (order == null) {
            throw new OrderManagementServiceException('Order not found');
        }

        Set<Id> productIds = new Set<Id>(productIdToQuantity.keySet());
        List<OrderItem> existingItems = dependencies().queryExistingOrderItems(orderId, productIds);

        Map<Id, List<OrderItem>> productIdToExistingItems = new Map<Id, List<OrderItem>>();
        
        for (OrderItem item : existingItems) {
            if (!productIdToExistingItems.containsKey(item.Product2Id)) {
                productIdToExistingItems.put(item.Product2Id, new List<OrderItem>());
            }
            productIdToExistingItems.get(item.Product2Id).add(item);
        }

        Map<Id, PricebookEntry> productIdToPbe = dependencies().queryActivePricebookEntries(pricebookId, productIds);

        List<OrderItem> itemsToInsert = new List<OrderItem>();
        List<OrderItem> itemsToUpdate = new List<OrderItem>();

        for (Id productId : productIds) {
            Decimal qty = productIdToQuantity.get(productId);
            if (qty == null || qty <= 0) {
                continue;
            }
            PricebookEntry pbe = productIdToPbe.get(productId);
            if (pbe == null) {
                continue;
            }

            if (productIdToExistingItems.containsKey(productId)) {
                List<OrderItem> existingItemsForProduct = productIdToExistingItems.get(productId);
                
                if (existingItemsForProduct.size() > 0) {
                    OrderItem firstItem = existingItemsForProduct[0];
                    firstItem.Quantity += qty;
                    if (firstItem.PricebookEntryId == null) {
                        firstItem.PricebookEntryId = pbe.Id;
                    }
                    firstItem.UnitPrice = pbe.UnitPrice;
                    itemsToUpdate.add(firstItem);
                    
                    for (Integer i = 1; i < existingItemsForProduct.size(); i++) {
                        OrderItem item = existingItemsForProduct[i];
                        if (item.PricebookEntryId == null) {
                            item.PricebookEntryId = pbe.Id;
                        }
                        if (item.UnitPrice != pbe.UnitPrice) {
                            item.UnitPrice = pbe.UnitPrice;
                        }
                        itemsToUpdate.add(item);
                    }
                }
            } else {
                itemsToInsert.add(new OrderItem(
                    OrderId = orderId,
                    PricebookEntryId = pbe.Id,
                    Product2Id = productId,
                    Quantity = qty,
                    UnitPrice = pbe.UnitPrice
                ));
            }
        }

        if (!itemsToInsert.isEmpty()) {
            dependencies().insertOrderItems(itemsToInsert);
        }
        if (!itemsToUpdate.isEmpty()) {
            dependencies().updateOrderItems(itemsToUpdate);
        }

        List<OrderItem> resultItems = new List<OrderItem>();
        resultItems.addAll(itemsToInsert);
        resultItems.addAll(itemsToUpdate);
        return resultItems;
    }
    
    public static void activateOrder(Id orderId) {
        dependencies().activateOrder(orderId);
    }
    
    public static Boolean canActivateOrder(Id orderId) {
        Order order = dependencies().getOrderWithItems(orderId);
        if (order == null) {
            return false;
        }
        
        if (order.Status == 'Activated') {
            return false;
        }
        
        List<OrderItem> orderItems = dependencies().getOrderItemsByOrder(orderId);
        return !orderItems.isEmpty();
    }
    
    public static List<OrderItem> updateOrderItemQuantities(Map<Id, Decimal> orderItemUpdates) {
        if (orderItemUpdates == null || orderItemUpdates.isEmpty()) {
            return new List<OrderItem>();
        }
        
        List<OrderItem> itemsToUpdate = dependencies().getOrderItemsByIds(new List<Id>(orderItemUpdates.keySet()));
        
        if (itemsToUpdate.isEmpty()) {
            throw new OrderManagementServiceException('No order items found to update');
        }
        
        for (OrderItem item : itemsToUpdate) {
            Decimal newQuantity = orderItemUpdates.get(item.Id);
            if (newQuantity != null && newQuantity > 0) {
                item.Quantity = newQuantity;
            }
        }
        
        dependencies().updateOrderItems(itemsToUpdate);
        
        return itemsToUpdate;
    }
    
    public static void deleteOrderItems(List<Id> orderItemIds) {
        if (orderItemIds == null || orderItemIds.isEmpty()) {
            return;
        }
        
        List<OrderItem> itemsToDelete = dependencies().getOrderItemsByIds(orderItemIds);
        if (itemsToDelete.isEmpty()) {
            throw new OrderManagementServiceException('No order items found to delete');
        }
        
        dependencies().deleteOrderItems(orderItemIds);
    }
    
    public static List<AvailableProductsController.ProductTreeNode> getAvailableProducts(AvailableProductsController.AvailableProductsRequest request) {
        if (request == null) {
            throw new OrderManagementServiceException('Request parameter is required');
        }
        
        if (request.orderId == null && request.pricebookId == null) {
            throw new OrderManagementServiceException('Either orderId or pricebookId must be provided');
        }
        
        Id pricebookId;
        String productName = request.productName;
        Map<Id, Decimal> orderItemProductQuantities = new Map<Id, Decimal>();
        
        if (request.orderId != null) {
            Order order = dependencies().getOrderWithItems(request.orderId);
            if (order == null || order.Pricebook2Id == null) {
                throw new OrderManagementServiceException('Order not found or no pricebook assigned');
            }
            pricebookId = order.Pricebook2Id;
            orderItemProductQuantities = dependencies().getProductQuantitiesInOrder(request.orderId);
        } else if (request.pricebookId != null) {
            pricebookId = request.pricebookId;
        }
        
        List<Product2> allProducts = dependencies().getProductsByName(productName, pricebookId);
        
        Map<Id, ProductWrapper> productWrapperMap = new Map<Id, ProductWrapper>();
        Map<Id, List<ProductWrapper>> parentIdToChildren = new Map<Id, List<ProductWrapper>>();
        List<ProductWrapper> parentProducts = new List<ProductWrapper>();
        
        for (Product2 product : allProducts) {
            Decimal quantity = orderItemProductQuantities.containsKey(product.Id) 
                ? orderItemProductQuantities.get(product.Id) 
                : 0;
            
            ProductWrapper wrapper = new ProductWrapper(product, quantity > 0);
            wrapper.quantityInOrder = quantity;
            productWrapperMap.put(product.Id, wrapper);
            
            if (product.Parent_Product__c == null) {
                parentProducts.add(wrapper);
            }
        }
        
        for (Product2 product : allProducts) {
            if (product.Parent_Product__c != null) {
                ProductWrapper childWrapper = productWrapperMap.get(product.Id);
                Id parentId = product.Parent_Product__c;
                
                if (!parentIdToChildren.containsKey(parentId)) {
                    parentIdToChildren.put(parentId, new List<ProductWrapper>());
                }
                parentIdToChildren.get(parentId).add(childWrapper);
            }
        }
        
        String parentName = (request != null && request.parentName != null) ? request.parentName : null;
        if (String.isNotBlank(parentName)) {
            List<ProductWrapper> filteredParents = new List<ProductWrapper>();
            String searchTerm = parentName.trim();
            for (ProductWrapper parentWrapper : parentProducts) {
                if (parentWrapper.name != null && parentWrapper.name.containsIgnoreCase(searchTerm)) {
                    filteredParents.add(parentWrapper);
                }
            }
            parentProducts = filteredParents;
        }
        
        List<AvailableProductsController.ProductTreeNode> treeNodes = new List<AvailableProductsController.ProductTreeNode>();
        
        parentProducts.sort(new ProductWrapperComparator());
        
        for (ProductWrapper parentWrapper : parentProducts) {
            AvailableProductsController.ProductTreeNode parentNode = new AvailableProductsController.ProductTreeNode();
            parentNode.name = parentWrapper.name;
            parentNode.label = parentWrapper.name;
            parentNode.productId = parentWrapper.id;
            parentNode.productCode = parentWrapper.productCode;
            parentNode.description = parentWrapper.description;
            parentNode.listPrice = parentWrapper.listPrice;
            parentNode.isInOrder = parentWrapper.isInOrder;
            parentNode.quantityInOrder = parentWrapper.quantityInOrder;
            parentNode.metatext = parentWrapper.productCode;
            parentNode.expanded = false;
            parentNode.items = new List<AvailableProductsController.ProductTreeNode>();
            
            if (parentIdToChildren.containsKey(parentWrapper.id)) {
                List<ProductWrapper> children = parentIdToChildren.get(parentWrapper.id);
                children.sort(new ProductWrapperComparator());
                
                for (ProductWrapper childWrapper : children) {
                    AvailableProductsController.ProductTreeNode childNode = new AvailableProductsController.ProductTreeNode();
                    childNode.name = childWrapper.name;
                    childNode.label = childWrapper.name;
                    childNode.productId = childWrapper.id;
                    childNode.productCode = childWrapper.productCode;
                    childNode.description = childWrapper.description;
                    childNode.listPrice = childWrapper.listPrice;
                    childNode.isInOrder = childWrapper.isInOrder;
                    childNode.quantityInOrder = childWrapper.quantityInOrder;
                    childNode.metatext = childWrapper.productCode;
                    
                    parentNode.items.add(childNode);
                }
            }
            
            treeNodes.add(parentNode);
        }
        
        return treeNodes;
    }
    
    private class ProductWrapper {
        public Id id { get; set; }
        public String name { get; set; }
        public String productCode { get; set; }
        public Decimal listPrice { get; set; }
        public Boolean isInOrder { get; set; }
        public String description { get; set; }
        public Decimal quantityInOrder { get; set; }
        
        public ProductWrapper(Product2 product, Boolean isInOrder) {
            this.id = product.Id;
            this.name = product.Name;
            this.productCode = product.ProductCode;
            this.description = product.Description;
            this.isInOrder = isInOrder;
            this.quantityInOrder = 0;
            
            this.listPrice = getListPriceFromPricebookEntry(product);
        }
        
        private Decimal getListPriceFromPricebookEntry(Product2 product) {
            if (product.PricebookEntries != null && !product.PricebookEntries.isEmpty()) {
                return product.PricebookEntries[0].UnitPrice;
            }
            return 0;
        }
    }
    
    private class ProductWrapperComparator implements Comparator<ProductWrapper> {
        public Integer compare(ProductWrapper a, ProductWrapper b) {
            if (a == null && b == null) {
                return 0;
            }
            if (a == null) {
                return 1;
            }
            if (b == null) {
                return -1;
            }
            if (a.name == b.name) {
                return 0;
            }
            if (a.name == null) {
                return 1;
            }
            if (b.name == null) {
                return -1;
            }
            return a.name.compareTo(b.name);
        }
    }
    
    public class OrderManagementServiceException extends Exception {}
}