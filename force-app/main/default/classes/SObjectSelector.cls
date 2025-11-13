public abstract with sharing class SObjectSelector {
    
    public abstract Schema.SObjectType getSObjectType();
    public abstract List<Schema.SObjectField> getSObjectFieldList();
    
    public String getSObjectName() {
        return getSObjectType().getDescribe().getName();
    }
    
    public String getFieldListString() {
        List<String> fieldNames = new List<String>();
        for (Schema.SObjectField field : getSObjectFieldList()) {
            fieldNames.add(field.getDescribe().getName());
        }
        return String.join(fieldNames, ', ');
    }
    
    public List<SObject> selectSObjectsById(Set<Id> idSet) {
        if (idSet == null || idSet.isEmpty()) {
            return new List<SObject>();
        }
        
        String query = 'SELECT ' + getFieldListString() + 
                      ' FROM ' + getSObjectName() + 
                      ' WHERE Id IN :idSet';
        
        return Database.query(query);
    }
    
    public SObject selectSObjectById(Id id) {
        List<SObject> records = selectSObjectsById(new Set<Id>{id});
        return records.isEmpty() ? null : records[0];
    }
    
    public List<SObject> selectSObjectsWhere(String whereClause) {
        return selectSObjectsWhere(whereClause, null);
    }
    
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