/**
 * @description Test class for OrderSelector
 * @group Test
 */
@isTest
private class OrderSelectorTest {

    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        System.assertEquals(Order.SObjectType, result, 'Should return Order SObjectType');
    }

    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(null, fields, 'Field list should not be null');
        System.assert(fields.size() > 0, 'Field list should contain fields');
        System.assert(fields.contains(Order.Id), 'Should contain Id field');
        System.assert(fields.contains(Order.OrderNumber), 'Should contain OrderNumber field');
        System.assert(fields.contains(Order.AccountId), 'Should contain AccountId field');
        System.assert(fields.contains(Order.Status), 'Should contain Status field');
        System.assert(fields.contains(Order.Pricebook2Id), 'Should contain Pricebook2Id field');
    }

    @IsTest
    static void testGetSObjectName() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        String result = selector.getSObjectName();
        Test.stopTest();

        System.assertEquals('Order', result, 'Should return Order as SObject name');
    }

    @IsTest
    static void testGetFieldListString() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        String result = selector.getFieldListString();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Field list string should not be null');
        System.assert(result.contains('Id'), 'Should contain Id field');
        System.assert(result.contains('Status'), 'Should contain Status field');
    }

    @IsTest
    static void testGetOrderWithItems_NotFound() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        Order result = selector.getOrderWithItems((Id) '801000000000000AAA');
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for non-existent order');
    }

    @IsTest
    static void testSelectSObjectsById_EmptySet() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        List<SObject> results = selector.selectSObjectsById(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for empty set');
    }

    @IsTest
    static void testSelectSObjectsById_NullSet() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        List<SObject> results = selector.selectSObjectsById(null);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for null set');
    }

    @IsTest
    static void testSelectSObjectById_NotFound() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        SObject result = selector.selectSObjectById((Id) '801000000000000AAA');
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for non-existent order');
    }

    @IsTest
    static void testSelectSObjectsWhere_NoWhereClause() {
        Test.startTest();
        OrderSelector selector = new OrderSelector();
        List<SObject> results = selector.selectSObjectsWhere(null);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
    }

}