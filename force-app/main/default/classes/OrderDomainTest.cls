@IsTest
private class OrderDomainTest {

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
    static void testOnBeforeInsert_Validation_Success() {
        Id accountId = (Id) '001000000000001AAA';
        Id pricebookId = (Id) '01s000000000001AAA';

        Order newOrder = new Order(
            AccountId = accountId,
            Pricebook2Id = pricebookId,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );

        OrderDomain domain = new OrderDomain(new List<Order>{ newOrder });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assertEquals(accountId, newOrder.AccountId, 'Account should be set');
        System.assertNotEquals(null, newOrder.EffectiveDate, 'Effective date should be set');
        System.assertEquals('Draft', newOrder.Status, 'Status should be Draft');
    }

    @IsTest
    static void testOnBeforeInsert_Validation_NoAccount() {
        Id pricebookId = (Id) '01s000000000002AAA';

        Order newOrder = new Order(
            Pricebook2Id = pricebookId,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );

        OrderDomain domain = new OrderDomain(new List<Order>{ newOrder });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assert(newOrder.hasErrors(), 'Order should have validation errors');
    }

    @IsTest
    static void testOnBeforeInsert_Validation_NoEffectiveDate() {
        Id accountId = (Id) '001000000000002AAA';
        Id pricebookId = (Id) '01s000000000003AAA';

        Order newOrder = new Order(
            AccountId = accountId,
            Pricebook2Id = pricebookId,
            Status = 'Draft'
        );

        OrderDomain domain = new OrderDomain(new List<Order>{ newOrder });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assertNotEquals(null, newOrder.EffectiveDate, 'Domain class should set EffectiveDate');
        System.assertEquals(Date.today(), newOrder.EffectiveDate, 'Domain class should set EffectiveDate to today');
    }

    @IsTest
    static void testOnBeforeUpdate_Validation() {
        Id accountId = (Id) '001000000000003AAA';
        Id pricebookId = (Id) '01s000000000004AAA';
        Id orderId = (Id) '801000000000001AAA';

        Order testOrder = makeOrder(orderId, pricebookId, accountId);
        testOrder.EffectiveDate = Date.today().addDays(10);

        OrderDomain domain = new OrderDomain(new List<Order>{ testOrder });
        Map<Id, SObject> existingRecords = new Map<Id, SObject>{ orderId => makeOrder(orderId, pricebookId, accountId) };
        
        Test.startTest();
        domain.handleBeforeUpdate(existingRecords);
        Test.stopTest();

        System.assertEquals(Date.today().addDays(10), testOrder.EffectiveDate, 'Should update EffectiveDate');
    }


    @IsTest
    static void testOnBeforeInsert_SetDefaultEffectiveDate() {
        Id accountId = (Id) '001000000000007AAA';
        Id pricebookId = (Id) '01s000000000008AAA';

        Order newOrder = new Order(
            AccountId = accountId,
            Pricebook2Id = pricebookId,
            Status = 'Draft'
        );

        OrderDomain domain = new OrderDomain(new List<Order>{ newOrder });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assertNotEquals(null, newOrder.EffectiveDate, 'Domain class should set EffectiveDate');
        System.assertEquals(Date.today(), newOrder.EffectiveDate, 'Domain class should set EffectiveDate to today');
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

            System.assertEquals(orderId, d.activatedOrderId, 'Should capture activated order ID');
            System.assertEquals('Activated', d.order.Status, 'Order status should be Activated');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testActivateOrder_AlreadyActivated() {
        Id orderId = (Id) '801000000000002AAA';
        Id accountId = (Id) '001000000000002AAA';
        Id pricebookId = (Id) '01s000000000002AAA';

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

            System.assertEquals(orderId, d.activatedOrderId, 'Should capture activated order ID');
            System.assertEquals('Activated', d.order.Status, 'Order status should remain Activated');
        } finally {
            scope.close();
        }
    }

    @IsTest
    static void testActivateOrder_InvalidOrderId() {
        Id invalidOrderId = (Id) '801000000000999AAA';

        ApplicationDependencyTestKit.Data d = new ApplicationDependencyTestKit.Data();
        d.order = null;

        ApplicationDependencyProvider fake = ApplicationDependencyTestKit.makeProvider(d);
        ApplicationDependencyTestKit.Scope scope = ApplicationDependencyTestKit.overrideProvider(fake);

        try {
            Test.startTest();
            ApplicationDependencyProvider provider = ApplicationDependencyContext.getProvider();
            provider.activateOrder(invalidOrderId);
            Test.stopTest();

            System.assertEquals(invalidOrderId, d.activatedOrderId, 'Should capture order ID even if order is null');
        } finally {
            scope.close();
        }
    }
}