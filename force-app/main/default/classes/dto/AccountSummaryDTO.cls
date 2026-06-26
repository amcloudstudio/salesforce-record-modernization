/**
 * Lightweight projection of an Account related to an Engagement, used by
 * the "Related Customers" panel.
 */
public class AccountSummaryDTO {
    @AuraEnabled public Id accountId;
    @AuraEnabled public String name;
    @AuraEnabled public String industry;
    @AuraEnabled public String relationshipType;

    public AccountSummaryDTO(Engagement_Account__c junction) {
        this.accountId = junction.Account__c;
        this.name = junction.Account__r.Name;
        this.industry = junction.Account__r.Industry;
        this.relationshipType = junction.Relationship_Type__c;
    }
}
