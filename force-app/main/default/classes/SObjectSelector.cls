/**
 * Base selector that standardizes SOQL generation for SObject queries.
 */
public abstract with sharing class SObjectSelector {
    
    /**
     * @return Schema.SObjectType handled by the concrete selector.
     */
    public abstract Schema.SObjectType getSObjectType();
    
    /**
     * @return fields that must be selected for the SObject.
     */
    public abstract List<Schema.SObjectField> getSObjectFieldList();
    
    /**
     * @return API name of the SObject described by the selector.
     */
    public String getSObjectName() {
        return getSObjectType().getDescribe().getName();
    }
    
    /**
     * Builds a comma-separated field list suitable for dynamic SOQL.
     *
     * @return comma-separated list of field API names.
     */
    public String getFieldListString() {
        List<String> fieldNames = new List<String>();
        for (Schema.SObjectField field : getSObjectFieldList()) {
            fieldNames.add(field.getDescribe().getName());
        }
        return String.join(fieldNames, ', ');
    }
    
    /**
     * Queries records by id using the selector field list.
     *
     * @param idSet set of ids to query.
     * @return list of SObjects matching the ids.
     */
    public List<SObject> selectSObjectsById(Set<Id> idSet) {
        if (idSet == null || idSet.isEmpty()) {
            return new List<SObject>();
        }
        
        String query = 'SELECT ' + getFieldListString() + 
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id IN :idSet';
        
        return Database.query(query);
    }
    
    /**
     * Convenience method that retrieves a single record by id.
     *
     * @param id identifier of the record.
     * @return matching SObject or null.
     */
    public SObject selectSObjectById(Id id) {
        List<SObject> records = selectSObjectsById(new Set<Id>{id});
        return records.isEmpty() ? null : records[0];
    }
    
    /**
     * Queries records using a custom WHERE clause.
     *
     * @param whereClause filter string appended to the query.
     * @return list of matching SObjects.
     */
    public List<SObject> selectSObjectsWhere(String whereClause) {
        return selectSObjectsWhere(whereClause, null);
    }
    
    /**
     * Queries records using custom WHERE and ORDER BY clauses.
     *
     * @param whereClause filter string appended to the query.
     * @param orderBy order by clause appended to the query.
     * @return list of matching SObjects.
     */
    public List<SObject> selectSObjectsWhere(String whereClause, String orderBy) {
        String query = 'SELECT ' + getFieldListString() + 
                      ' FROM ' + getSObjectName();
        
        if (String.isNotBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        }
        
        if (String.isNotBlank(orderBy)) {
            query += ' ORDER BY ' + orderBy;
        }
        
        return Database.query(query);
    }
}