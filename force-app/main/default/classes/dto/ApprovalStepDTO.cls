/**
 * Projection of an Approval_Step__c record used to render the approval
 * timeline.
 */
public class ApprovalStepDTO {
    @AuraEnabled public Id stepId;
    @AuraEnabled public Integer stepOrder;
    @AuraEnabled public String status;
    @AuraEnabled public String approverName;
    @AuraEnabled public Date completedDate;

    public ApprovalStepDTO(Approval_Step__c step) {
        this.stepId = step.Id;
        this.stepOrder = step.Step_Order__c != null ? Integer.valueOf(step.Step_Order__c) : null;
        this.status = step.Status__c;
        this.approverName = step.Approver_Name__c;
        this.completedDate = step.Completed_Date__c;
    }
}
