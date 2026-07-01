@isTest
private class EngagementControllerTest {

    @TestSetup
    static void makeData() {
        Engagement__c engagement = TestDataFactory.insertEngagement('Controller Test Engagement');
        List<Account> accounts = TestDataFactory.insertAccounts(1);
        TestDataFactory.insertEngagementAccounts(
            engagement.Id,
            new List<Id>{ accounts[0].Id }
        );
        TestDataFactory.insertOpportunities(engagement.Id, accounts[0].Id, 2);
        TestDataFactory.insertApprovalSteps(engagement.Id, 2);
    }

    // ─── getEngagementWorkspace ───────────────────────────────────────────────

    @isTest
    static void getEngagementWorkspace_returnsWorkspace_forValidId() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;

        Test.startTest();
        EngagementWorkspaceDTO workspace = EngagementController.getEngagementWorkspace(engagementId);
        Test.stopTest();

        System.assertNotEquals(null, workspace, 'Workspace should not be null.');
        System.assertEquals(engagementId, workspace.engagement.engagementId, 'Engagement Id should match.');
        System.assertEquals(1, workspace.relatedAccounts.size());
        System.assertEquals(2, workspace.relatedOpportunities.size());
        System.assertEquals(2, workspace.approvalSteps.size());
    }

    @isTest
    static void getEngagementWorkspace_throwsAuraHandledException_forNullId() {
        Test.startTest();
        try {
            EngagementController.getEngagementWorkspace(null);
            System.assert(false, 'Expected AuraHandledException for null Id.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getEngagementWorkspace_throwsAuraHandledException_forDeletedRecord() {
        Engagement__c eng = [SELECT Id FROM Engagement__c LIMIT 1];
        Id deletedId = eng.Id;
        delete eng;

        Test.startTest();
        try {
            EngagementController.getEngagementWorkspace(deletedId);
            System.assert(false, 'Expected AuraHandledException for deleted record.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null.');
        }
        Test.stopTest();
    }

    // ─── advanceApproval ─────────────────────────────────────────────────────

    @isTest
    static void advanceApproval_returnsRefreshedWorkspace_afterAdvancing() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;

        Test.startTest();
        EngagementWorkspaceDTO workspace = EngagementController.advanceApproval(engagementId);
        Test.stopTest();

        System.assertNotEquals(null, workspace, 'Workspace should be returned after advancing.');
        System.assertEquals(1, workspace.statistics.completedApprovalStepCount,
            'One step should be approved after first advance.');
    }

    @isTest
    static void advanceApproval_throwsAuraHandledException_forNullId() {
        Test.startTest();
        try {
            EngagementController.advanceApproval(null);
            System.assert(false, 'Expected AuraHandledException for null Id.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
}
