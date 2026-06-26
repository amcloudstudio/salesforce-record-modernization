/**
 * Lightweight projection of an Opportunity related to an Engagement, used
 * by the "Related Opportunities" panel.
 */
public class OpportunitySummaryDTO {
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public String name;
    @AuraEnabled public String stageName;
    @AuraEnabled public Decimal amount;
    @AuraEnabled public Date closeDate;

    public OpportunitySummaryDTO(Opportunity opp) {
        this.opportunityId = opp.Id;
        this.name = opp.Name;
        this.stageName = opp.StageName;
        this.amount = opp.Amount;
        this.closeDate = opp.CloseDate;
    }
}
