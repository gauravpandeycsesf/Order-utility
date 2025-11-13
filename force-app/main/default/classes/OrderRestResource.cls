@RestResource(urlMapping='/orders/*')
global with sharing class OrderRestResource {
    
    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    @HttpPost
    global static void createOrder() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            if (String.isBlank(requestBody)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Request body is required')));
                return;
            }
            
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String accountIdStr = (String) requestMap.get('accountId');
            if (String.isBlank(accountIdStr)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Account ID is required')));
                return;
            }
            
            String pricebookIdStr = (String) requestMap.get('pricebookId');
            if (String.isBlank(pricebookIdStr)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Pricebook ID is required')));
                return;
            }
            
            Object productIdToQuantityObj = requestMap.get('productIdToQuantity');
            if (productIdToQuantityObj == null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Product ID to Quantity map is required and cannot be empty')));
                return;
            }
            
            Id accountId = Id.valueOf(accountIdStr);
            Id pricebookId = Id.valueOf(pricebookIdStr);
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>();
            
            Map<String, Object> productIdToQuantityMap = (Map<String, Object>) productIdToQuantityObj;
            if (productIdToQuantityMap.isEmpty()) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Product ID to Quantity map cannot be empty')));
                return;
            }
            
            for (String productIdStr : productIdToQuantityMap.keySet()) {
                Id productId = Id.valueOf(productIdStr);
                Object qtyObj = productIdToQuantityMap.get(productIdStr);
                Decimal quantity;
                
                if (qtyObj instanceof Decimal) {
                    quantity = (Decimal) qtyObj;
                } else if (qtyObj instanceof Integer) {
                    quantity = Decimal.valueOf((Integer) qtyObj);
                } else if (qtyObj instanceof Double) {
                    quantity = Decimal.valueOf((Double) qtyObj);
                } else if (qtyObj instanceof String) {
                    quantity = Decimal.valueOf((String) qtyObj);
                } else {
                    quantity = Decimal.valueOf(String.valueOf(qtyObj));
                }
                
                productIdToQuantity.put(productId, quantity);
            }
            
            Order newOrder = new Order(
                AccountId = accountId,
                Pricebook2Id = pricebookId,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            );
            newOrder = dependencies().insertOrder(newOrder);
            
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = newOrder.Id;
            request.pricebookId = pricebookId;
            request.productIdToQuantity = productIdToQuantity;
            
            AvailableProductsController.addProductsToOrderWithQuantities(request);
            
            List<OrderItem> orderItems = dependencies().getOrderItemsForOrder(newOrder.Id);
            
            OrderResponse orderResponse = new OrderResponse(newOrder, orderItems);
            
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(orderResponse));
            
        } catch (TypeException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Invalid ID format: ' + e.getMessage())));
        } catch (IllegalArgumentException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Invalid format: ' + e.getMessage())));
        } catch (AuraHandledException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(e.getMessage())));
        } catch (OrderManagementService.OrderManagementServiceException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(e.getMessage())));
        } catch (DmlException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Error creating order: ' + e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Error processing order: ' + e.getMessage())));
        }
    }
    global class OrderResponse {
        global Id orderId { get; set; }
        global Integer itemsAdded { get; set; }
        global List<OrderItemResponse> orderItems { get; set; }
        global String message { get; set; }
        
        public OrderResponse(Order order, List<OrderItem> items) {
            this.orderId = order.Id;
            this.itemsAdded = items.size();
            this.message = 'Order created successfully with ' + items.size() + ' product(s)';
            this.orderItems = new List<OrderItemResponse>();
            
            for (OrderItem item : items) {
                this.orderItems.add(new OrderItemResponse(item));
            }
        }
    }
    
    global class OrderItemResponse {
        global Id id { get; set; }
        global Id orderId { get; set; }
        global Id product2Id { get; set; }
        global Decimal quantity { get; set; }
        global Decimal unitPrice { get; set; }
        global Decimal totalPrice { get; set; }
        
        public OrderItemResponse(OrderItem item) {
            this.id = item.Id;
            this.orderId = item.OrderId;
            this.product2Id = item.Product2Id;
            this.quantity = item.Quantity;
            this.unitPrice = item.UnitPrice;
            this.totalPrice = item.Quantity * item.UnitPrice;
        }
    }
    
    global class ErrorResponse {
        global String error { get; set; }
        
        public ErrorResponse(String errorMessage) {
            this.error = errorMessage;
        }
    }
}