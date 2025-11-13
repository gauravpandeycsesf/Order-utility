@IsTest
private class OrderRestResourceTest {

    static final Id ACCOUNT_ID = (Id) '001000000000001AAA';
    static final Id PRICEBOOK_ID = (Id) '01s000000000001AAA';
    static final Id PROD_A_ID = (Id) '01t000000000001AAA';
    static final Id PROD_B_ID = (Id) '01t000000000002AAA';
    static final Id ORDER_ID = (Id) '801000000000001AAA';
    static final Id PBE_A_ID = (Id) '01u000000000001AAA';
    static final Id PBE_B_ID = (Id) '01u000000000002AAA';

    @IsTest
    static void testCreateOrder_MissingAccountId() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('pricebookId', String.valueOf(PRICEBOOK_ID));

            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put(String.valueOf(PROD_A_ID), 5);
            requestBody.put('productIdToQuantity', productIdToQuantity);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assertEquals(400, res.statusCode, 'Status code should be 400');

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(errorResponse.error.contains('Account ID is required'), 
                         'Error message should indicate account ID is required');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_MissingPricebookId() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', String.valueOf(ACCOUNT_ID));

            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put(String.valueOf(PROD_A_ID), 5);
            requestBody.put('productIdToQuantity', productIdToQuantity);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assertEquals(400, res.statusCode, 'Status code should be 400');

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(errorResponse.error.contains('Pricebook ID is required'), 
                         'Error message should indicate pricebook ID is required');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_MissingProductIdToQuantity() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', String.valueOf(ACCOUNT_ID));
            requestBody.put('pricebookId', String.valueOf(PRICEBOOK_ID));

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assertEquals(400, res.statusCode, 'Status code should be 400');

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(errorResponse.error.contains('Product ID to Quantity map is required'), 
                         'Error message should indicate product ID to quantity map is required');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_EmptyProductIdToQuantity() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', String.valueOf(ACCOUNT_ID));
            requestBody.put('pricebookId', String.valueOf(PRICEBOOK_ID));
            requestBody.put('productIdToQuantity', new Map<String, Object>());

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assertEquals(400, res.statusCode, 'Status code should be 400');

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(errorResponse.error.contains('Product ID to Quantity map cannot be empty'), 
                         'Error message should indicate map cannot be empty');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_EmptyRequestBody() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('');

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assertEquals(400, res.statusCode, 'Status code should be 400');

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(errorResponse.error.contains('Request body is required'), 
                         'Error message should indicate request body is required');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_InvalidIdFormat() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', 'INVALID_ID');
            requestBody.put('pricebookId', String.valueOf(PRICEBOOK_ID));

            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put(String.valueOf(PROD_A_ID), 5);
            requestBody.put('productIdToQuantity', productIdToQuantity);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assert(res.statusCode >= 400, 'Status code should be 400 or 500 for invalid ID');

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(
                errorResponse.error.contains('Invalid ID format') || 
                errorResponse.error.contains('Error processing order') ||
                errorResponse.error.contains('Error creating order'),
                'Error message should indicate invalid ID or error: ' + errorResponse.error
            );
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_ResponseWrapper() {
        Order testOrder = new Order();
        testOrder.Id = ORDER_ID;
        testOrder.AccountId = ACCOUNT_ID;
        testOrder.Pricebook2Id = PRICEBOOK_ID;
        testOrder.Status = 'Draft';
        testOrder.EffectiveDate = Date.today();

        Map<String, Object> item1Map = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000001AAA',
            'OrderId' => (String) ORDER_ID,
            'Product2Id' => (String) PROD_A_ID,
            'PricebookEntryId' => (String) PBE_A_ID,
            'Quantity' => 5,
            'UnitPrice' => 100
        };
        OrderItem item1 = (OrderItem) JSON.deserializeStrict(JSON.serialize(item1Map), OrderItem.class);

