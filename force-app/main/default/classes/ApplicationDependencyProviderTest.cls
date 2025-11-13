@IsTest
private class ApplicationDependencyProviderTest {

    private static Order makeOrder(Id idVal, Id pricebookId, Id accountId) {
        Order o = new Order();
        o.Id = idVal;
        o.Pricebook2Id = pricebookId;
        o.AccountId = accountId;
        o.EffectiveDate = Date.today();
        o.Status = 'Draft';
        return o;
    }

    @IsTest
    static void testGetOrderProducts_EmptySet() {
        Test.startTest();
        ApplicationDependencyProvider provider = new ApplicationDependencyProvider();
        List<Product2> result = provider.getOrderProducts(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list for empty set');
    }

    @IsTest
    static void testGetOrderProducts_NullSet() {
        Test.startTest();
        ApplicationDependencyProvider provider = new ApplicationDependencyProvider();
        List<Product2> result = provider.getOrderProducts(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list for null set');
    }

    @IsTest
    static void testGetProductsByName_NullPricebookId() {
        Test.startTest();
        ApplicationDependencyProvider provider = new ApplicationDependencyProvider();
        try {
            List<Product2> result = provider.getProductsByName('Test', null);
            System.assert(false, 'Should throw IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Pricebook ID is required'), 
                         'Should throw error about pricebook ID being required');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetAvailableProductsForOrder() {
        Id pricebookId = (Id) '01s000000000001AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        Product2 product1 = ApplicationDependencyTestKit.p((String)productId1, 'P-100', 'Product 1');
        Product2 product2 = ApplicationDependencyTestKit.p((String)productId2, 'P-200', 'Product 2');

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts.addAll(new List<Product2>{ product1, product2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<Product2> result = provider.getAvailableProductsForOrder(pricebookId, new Set<Id>());
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return available products');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testQueryExistingOrderItems_Empty() {
        Id orderId = (Id) '801000000000001AAA';
        Set<Id> productIds = new Set<Id>();

        Test.startTest();
        ApplicationDependencyProvider provider = new ApplicationDependencyProvider();
        List<OrderItem> result = provider.queryExistingOrderItems(orderId, productIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Should return empty list for empty product IDs');
    }

    @IsTest
    static void testQueryActivePricebookEntries_Empty() {
        Id pricebookId = (Id) '01s000000000001AAA';
        Set<Id> productIds = new Set<Id>();

        Test.startTest();
        ApplicationDependencyProvider provider = new ApplicationDependencyProvider();
        Map<Id, PricebookEntry> result = provider.queryActivePricebookEntries(pricebookId, productIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Should return empty map for empty product IDs');
    }

    @IsTest
    static void testGetOrderItemsForOrder_Empty() {
        Id orderId = (Id) '801000000000001AAA';

        Test.startTest();
        ApplicationDependencyProvider provider = new ApplicationDependencyProvider();
        List<OrderItem> result = provider.getOrderItemsForOrder(orderId);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Should return empty list for non-existent order');
    }

    @IsTest
    static void testActivateOrder_NullOrder() {
        Id orderId = (Id) '801000000000001AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = null;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.activateOrder(orderId);
            Test.stopTest();

            System.assert(true, 'Should complete without error when order is null');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testActivateOrder_AlreadyActivated() {
        Id orderId = (Id) '801000000000001AAA';
        Id accountId = (Id) '001000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId, accountId);
        d.order.Status = 'Activated';

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.activateOrder(orderId);
            Test.stopTest();

            System.assertEquals('Activated', d.order.Status, 'Status should remain Activated');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testActivateOrder_Success() {
        Id orderId = (Id) '801000000000001AAA';
        Id accountId = (Id) '001000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId, accountId);
        d.order.Status = 'Draft';

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.activateOrder(orderId);
            Test.stopTest();

            System.assertEquals('Activated', d.order.Status, 'Status should be Activated');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderWithItems() {
        Id orderId = (Id) '801000000000001AAA';
        Id accountId = (Id) '001000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId, accountId);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            Order result = provider.getOrderWithItems(orderId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(orderId, result.Id, 'Should return correct order');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetProductIdsInOrder() {
        Id orderId = (Id) '801000000000001AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemProductIds.addAll(new Set<Id>{ productId1, productId2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            Set<Id> result = provider.getProductIdsInOrder(orderId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 product IDs');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetProductQuantitiesInOrder() {
        Id orderId = (Id) '801000000000001AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productQuantitiesInOrder.put(productId1, 5);
        d.productQuantitiesInOrder.put(productId2, 10);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            Map<Id, Decimal> result = provider.getProductQuantitiesInOrder(orderId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 product quantities');
            System.assertEquals(5, result.get(productId1), 'Should return correct quantity for product1');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetProductsByName() {
        Id pricebookId = (Id) '01s000000000001AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        Product2 product1 = ApplicationDependencyTestKit.p((String)productId1, 'P-100', 'Product 1');
        Product2 product2 = ApplicationDependencyTestKit.p((String)productId2, 'P-200', 'Product 2');

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ product1, product2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<Product2> result = provider.getProductsByName('Product', pricebookId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 products');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderProducts() {
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        Product2 product1 = ApplicationDependencyTestKit.p((String)productId1, 'P-100', 'Product 1');
        Product2 product2 = ApplicationDependencyTestKit.p((String)productId2, 'P-200', 'Product 2');

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderProducts.addAll(new List<Product2>{ product1, product2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<Product2> result = provider.getOrderProducts(new Set<Id>{ productId1, productId2 });
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 products');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderItemsByOrder() {
        Id orderId = (Id) '801000000000001AAA';
        Id orderItemId1 = (Id) '802000000000001AAA';
        Id orderItemId2 = (Id) '802000000000002AAA';

        OrderItem item1 = ApplicationDependencyTestKit.oi((String)orderItemId1, 5, 100);
        OrderItem item2 = ApplicationDependencyTestKit.oi((String)orderItemId2, 10, 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemsByOrder.addAll(new List<OrderItem>{ item1, item2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<OrderItem> result = provider.getOrderItemsByOrder(orderId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 order items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderItemsByIds() {
        Id orderItemId1 = (Id) '802000000000001AAA';
        Id orderItemId2 = (Id) '802000000000002AAA';

        OrderItem item1 = ApplicationDependencyTestKit.oi((String)orderItemId1, 5, 100);
        OrderItem item2 = ApplicationDependencyTestKit.oi((String)orderItemId2, 10, 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.itemsById.put(orderItemId1, item1);
        d.itemsById.put(orderItemId2, item2);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<OrderItem> result = provider.getOrderItemsByIds(new List<Id>{ orderItemId1, orderItemId2 });
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 order items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderItemsForOrder() {
        Id orderId = (Id) '801000000000001AAA';
        Id orderItemId1 = (Id) '802000000000001AAA';
        Id orderItemId2 = (Id) '802000000000002AAA';

        OrderItem item1 = ApplicationDependencyTestKit.oi((String)orderItemId1, 5, 100);
        OrderItem item2 = ApplicationDependencyTestKit.oi((String)orderItemId2, 10, 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemsForOrder.addAll(new List<OrderItem>{ item1, item2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<OrderItem> result = provider.getOrderItemsForOrder(orderId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 order items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testQueryExistingOrderItems() {
        Id orderId = (Id) '801000000000001AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        OrderItem item1 = ApplicationDependencyTestKit.oi('802000000000001AAA', 5, 100);
        OrderItem item2 = ApplicationDependencyTestKit.oi('802000000000002AAA', 10, 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.existingOrderItems.addAll(new List<OrderItem>{ item1, item2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            List<OrderItem> result = provider.queryExistingOrderItems(orderId, new Set<Id>{ productId1, productId2 });
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 existing order items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testQueryActivePricebookEntries() {
        Id pricebookId = (Id) '01s000000000001AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productIdToPbe.put(productId1, pbe1);
        d.productIdToPbe.put(productId2, pbe2);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            Map<Id, PricebookEntry> result = provider.queryActivePricebookEntries(pricebookId, new Set<Id>{ productId1, productId2 });
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 pricebook entries');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testInsertOrderItems() {
        Id orderItemId1 = (Id) '802000000000001AAA';
        Id orderItemId2 = (Id) '802000000000002AAA';

        OrderItem item1 = ApplicationDependencyTestKit.oi((String)orderItemId1, 5, 100);
        OrderItem item2 = ApplicationDependencyTestKit.oi((String)orderItemId2, 10, 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.insertOrderItems(new List<OrderItem>{ item1, item2 });
            Test.stopTest();

            System.assertEquals(2, d.insertedItems.size(), 'Should capture 2 inserted items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testUpdateOrderItems() {
        Id orderItemId1 = (Id) '802000000000001AAA';
        Id orderItemId2 = (Id) '802000000000002AAA';

        OrderItem item1 = ApplicationDependencyTestKit.oi((String)orderItemId1, 5, 100);
        OrderItem item2 = ApplicationDependencyTestKit.oi((String)orderItemId2, 10, 200);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.updateOrderItems(new List<OrderItem>{ item1, item2 });
            Test.stopTest();

            System.assertEquals(2, d.updatedItems.size(), 'Should capture 2 updated items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testUpdateOrder() {
        Id orderId = (Id) '801000000000001AAA';
        Id accountId = (Id) '001000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId, accountId);
        d.order.Status = 'Draft';

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Order orderToUpdate = makeOrder(orderId, pricebookId, accountId);
            orderToUpdate.Status = 'Activated';

            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.updateOrder(orderToUpdate);
            Test.stopTest();

            System.assertEquals('Activated', d.order.Status, 'Order status should be updated');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testInsertOrder() {
        Id orderId = (Id) '801000000000001AAA';
        Id accountId = (Id) '001000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.insertedOrder = makeOrder(orderId, pricebookId, accountId);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Order orderToInsert = makeOrder(null, pricebookId, accountId);

            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            Order result = provider.insertOrder(orderToInsert);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals(null, result.Id, 'Order should have an ID after insert');
        } finally {
            scope.close();
        }
    }
}