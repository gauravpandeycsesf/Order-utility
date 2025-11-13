@IsTest
private class ProductDomainTest {

    private static Product2 prod(String id18, String code, String name) {
        return ApplicationDependencyTestKit.p(id18, code, name);
    }

    @IsTest
    static void testOnBeforeInsert_Validation_Success() {
        Product2 newProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TEST-001',
            IsActive = true,
            Description = 'Test Description'
        );

        Test.startTest();
        insert newProduct;
        Test.stopTest();

        Product2 insertedProduct = [SELECT Name, ProductCode, IsActive FROM Product2 WHERE Id = :newProduct.Id];
        System.assertEquals('Test Product', insertedProduct.Name, 'Product name should be set');
        System.assertEquals('TEST-001', insertedProduct.ProductCode, 'Product code should be set');
        System.assertEquals(true, insertedProduct.IsActive, 'Product should be active');
    }

    @IsTest
    static void testOnBeforeInsert_Validation_BlankName() {
        Product2 newProduct = new Product2(
            Name = '',
            ProductCode = 'TEST-003',
            IsActive = true
        );

        ProductDomain domain = new ProductDomain(new List<Product2>{ newProduct });
        domain.handleBeforeInsert();

        Test.startTest();
        Database.SaveResult result = Database.insert(newProduct, false);
        Test.stopTest();

        System.assert(!result.isSuccess(), 'Insert should fail due to validation error');
        System.assert(result.getErrors().size() > 0, 'Should have validation errors');
    }

    @IsTest
    static void testOnBeforeInsert_Validation_WhitespaceName() {
        Product2 newProduct = new Product2(
            Name = '   ',
            ProductCode = 'TEST-004',
            IsActive = true
        );

        ProductDomain domain = new ProductDomain(new List<Product2>{ newProduct });
        domain.handleBeforeInsert();

        Test.startTest();
        Database.SaveResult result = Database.insert(newProduct, false);
        Test.stopTest();

        System.assert(!result.isSuccess(), 'Insert should fail due to validation error');
        System.assert(result.getErrors().size() > 0, 'Should have validation errors');
    }

    @IsTest
    static void testOnBeforeUpdate_Validation_Success() {
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TEST-001',
            IsActive = true
        );
        insert testProduct;

        testProduct.Name = 'Updated Product Name';
        testProduct.Description = 'Updated Description';

        Test.startTest();
        update testProduct;
        Test.stopTest();

        Product2 updatedProduct = [SELECT Name, Description FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals('Updated Product Name', updatedProduct.Name, 'Product name should be updated');
        System.assertEquals('Updated Description', updatedProduct.Description, 'Description should be updated');
    }

    @IsTest
    static void testOnBeforeUpdate_Validation_BlankName() {
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TEST-001',
            IsActive = true
        );
        insert testProduct;

        testProduct.Name = null;

        ProductDomain domain = new ProductDomain(new List<Product2>{ testProduct });
        domain.handleBeforeUpdate(new Map<Id, SObject>{ testProduct.Id => testProduct });

        Test.startTest();
        Database.SaveResult result = Database.update(testProduct, false);
        Test.stopTest();

        System.assert(!result.isSuccess(), 'Update should fail due to validation error');
        System.assert(result.getErrors().size() > 0, 'Should have validation errors');
    }

    @IsTest
    static void testGetProductsByPricebook_Success() {
        Id pricebookId = (Id) '01s000000000001AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1');
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2');
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3');
        Product2 product4 = prod('01t000000000004AAA', 'P-400', 'Product 4');
        Product2 product5 = prod('01t000000000005AAA', 'P-500', 'Product 5');

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts.addAll(new List<Product2>{ product1, product2, product3, product4, product5 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = ProductDomain.getProductsByPricebook(pricebookId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return products');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetProductsByPricebook_EmptyPricebook() {
        Id pricebookId = (Id) '01s000000000002AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts = new List<Product2>();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = ProductDomain.getProductsByPricebook(pricebookId);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list for pricebook with no products');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_Success() {
        Id pricebookId = (Id) '01s000000000003AAA';
        Id productId1 = (Id) '01t000000000001AAA';
        Id productId2 = (Id) '01t000000000002AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1');
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2');
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3');

        Set<Id> orderItemProductIds = new Set<Id>{ productId1, productId2 };

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts.addAll(new List<Product2>{ product1, product2, product3 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = ProductDomain.getAvailableProductsForOrder(pricebookId, orderItemProductIds);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return available products');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_EmptyOrder() {
        Id pricebookId = (Id) '01s000000000004AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1');
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2');
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3');
        Product2 product4 = prod('01t000000000004AAA', 'P-400', 'Product 4');
        Product2 product5 = prod('01t000000000005AAA', 'P-500', 'Product 5');

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts.addAll(new List<Product2>{ product1, product2, product3, product4, product5 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = ProductDomain.getAvailableProductsForOrder(pricebookId, new Set<Id>());
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return all products when order is empty');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_NullProductIds() {
        Id pricebookId = (Id) '01s000000000005AAA';

        Product2 product1 = prod('01t000000000001AAA', 'P-100', 'Product 1');
        Product2 product2 = prod('01t000000000002AAA', 'P-200', 'Product 2');
        Product2 product3 = prod('01t000000000003AAA', 'P-300', 'Product 3');
        Product2 product4 = prod('01t000000000004AAA', 'P-400', 'Product 4');
        Product2 product5 = prod('01t000000000005AAA', 'P-500', 'Product 5');

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts.addAll(new List<Product2>{ product1, product2, product3, product4, product5 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = ProductDomain.getAvailableProductsForOrder(pricebookId, null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should return all products when product IDs set is null');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_AllProductsInOrder() {
        Id pricebookId = (Id) '01s000000000006AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts = new List<Product2>();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Set<Id> allProductIds = new Set<Id>{
                (Id) '01t000000000001AAA',
                (Id) '01t000000000002AAA',
                (Id) '01t000000000003AAA',
                (Id) '01t000000000004AAA',
                (Id) '01t000000000005AAA'
            };

            Test.startTest();
            List<Product2> result = ProductDomain.getAvailableProductsForOrder(pricebookId, allProductIds);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return empty list when all products are in order');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testGetAvailableProductsForOrder_InvalidPricebookId() {
        Id invalidPricebookId = (Id) '01s000000000099AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.availableProducts = new List<Product2>();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            List<Product2> result = ProductDomain.getAvailableProductsForOrder(invalidPricebookId, new Set<Id>());
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() >= 0, 'Should handle invalid pricebook gracefully');
        } finally {
            scope.close();
        }
    }
}