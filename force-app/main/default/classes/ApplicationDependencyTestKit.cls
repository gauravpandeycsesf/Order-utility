@IsTest
public class ApplicationDependencyTestKit {
    // =========================
    //  Data bucket for stubbing
    // =========================
    public class Data {
        // IDs you might care about
        public Id orderId;
        public Id pricebookId;

        // Values returned by dependency methods (READS)
        public Order  order;                                     // getOrderWithItems
        public Map<Id, Decimal> productQuantitiesInOrder =       // getProductQuantitiesInOrder
            new Map<Id, Decimal>();
        public List<Product2>   productsByName = new List<Product2>(); // getProductsByName(String, Id)

        public Set<Id>   orderItemProductIds = new Set<Id>();    // getProductIdsInOrder
        public List<Product2> availableProducts = new List<Product2>(); // getAvailableProductsForOrder
        public List<Product2> orderProducts   = new List<Product2>();   // getOrderProducts
        public List<OrderItem> orderItemsByOrder = new List<OrderItem>(); // getOrderItemsByOrder
        public List<OrderItem> existingOrderItems = new List<OrderItem>(); // queryExistingOrderItems
        public Map<Id, PricebookEntry> productIdToPbe = new Map<Id, PricebookEntry>(); // queryActivePricebookEntries

        // Support for getOrderItemsByIds
        public Map<Id, OrderItem> itemsById = new Map<Id, OrderItem>();

        // Support for pagination
        public List<OrderItem> orderItemsByOrderPaginated = new List<OrderItem>(); // getOrderItemsByOrderPaginated
        public Integer orderItemsCount = 0; // getOrderItemsCount

        // Captured "writes" for assertions (WRITES)
        public List<OrderItem> insertedItems = new List<OrderItem>(); // insertOrderItems
        public List<OrderItem> updatedItems  = new List<OrderItem>(); // updateOrderItems
        public Id activatedOrderId;                                   // activateOrder
        public Order insertedOrder;                                   // insertOrder
        public List<OrderItem> orderItemsForOrder = new List<OrderItem>(); // getOrderItemsForOrder
        public List<Id> deletedOrderItemIds = new List<Id>(); // deleteOrderItems
    }

    // ==========================================
    //  Stub for ApplicationDependencyProvider
    //  (older handleMethodCall signature)
    // ==========================================
    private class ProviderStub implements System.StubProvider {
        private final Data d;
        ProviderStub(Data data) { this.d = data; }

        public Object handleMethodCall(
            Object stub,
            String methodName,
            System.Type returnType,
            List<System.Type> paramTypes,
            List<String> paramNames,
            List<Object> args
        ) {
            // --------- Readers ----------
            if (methodName == 'getOrderWithItems') {
                // (Id orderId)
                return d.order;
            }
            if (methodName == 'getProductQuantitiesInOrder') {
                // (Id orderId)
                return d.productQuantitiesInOrder;
            }
            if (methodName == 'getProductsByName') {
                // (String nameFilter, Id pricebookId)
                // Keep it simple for tests: return whatever tests loaded.
                return d.productsByName;
            }
            if (methodName == 'getProductIdsInOrder') {
                // (Id orderId)
                return d.orderItemProductIds;
            }
            if (methodName == 'getAvailableProductsForOrder') {
                // (Id pricebookId, Set<Id> excludeIds)
                Set<Id> exclude = (args != null && args.size() > 1 && args[1] != null)
                    ? (Set<Id>) args[1] : new Set<Id>();
                List<Product2> out = new List<Product2>();
                for (Product2 p : d.availableProducts) if (!exclude.contains(p.Id)) out.add(p);
                return out;
            }
            if (methodName == 'getOrderProducts') {
                // (Set<Id> productIds)
                return d.orderProducts;
            }
            if (methodName == 'getOrderItemsByOrder') {
                // (Id orderId)
                return d.orderItemsByOrder;
            }
            if (methodName == 'getOrderItemsByOrderPaginated') {
                // (Id orderId, Integer offset, Integer pageSize)
                return d.orderItemsByOrderPaginated;
            }
            if (methodName == 'getOrderItemsCount') {
                // (Id orderId)
                return d.orderItemsCount;
            }
            if (methodName == 'getOrderItemsForOrder') {
                // (Id orderId)
                return d.orderItemsForOrder;
            }
            if (methodName == 'queryExistingOrderItems') {
                // (Id orderId, Set<Id> productIds)
                return d.existingOrderItems;
            }
            if (methodName == 'queryActivePricebookEntries') {
                // (Id pricebookId, Set<Id> productIds)
                return d.productIdToPbe;
            }
            if (methodName == 'getOrderItemsByIds') {
                // (List<Id> ids)
                List<Id> ids = (List<Id>) args[0];
                List<OrderItem> result = new List<OrderItem>();
                for (Id i : ids) if (d.itemsById.containsKey(i)) result.add(d.itemsById.get(i));
                return result;
            }

            // --------- Writers / commands ----------
            if (methodName == 'insertOrderItems') {
                // (List<OrderItem> items)
                d.insertedItems.addAll((List<OrderItem>) args[0]);
                return null;
            }
            if (methodName == 'updateOrderItems') {
                // (List<OrderItem> items)
                d.updatedItems.addAll((List<OrderItem>) args[0]);
                return null;
            }
            if (methodName == 'updateOrder') {
                // (Order order)
                Order orderToUpdate = (Order) args[0];
                if (d.order != null && d.order.Id == orderToUpdate.Id) {
                    d.order.Status = orderToUpdate.Status;
                }
                return null;
            }
            if (methodName == 'insertOrder') {
                // (Order order)
                Order orderToInsert = (Order) args[0];
                if (orderToInsert.Id == null) {
                    if (d.insertedOrder != null && d.insertedOrder.Id != null) {
                        orderToInsert.Id = d.insertedOrder.Id;
                    } else if (d.order != null && d.order.Id != null) {
                        orderToInsert.Id = d.order.Id;
                    } else {
                        orderToInsert.Id = (Id) '801000000000001AAA';
                    }
                }
                if (d.insertedOrder == null) {
                    d.insertedOrder = orderToInsert;
                }
                if (d.order == null) {
                    d.order = orderToInsert;
                } else if (d.order.Id == orderToInsert.Id) {
                    d.order = orderToInsert;
                }
                return orderToInsert;
            }
            if (methodName == 'activateOrder') {
                // (Id orderId)
                d.activatedOrderId = (Id) args[0];
                if (d.order != null && d.order.Id == (Id) args[0]) {
                    d.order.Status = 'Activated';
                }
                return null;
            }
            if (methodName == 'deleteOrderItems') {
                // (List<Id> orderItemIds)
                List<Id> ids = (List<Id>) args[0];
                if (ids != null) {
                    d.deletedOrderItemIds.addAll(ids);
                }
                return null;
            }

            // Unused → null is fine
            return null;
        }
    }

