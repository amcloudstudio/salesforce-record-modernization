/**
 * Sole point of SOQL access for Opportunities related to an Engagement.
 */
public with sharing class OpportunityRepository {

    public List<Opportunity> findByEngagementId(Id engagementId) {
        return findByEngagementIds(new Set<Id>{ engagementId });
    }

    public List<Opportunity> findByEngagementIds(Set<Id> engagementIds) {
        return [
            SELECT Id, Name, StageName, Amount, CloseDate, Engagement__c
            FROM Opportunity
            WHERE Engagement__c IN :engagementIds
            ORDER BY CloseDate DESC
        ];
    }
}
