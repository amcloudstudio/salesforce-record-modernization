/**
 * Read/write projection of an Engagement__c record exposed to the LWC layer.
 */
public class EngagementDTO {
    @AuraEnabled public Id engagementId;
    @AuraEnabled public String name;
    @AuraEnabled public String status;
    @AuraEnabled public String stage;
    @AuraEnabled public String priority;
    @AuraEnabled public String ownerNotes;
    @AuraEnabled public Date startDate;
    @AuraEnabled public Date targetCloseDate;

    public EngagementDTO() {
    }

    public EngagementDTO(Engagement__c record) {
        this.engagementId = record.Id;
        this.name = record.Name;
        this.status = record.Status__c;
        this.stage = record.Stage__c;
        this.priority = record.Priority__c;
        this.ownerNotes = record.Owner_Notes__c;
        this.startDate = record.Start_Date__c;
        this.targetCloseDate = record.Target_Close_Date__c;
    }
}
