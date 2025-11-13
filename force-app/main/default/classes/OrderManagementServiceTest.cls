@IsTest
private class OrderManagementServiceTest {

    static final Id ORDER_ID = (Id) '801000000000001AAA';
    static final Id PRICEBOOK_ID = (Id) '01s000000000001AAA';
    static final Id PROD_A_ID = (Id) '01t000000000001AAA';
    static final Id PROD_B_ID = (Id) '01t000000000002AAA';
    static final Id PROD_C_ID = (Id) '01t000000000003AAA';
    static final Id PBE_A_ID = (Id) '01u000000000001AAA';
    static final Id PBE_B_ID = (Id) '01u000000000002AAA';
    static final Id PBE_C_ID = (Id) '01u000000000003AAA';

    private static Order makeOrder(Id idVal, Id pricebookId, String status) {
        Order o = new Order();
        o.Id = idVal;
        o.Pricebook2Id = pricebookId;
        o.Status = status;
        return o;
    }

    @IsTest
    static void testGetAvailableProductsForOrder_Success() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderId = ORDER_ID;
        d.pricebookId = PRICEBOOK_ID;
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        Product2 pA = ApplicationDependencyTestKit.p((String)PROD_A_ID, 'A-100', 'Alpha');
        Product2 pB = ApplicationDependencyTestKit.p((String)PROD_B_ID, 'B-200', 'Beta');
        Product2 pC = ApplicationDependencyTestKit.p((String)PROD_C_ID, 'C-300', 'Gamma');
        d.availableProducts.addAll(new List<Product2>{ pA, pB, pC });
        d.orderItemProductIds.add(PROD_A_ID);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = OrderManagementService.getAvailableProductsForOrder(ORDER_ID);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 available products (3 total - 1 in order)');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_EmptyOrder() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        Product2 pA = ApplicationDependencyTestKit.p((String)PROD_A_ID, 'A-100', 'Alpha');
        Product2 pB = ApplicationDependencyTestKit.p((String)PROD_B_ID, 'B-200', 'Beta');
        Product2 pC = ApplicationDependencyTestKit.p((String)PROD_C_ID, 'C-300', 'Gamma');
        Product2 pD = ApplicationDependencyTestKit.p((String)'01t000000000004AAA', 'D-400', 'Delta');
        Product2 pE = ApplicationDependencyTestKit.p((String)'01t000000000005AAA', 'E-500', 'Epsilon');
        d.availableProducts.addAll(new List<Product2>{ pA, pB, pC, pD, pE });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = OrderManagementService.getAvailableProductsForOrder(ORDER_ID);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(5, result.size(), 'Should return all 5 products when order is empty');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_NoPricebook() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, null, 'Draft');

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = OrderManagementService.getAvailableProductsForOrder(ORDER_ID);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list when no pricebook');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderProducts_Success() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemProductIds.addAll(new Set<Id>{ PROD_A_ID, PROD_B_ID });
        d.orderProducts.addAll(new List<Product2>{
            ApplicationDependencyTestKit.p((String)PROD_A_ID, 'A-100', 'Alpha'),
            ApplicationDependencyTestKit.p((String)PROD_B_ID, 'B-200', 'Beta')
        });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = OrderManagementService.getOrderProducts(ORDER_ID);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 products in order');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderProducts_EmptyOrder() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemProductIds = new Set<Id>();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = OrderManagementService.getOrderProducts(ORDER_ID);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for order with no items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetOrderItemsForDisplay_Success() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemsByOrder.add(ApplicationDependencyTestKit.oi('802000000000001AAA', 2, 100));
        d.orderItemsByOrder.add(ApplicationDependencyTestKit.oi('802000000000002AAA', 3, 200));

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<OrderItem> result = OrderManagementService.getOrderItemsForDisplay(ORDER_ID);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 order items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProductsToOrderWithQuantities_Success() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        PricebookEntry pbeA = ApplicationDependencyTestKit.pbe((String)PBE_A_ID, 15);
        PricebookEntry pbeB = ApplicationDependencyTestKit.pbe((String)PBE_B_ID, 20);
        d.productIdToPbe.put(PROD_A_ID, pbeA);
        d.productIdToPbe.put(PROD_B_ID, pbeB);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>{ PROD_A_ID => 5, PROD_B_ID => 3 };

            Test.startTest();
            List<OrderItem> result = OrderManagementService.addProductsToOrderWithQuantities(
                ORDER_ID, PRICEBOOK_ID, productIdToQuantity
            );
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, d.insertedItems.size(), 'Should insert 2 new order items');
            System.assertEquals(ORDER_ID, d.insertedItems[0].OrderId, 'Order ID should be set');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProductsToOrderWithQuantities_EmptyMap() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<OrderItem> result = OrderManagementService.addProductsToOrderWithQuantities(
                ORDER_ID, PRICEBOOK_ID, new Map<Id, Decimal>()
            );
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for empty map');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProductsToOrderWithQuantities_NullMap() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<OrderItem> result = OrderManagementService.addProductsToOrderWithQuantities(
                ORDER_ID, PRICEBOOK_ID, null
            );
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for null map');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProductsToOrderWithQuantities_InvalidOrderId() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = null;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>{ PROD_A_ID => 1 };

            Test.startTest();
            Boolean threw = false;
            try {
                OrderManagementService.addProductsToOrderWithQuantities(null, PRICEBOOK_ID, productIdToQuantity);
            } catch (OrderManagementService.OrderManagementServiceException e) {
                threw = true;
            }
            Test.stopTest();

            System.assertEquals(true, threw, 'Should throw exception for invalid order ID');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProductsToOrderWithQuantities_OrderWithoutPricebook() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, null, 'Draft');

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>{ PROD_A_ID => 1 };

            Test.startTest();
            Boolean threw = false;
            try {
                OrderManagementService.addProductsToOrderWithQuantities(ORDER_ID, null, productIdToQuantity);
            } catch (OrderManagementService.OrderManagementServiceException e) {
                threw = true;
            }
            Test.stopTest();

            System.assertEquals(true, threw, 'Should throw exception when no pricebook assigned');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProducts_updatesExisting_andNormalizesOthers() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        PricebookEntry pbeA = ApplicationDependencyTestKit.pbe((String)PBE_A_ID, 15);
        d.productIdToPbe.put(PROD_A_ID, pbeA);

        OrderItem existingFirst = ApplicationDependencyTestKit.oiJson('802000000000010AAA', PROD_A_ID, PBE_A_ID, 1, 15);
        OrderItem existingSecond = ApplicationDependencyTestKit.oiJson('802000000000011AAA', PROD_A_ID, PBE_A_ID, 4, 10);
        d.existingOrderItems.addAll(new List<OrderItem>{ existingFirst, existingSecond });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> addMap = new Map<Id, Decimal>{ PROD_A_ID => 2 };

            Test.startTest();
            List<OrderItem> result = OrderManagementService.addProductsToOrderWithQuantities(
                ORDER_ID, PRICEBOOK_ID, addMap
            );
            Test.stopTest();

            System.assertEquals(0, d.insertedItems.size(), 'No inserts expected for existing product');
            System.assertEquals(2, d.updatedItems.size(), 'Both existing items should be updated');

            Map<Id, OrderItem> byId = new Map<Id, OrderItem>();
            for (OrderItem oi : d.updatedItems) byId.put(oi.Id, oi);

            System.assertEquals(3, byId.get(existingFirst.Id).Quantity, 'First item quantity should be 3');
            System.assertEquals(15, byId.get(existingFirst.Id).UnitPrice, 'First item unit price should be 15');
            System.assertEquals(4, byId.get(existingSecond.Id).Quantity, 'Second item quantity should be 4');
            System.assertEquals(15, byId.get(existingSecond.Id).UnitPrice, 'Second item unit price should be normalized to 15');
            System.assertEquals(2, result.size(), 'Result should contain both updated items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testAddProducts_insertsOnly_whenNoExistingItems() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');

        PricebookEntry pbeA = ApplicationDependencyTestKit.pbe((String)PBE_A_ID, 15);
        PricebookEntry pbeB = ApplicationDependencyTestKit.pbe((String)PBE_B_ID, 20);
        d.productIdToPbe.put(PROD_A_ID, pbeA);
        d.productIdToPbe.put(PROD_B_ID, pbeB);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> addMap = new Map<Id, Decimal>{ PROD_A_ID => 2, PROD_B_ID => 5 };

            Test.startTest();
            List<OrderItem> result = OrderManagementService.addProductsToOrderWithQuantities(
                ORDER_ID, PRICEBOOK_ID, addMap
            );
            Test.stopTest();

            System.assertEquals(0, d.updatedItems.size(), 'No updates expected');
            System.assertEquals(2, d.insertedItems.size(), 'Two inserts expected');
            System.assertEquals(ORDER_ID, d.insertedItems[0].OrderId, 'Order ID should be set');
            System.assertEquals(ORDER_ID, d.insertedItems[1].OrderId, 'Order ID should be set');
            System.assertEquals(2, result.size(), 'Result should include both new items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testActivateOrder_Success() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            OrderManagementService.activateOrder(ORDER_ID);
            Test.stopTest();

            System.assertEquals(ORDER_ID, d.activatedOrderId, 'activateOrder should forward the ID');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCanActivateOrder_True() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');
        d.orderItemsByOrder.add(ApplicationDependencyTestKit.oi(null, 1, 10));

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            Boolean result = OrderManagementService.canActivateOrder(ORDER_ID);
            Test.stopTest();

            System.assertEquals(true, result, 'Order should be activatable when it has items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCanActivateOrder_False_NoItems() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Draft');
        d.orderItemsByOrder = new List<OrderItem>();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            Boolean result = OrderManagementService.canActivateOrder(ORDER_ID);
            Test.stopTest();

            System.assertEquals(false, result, 'Order should not be activatable when it has no items');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCanActivateOrder_False_AlreadyActivated() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(ORDER_ID, PRICEBOOK_ID, 'Activated');

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            Boolean result = OrderManagementService.canActivateOrder(ORDER_ID);
            Test.stopTest();

            System.assertEquals(false, result, 'Order should not be activatable when already activated');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testCanActivateOrder_InvalidOrderId() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = null;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            Boolean result = OrderManagementService.canActivateOrder(null);
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false for invalid order ID');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testUpdateOrderItemQuantities_Success() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        OrderItem x = ApplicationDependencyTestKit.oi('802000000000004AAA', 1, 10);
        d.itemsById.put(x.Id, x);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> updates = new Map<Id, Decimal>{ x.Id => 10 };

            Test.startTest();
            List<OrderItem> result = OrderManagementService.updateOrderItemQuantities(updates);
            Test.stopTest();

            System.assertEquals(1, d.updatedItems.size(), 'Should call updateOrderItems once with one item');
            System.assertEquals(10, d.updatedItems[0].Quantity, 'Quantity should be updated');
            System.assertEquals(1, result.size(), 'Should return one item');
            System.assertEquals(10, result[0].Quantity, 'Result quantity should be 10');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testUpdateOrderItemQuantities_EmptyMap() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<OrderItem> result = OrderManagementService.updateOrderItemQuantities(new Map<Id, Decimal>());
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for empty map');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testUpdateOrderItemQuantities_NullMap() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<OrderItem> result = OrderManagementService.updateOrderItemQuantities(null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for null map');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testUpdateOrderItemQuantities_InvalidIds() {
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> updates = new Map<Id, Decimal>{ (Id) '802000000000099AAA' => 3 };

            Test.startTest();
            Boolean threw = false;
            try {
                OrderManagementService.updateOrderItemQuantities(updates);
            } catch (OrderManagementService.OrderManagementServiceException e) {
                threw = true;
            }
            Test.stopTest();

            System.assertEquals(true, threw, 'Expected exception when items not found');
        } finally {
            scope.close();
        }
    }
}