    // ======================
    //  Factory & override API
    // ======================
    public static ApplicationDependencyProvider makeProvider(Data data) {
        return (ApplicationDependencyProvider) Test.createStub(
            ApplicationDependencyProvider.class,
            new ProviderStub(data)
        );
    }

    public class Scope {
        private ApplicationDependencyProvider original;
        Scope(ApplicationDependencyProvider o) { original = o; }
        public void close() { ApplicationDependencyContext.setProvider(original); }
    }
    public static Scope overrideProvider(ApplicationDependencyProvider fake) {
        ApplicationDependencyProvider original = ApplicationDependencyContext.getProvider();
        ApplicationDependencyContext.setProvider(fake);
        return new Scope(original);
    }

    // ==========================
    //  Lightweight object makers
    //  (only writeable fields)
    // ==========================
    public static Product2 p(String id18, String code, String name) {
        Product2 x = new Product2();
        x.Id = (Id) id18;   // '01t...' recommended but not required
        x.ProductCode = code;
        x.Name = name;
        return x;
    }

    public static PricebookEntry pbe(String id18, Decimal unit) {
        PricebookEntry e = new PricebookEntry();
        e.Id = (Id) id18;   // '01u...' recommended but not required
        e.UnitPrice = unit;
        e.IsActive = true;
        // Do NOT set Pricebook2Id/Product2Id here (often read-only in-memory)
        return e;
    }

    // Minimal OrderItem (avoid non-writeable fields like OrderId, Product2Id, PricebookEntryId)
    public static OrderItem oi(String id18, Decimal qty, Decimal unit) {
        OrderItem o = new OrderItem();
        if (id18 != null) o.Id = (Id) id18;  // '802...' recommended but not required
        o.Quantity = qty;
        o.UnitPrice = unit;
        return o;
    }

    /**
     * Build an "existing" OrderItem with read-only fields (e.g., Product2Id, PricebookEntryId)
     * via JSON to avoid writeability errors in tests. Use ONLY in tests—never in production code.
     */
    public static OrderItem oiJson(String id18, Id product2Id, Id pbeId, Decimal qty, Decimal unit) {
        Map<String, Object> m = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'OrderItem' },
            'Quantity'   => qty,
            'UnitPrice'  => unit
        };
        if (id18 != null)       m.put('Id', (String) id18);
        if (product2Id != null) m.put('Product2Id', (String) product2Id);
        if (pbeId != null)      m.put('PricebookEntryId', (String) pbeId);

        String payload = JSON.serialize(m);
        return (OrderItem) JSON.deserializeStrict(payload, OrderItem.class);
    }
}