public interface ISObjectUnitOfWork {
    
    void registerNew(SObject record);
    void registerNew(List<SObject> records);
    void registerNew(SObject record, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    void registerNew(List<SObject> records, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    
    void registerDirty(SObject record);
    void registerDirty(List<SObject> records);
    void registerDirty(SObject record, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    void registerDirty(List<SObject> records, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    
    void registerDeleted(SObject record);
    void registerDeleted(List<SObject> records);
    
    void commitWork();
}