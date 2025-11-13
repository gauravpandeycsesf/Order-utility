public class ProductDomain extends SObjectDomain {
    
    public ProductDomain(List<Product2> records) {
        super(records);
    }
    
    public ProductDomain(List<Product2> records, ISObjectUnitOfWork uow) {
        super(records, uow);
    }
    
    public override void onBeforeInsert() {
        validateProducts();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateProducts();
    }
    
    private void validateProducts() {
        for (Product2 product : (List<Product2>) Records) {
            if (String.isBlank(product.Name)) {
                product.addError('Product Name is required');
            }
        }
    }
    
    public static List<Product2> getProductsByPricebook(Id pricebookId) {
        ProductSelector selector = new ProductSelector();
        return selector.getProductsByPricebook(pricebookId);
    }
    
    public static List<Product2> getAvailableProductsForOrder(Id pricebookId, Set<Id> orderItemProductIds) {
        ProductSelector selector = new ProductSelector();
        return selector.getAvailableProductsForOrder(pricebookId, orderItemProductIds);
    }
}