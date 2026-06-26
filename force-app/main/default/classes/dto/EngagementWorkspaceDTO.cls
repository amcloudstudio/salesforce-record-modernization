/**
 * Aggregate payload for the Engagement record workspace. Bundling every
 * panel's data into a single DTO lets the LWC container make one Apex call
 * instead of one call per panel.
 */
public class EngagementWorkspaceDTO {
    @AuraEnabled public EngagementDTO engagement;
    @AuraEnabled public List<AccountSummaryDTO> relatedAccounts;
    @AuraEnabled public List<OpportunitySummaryDTO> relatedOpportunities;
    @AuraEnabled public List<ApprovalStepDTO> approvalSteps;
    @AuraEnabled public EngagementStatisticsDTO statistics;

    public EngagementWorkspaceDTO(
        EngagementDTO engagement,
        List<AccountSummaryDTO> relatedAccounts,
        List<OpportunitySummaryDTO> relatedOpportunities,
        List<ApprovalStepDTO> approvalSteps,
        EngagementStatisticsDTO statistics
    ) {
        this.engagement = engagement;
        this.relatedAccounts = relatedAccounts;
        this.relatedOpportunities = relatedOpportunities;
        this.approvalSteps = approvalSteps;
        this.statistics = statistics;
    }
}
