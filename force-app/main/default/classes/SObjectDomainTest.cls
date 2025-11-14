@IsTest
/**
 * Test coverage for SObject Domain.
 */
private class SObjectDomainTest {

    /**
     * Lightweight fake Unit of Work implementation for exercising the constructor
     * that accepts an ISObjectUnitOfWork instance.
     */
    private class FakeUnitOfWork implements ISObjectUnitOfWork {
        public void registerNew(SObject record) { return; }
        public void registerNew(List<SObject> records) { return; }
        public void registerNew(SObject record, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField) { return; }
        public void registerNew(List<SObject> records, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField) { return; }
        public void registerDirty(SObject record) { return; }
        public void registerDirty(List<SObject> records) { return; }
        public void registerDirty(SObject record, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField) { return; }
        public void registerDirty(List<SObject> records, Schema.SObjectType relatedToType, Schema.SObjectField relatedToField) { return; }
        public void registerDeleted(SObject record) { return; }
        public void registerDeleted(List<SObject> records) { return; }
        public void commitWork() { return; }
    }

    /**
     * Concrete implementation that flips flags whenever the lifecycle hooks are invoked.
     */
    private class TestDomain extends SObjectDomain {
        public Boolean beforeInsertCalled  = false;
        public Boolean afterInsertCalled   = false;
        public Boolean beforeUpdateCalled  = false;
        public Boolean afterUpdateCalled   = false;
        public Boolean beforeDeleteCalled  = false;
        public Boolean afterDeleteCalled   = false;
        public Boolean undeleteCalled      = false;

        public Map<Id, SObject> beforeUpdateRecords;
        public Map<Id, SObject> afterUpdateRecords;

        /**
         * Verifies domain.
         */
        public TestDomain(List<SObject> records) {
            super(records);
        }

        public TestDomain(List<SObject> records, ISObjectUnitOfWork uow) {
            super(records, uow);
        }

        /**
         * Handles before insert.
         */
        public override void onBeforeInsert() {
            beforeInsertCalled = true;
        }

        /**
         * Handles after insert.
         */
        public override void onAfterInsert() {
            afterInsertCalled = true;
        }

        /**
         * Handles before update.
         */
        public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
            beforeUpdateCalled = true;
            beforeUpdateRecords = existingRecords;
        }

        /**
         * Handles after update.
         */
        public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
            afterUpdateCalled = true;
            afterUpdateRecords = existingRecords;
        }

        /**
         * Handles before delete.
         */
        public override void onBeforeDelete() {
            beforeDeleteCalled = true;
        }

        /**
         * Handles after delete.
         */
        public override void onAfterDelete() {
            afterDeleteCalled = true;
        }

        /**
         * Handles undelete.
         */
        public override void onUndelete() {
            undeleteCalled = true;
        }
    }

    /**
     * Domain implementation that does not override lifecycle hooks so that
     * the base-class implementations are executed for coverage.
     */
    private class NoopDomain extends SObjectDomain {
        /**
         * Handles domain.
         */
        public NoopDomain(List<SObject> records) {
            super(records);
        }
    }

    /**
     * Verifies lifecycle handlers delegate to hooks.
     */
    @IsTest
    static void testLifecycleHandlersDelegateToHooks() {
        List<SObject> records = new List<SObject>{
            new Account(Name = 'Test Account')
        };
        FakeUnitOfWork uow = new FakeUnitOfWork();

        TestDomain domain = new TestDomain(records, uow);

        System.assertEquals(records, domain.Records, 'Constructor should capture records');
        System.assertEquals(uow, domain.Uow, 'Constructor should capture unit of work');

        Map<Id, SObject> existingRecords = new Map<Id, SObject>();

        Test.startTest();
        domain.handleBeforeInsert();
        domain.handleAfterInsert();
        domain.handleBeforeUpdate(existingRecords);
        domain.handleAfterUpdate(existingRecords);
        domain.handleBeforeDelete();
        domain.handleAfterDelete();
        domain.handleUndelete();
        Test.stopTest();

        System.assert(domain.beforeInsertCalled, 'handleBeforeInsert should invoke onBeforeInsert');
        System.assert(domain.afterInsertCalled, 'handleAfterInsert should invoke onAfterInsert');
        System.assert(domain.beforeUpdateCalled, 'handleBeforeUpdate should invoke onBeforeUpdate');
        System.assertEquals(existingRecords, domain.beforeUpdateRecords, 'Existing records should be forwarded to onBeforeUpdate');
        System.assert(domain.afterUpdateCalled, 'handleAfterUpdate should invoke onAfterUpdate');
        System.assertEquals(existingRecords, domain.afterUpdateRecords, 'Existing records should be forwarded to onAfterUpdate');
        System.assert(domain.beforeDeleteCalled, 'handleBeforeDelete should invoke onBeforeDelete');
        System.assert(domain.afterDeleteCalled, 'handleAfterDelete should invoke onAfterDelete');
        System.assert(domain.undeleteCalled, 'handleUndelete should invoke onUndelete');
    }

    /**
     * Verifies constructor without unit of work.
     */
    @IsTest
    static void testConstructorWithoutUnitOfWork() {
        List<SObject> records = new List<SObject>{
            new Account(Name = 'Another Account')
        };

        TestDomain domain = new TestDomain(records);

        System.assertEquals(records, domain.Records, 'Records should be assigned when no UoW is provided');
        System.assertEquals(null, domain.Uow, 'UoW should remain null when not supplied');
    }

    /**
     * Verifies base lifecycle methods covered.
     */
    @IsTest
    static void testBaseLifecycleMethodsCovered() {
        List<SObject> records = new List<SObject>{
            new Account(Name = 'Base Hooks')
        };
        NoopDomain domain = new NoopDomain(records);

        Map<Id, SObject> existingRecords = new Map<Id, SObject>();

        Test.startTest();
        domain.handleBeforeInsert();
        domain.handleAfterInsert();
        domain.handleBeforeUpdate(existingRecords);
        domain.handleAfterUpdate(existingRecords);
        domain.handleBeforeDelete();
        domain.handleAfterDelete();
        domain.handleUndelete();
        Test.stopTest();

        System.assert(true, 'Base lifecycle methods executed without override');
    }
}