/**
 * @description Shared stub provider for tests. Allows individual test methods to override specific dependency
 *              calls while falling back to the default implementation when not overridden.
 */
global class ApplicationDependencyTestStub implements System.StubProvider {

    public interface ResponseHandler {
        Object invoke(List<Object> params);
    }

    private final Map<String, Object> overrides;
    private final ApplicationDependencyProvider fallbackProvider;

    public ApplicationDependencyTestStub() {
        this(new Map<String, Object>());
    }

    public ApplicationDependencyTestStub(Map<String, Object> overrides) {
        this.overrides = (overrides == null) ? new Map<String, Object>() : overrides;
        this.fallbackProvider = new ApplicationDependencyProvider();
    }

    global Object handleMethodCall(
        Object stubbedObject,
        String stubbedMethodName,
        System.Type returnType,
        List<System.Type> stubbedMethodParamTypes,
        List<String> stubbedMethodParamNames,
        List<Object> stubbedMethodParamValues
    ) {
        if (overrides.containsKey(stubbedMethodName)) {
            Object overrideValue = overrides.get(stubbedMethodName);
            if (overrideValue instanceof ResponseHandler) {
                return ((ResponseHandler) overrideValue).invoke(stubbedMethodParamValues);
            }
            return overrideValue;
        }

        if (stubbedMethodName == 'getOrderWithItems') {
            return fallbackProvider.getOrderWithItems((Id) stubbedMethodParamValues.get(0));
        } else if (stubbedMethodName == 'getProductIdsInOrder') {
            return fallbackProvider.getProductIdsInOrder((Id) stubbedMethodParamValues.get(0));
        } else if (stubbedMethodName == 'getProductQuantitiesInOrder') {
            return fallbackProvider.getProductQuantitiesInOrder((Id) stubbedMethodParamValues.get(0));
        } else if (stubbedMethodName == 'getProductsByName') {
            return fallbackProvider.getProductsByName((String) stubbedMethodParamValues.get(0), (Id) stubbedMethodParamValues.get(1));
        } else if (stubbedMethodName == 'getAvailableProductsForOrder') {
            return fallbackProvider.getAvailableProductsForOrder((Id) stubbedMethodParamValues.get(0), (Set<Id>) stubbedMethodParamValues.get(1));
        } else if (stubbedMethodName == 'getOrderProducts') {
            return fallbackProvider.getOrderProducts((Set<Id>) stubbedMethodParamValues.get(0));
        } else if (stubbedMethodName == 'getOrderItemsByOrder') {
            return fallbackProvider.getOrderItemsByOrder((Id) stubbedMethodParamValues.get(0));
        } else if (stubbedMethodName == 'getOrderItemsByIds') {
            return fallbackProvider.getOrderItemsByIds((List<Id>) stubbedMethodParamValues.get(0));
        } else if (stubbedMethodName == 'queryExistingOrderItems') {
            return fallbackProvider.queryExistingOrderItems((Id) stubbedMethodParamValues.get(0), (Set<Id>) stubbedMethodParamValues.get(1));
        } else if (stubbedMethodName == 'queryActivePricebookEntries') {
            return fallbackProvider.queryActivePricebookEntries((Id) stubbedMethodParamValues.get(0), (Set<Id>) stubbedMethodParamValues.get(1));
        } else if (stubbedMethodName == 'insertOrderItems') {
            fallbackProvider.insertOrderItems((List<OrderItem>) stubbedMethodParamValues.get(0));
            return null;
        } else if (stubbedMethodName == 'updateOrderItems') {
            fallbackProvider.updateOrderItems((List<OrderItem>) stubbedMethodParamValues.get(0));
            return null;
        } else if (stubbedMethodName == 'activateOrder') {
            fallbackProvider.activateOrder((Id) stubbedMethodParamValues.get(0));
            return null;
        }

        return null;
    }
}