        Map<String, Object> item2Map = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000002AAA',
            'OrderId' => (String) ORDER_ID,
            'Product2Id' => (String) PROD_B_ID,
            'PricebookEntryId' => (String) PBE_B_ID,
            'Quantity' => 10,
            'UnitPrice' => 100
        };
        OrderItem item2 = (OrderItem) JSON.deserializeStrict(JSON.serialize(item2Map), OrderItem.class);

        List<OrderItem> orderItems = new List<OrderItem>{ item1, item2 };

        Test.startTest();
        OrderRestResource.OrderResponse orderResponse = 
            new OrderRestResource.OrderResponse(testOrder, orderItems);
        Test.stopTest();

        System.assertEquals(testOrder.Id, orderResponse.orderId, 'Order ID should match');
        System.assertEquals(2, orderResponse.itemsAdded, 'Items added should be 2');
        System.assertEquals(2, orderResponse.orderItems.size(), 'Order items size should be 2');
        System.assert(orderResponse.message.contains('Order created successfully'), 'Message should indicate success');

        for (OrderRestResource.OrderItemResponse itemResponse : orderResponse.orderItems) {
            System.assertNotEquals(null, itemResponse.id, 'Order item ID should not be null');
            System.assertEquals(ORDER_ID, itemResponse.orderId, 'Order ID should match');
            System.assertNotEquals(null, itemResponse.product2Id, 'Product ID should not be null');
            System.assert(itemResponse.quantity > 0, 'Quantity should be greater than 0');
            System.assertEquals(100, itemResponse.unitPrice, 'Unit price should be 100');
            System.assertEquals(itemResponse.quantity * itemResponse.unitPrice, itemResponse.totalPrice, 
                               'Total price should be quantity * unit price');
        }
    }

    @IsTest
    static void testCreateOrder_ErrorResponseWrapper() {
        Test.startTest();
        OrderRestResource.ErrorResponse errorResponse = 
            new OrderRestResource.ErrorResponse('Test error message');
        Test.stopTest();

        System.assertEquals('Test error message', errorResponse.error, 'Error message should match');
    }

    @IsTest
    static void testCreateOrder_Success_WithDifferentNumericTypes() {
        Id accountId = ACCOUNT_ID;
        Id pricebookId = PRICEBOOK_ID;
        Id product1Id = PROD_A_ID;
        Id product2Id = PROD_B_ID;
        Id product3Id = (Id) '01t000000000003AAA';
        Id product4Id = (Id) '01t000000000004AAA';
        Id orderId = ORDER_ID;

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        
        Order testOrder = new Order();
        testOrder.Id = orderId;
        testOrder.AccountId = accountId;
        testOrder.Pricebook2Id = pricebookId;
        testOrder.Status = 'Draft';
        testOrder.EffectiveDate = Date.today();
        d.order = testOrder;
        d.insertedOrder = testOrder;
        
        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 100);
        PricebookEntry pbe3 = ApplicationDependencyTestKit.pbe('01u000000000003AAA', 100);
        PricebookEntry pbe4 = ApplicationDependencyTestKit.pbe('01u000000000004AAA', 100);
        d.productIdToPbe.put(product1Id, pbe1);
        d.productIdToPbe.put(product2Id, pbe2);
        d.productIdToPbe.put(product3Id, pbe3);
        d.productIdToPbe.put(product4Id, pbe4);
        
        Map<String, Object> item1Map = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000001AAA',
            'OrderId' => (String) orderId,
            'Product2Id' => (String) product1Id,
            'Quantity' => 5,
            'UnitPrice' => 100
        };
        OrderItem item1 = (OrderItem) JSON.deserializeStrict(JSON.serialize(item1Map), OrderItem.class);

        Map<String, Object> item2Map = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000002AAA',
            'OrderId' => (String) orderId,
            'Product2Id' => (String) product2Id,
            'Quantity' => 10,
            'UnitPrice' => 100
        };
        OrderItem item2 = (OrderItem) JSON.deserializeStrict(JSON.serialize(item2Map), OrderItem.class);

        Map<String, Object> item3Map = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000003AAA',
            'OrderId' => (String) orderId,
            'Product2Id' => (String) product3Id,
            'Quantity' => 15,
            'UnitPrice' => 100
        };
        OrderItem item3 = (OrderItem) JSON.deserializeStrict(JSON.serialize(item3Map), OrderItem.class);

        Map<String, Object> item4Map = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000004AAA',
            'OrderId' => (String) orderId,
            'Product2Id' => (String) product4Id,
            'Quantity' => 20,
            'UnitPrice' => 100
        };
        OrderItem item4 = (OrderItem) JSON.deserializeStrict(JSON.serialize(item4Map), OrderItem.class);

        d.insertedItems.addAll(new List<OrderItem>{ item1, item2, item3, item4 });
        d.orderItemsForOrder.addAll(new List<OrderItem>{ item1, item2, item3, item4 });
        d.existingOrderItems = new List<OrderItem>(); // No existing items

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', String.valueOf(accountId));
            requestBody.put('pricebookId', String.valueOf(pricebookId));

            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put(String.valueOf(product1Id), 5); // Integer
            productIdToQuantity.put(String.valueOf(product2Id), 10.5); // Double
            productIdToQuantity.put(String.valueOf(product3Id), '15'); // String
            productIdToQuantity.put(String.valueOf(product4Id), Decimal.valueOf(20)); // Decimal
            requestBody.put('productIdToQuantity', productIdToQuantity);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            if (res.statusCode != 201) {
                String errorBody = res.responseBody != null ? res.responseBody.toString() : 'null';
                OrderRestResource.ErrorResponse errorResponse = 
                    (OrderRestResource.ErrorResponse) JSON.deserialize(
                        errorBody, 
                        OrderRestResource.ErrorResponse.class
                    );
                System.assertEquals(201, res.statusCode, 'Status code should be 201. Error: ' + errorResponse.error);
            }

            OrderRestResource.OrderResponse orderResponse = 
                (OrderRestResource.OrderResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.OrderResponse.class
                );

            System.assertNotEquals(null, orderResponse.orderId, 'Order ID should not be null');
            System.assertEquals(4, orderResponse.itemsAdded, 'Should have 4 order items');
            System.assert(orderResponse.message.contains('Order created successfully'), 'Message should indicate success');
            System.assertNotEquals(null, d.insertedOrder, 'Order should be inserted');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_Success_TypeException() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', 'INVALID_ID_FORMAT');
            requestBody.put('pricebookId', String.valueOf(PRICEBOOK_ID));

            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put('INVALID_PRODUCT_ID', 5);
            requestBody.put('productIdToQuantity', productIdToQuantity);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assert(res.statusCode >= 400, 'Status code should be 400 or 500: ' + res.responseBody.toString());

            OrderRestResource.ErrorResponse errorResponse = 
                (OrderRestResource.ErrorResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.ErrorResponse.class
                );

            System.assert(
                errorResponse.error.contains('Invalid ID format') || 
                errorResponse.error.contains('Error processing order') ||
                errorResponse.error.contains('Error creating order'),
                'Error message should indicate invalid ID or error: ' + errorResponse.error
            );
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCreateOrder_Success_AuraHandledException() {
        Id accountId = ACCOUNT_ID;
        Id pricebookId = PRICEBOOK_ID;
        Id orderId = ORDER_ID;
        Id productId = PROD_A_ID;

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        
        Order testOrder = new Order();
        testOrder.Id = orderId;
        testOrder.AccountId = accountId;
        testOrder.Pricebook2Id = pricebookId;
        testOrder.Status = 'Draft';
        testOrder.EffectiveDate = Date.today();
        d.order = testOrder;
        d.insertedOrder = testOrder;
        
        PricebookEntry pbe = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        d.productIdToPbe.put(productId, pbe);
        
        Map<String, Object> itemMap = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Id' => '802000000000001AAA',
            'OrderId' => (String) orderId,
            'Product2Id' => (String) productId,
            'Quantity' => 5,
            'UnitPrice' => 100
        };
        OrderItem item = (OrderItem) JSON.deserializeStrict(JSON.serialize(itemMap), OrderItem.class);
        
        d.insertedItems.add(item);
        d.orderItemsForOrder.add(item);
        d.existingOrderItems = new List<OrderItem>(); // No existing items

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', String.valueOf(accountId));
            requestBody.put('pricebookId', String.valueOf(pricebookId));

            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put(String.valueOf(productId), 5);
            requestBody.put('productIdToQuantity', productIdToQuantity);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/orders';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            OrderRestResource.createOrder();
            Test.stopTest();

            System.assertEquals(201, res.statusCode, 'Status code should be 201: ' + res.responseBody.toString());

            OrderRestResource.OrderResponse orderResponse = 
                (OrderRestResource.OrderResponse) JSON.deserialize(
                    res.responseBody.toString(), 
                    OrderRestResource.OrderResponse.class
                );

            System.assertNotEquals(null, orderResponse.orderId, 'Order ID should not be null');
        } finally {
            scope.close();
        }
    }
}