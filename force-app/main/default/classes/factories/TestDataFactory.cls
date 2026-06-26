/**
 * Centralized creation of test data for Engagement Hub unit tests.
 * Keeps test classes focused on behavior rather than record setup.
 */
@isTest
public class TestDataFactory {

    public static Engagement__c createEngagement(String name) {
        return new Engagement__c(
            Name = name,
            Status__c = 'New',
            Stage__c = 'Discovery',
            Priority__c = 'Medium',
            Start_Date__c = Date.today(),
            Target_Close_Date__c = Date.today().addMonths(1)
        );
    }

    public static Engagement__c insertEngagement(String name) {
        Engagement__c engagement = createEngagement(name);
        insert engagement;
        return engagement;
    }

    public static Account createAccount(String name) {
        return new Account(Name = name);
    }

    public static List<Account> insertAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(createAccount('Test Account ' + i));
        }
        insert accounts;
        return accounts;
    }

    public static List<Engagement_Account__c> insertEngagementAccounts(Id engagementId, List<Id> accountIds) {
        List<Engagement_Account__c> junctions = new List<Engagement_Account__c>();
        Boolean first = true;
        for (Id accountId : accountIds) {
            junctions.add(new Engagement_Account__c(
                Engagement__c = engagementId,
                Account__c = accountId,
                Relationship_Type__c = first ? 'Primary' : 'Secondary'
            ));
            first = false;
        }
        insert junctions;
        return junctions;
    }

    public static List<Opportunity> insertOpportunities(Id engagementId, Id accountId, Integer count) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = accountId,
                Engagement__c = engagementId,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1),
                Amount = 1000 * (i + 1)
            ));
        }
        insert opportunities;
        return opportunities;
    }

    public static List<Approval_Step__c> insertApprovalSteps(Id engagementId, Integer count) {
        List<Approval_Step__c> steps = new List<Approval_Step__c>();
        for (Integer i = 0; i < count; i++) {
            steps.add(new Approval_Step__c(
                Engagement__c = engagementId,
                Step_Order__c = i + 1,
                Status__c = 'Pending',
                Approver_Name__c = 'Approver ' + (i + 1)
            ));
        }
        insert steps;
        return steps;
    }
}
