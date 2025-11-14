/**
 * Describes the operations required to implement a unit-of-work pattern for SObjects.
 */
public interface ISObjectUnitOfWork {
    
    /**
     * Tracks a single new record to insert during commit.
     *
     * @param record SObject pending creation.
     */
    void registerNew(SObject record);
    
    /**
     * Tracks a collection of new records to insert during commit.
     *
     * @param records SObjects pending creation.
     */
    void registerNew(List<SObject> records);
    
    /**
     * Tracks a new child record that should relate to another SObject when committed.
     *
     * @param record child record pending creation.
     * @param relatedToType parent SObject type.
     * @param relatedToField relationship field on the child.
     */
    void registerNew(SObject record, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    
    /**
     * Tracks multiple new child records that require relationship wiring on commit.
     *
     * @param records child records pending creation.
     * @param relatedToType parent SObject type.
     * @param relatedToField relationship field on the child.
     */
    void registerNew(List<SObject> records, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    
    /**
     * Marks a single record as dirty so it will be updated when the unit of work commits.
     *
     * @param record record to update.
     */
    void registerDirty(SObject record);
    
    /**
     * Marks multiple records as dirty for update during commit.
     *
     * @param records collection of records to update.
     */
    void registerDirty(List<SObject> records);
    
    /**
     * Marks a related record for update and ensures the relationship is set before persistence.
     *
     * @param record record to update.
     * @param relatedToType parent SObject type.
     * @param relatedToField relationship field on the record.
     */
    void registerDirty(SObject record, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    
    /**
     * Marks multiple related records for update with relationship wiring.
     *
     * @param records records to update.
     * @param relatedToType parent SObject type.
     * @param relatedToField relationship field on the records.
     */
    void registerDirty(List<SObject> records, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField);
    
    /**
     * Schedules a single record for deletion when committing the unit of work.
     *
     * @param record record to delete.
     */
    void registerDeleted(SObject record);
    
    /**
     * Schedules multiple records for deletion when committing the unit of work.
     *
     * @param records records to delete.
     */
    void registerDeleted(List<SObject> records);
    
    /**
     * Executes the pending insert, update, and delete operations in the correct order.
     */
    void commitWork();
}