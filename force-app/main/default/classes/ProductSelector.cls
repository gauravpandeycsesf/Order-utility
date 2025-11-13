public with sharing class ProductSelector extends SObjectSelector {
    
    public override Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }
    
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
    
    public List<Product2> getProductsByPricebook(Id pricebookId) {
        String query = 'SELECT ' + getFieldListString() + 
                      ', (SELECT Id, UnitPrice FROM PricebookEntries WHERE Pricebook2Id = :pricebookId AND IsActive = true)' +
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND IsActive = true)' +
                      ' AND IsActive = true' +
                      ' ORDER BY Name';
        
        return Database.query(query);
    }
    
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