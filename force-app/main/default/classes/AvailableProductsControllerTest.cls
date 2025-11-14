@IsTest
/**
 * Test coverage for Available Products Controller.
 */
private class AvailableProductsControllerTest {

    /**
     * Handles prod.
     */
    private static Product2 prod(String id18, String code, String name, Id parentOpt) {
        Product2 p = ApplicationDependencyTestKit.p(id18, code, name);
        if (parentOpt != null) p.put('Parent_Product__c', parentOpt);
        return p;
    }

    /**
     * Creates order.
     */
    private static Order makeOrder(Id idVal, Id pricebookId) {
        Order o = new Order();
        o.Id = idVal;
        o.Pricebook2Id = pricebookId;
        return o;
    }

    /**
     * Verifies get available products success.
     */
    @IsTest
    static void testGetAvailableProducts_Success() {
        Id orderId = (Id) '801000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        Product2 parent1 = prod('01t000000000001AAA', 'P-100', 'Parent 1', null);
        Product2 child1 = prod('01t000000000002AAA', 'C-110', 'Child 1-1', parent1.Id);
        Product2 child2 = prod('01t000000000003AAA', 'C-120', 'Child 1-2', parent1.Id);
        Product2 parent2 = prod('01t000000000004AAA', 'P-200', 'Parent 2', null);
        Product2 child3 = prod('01t000000000005AAA', 'C-210', 'Child 2-1', parent2.Id);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productQuantitiesInOrder.put(child1.Id, 2);
        d.productQuantitiesInOrder.put(child2.Id, 3);
        d.productsByName.addAll(new List<Product2>{ parent1, child1, child2, parent2, child3 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            AvailableProductsController.AvailableProductsRequest request = new AvailableProductsController.AvailableProductsRequest();
            request.orderId = orderId;
            List<AvailableProductsController.ProductTreeNode> result = 
                AvailableProductsController.getAvailableProducts(request);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            List<AvailableProductsController.ProductTreeNode> allNodes = flattenTree(result);
            System.assertEquals(5, allNodes.size(), 'Should return all 5 products');

            Integer inOrderCount = 0;
            Integer availableCount = 0;

            for (AvailableProductsController.ProductTreeNode product : allNodes) {
                System.assertNotEquals(null, product.productId, 'Product ID should not be null');
                System.assertNotEquals(null, product.name, 'Product name should not be null');
                System.assertNotEquals(null, product.isInOrder, 'isInOrder flag should not be null');

                if (product.isInOrder) {
                    inOrderCount++;
                } else {
                    availableCount++;
                }
            }

            System.assertEquals(2, inOrderCount, 'Should have 2 products in order');
            System.assertEquals(3, availableCount, 'Should have 3 available products');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get available products empty order.
     */
    @IsTest
    static void testGetAvailableProducts_EmptyOrder() {
        Id orderId = (Id) '801000000000002AAA';
        Id pricebookId = (Id) '01s000000000002AAA';

        Product2 parent1 = prod('01t000000000001AAA', 'P-100', 'Parent 1', null);
        Product2 child1 = prod('01t000000000002AAA', 'C-110', 'Child 1-1', parent1.Id);
        Product2 child2 = prod('01t000000000003AAA', 'C-120', 'Child 1-2', parent1.Id);
        Product2 parent2 = prod('01t000000000004AAA', 'P-200', 'Parent 2', null);
        Product2 child3 = prod('01t000000000005AAA', 'C-210', 'Child 2-1', parent2.Id);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productsByName.addAll(new List<Product2>{ parent1, child1, child2, parent2, child3 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            AvailableProductsController.AvailableProductsRequest request = new AvailableProductsController.AvailableProductsRequest();
            request.orderId = orderId;
            List<AvailableProductsController.ProductTreeNode> result = 
                AvailableProductsController.getAvailableProducts(request);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            List<AvailableProductsController.ProductTreeNode> allNodes = flattenTree(result);
            System.assertEquals(5, allNodes.size(), 'Should return all 5 products');

            for (AvailableProductsController.ProductTreeNode product : allNodes) {
                System.assertEquals(false, product.isInOrder, 'No products should be in order');
            }
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities success.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_Success() {
        Id orderId = (Id) '801000000000003AAA';
        Id pricebookId = (Id) '01s000000000003AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3', null);
        Product2 product4 = prod('01t000000000004AAA', 'P-400', 'Product 4', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productQuantitiesInOrder.put(product1.Id, 2);
        d.productQuantitiesInOrder.put(product2.Id, 3);
        d.productsByName.addAll(new List<Product2>{ product1, product2, product3, product4 });

        PricebookEntry pbe3 = ApplicationDependencyTestKit.pbe('01u000000000003AAA', 100);
        PricebookEntry pbe4 = ApplicationDependencyTestKit.pbe('01u000000000004AAA', 200);
        d.productIdToPbe.put(product3.Id, pbe3);
        d.productIdToPbe.put(product4.Id, pbe4);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>();
            productIdToQuantity.put(product3.Id, 5);
            productIdToQuantity.put(product4.Id, 5);

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should return success message');
            System.assert(d.insertedItems.size() >= 2, 'Should have inserted at least 2 order items');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities empty map.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_EmptyMap() {
        Id orderId = (Id) '801000000000004AAA';
        Id pricebookId = (Id) '01s000000000004AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = new Map<Id, Decimal>();
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('0 product(s)'), 'Should handle empty map');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities product not in pricebook.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_ProductNotInPricebook() {
        Id orderId = (Id) '801000000000005AAA';
        Id pricebookId = (Id) '01s000000000005AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);
        Product2 productWithoutPb = prod('01t000000000099AAA', 'P-999', 'Product Without Pricebook', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productQuantitiesInOrder.put(product1.Id, 1);
        d.productQuantitiesInOrder.put(product2.Id, 1);
        d.productsByName.addAll(new List<Product2>{ product1, product2, productWithoutPb });

        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200);
        d.productIdToPbe.put(product1.Id, pbe1);
        d.productIdToPbe.put(product2.Id, pbe2);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>();
            productIdToQuantity.put(productWithoutPb.Id, 1);

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should return success message');
            System.assertEquals(0, d.insertedItems.size(), 'Should not add product not in pricebook');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities bulk.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_Bulk() {
        Id orderId = (Id) '801000000000006AAA';
        Id pricebookId = (Id) '01s000000000006AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3', null);
        Product2 product4 = prod('01t000000000004AAA', 'P-400', 'Product 4', null);
        Product2 product5 = prod('01t000000000005AAA', 'P-500', 'Product 5', null);

        List<Product2> products = new List<Product2>{ product1, product2, product3, product4, product5 };
        Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
        
        pbeMap.put(product1.Id, ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100));
        pbeMap.put(product2.Id, ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200));
        pbeMap.put(product3.Id, ApplicationDependencyTestKit.pbe('01u000000000003AAA', 300));
        pbeMap.put(product4.Id, ApplicationDependencyTestKit.pbe('01u000000000004AAA', 400));
        pbeMap.put(product5.Id, ApplicationDependencyTestKit.pbe('01u000000000005AAA', 500));

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productsByName.addAll(products);
        d.productIdToPbe.putAll(pbeMap);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>();
            for (Product2 product : products) {
                productIdToQuantity.put(product.Id, 10);
            }

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should handle bulk operations');
            System.assert(d.insertedItems.size() >= 5, 'Should have multiple order items');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities map object object.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_MapObjectObject() {
        Id orderId = (Id) '801000000000007AAA';
        Id pricebookId = (Id) '01s000000000007AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productsByName.addAll(new List<Product2>{ product1, product2 });

        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200);
        d.productIdToPbe.put(product1.Id, pbe1);
        d.productIdToPbe.put(product2.Id, pbe2);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Object, Object> productIdToQuantity = new Map<Object, Object>();
            productIdToQuantity.put(String.valueOf(product1.Id), 5);
            productIdToQuantity.put(String.valueOf(product2.Id), 10);

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should handle Map<Object, Object>');
            System.assert(d.insertedItems.size() >= 2, 'Should have inserted order items');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities map string object.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_MapStringObject() {
        Id orderId = (Id) '801000000000008AAA';
        Id pricebookId = (Id) '01s000000000008AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productsByName.addAll(new List<Product2>{ product1, product2 });

        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200);
        d.productIdToPbe.put(product1.Id, pbe1);
        d.productIdToPbe.put(product2.Id, pbe2);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<String, Object> productIdToQuantity = new Map<String, Object>();
            productIdToQuantity.put(String.valueOf(product1.Id), 5);
            productIdToQuantity.put(String.valueOf(product2.Id), 10);

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should handle Map<String, Object>');
            System.assert(d.insertedItems.size() >= 2, 'Should have inserted order items');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities different numeric types.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_DifferentNumericTypes() {
        Id orderId = (Id) '801000000000009AAA';
        Id pricebookId = (Id) '01s000000000009AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, pricebookId);
        d.productsByName.addAll(new List<Product2>{ product1, product2, product3 });

        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200);
        PricebookEntry pbe3 = ApplicationDependencyTestKit.pbe('01u000000000003AAA', 300);
        d.productIdToPbe.put(product1.Id, pbe1);
        d.productIdToPbe.put(product2.Id, pbe2);
        d.productIdToPbe.put(product3.Id, pbe3);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Object, Object> productIdToQuantity = new Map<Object, Object>();
            productIdToQuantity.put(String.valueOf(product1.Id), 5.5);
            productIdToQuantity.put(String.valueOf(product2.Id), 10);
            productIdToQuantity.put(String.valueOf(product3.Id), '15');

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should handle different numeric types');
            System.assert(d.insertedItems.size() >= 3, 'Should have inserted order items');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities with pricebook id.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_WithPricebookId() {
        Id orderId = (Id) '801000000000010AAA';
        Id pricebookId = (Id) '01s000000000010AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1', null);
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = makeOrder(orderId, null);
        d.productsByName.addAll(new List<Product2>{ product1, product2 });

        PricebookEntry pbe1 = ApplicationDependencyTestKit.pbe('01u000000000001AAA', 100);
        PricebookEntry pbe2 = ApplicationDependencyTestKit.pbe('01u000000000002AAA', 200);
        d.productIdToPbe.put(product1.Id, pbe1);
        d.productIdToPbe.put(product2.Id, pbe2);

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>();
            productIdToQuantity.put(product1.Id, 5);
            productIdToQuantity.put(product2.Id, 10);

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.pricebookId = pricebookId;
            request.productIdToQuantity = productIdToQuantity;
            String result = AvailableProductsController.addProductsToOrderWithQuantities(request);
            Test.stopTest();

            System.assert(result.contains('product(s) added'), 'Should handle request with pricebookId');
            System.assert(d.insertedItems.size() >= 2, 'Should have inserted order items');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies add products to order with quantities exception handling.
     */
    @IsTest
    static void testAddProductsToOrderWithQuantities_ExceptionHandling() {
        Id orderId = (Id) '801000000000011AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = null;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Map<Id, Decimal> productIdToQuantity = new Map<Id, Decimal>();
            productIdToQuantity.put((Id) '01t000000000001AAA', 5);

            Test.startTest();
            AvailableProductsController.AddProductsRequest request = new AvailableProductsController.AddProductsRequest();
            request.orderId = orderId;
            request.productIdToQuantity = productIdToQuantity;
            
            Boolean threw = false;
            try {
                AvailableProductsController.addProductsToOrderWithQuantities(request);
            } catch (AuraHandledException e) {
                threw = true;
            }
            Test.stopTest();

            System.assertEquals(true, threw, 'Should throw AuraHandledException when order is null');
        } finally {
            scope.close();
        }
    }

    /**
     * Handles tree.
     */
    private static List<AvailableProductsController.ProductTreeNode> flattenTree(List<AvailableProductsController.ProductTreeNode> nodes) {
        List<AvailableProductsController.ProductTreeNode> flat = new List<AvailableProductsController.ProductTreeNode>();
        if (nodes == null) {
            return flat;
        }

        for (AvailableProductsController.ProductTreeNode node : nodes) {
            flat.add(node);
            if (node.items != null && !node.items.isEmpty()) {
                flat.addAll(flattenTree(node.items));
            }
        }
        return flat;
    }
}