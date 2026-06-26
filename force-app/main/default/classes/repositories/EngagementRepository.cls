/**
 * Sole point of SOQL/DML access for Engagement__c records. Selects only
 * the fields required by EngagementDTO and is bulk-safe by accepting and
 * returning collections.
 */
public with sharing class EngagementRepository {

    public Engagement__c findById(Id engagementId) {
        List<Engagement__c> results = findByIds(new Set<Id>{ engagementId });
        return results.isEmpty() ? null : results[0];
    }

    public List<Engagement__c> findByIds(Set<Id> engagementIds) {
        return [
            SELECT Id, Name, Status__c, Stage__c, Priority__c, Owner_Notes__c,
                   Start_Date__c, Target_Close_Date__c
            FROM Engagement__c
            WHERE Id IN :engagementIds
        ];
    }

    public void updateEngagements(List<Engagement__c> engagements) {
        if (engagements == null || engagements.isEmpty()) {
            return;
        }
        if (!Schema.sObjectType.Engagement__c.isUpdateable()) {
            throw new EngagementRepositoryException('Insufficient access to update Engagement records.');
        }
        update engagements;
    }
}
