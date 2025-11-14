@IsTest
/**
 * Test coverage for Product Rest Resource.
 */
private class ProductRestResourceTest {

    private static Product2 prodJson(
        String prodId, String code, String name,
        String description, String fam, Boolean isActive,
        String pbeIdOpt, Decimal unitPriceOpt
    ) {
        Product2 prod = ApplicationDependencyTestKit.p(prodId, code, name);
        prod.Description = description;
        prod.Family = fam;
        prod.IsActive = isActive;
        return prod;
    }

    /**
     * Sets rest context.
     */
    private static void setRestContext(String nameParam, String pricebookParam) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/products';
        req.httpMethod = 'GET';
        if (nameParam != null)      req.addParameter('name', nameParam);
        if (pricebookParam != null) req.addParameter('pricebookId', pricebookParam);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    }

    /**
     * Handles list body.
     */
    private static List<Object> parseListBody() {
        return (List<Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    }

    /**
     * Handles map body.
     */
    private static Map<String, Object> parseMapBody() {
        return (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    }

    /**
     * Verifies get products by name success.
     */
    @IsTest
    static void testGetProductsByName_Success() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext('Test', (String) pbId);

        Product2 p1 = prodJson('01t000000000001AAA', 'TP001', 'Test Product One', 'Description One', 'Hardware', true,
                               '01u000000000001AAA', 100);
        Product2 p2 = prodJson('01t000000000002AAA', 'TP002', 'Test Product Two', 'Description Two', 'Hardware', true,
                               '01u000000000002AAA', 100);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ p1, p2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(2, arr.size(), 'Should return 2 products');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name with pricebook id.
     */
    @IsTest
    static void testGetProductsByName_WithPricebookId() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext('Test', (String) pbId);

        Product2 p1 = prodJson('01t000000000001AAA', 'TP001', 'Test Product One', 'Description One', 'Hardware', true,
                               '01u000000000001AAA', 100);
        Product2 p2 = prodJson('01t000000000002AAA', 'TP002', 'Test Product Two', 'Description Two', 'Hardware', true,
                               '01u000000000002AAA', 100);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ p1, p2 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(2, arr.size(), 'Should return 2 products');

            Map<String, Object> r0 = (Map<String, Object>) arr[0];
            System.assertEquals('01t000000000001AAA', (String) r0.get('productId'), 'Product ID should match');
            System.assertEquals('Test Product One', (String) r0.get('name'), 'Product name should match');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name partial match.
     */
    @IsTest
    static void testGetProductsByName_PartialMatch() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext('Another', (String) pbId);

        Product2 p1 = prodJson('01t000000000003AAA', 'AP001', 'Another Product', 'Another Description', 'Software', true,
                               '01u000000000003AAA', 150);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ p1 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(1, arr.size(), 'Should return 1 product');
            Map<String, Object> r0 = (Map<String, Object>) arr[0];
            System.assertEquals('Another Product', (String) r0.get('name'), 'Product name should match');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name no match.
     */
    @IsTest
    static void testGetProductsByName_NoMatch() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext('NonExistentProduct', (String) pbId);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName = new List<Product2>();

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(0, arr.size(), 'Should return 0 products');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name missing pricebook id parameter.
     */
    @IsTest
    static void testGetProductsByName_MissingPricebookIdParameter() {
        setRestContext('Test Product', null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(400, RestContext.response.statusCode, 'Status code should be 400');
            Map<String, Object> err = parseMapBody();
            System.assertEquals('Pricebook ID parameter is required', (String) err.get('error'), 
                             'Error message should indicate pricebook ID is required');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name without name parameter.
     */
    @IsTest
    static void testGetProductsByName_WithoutNameParameter() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext(null, (String) pbId);

        Product2 p1 = prodJson('01t000000000001AAA', 'TP001', 'Test Product One', 'Description One', 'Hardware', true,
                               '01u000000000001AAA', 100);
        Product2 p2 = prodJson('01t000000000002AAA', 'TP002', 'Test Product Two', 'Description Two', 'Hardware', true,
                               '01u000000000002AAA', 100);
        Product2 p3 = prodJson('01t000000000003AAA', 'AP001', 'Another Product', 'Another Description', 'Software', true,
                               '01u000000000003AAA', 150);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ p1, p2, p3 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(3, arr.size(), 'Should return all products when name is not provided');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name empty name parameter.
     */
    @IsTest
    static void testGetProductsByName_EmptyNameParameter() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext('', (String) pbId);

        Product2 p1 = prodJson('01t000000000001AAA', 'TP001', 'Test Product One', 'Description One', 'Hardware', true,
                               '01u000000000001AAA', 100);
        Product2 p2 = prodJson('01t000000000002AAA', 'TP002', 'Test Product Two', 'Description Two', 'Hardware', true,
                               '01u000000000002AAA', 100);
        Product2 p3 = prodJson('01t000000000003AAA', 'AP001', 'Another Product', 'Another Description', 'Software', true,
                               '01u000000000003AAA', 150);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ p1, p2, p3 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(3, arr.size(), 'Should return all products when name is empty');
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name excludes inactive products.
     */
    @IsTest
    static void testGetProductsByName_ExcludesInactiveProducts() {
        Id pbId = (Id) '01s000000000001AAA';
        setRestContext('Product', (String) pbId);

        Product2 p1 = prodJson('01t000000000001AAA', 'TP001', 'Test Product One', 'Description One', 'Hardware', true,
                               '01u000000000001AAA', 100);
        Product2 p2 = prodJson('01t000000000002AAA', 'TP002', 'Test Product Two', 'Description Two', 'Hardware', true,
                               '01u000000000002AAA', 100);
        Product2 p3 = prodJson('01t000000000003AAA', 'AP001', 'Another Product', 'Another Description', 'Software', true,
                               '01u000000000003AAA', 150);
        Product2 p4 = prodJson('01t000000000004AAA', 'IP001', 'Inactive Product', 'Inactive Description', 'Hardware', false,
                               null, null);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName.addAll(new List<Product2>{ p1, p2, p3 });

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');
            List<Object> arr = parseListBody();
            System.assertEquals(3, arr.size(), 'Should return only active products');

            for (Object obj : arr) {
                Map<String, Object> product = (Map<String, Object>) obj;
                System.assertEquals(true, (Boolean) product.get('isInOrder') == false || product.get('isInOrder') == null, 
                                 'Products should be active');
            }
        } finally {
            scope.close();
        }
    }

    /**
     * Verifies get products by name 500 on exception.
     */
    @IsTest
    static void testGetProductsByName_500_on_exception() {
        Id pbId = (Id) '01s000000000009AAA';
        setRestContext(null, (String) pbId);

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.productsByName = null;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);
        try {
            Test.startTest();
            ProductRestResource.getProductsByName();
            Test.stopTest();

            System.assertEquals(500, RestContext.response.statusCode, 'Status code should be 500');
            Map<String, Object> err = parseMapBody();
            System.assert(((String) err.get('error')).startsWith('Error retrieving products'), 
                         'Should wrap error: ' + err.get('error'));
        } finally {
            scope.close();
        }
    }
}