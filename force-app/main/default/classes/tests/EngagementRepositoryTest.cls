@isTest
private class EngagementRepositoryTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.createEngagement('Repo Test Engagement');
    }

    @isTest
    static void findById_returnsEngagement_whenIdIsValid() {
        Engagement__c engagement = [SELECT Id FROM Engagement__c LIMIT 1];

        Test.startTest();
        Engagement__c result = new EngagementRepository().findById(engagement.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a record to be returned.');
        System.assertEquals(engagement.Id, result.Id, 'Returned Id should match queried Id.');
    }

    @isTest
    static void findById_returnsNull_whenIdDoesNotExist() {
        Id fakeId = TestDataFactory.createEngagement('Unused').Id;
        delete [SELECT Id FROM Engagement__c WHERE Name = 'Unused'];

        Test.startTest();
        Engagement__c result = new EngagementRepository().findById(fakeId);
        Test.stopTest();

        System.assertEquals(null, result, 'Expected null for a deleted/non-existent record.');
    }

    @isTest
    static void findByIds_returnsBulkResults() {
        List<Engagement__c> batch = new List<Engagement__c>();
        for (Integer i = 0; i < 5; i++) {
            batch.add(TestDataFactory.createEngagement('Bulk Engagement ' + i));
        }
        insert batch;

        Set<Id> ids = new Map<Id, Engagement__c>(batch).keySet();

        Test.startTest();
        List<Engagement__c> results = new EngagementRepository().findByIds(ids);
        Test.stopTest();

        System.assertEquals(5, results.size(), 'Expected all 5 bulk records to be returned.');
    }

    @isTest
    static void updateEngagements_updatesRecord_whenUserHasAccess() {
        Engagement__c engagement = [SELECT Id, Status__c FROM Engagement__c LIMIT 1];
        engagement.Status__c = 'In Review';

        Test.startTest();
        new EngagementRepository().updateEngagements(new List<Engagement__c>{ engagement });
        Test.stopTest();

        Engagement__c updated = [SELECT Status__c FROM Engagement__c WHERE Id = :engagement.Id];
        System.assertEquals('In Review', updated.Status__c, 'Status should have been updated.');
    }

    @isTest
    static void updateEngagements_doesNothing_whenListIsEmpty() {
        Test.startTest();
        new EngagementRepository().updateEngagements(new List<Engagement__c>());
        Test.stopTest();
        // no exception = pass
        System.assert(true, 'Empty list update should not throw.');
    }
}
