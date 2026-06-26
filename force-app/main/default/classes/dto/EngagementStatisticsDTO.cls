/**
 * Aggregate statistics for an Engagement, computed server-side so the
 * client never has to derive totals from raw collections.
 */
public class EngagementStatisticsDTO {
    @AuraEnabled public Integer relatedAccountCount;
    @AuraEnabled public Integer relatedOpportunityCount;
    @AuraEnabled public Decimal totalOpportunityAmount;
    @AuraEnabled public Integer completedApprovalStepCount;
    @AuraEnabled public Integer totalApprovalStepCount;

    public EngagementStatisticsDTO(
        Integer relatedAccountCount,
        Integer relatedOpportunityCount,
        Decimal totalOpportunityAmount,
        Integer completedApprovalStepCount,
        Integer totalApprovalStepCount
    ) {
        this.relatedAccountCount = relatedAccountCount;
        this.relatedOpportunityCount = relatedOpportunityCount;
        this.totalOpportunityAmount = totalOpportunityAmount == null ? 0 : totalOpportunityAmount;
        this.completedApprovalStepCount = completedApprovalStepCount;
        this.totalApprovalStepCount = totalApprovalStepCount;
    }
}
