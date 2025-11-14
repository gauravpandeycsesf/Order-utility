/**
 * Selector that contains reusable SOQL queries for Product2 records.
 */
public with sharing class ProductSelector extends SObjectSelector {
    
    /**
     * Identifies the SObject type handled by this selector.
     *
     * @return Schema.SObjectType for Product2.
     */
    public override Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }
    
    /**
     * Specifies the base fields queried for every product request.
     *
     * @return list of Product2 fields.
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Product2.Id,
            Product2.Name,
            Product2.ProductCode,
            Product2.IsActive,
            Product2.Family,
            Product2.Description,
            Product2.Parent_Product__c
        };
    }
    
    /**
     * Retrieves products that belong to the provided pricebook.
     *
     * @param pricebookId pricebook scope.
     * @return list of active Product2 records tied to the pricebook.
     */
    public List<Product2> getProductsByPricebook(Id pricebookId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', (SELECT Id, UnitPrice FROM PricebookEntries WHERE Pricebook2Id = :pricebookId AND IsActive = true)' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND IsActive = true)' +
                      ' AND IsActive = true' +
                      ' ORDER BY Name';
        
        return Database.query(query);
    }
    
    /**
     * Retrieves products available to add to an order, excluding those already selected.
     *
     * @param pricebookId pricebook scope.
     * @param orderItemProductIds ids already used on the order.
     * @return list of available products.
     */
    public List<Product2> getAvailableProductsForOrder(Id pricebookId, Set<Id> orderItemProductIds) {
        String whereClause = 'Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND IsActive = true) AND IsActive = true';
        
        if (orderItemProductIds != null && !orderItemProductIds.isEmpty()) {
            whereClause += ' AND Id NOT IN :orderItemProductIds';
        }
        
        String query = 'SELECT ' + getFieldListString() + 
                      ', (SELECT Id, UnitPrice FROM PricebookEntries WHERE Pricebook2Id = :pricebookId AND IsActive = true)' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE ' + whereClause +
                      ' ORDER BY Name';
        
        return Database.query(query);
    }
    
    /**
     * Retrieves the products corresponding to the provided order item product ids.
     *
     * @param orderItemProductIds ids sourced from order items.
     * @return list of Product2 records.
     */
    public List<Product2> getOrderProducts(Set<Id> orderItemProductIds) {
        if (orderItemProductIds == null || orderItemProductIds.isEmpty()) {
            return new List<Product2>();
        }
        
        String query = 'SELECT ' + getFieldListString() + 
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id IN :orderItemProductIds AND IsActive = true' +
                      ' ORDER BY Name';
        
        return Database.query(query);
    }
    
    /**
     * Performs a name-filtered search for products within a pricebook.
     *
     * @param productName text used to filter by product name.
     * @param pricebookId pricebook scope.
     * @return list of Product2 records matching the criteria.
     */
    public List<Product2> getProductsByName(String productName, Id pricebookId) {
        if (pricebookId == null) {
            throw new IllegalArgumentException('Pricebook ID is required');
        }
        
        String whereClause = 'Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND IsActive = true) AND IsActive = true';
        
        if (String.isNotBlank(productName)) {
            String searchPattern = '%' + String.escapeSingleQuotes(productName) + '%';
            whereClause += ' AND Name LIKE :searchPattern';
        }
        
        String query = 'SELECT ' + getFieldListString() + 
                      ', (SELECT Id, UnitPrice FROM PricebookEntries WHERE Pricebook2Id = :pricebookId AND IsActive = true)' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE ' + whereClause +
                      ' ORDER BY Name';
        
        return Database.query(query);
    }
}