/**
 * Domain layer for enforcing Product2 validation and exposing helper queries.
 */
public class ProductDomain extends SObjectDomain {
    
    /**
     * Creates a domain instance to manage product records.
     *
     * @param records products under management.
     */
    public ProductDomain(List<Product2> records) {
        super(records);
    }
    
    /**
     * Creates a domain instance backed by a unit of work.
     *
     * @param records products under management.
     * @param uow unit of work coordinating commits.
     */
    public ProductDomain(List<Product2> records, ISObjectUnitOfWork uow) {
        super(records, uow);
    }
    
    /**
     * Validates product data before insert.
     */
    public override void onBeforeInsert() {
        validateProducts();
    }
    
    /**
     * Validates product data before update.
     *
     * @param existingRecords map of existing products.
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateProducts();
    }
    
    /**
     * Ensures required fields such as Name are populated.
     */
    private void validateProducts() {
        for (Product2 product : (List<Product2>) Records) {
            if (String.isBlank(product.Name)) {
                product.addError('Product Name is required');
            }
        }
    }
    
    /**
     * Retrieves products from the specified pricebook.
     *
     * @param pricebookId pricebook identifier.
     * @return products belonging to the pricebook.
     */
    public static List<Product2> getProductsByPricebook(Id pricebookId) {
        ProductSelector selector = new ProductSelector();
        return selector.getProductsByPricebook(pricebookId);
    }
    
    /**
     * Returns products that are available to add to an order (i.e., not already selected).
     *
     * @param pricebookId pricebook identifier.
     * @param orderItemProductIds product ids already tied to the order.
     * @return list of additional Product2 records that can be added.
     */
    public static List<Product2> getAvailableProductsForOrder(Id pricebookId, Set<Id> orderItemProductIds) {
        ProductSelector selector = new ProductSelector();
        return selector.getAvailableProductsForOrder(pricebookId, orderItemProductIds);
    }
}