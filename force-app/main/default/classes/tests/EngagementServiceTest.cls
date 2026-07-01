@isTest
private class EngagementServiceTest {

    @TestSetup
    static void makeData() {
        Engagement__c engagement = TestDataFactory.insertEngagement('Service Test Engagement');

        List<Account> accounts = TestDataFactory.insertAccounts(2);
        TestDataFactory.insertEngagementAccounts(
            engagement.Id,
            new List<Id>{ accounts[0].Id, accounts[1].Id }
        );

        TestDataFactory.insertOpportunities(engagement.Id, accounts[0].Id, 3);
        TestDataFactory.insertApprovalSteps(engagement.Id, 3);
    }

    // ─── getWorkspace ────────────────────────────────────────────────────────

    @isTest
    static void getWorkspace_returnsFullPayload_forValidEngagement() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;

        Test.startTest();
        EngagementWorkspaceDTO workspace = new EngagementService().getWorkspace(engagementId);
        Test.stopTest();

        System.assertNotEquals(null, workspace, 'Workspace should not be null.');
        System.assertNotEquals(null, workspace.engagement, 'Engagement DTO should be populated.');
        System.assertEquals(2, workspace.relatedAccounts.size(), 'Should return 2 related accounts.');
        System.assertEquals(3, workspace.relatedOpportunities.size(), 'Should return 3 opportunities.');
        System.assertEquals(3, workspace.approvalSteps.size(), 'Should return 3 approval steps.');
        System.assertNotEquals(null, workspace.statistics, 'Statistics should be populated.');
        System.assertEquals(2, workspace.statistics.relatedAccountCount);
        System.assertEquals(3, workspace.statistics.relatedOpportunityCount);
        System.assertEquals(0, workspace.statistics.completedApprovalStepCount);
        System.assertEquals(3, workspace.statistics.totalApprovalStepCount);
    }

    @isTest
    static void getWorkspace_throwsServiceException_whenIdIsNull() {
        Test.startTest();
        try {
            new EngagementService().getWorkspace(null);
            System.assert(false, 'Expected EngagementServiceException for null Id.');
        } catch (EngagementServiceException e) {
            System.assert(e.getMessage().contains('required'), 'Exception message should mention required Id.');
        }
        Test.stopTest();
    }

    @isTest
    static void getWorkspace_throwsServiceException_whenEngagementNotFound() {
        Engagement__c eng = [SELECT Id FROM Engagement__c LIMIT 1];
        Id deletedId = eng.Id;
        delete eng;

        Test.startTest();
        try {
            new EngagementService().getWorkspace(deletedId);
            System.assert(false, 'Expected EngagementServiceException for deleted record.');
        } catch (EngagementServiceException e) {
            System.assert(e.getMessage().contains('not found'), 'Exception message should mention not found.');
        }
        Test.stopTest();
    }

    // ─── advanceApproval ─────────────────────────────────────────────────────

    @isTest
    static void advanceApproval_approvesFirstPendingStep() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;

        Test.startTest();
        EngagementWorkspaceDTO workspace = new EngagementService().advanceApproval(engagementId);
        Test.stopTest();

        System.assertEquals(1, workspace.statistics.completedApprovalStepCount,
            'One step should now be approved.');
        Approval_Step__c step1 = [
            SELECT Status__c, Completed_Date__c
            FROM Approval_Step__c
            WHERE Engagement__c = :engagementId AND Step_Order__c = 1
        ];
        System.assertEquals('Approved', step1.Status__c, 'Step 1 should be Approved.');
        System.assertEquals(Date.today(), step1.Completed_Date__c, 'Completed date should be today.');
    }

    @isTest
    static void advanceApproval_promotesEngagementToApproved_whenAllStepsDone() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;
        EngagementService svc = new EngagementService();

        Test.startTest();
        svc.advanceApproval(engagementId);
        svc.advanceApproval(engagementId);
        svc.advanceApproval(engagementId);
        Test.stopTest();

        Engagement__c eng = [SELECT Status__c FROM Engagement__c WHERE Id = :engagementId];
        System.assertEquals('Approved', eng.Status__c,
            'Engagement should be Approved once all steps are complete.');
    }

    @isTest
    static void advanceApproval_throwsServiceException_whenNoStepsDefined() {
        Engagement__c fresh = TestDataFactory.insertEngagement('No Steps');

        Test.startTest();
        try {
            new EngagementService().advanceApproval(fresh.Id);
            System.assert(false, 'Expected EngagementServiceException when no steps exist.');
        } catch (EngagementServiceException e) {
            System.assert(e.getMessage().contains('no approval steps'), e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void advanceApproval_throwsServiceException_whenAllStepsAlreadyComplete() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;
        List<Approval_Step__c> steps = [
            SELECT Id, Status__c, Completed_Date__c FROM Approval_Step__c WHERE Engagement__c = :engagementId
        ];
        for (Approval_Step__c s : steps) {
            s.Status__c = 'Approved';
            s.Completed_Date__c = Date.today();
        }
        update steps;

        Test.startTest();
        try {
            new EngagementService().advanceApproval(engagementId);
            System.assert(false, 'Expected EngagementServiceException when all steps are done.');
        } catch (EngagementServiceException e) {
            System.assert(e.getMessage().contains('already complete'), e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void advanceApproval_throwsServiceException_whenIdIsNull() {
        Test.startTest();
        try {
            new EngagementService().advanceApproval(null);
            System.assert(false, 'Expected EngagementServiceException for null Id.');
        } catch (EngagementServiceException e) {
            System.assert(e.getMessage().contains('required'), e.getMessage());
        }
        Test.stopTest();
    }

    // ─── statistics ──────────────────────────────────────────────────────────

    @isTest
    static void getWorkspace_totalOpportunityAmount_isSummedCorrectly() {
        Id engagementId = [SELECT Id FROM Engagement__c LIMIT 1].Id;

        Test.startTest();
        EngagementWorkspaceDTO workspace = new EngagementService().getWorkspace(engagementId);
        Test.stopTest();

        // TestDataFactory inserts 3 opportunities with amounts 1000, 2000, 3000
        System.assertEquals(6000, workspace.statistics.totalOpportunityAmount,
            'Total opportunity amount should be 6000.');
    }
}
