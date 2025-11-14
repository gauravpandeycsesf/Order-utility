/**
 * @description Test class for OrderItemSelector
 * @group Test
 */
@isTest
private class OrderItemSelectorTest {

    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        System.assertEquals(OrderItem.SObjectType, result, 'Should return OrderItem SObjectType');
    }

    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(null, fields, 'Field list should not be null');
        System.assert(fields.size() > 0, 'Field list should contain fields');
        System.assert(fields.contains(OrderItem.Id), 'Should contain Id field');
        System.assert(fields.contains(OrderItem.OrderId), 'Should contain OrderId field');
        System.assert(fields.contains(OrderItem.Product2Id), 'Should contain Product2Id field');
        System.assert(fields.contains(OrderItem.Quantity), 'Should contain Quantity field');
        System.assert(fields.contains(OrderItem.UnitPrice), 'Should contain UnitPrice field');
        System.assert(fields.contains(OrderItem.TotalPrice), 'Should contain TotalPrice field');
    }

    @IsTest
    static void testGetSObjectName() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        String result = selector.getSObjectName();
        Test.stopTest();

        System.assertEquals('OrderItem', result, 'Should return OrderItem as SObject name');
    }

    @IsTest
    static void testGetFieldListString() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        String result = selector.getFieldListString();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Field list string should not be null');
        System.assert(result.contains('Id'), 'Should contain Id field');
        System.assert(result.contains('Quantity'), 'Should contain Quantity field');
    }

    @IsTest
    static void testGetOrderItemsByOrder_NoItems() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<OrderItem> results = selector.getOrderItemsByOrder((Id) '801000000000000AAA');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for order with no items');
    }

    @IsTest
    static void testGetOrderItemByOrderAndProduct_NotFound() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        OrderItem result = selector.getOrderItemByOrderAndProduct(
            (Id) '801000000000000AAA',
            (Id) '01t000000000000AAA'
        );
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for non-existent order item');
    }

    @IsTest
    static void testGetOrderItemByOrderAndProduct_Coverage() {
        // Test method execution path for coverage (without inserting data)
        // This tests the query construction and execution path
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        
        // Test with different order and product IDs to cover the method
        OrderItem result1 = selector.getOrderItemByOrderAndProduct(
            (Id) '801000000000001AAA',
            (Id) '01t000000000001AAA'
        );
        
        OrderItem result2 = selector.getOrderItemByOrderAndProduct(
            (Id) '801000000000002AAA',
            (Id) '01t000000000002AAA'
        );
        
        Test.stopTest();

        // Both should return null since no data exists, but method execution is covered
        System.assertEquals(null, result1, 'Should return null for non-existent order item');
        System.assertEquals(null, result2, 'Should return null for non-existent order item');
    }

    @IsTest
    static void testGetOrderItemsByIds_EmptyList() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<OrderItem> results = selector.getOrderItemsByIds(new List<Id>());
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for empty input');
    }

    @IsTest
    static void testGetOrderItemsByIds_NullList() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<OrderItem> results = selector.getOrderItemsByIds(null);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for null input');
    }

    @IsTest
    static void testGetProductIdsInOrder_NoItems() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        Set<Id> productIds = selector.getProductIdsInOrder((Id) '801000000000000AAA');
        Test.stopTest();

        System.assertEquals(0, productIds.size(), 'Should return empty set for order with no items');
    }

    @IsTest
    static void testGetProductQuantitiesInOrder_NoItems() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        Map<Id, Decimal> productQuantities = selector.getProductQuantitiesInOrder((Id) '801000000000000AAA');
        Test.stopTest();

        System.assertEquals(0, productQuantities.size(), 'Should return empty map for order with no items');
    }

    @IsTest
    static void testGetOrderItemsByOrderPaginated_NoItems() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<OrderItem> results = selector.getOrderItemsByOrderPaginated((Id) '801000000000000AAA', 0, 5);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for order with no items');
    }

    @IsTest
    static void testGetOrderItemsCount_NoItems() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        Integer count = selector.getOrderItemsCount((Id) '801000000000000AAA');
        Test.stopTest();

        System.assertEquals(0, count, 'Should return count of 0 for order with no items');
    }

    @IsTest
    static void testSelectSObjectsById_EmptySet() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<SObject> results = selector.selectSObjectsById(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for empty set');
    }

    @IsTest
    static void testSelectSObjectsById_NullSet() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<SObject> results = selector.selectSObjectsById(null);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for null set');
    }

    @IsTest
    static void testSelectSObjectById_NotFound() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        SObject result = selector.selectSObjectById((Id) '802000000000000AAA');
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for non-existent order item');
    }

    @IsTest
    static void testSelectSObjectsWhere_NoWhereClause() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<SObject> results = selector.selectSObjectsWhere(null);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
    }

    @IsTest
    static void testSelectSObjectsWhere_WithOrderBy() {
        Test.startTest();
        OrderItemSelector selector = new OrderItemSelector();
        List<SObject> results = selector.selectSObjectsWhere('OrderId = \'801000000000000AAA\'', 'Quantity DESC');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
    }
}