/**
 * Sole point of SOQL access for Accounts related to an Engagement via the
 * Engagement_Account__c junction object.
 */
public with sharing class AccountRepository {

    public List<Engagement_Account__c> findByEngagementId(Id engagementId) {
        return findByEngagementIds(new Set<Id>{ engagementId });
    }

    public List<Engagement_Account__c> findByEngagementIds(Set<Id> engagementIds) {
        return [
            SELECT Id, Engagement__c, Relationship_Type__c,
                   Account__c, Account__r.Name, Account__r.Industry
            FROM Engagement_Account__c
            WHERE Engagement__c IN :engagementIds
            ORDER BY Relationship_Type__c
        ];
    }
}
