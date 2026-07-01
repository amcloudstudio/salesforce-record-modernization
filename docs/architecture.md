# Architecture

## Problem

Legacy Salesforce record pages often render every related list and field in a
single, dense view — difficult to navigate, slow to load, and impossible to
extend without touching a monolithic Visualforce page or a sprawling page
layout.

## Solution

Engagement Hub replaces that pattern with a componentized Lightning Web
Component page backed by a clean, four-layer Apex architecture. Each layer
has exactly one responsibility and communicates only with the layer directly
below it.

---

## Layer Map

```
LWC  ──────────────────────────────────────────────────────────
  recordWorkspace  (container, @wire, refreshApex)
    ├── recordHeader             (@api engagement)
    ├── relatedAccounts          (@api accounts)
    ├── relatedOpportunities     (@api opportunities)
    ├── approvalTimeline         (@api steps)
    └── actionPanel              (@api statistics, engagementId)
         └── imperative call: EngagementController.advanceApproval

Controller ─────────────────────────────────────────────────────
  EngagementController
    @AuraEnabled(cacheable=true) getEngagementWorkspace(Id)
    @AuraEnabled                 advanceApproval(Id)

Service ─────────────────────────────────────────────────────────
  EngagementService
    getWorkspace(Id)    → EngagementWorkspaceDTO
    advanceApproval(Id) → EngagementWorkspaceDTO

Repository ──────────────────────────────────────────────────────
  EngagementRepository       (Engagement__c SOQL / DML)
  AccountRepository          (Engagement_Account__c SOQL)
  OpportunityRepository      (Opportunity SOQL)
  ApprovalStepRepository     (Approval_Step__c SOQL / DML)

Database ────────────────────────────────────────────────────────
```

---

## Layer Responsibilities

### LWC

- Renders data received via `@api` properties.
- Dispatches user intent via custom events or imperative Apex calls.
- Contains **no SOQL** and **no business logic**.
- `recordWorkspace` makes one `@wire` call on load and calls `refreshApex`
  after the user advances an approval step, so all panels update atomically.

### Controller

- The only `@AuraEnabled` boundary in the project.
- Accepts an `Id` parameter, delegates to `EngagementService`, and returns a
  DTO.
- Catches `EngagementServiceException` (and any unexpected exception) and
  re-throws as `AuraHandledException` with a user-presentable message.
- Contains **no business logic** and **no SOQL**.

### Service

- Owns all business rules:
  - Which step is "next" when advancing an approval.
  - Whether an Engagement should be promoted to Approved once all steps are
    complete.
  - How statistics are computed from raw collections.
- Maps raw `sObject` collections from the Repository layer into DTOs.
- Accepts repositories through the constructor, enabling dependency injection
  in unit tests.
- Contains **no SOQL or DML** — all data access is delegated to repositories.

### Repository

- The **only** layer that issues SOQL or DML.
- Every query selects only the fields required by its corresponding DTO
  (no `SELECT *`).
- Every method accepts/returns a collection — never a single record in a loop.
- Checks `Schema.sObjectType.isUpdateable()` before any DML and throws
  `EngagementRepositoryException` if access is denied.

---

## Data Transfer Objects (DTOs)

| DTO | Purpose |
|---|---|
| `EngagementDTO` | Core fields of `Engagement__c` |
| `AccountSummaryDTO` | Account name, industry, and relationship type |
| `OpportunitySummaryDTO` | Opportunity name, stage, amount, close date |
| `ApprovalStepDTO` | Step order, status, approver name, completed date |
| `EngagementStatisticsDTO` | Counts and totals computed server-side |
| `EngagementWorkspaceDTO` | Aggregate of all DTOs above for one round-trip |

All DTOs use explicit typed fields annotated `@AuraEnabled`. No
`Map<String, Object>` is used anywhere in the project.

---

## Governor Limits Strategy

| Risk | Mitigation |
|---|---|
| Multiple SOQL calls per page load | One `getEngagementWorkspace` wire call aggregates all panel data |
| SOQL inside loops | Forbidden — all repositories query by collection (`WHERE Id IN :ids`) |
| DML on individual records in a loop | Repositories batch-update via `List<sObject>` |
| N+1 queries from child navigation | Cross-object fields (`Account__r.Name`) used in the same query |

---

## Security Model

- Every Apex class declares `with sharing`, enforcing the running user's
  sharing rules.
- CRUD/FLS is verified with `Schema.sObjectType.isAccessible()` /
  `isUpdateable()` describe checks before any DML.
- The `Engagement_Hub_User` permission set grants the minimum object/field
  access required to use the application.
- No hardcoded record Ids, org URLs, credentials, or secrets appear anywhere
  in the codebase.

---

## Test Strategy

```
EngagementRepositoryTest   ──► findById, findByIds, updateEngagements
                                positive + null/empty/deleted scenarios

EngagementServiceTest      ──► getWorkspace, advanceApproval
                                positive + all negative paths
                                (null Id, deleted record, no steps,
                                all steps complete, amount rollup)

EngagementControllerTest   ──► @AuraEnabled boundary
                                positive + AuraHandledException on
                                every error path

TestDataFactory            ──► centralised record creation,
                                keeps test classes focused on behaviour
```

Unit tests use `@TestSetup` to share insert cost across test methods in the
same class. No external HTTP callouts are required; all tests run in isolation.
