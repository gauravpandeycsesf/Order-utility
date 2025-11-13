/**
 * @description Test class for OrderProductsController
 * @group Test
 */
@isTest
private class OrderProductsControllerTest {

    private static Order makeOrder(Id idVal, Id pricebookId, String status) {
        Order o = new Order();
        o.Id = idVal;
        o.Pricebook2Id = pricebookId;
        o.Status = status;
        return o;
    }

    // Build an OrderItem (for display) that includes nested Product2.Name and read-only values
    // safely via JSON to avoid writeability issues.
    private static OrderItem oiForDisplay(
        String oiId, String productName, Decimal qty, Decimal unit, Decimal total, String description
    ) {
        Map<String, Object> m = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Quantity'   => qty,
            'UnitPrice'  => unit,
            'TotalPrice' => total,
            'Description'=> description,
            'Product2'   => new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'type' => 'Product2' },
                'Name'       => productName
            }
        };
        if (oiId != null) m.put('Id', oiId);
        String payload = JSON.serialize(m);
        return (OrderItem) JSON.deserializeStrict(payload, OrderItem.class);
    }

    // -------- tests --------

    @IsTest
    static void getOrderItems_returns_wrapped_rows() {
        // Arrange
        Id orderId = (Id) '801000000000101AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        // Service method getOrderItemsForDisplay reads from dependency.getOrderItemsByOrder
        d.orderItemsByOrder.addAll(new List<OrderItem>{
            oiForDisplay('802000000000201AAA', 'Widget A', 2, 10, 20, 'Top seller'),
            oiForDisplay('802000000000202AAA', 'Widget B', 3,  5, 15, 'Bundle item')
        });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act
            Test.startTest();
            List<OrderProductsController.OrderItemWrapper> rows =
                OrderProductsController.getOrderItems(orderId);
            Test.stopTest();

            // Assert
            System.assertEquals(2, rows.size());
            System.assertEquals('Widget A', rows[0].productName);
            System.assertEquals(Decimal.valueOf(10), rows[0].unitPrice);
            System.assertEquals(Decimal.valueOf(2),  rows[0].quantity);
            System.assertEquals(Decimal.valueOf(20), rows[0].totalPrice);
            System.assertEquals('Top seller', rows[0].description);

            System.assertEquals('Widget B', rows[1].productName);
            System.assertEquals(Decimal.valueOf(15), rows[1].totalPrice);
        } finally { scope.close(); }
    }

    @IsTest
    static void canActivateOrder_true_when_draft_with_items() {
        // Arrange: canActivateOrder checks dependency.getOrderWithItems + getOrderItemsByOrder
        Id orderId = (Id) '801000000000102AAA';
        Id pbId    = (Id) '01s000000000102AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pbId, 'Draft');
        d.orderItemsByOrder.add(ApplicationDependencyTestKit.oi(null, 1, 10));

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Boolean ok = OrderProductsController.canActivateOrder(orderId);
            System.assertEquals(true, ok);
        } finally { scope.close(); }
    }

    @IsTest
    static void canActivateOrder_false_when_activated() {
        // Arrange: already Activated → false
        Id orderId = (Id) '801000000000103AAA';
        Id pbId    = (Id) '01s000000000103AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pbId, 'Activated');
        d.orderItemsByOrder.add(ApplicationDependencyTestKit.oi(null, 1, 10));

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Boolean ok = OrderProductsController.canActivateOrder(orderId);
            System.assertEquals(false, ok);
        } finally { scope.close(); }
    }

    @IsTest
    static void activateOrder_calls_service_and_returns_message() {
        // Arrange: capture the call through the kit (dependency.activateOrder)
        Id orderId = (Id) '801000000000104AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act
            String msg = OrderProductsController.activateOrder(orderId);

            // Assert
            System.assertEquals('Order activated successfully', msg);
            System.assertEquals(orderId, d.activatedOrderId, 'Should forward to dependency.activateOrder');
        } finally { scope.close(); }
    }

    @IsTest
    static void getOrderStatus_returns_status_or_null() {
        // Arrange
        Id orderId = (Id) '801000000000105AAA';
        Id pbId    = (Id) '01s000000000105AAA';
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pbId, 'Pending Approval');

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act & Assert
            System.assertEquals('Pending Approval', OrderProductsController.getOrderStatus(orderId));

            // And when no order is returned
            d.order = null;
            System.assertEquals(null, OrderProductsController.getOrderStatus(orderId));
        } finally { scope.close(); }
    }

    @IsTest
    static void updateOrderItemQuantities_updates_and_returns_message() {
        // Arrange: Service will read via dependency.getOrderItemsByIds and then call updateOrderItems.
        Id oiId = (Id) '802000000000301AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        // Provide one existing order item (only writeable fields needed)
        OrderItem existing = ApplicationDependencyTestKit.oi((String)oiId, 1, 9);
        d.itemsById.put(oiId, existing);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act
            String msg = OrderProductsController.updateOrderItemQuantities(
                new Map<Id, Decimal>{ oiId => 7 }
            );

            // Assert: message + dependency received updated item with quantity 7
            System.assertEquals('Quantities updated successfully', msg);
            System.assertEquals(1, d.updatedItems.size(), 'One row should be sent to update');
            System.assertEquals(Decimal.valueOf(7), d.updatedItems[0].Quantity);
        } finally { scope.close(); }
    }

    @IsTest
    static void updateOrderItemQuantities_throws_when_service_throws() {
        // Arrange: Service throws when no items found (our kit returns empty for itemsById)
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Boolean threw = false;
            try {
                OrderProductsController.updateOrderItemQuantities(
                    new Map<Id, Decimal>{ (Id) '802000000000399AAA' => 5 }
                );
            } catch (AuraHandledException e) {
                threw = true; // Controller wraps exceptions in AuraHandledException
            }
            System.assertEquals(true, threw, 'Expected AuraHandledException when service finds no items');
        } finally { scope.close(); }
    }

    @IsTest
    static void getOrderItemsPaginated_returns_paginated_results() {
        // Arrange
        Id orderId = (Id) '801000000000106AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        // Set up paginated order items (first page: 2 items)
        d.orderItemsByOrderPaginated.addAll(new List<OrderItem>{
            oiForDisplay('802000000000203AAA', 'Widget C', 1, 15, 15, 'First item'),
            oiForDisplay('802000000000204AAA', 'Widget D', 2, 20, 40, 'Second item')
        });
        // Set total count (more items exist)
        d.orderItemsCount = 5;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act
            Test.startTest();
            OrderProductsController.PaginatedOrderItemsResult result =
                OrderProductsController.getOrderItemsPaginated(orderId, 0, 2, 1234567890L);
            Test.stopTest();

            // Assert
            System.assertEquals(2, result.items.size(), 'Should return 2 items for first page');
            System.assertEquals(5, result.totalCount, 'Total count should be 5');
            System.assertEquals(true, result.hasMore, 'Should indicate more items available (2 < 5)');
            System.assertEquals('Widget C', result.items[0].productName);
            System.assertEquals(Decimal.valueOf(15), result.items[0].totalPrice);
            System.assertEquals('Widget D', result.items[1].productName);
            System.assertEquals(Decimal.valueOf(40), result.items[1].totalPrice);
        } finally { scope.close(); }
    }

    @IsTest
    static void getOrderItemsPaginated_hasMore_false_when_no_more_items() {
        // Arrange: Last page scenario
        Id orderId = (Id) '801000000000107AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.orderItemsByOrderPaginated.addAll(new List<OrderItem>{
            oiForDisplay('802000000000205AAA', 'Widget E', 1, 25, 25, 'Last item')
        });
        d.orderItemsCount = 3; // Total is 3, offset 2, pageSize 1, so this is the last item

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act
            OrderProductsController.PaginatedOrderItemsResult result =
                OrderProductsController.getOrderItemsPaginated(orderId, 2, 1, 1234567890L);

            // Assert
            System.assertEquals(1, result.items.size());
            System.assertEquals(3, result.totalCount);
            System.assertEquals(false, result.hasMore, 'Should indicate no more items (offset 2 + size 1 = 3, not < 3)');
        } finally { scope.close(); }
    }

    @IsTest
    static void deleteOrderItems_calls_service_and_returns_message() {
        // Arrange
        Id oiId1 = (Id) '802000000000206AAA';
        Id oiId2 = (Id) '802000000000207AAA';
        List<Id> orderItemIds = new List<Id>{ oiId1, oiId2 };

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        // Service verifies items exist before deleting - populate itemsById
        d.itemsById.put(oiId1, ApplicationDependencyTestKit.oi((String)oiId1, 1, 10));
        d.itemsById.put(oiId2, ApplicationDependencyTestKit.oi((String)oiId2, 2, 20));

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act
            Test.startTest();
            String msg = OrderProductsController.deleteOrderItems(orderItemIds);
            Test.stopTest();

            // Assert
            System.assertEquals('Order items deleted successfully', msg);
            System.assertEquals(2, d.deletedOrderItemIds.size(), 'Should capture 2 deleted item IDs');
            System.assertEquals(oiId1, d.deletedOrderItemIds[0], 'First ID should match');
            System.assertEquals(oiId2, d.deletedOrderItemIds[1], 'Second ID should match');
        } finally { scope.close(); }
    }

    @IsTest
    static void deleteOrderItems_throws_when_service_throws() {
        // Arrange: Service throws when no items found (itemsById is empty)
        Id oiId = (Id) '802000000000208AAA';
        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        // Don't populate itemsById - service will throw when items not found

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            // Act & Assert
            Boolean threw = false;
            try {
                OrderProductsController.deleteOrderItems(new List<Id>{ oiId });
            } catch (AuraHandledException e) {
                threw = true; // Controller wraps exceptions in AuraHandledException
            }
            System.assertEquals(true, threw, 'Expected AuraHandledException when service finds no items');
        } finally { scope.close(); }
    }
}