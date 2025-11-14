/**
 * Base domain class that encapsulates record collections and lifecycle hooks.
 */
public abstract class SObjectDomain {
    
    public List<SObject> Records { get; private set; }
    public ISObjectUnitOfWork Uow { get; private set; }
    
    /**
     * Creates a new domain for the provided records.
     *
     * @param records collection of SObjects the domain will manage.
     */
    public SObjectDomain(List<SObject> records) {
        this.Records = records;
    }
    
    /**
     * Creates a new domain backed by a unit of work for coordinated DML.
     *
     * @param records collection of SObjects the domain will manage.
     * @param uow unit of work used for persistence operations.
     */
    public SObjectDomain(List<SObject> records, ISObjectUnitOfWork uow) {
        this.Records = records;
        this.Uow = uow;
    }
    
    public virtual void onBeforeInsert() {}
    public virtual void onAfterInsert() {}
    public virtual void onBeforeUpdate(Map<Id, SObject> existingRecords) {}
    public virtual void onAfterUpdate(Map<Id, SObject> existingRecords) {}
    public virtual void onBeforeDelete() {}
    public virtual void onAfterDelete() {}
    public virtual void onUndelete() {}
    
    /**
     * Entry point called before insert that delegates to overridable hook.
     */
    public void handleBeforeInsert() {
        onBeforeInsert();
    }
    
    /**
     * Entry point called after insert that delegates to overridable hook.
     */
    public void handleAfterInsert() {
        onAfterInsert();
    }
    
    /**
     * Entry point called before update that supplies the existing record map.
     *
     * @param existingRecords map keyed by id for records being updated.
     */
    public void handleBeforeUpdate(Map<Id, SObject> existingRecords) {
        onBeforeUpdate(existingRecords);
    }
    
    /**
     * Entry point called after update that supplies the existing record map.
     *
     * @param existingRecords map keyed by id for records being updated.
     */
    public void handleAfterUpdate(Map<Id, SObject> existingRecords) {
        onAfterUpdate(existingRecords);
    }
    
    /**
     * Entry point invoked before delete operations.
     */
    public void handleBeforeDelete() {
        onBeforeDelete();
    }
    
    /**
     * Entry point invoked after delete operations.
     */
    public void handleAfterDelete() {
        onAfterDelete();
    }
    
    /**
     * Entry point invoked after undelete operations.
     */
    public void handleUndelete() {
        onUndelete();
    }
}