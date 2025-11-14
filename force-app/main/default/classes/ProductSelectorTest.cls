@IsTest
/**
 * Test coverage for Product Selector.
 */
private class ProductSelectorTest {

    /**
     * Verifies get sobject type.
     */
    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
        ProductSelector selector = new ProductSelector();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        System.assertEquals(Product2.SObjectType, result, 'Should return Product2 SObjectType');
    }

    /**
     * Verifies get sobject field list.
     */
    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        ProductSelector selector = new ProductSelector();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(null, fields, 'Field list should not be null');
        System.assert(fields.size() > 0, 'Field list should contain fields');
        System.assert(fields.contains(Product2.Id), 'Should contain Id field');
        System.assert(fields.contains(Product2.Name), 'Should contain Name field');
        System.assert(fields.contains(Product2.ProductCode), 'Should contain ProductCode field');
        System.assert(fields.contains(Product2.IsActive), 'Should contain IsActive field');
        System.assert(fields.contains(Product2.Family), 'Should contain Family field');
        System.assert(fields.contains(Product2.Description), 'Should contain Description field');
        System.assert(fields.contains(Product2.Parent_Product__c), 'Should contain Parent_Product__c field');
    }

    /**
     * Verifies get order products empty set.
     */
    @IsTest
    static void testGetOrderProducts_EmptySet() {
        Test.startTest();
        ProductSelector selector = new ProductSelector();
        List<Product2> result = selector.getOrderProducts(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list for empty set');
    }

    /**
     * Verifies get order products null set.
     */
    @IsTest
    static void testGetOrderProducts_NullSet() {
        Test.startTest();
        ProductSelector selector = new ProductSelector();
        List<Product2> result = selector.getOrderProducts(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list for null set');
    }

    /**
     * Verifies get products by name null pricebook id.
     */
    @IsTest
    static void testGetProductsByName_NullPricebookId() {
        Test.startTest();
        ProductSelector selector = new ProductSelector();
        try {
            List<Product2> result = selector.getProductsByName('Test', null);
            System.assert(false, 'Should throw IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Pricebook ID is required'), 
                         'Should throw error about pricebook ID being required');
        }
        Test.stopTest();
    }

    /**
     * Verifies get products by name with product name.
     */
    @IsTest
    static void testGetProductsByName_WithProductName() {
        Id pricebookId = (Id) '01s000000000001AAA';

        Test.startTest();
        ProductSelector selector = new ProductSelector();
        List<Product2> results = selector.getProductsByName('Widget', pricebookId);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null even when no data exists');
        System.assertEquals(0, results.size(), 'Should return empty list when no matching products exist');
    }

    /**
     * Verifies get products by name without product name.
     */
    @IsTest
    static void testGetProductsByName_WithoutProductName() {
        Id pricebookId = (Id) '01s000000000002AAA';

        Test.startTest();
        ProductSelector selector = new ProductSelector();
        List<Product2> results = selector.getProductsByName(null, pricebookId);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null even when no data exists');
        System.assertEquals(0, results.size(), 'Should return empty list when pricebook has no products');
    }
}