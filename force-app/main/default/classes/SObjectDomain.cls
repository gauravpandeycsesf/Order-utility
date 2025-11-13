public abstract class SObjectDomain {
    
    public List<SObject> Records { get; private set; }
    public ISObjectUnitOfWork Uow { get; private set; }
    
    public SObjectDomain(List<SObject> records) {
        this.Records = records;
    }
    
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
    
    public void handleBeforeInsert() {
        onBeforeInsert();
    }
    
    public void handleAfterInsert() {
        onAfterInsert();
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> existingRecords) {
        onBeforeUpdate(existingRecords);
    }
    
    public void handleAfterUpdate(Map<Id, SObject> existingRecords) {
        onAfterUpdate(existingRecords);
    }
    
    public void handleBeforeDelete() {
        onBeforeDelete();
    }
    
    public void handleAfterDelete() {
        onAfterDelete();
    }
    
    public void handleUndelete() {
        onUndelete();
    }
}