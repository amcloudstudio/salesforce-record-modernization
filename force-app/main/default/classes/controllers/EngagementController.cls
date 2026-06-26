/**
 * Thin AuraEnabled boundary for the Engagement record workspace. Performs
 * no business logic and no SOQL/DML directly; it delegates to
 * EngagementService and translates service exceptions into
 * AuraHandledException for the LWC layer.
 */
public with sharing class EngagementController {

    @AuraEnabled(cacheable=true)
    public static EngagementWorkspaceDTO getEngagementWorkspace(Id engagementId) {
        try {
            return new EngagementService().getWorkspace(engagementId);
        } catch (EngagementServiceException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load the Engagement workspace.');
        }
    }

    @AuraEnabled
    public static EngagementWorkspaceDTO advanceApproval(Id engagementId) {
        try {
            return new EngagementService().advanceApproval(engagementId);
        } catch (EngagementServiceException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Unable to advance the approval step.');
        }
    }
}
