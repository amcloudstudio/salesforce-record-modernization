/**
 * Business logic for retrieving and mutating Engagement data. Orchestrates
 * the repository layer and maps sObjects into DTOs; never issues SOQL/DML
 * directly.
 */
public with sharing class EngagementService {

    private final EngagementRepository engagementRepository;
    private final AccountRepository accountRepository;
    private final OpportunityRepository opportunityRepository;
    private final ApprovalStepRepository approvalStepRepository;

    public EngagementService() {
        this(
            new EngagementRepository(),
            new AccountRepository(),
            new OpportunityRepository(),
            new ApprovalStepRepository()
        );
    }

    public EngagementService(
        EngagementRepository engagementRepository,
        AccountRepository accountRepository,
        OpportunityRepository opportunityRepository,
        ApprovalStepRepository approvalStepRepository
    ) {
        this.engagementRepository = engagementRepository;
        this.accountRepository = accountRepository;
        this.opportunityRepository = opportunityRepository;
        this.approvalStepRepository = approvalStepRepository;
    }

    /**
     * Builds the full workspace payload for a single Engagement record in
     * one pass, so the LWC container can render every panel from a single
     * Apex call.
     */
    public EngagementWorkspaceDTO getWorkspace(Id engagementId) {
        if (engagementId == null) {
            throw new EngagementServiceException('An Engagement Id is required.');
        }

        Engagement__c engagement = engagementRepository.findById(engagementId);
        if (engagement == null) {
            throw new EngagementServiceException('Engagement not found or not accessible.');
        }

        List<Engagement_Account__c> accountJunctions = accountRepository.findByEngagementId(engagementId);
        List<Opportunity> opportunities = opportunityRepository.findByEngagementId(engagementId);
        List<Approval_Step__c> approvalSteps = approvalStepRepository.findByEngagementId(engagementId);

        List<AccountSummaryDTO> accountDTOs = new List<AccountSummaryDTO>();
        for (Engagement_Account__c junction : accountJunctions) {
            accountDTOs.add(new AccountSummaryDTO(junction));
        }

        List<OpportunitySummaryDTO> opportunityDTOs = new List<OpportunitySummaryDTO>();
        Decimal totalAmount = 0;
        for (Opportunity opp : opportunities) {
            opportunityDTOs.add(new OpportunitySummaryDTO(opp));
            totalAmount += (opp.Amount == null ? 0 : opp.Amount);
        }

        List<ApprovalStepDTO> approvalStepDTOs = new List<ApprovalStepDTO>();
        Integer completedSteps = 0;
        for (Approval_Step__c step : approvalSteps) {
            approvalStepDTOs.add(new ApprovalStepDTO(step));
            if (step.Status__c == 'Approved') {
                completedSteps++;
            }
        }

        EngagementStatisticsDTO statistics = new EngagementStatisticsDTO(
            accountDTOs.size(),
            opportunityDTOs.size(),
            totalAmount,
            completedSteps,
            approvalStepDTOs.size()
        );

        return new EngagementWorkspaceDTO(
            new EngagementDTO(engagement),
            accountDTOs,
            opportunityDTOs,
            approvalStepDTOs,
            statistics
        );
    }

    /**
     * Advances the next pending/in-progress approval step to Approved and
     * promotes the Engagement to "Approved" once every step is complete.
     */
    public EngagementWorkspaceDTO advanceApproval(Id engagementId) {
        if (engagementId == null) {
            throw new EngagementServiceException('An Engagement Id is required.');
        }

        List<Approval_Step__c> steps = approvalStepRepository.findByEngagementId(engagementId);
        if (steps.isEmpty()) {
            throw new EngagementServiceException('This Engagement has no approval steps defined.');
        }

        Approval_Step__c nextStep = null;
        for (Approval_Step__c step : steps) {
            if (step.Status__c != 'Approved' && step.Status__c != 'Rejected') {
                nextStep = step;
                break;
            }
        }

        if (nextStep == null) {
            throw new EngagementServiceException('All approval steps are already complete.');
        }

        nextStep.Status__c = 'Approved';
        nextStep.Completed_Date__c = Date.today();
        approvalStepRepository.updateApprovalSteps(new List<Approval_Step__c>{ nextStep });

        Boolean allApproved = true;
        for (Approval_Step__c step : steps) {
            if (step.Id == nextStep.Id) {
                continue;
            }
            if (step.Status__c != 'Approved') {
                allApproved = false;
                break;
            }
        }

        if (allApproved) {
            Engagement__c engagement = engagementRepository.findById(engagementId);
            if (engagement != null && engagement.Status__c != 'Approved') {
                engagement.Status__c = 'Approved';
                engagementRepository.updateEngagements(new List<Engagement__c>{ engagement });
            }
        }

        return getWorkspace(engagementId);
    }
}
