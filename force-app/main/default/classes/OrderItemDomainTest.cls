@IsTest
/**
 * Test coverage for Order Item Domain.
 */
private class OrderItemDomainTest {

    /**
     * Verifies on before insert validation success.
     */
    @IsTest
    static void testOnBeforeInsert_Validation_Success() {
        Id orderId = (Id) '801000000000001AAA';
        Id productId = (Id) '01t000000000001AAA';
        Id pbeId = (Id) '01u000000000001AAA';

        OrderItem newItem = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pbeId,
            Product2Id = productId,
            Quantity = 5,
            UnitPrice = 100
        );

        OrderItemDomain domain = new OrderItemDomain(new List<OrderItem>{ newItem });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assertEquals(5, newItem.Quantity, 'Quantity should be set');
        System.assertEquals(100, newItem.UnitPrice, 'Unit price should be set');
        System.assert(!newItem.hasErrors(), 'OrderItem should not have errors');
    }

    /**
     * Verifies on before insert validation no order.
     */
    @IsTest
    static void testOnBeforeInsert_Validation_NoOrder() {
        Id productId = (Id) '01t000000000002AAA';
        Id pbeId = (Id) '01u000000000002AAA';

        OrderItem newItem = new OrderItem(
            PricebookEntryId = pbeId,
            Product2Id = productId,
            Quantity = 5,
            UnitPrice = 100
        );

        OrderItemDomain domain = new OrderItemDomain(new List<OrderItem>{ newItem });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assert(newItem.hasErrors(), 'OrderItem should have validation errors');
    }

    /**
     * Verifies on before insert validation no product.
     */
    @IsTest
    static void testOnBeforeInsert_Validation_NoProduct() {
        Id orderId = (Id) '801000000000002AAA';

        OrderItem newItem = new OrderItem(
            OrderId = orderId,
            Quantity = 5,
            UnitPrice = 100
        );

        OrderItemDomain domain = new OrderItemDomain(new List<OrderItem>{ newItem });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assert(newItem.hasErrors(), 'OrderItem should have validation errors');
    }

    /**
     * Verifies on before insert validation invalid quantity.
     */
    @IsTest
    static void testOnBeforeInsert_Validation_InvalidQuantity() {
        Id orderId = (Id) '801000000000003AAA';
        Id productId = (Id) '01t000000000003AAA';
        Id pbeId = (Id) '01u000000000003AAA';

        OrderItem newItem = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pbeId,
            Product2Id = productId,
            Quantity = 0,
            UnitPrice = 100
        );

        OrderItemDomain domain = new OrderItemDomain(new List<OrderItem>{ newItem });
        
        Test.startTest();
        domain.handleBeforeInsert();
        Test.stopTest();

        System.assert(newItem.hasErrors(), 'OrderItem should have validation errors');
    }

    /**
     * Verifies on before update validation.
     */
    @IsTest
    static void testOnBeforeUpdate_Validation() {
        Id orderId = (Id) '801000000000004AAA';
        Id productId = (Id) '01t000000000004AAA';
        Id pbeId = (Id) '01u000000000004AAA';
        Id itemId = (Id) '802000000000001AAA';

        OrderItem item = new OrderItem(
            Id = itemId,
            OrderId = orderId,
            PricebookEntryId = pbeId,
            Product2Id = productId,
            Quantity = 2,
            UnitPrice = 100
        );

        item.Quantity = 10;

        OrderItemDomain domain = new OrderItemDomain(new List<OrderItem>{ item });
        Map<Id, SObject> existingRecords = new Map<Id, SObject>{
            itemId => new OrderItem(Id = itemId, Quantity = 2)
        };
        
        Test.startTest();
        domain.handleBeforeUpdate(existingRecords);
        Test.stopTest();

        System.assertEquals(10, item.Quantity, 'Should update Quantity');
    }

}