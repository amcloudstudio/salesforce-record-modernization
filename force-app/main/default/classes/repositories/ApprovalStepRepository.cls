/**
 * Sole point of SOQL/DML access for Approval_Step__c records.
 */
public with sharing class ApprovalStepRepository {

    public List<Approval_Step__c> findByEngagementId(Id engagementId) {
        return findByEngagementIds(new Set<Id>{ engagementId });
    }

    public List<Approval_Step__c> findByEngagementIds(Set<Id> engagementIds) {
        return [
            SELECT Id, Engagement__c, Step_Order__c, Status__c,
                   Approver_Name__c, Completed_Date__c
            FROM Approval_Step__c
            WHERE Engagement__c IN :engagementIds
            ORDER BY Step_Order__c ASC
        ];
    }

    public void updateApprovalSteps(List<Approval_Step__c> steps) {
        if (steps == null || steps.isEmpty()) {
            return;
        }
        if (!Schema.sObjectType.Approval_Step__c.isUpdateable()) {
            throw new EngagementRepositoryException('Insufficient access to update Approval Step records.');
        }
        update steps;
    }
}
