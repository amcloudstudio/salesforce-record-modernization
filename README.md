# Engagement Hub

> A production-quality Salesforce demo application demonstrating how to
> modernize a legacy record-detail experience using Lightning Web Components,
> a clean layered Apex architecture, and Salesforce best practices.
>
> **This is an original, fictitious open-source project. It contains no
> employer code, proprietary data, internal object names, or business logic.**

---

## Overview

Enterprise Salesforce orgs often accumulate dense, hard-to-navigate record
pages — every related list crammed onto a single screen, slow to load, and
difficult to extend. **Engagement Hub** shows how to replace that pattern with
a componentized Lightning experience backed by a clean, testable Apex
architecture.

The domain is intentionally generic: an `Engagement__c` record represents any
business record that moves through a multi-step approval process and has
related Accounts and Opportunities.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Lightning Record Page                         │
│                                                                   │
│   ┌─────────────────── recordWorkspace ───────────────────────┐  │
│   │  @wire getEngagementWorkspace  ←─ single Apex call        │  │
│   │                                                            │  │
│   │  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐  │  │
│   │  │recordHeader│  │relatedAccounts│  │relatedOpportunities│  │  │
│   │  └────────────┘  └──────────────┘  └──────────────────┘  │  │
│   │                                                            │  │
│   │  ┌──────────────────┐  ┌───────────────────────────────┐  │  │
│   │  │ approvalTimeline │  │        actionPanel            │  │  │
│   │  │                  │  │  (statistics + actions)       │  │  │
│   │  └──────────────────┘  └───────────────────────────────┘  │  │
│   └────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         │ @AuraEnabled  (imperative: advanceApproval)
         ▼
┌─────────────────────────┐
│   EngagementController  │  Thin boundary — no logic, no SOQL
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│   EngagementService     │  Business logic, validation,
│                         │  DTO mapping, approval progression
└────────────┬────────────┘
             │
     ┌───────┼───────────────────┐
     ▼       ▼                   ▼
┌────────┐ ┌───────────────┐ ┌──────────────────────┐
│Engage- │ │AccountRepo /  │ │ApprovalStepRepository│
│mentRepo│ │OpportunityRepo│ │                      │
└────────┘ └───────────────┘ └──────────────────────┘
     │               │                   │
     └───────────────┴───────────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  Database   │
              └─────────────┘
```

### Layering rules

| Layer | Responsibility | What it must NOT do |
|---|---|---|
| LWC | Render, handle user events | SOQL, business logic |
| Controller | `@AuraEnabled` boundary, input validation | Business logic, SOQL |
| Service | Orchestration, business rules, DTO mapping | SOQL, DML |
| Repository | SOQL and DML only | Business logic |

---

## Technologies

| Technology | Usage |
|---|---|
| **Lightning Web Components** | UI layer — wire adapter, imperative Apex, custom events |
| **Apex** | Controller / Service / Repository with `with sharing` |
| **SLDS** | Lightning Design System for all visual styling |
| **SOQL** | Bulk-safe, field-scoped queries inside repository classes only |
| **Salesforce Metadata API** | Custom objects, fields, permission set, FlexiPage, tab |
| **SFDX source format** | Full source-tracked project deployable with Salesforce CLI |

---

## Data Model

```
Engagement__c
│  Name, Status__c, Stage__c, Priority__c
│  Owner_Notes__c, Start_Date__c, Target_Close_Date__c
│
├─── Engagement_Account__c (junction)
│      Engagement__c  ──►  Engagement__c
│      Account__c     ──►  Account
│      Relationship_Type__c
│
├─── Approval_Step__c (child)
│      Engagement__c  ──►  Engagement__c
│      Step_Order__c, Status__c, Approver_Name__c, Completed_Date__c
│
└─── Opportunity (standard, extended)
       Engagement__c  ──►  Engagement__c  (lookup field added)
```

---

## Design Decisions

**Single server round-trip.** `recordWorkspace` calls one `@wire` method
(`getEngagementWorkspace`) that returns an `EngagementWorkspaceDTO` containing
all panel data — engagement details, accounts, opportunities, approval steps,
and statistics — in a single response. Child components receive their data
via `@api` properties from the parent.

**DTO wrapper classes over `Map<String, Object>`.** Every payload that crosses
the Apex/LWC boundary is a typed class. This enforces a contract, enables
compile-time checks, and makes the interface self-documenting.

**Dependency injection in the Service.** `EngagementService` accepts its
repositories through the constructor. The no-arg constructor instantiates real
repositories for production; tests inject mock-friendly instances. This keeps
unit tests fast and avoids database round-trips in the service layer.

**Custom exceptions per layer.** `EngagementRepositoryException` and
`EngagementServiceException` make the source of an error unambiguous.
The Controller catches both and re-throws as `AuraHandledException` so the
LWC layer receives a clean, user-presentable message.

**`with sharing` everywhere.** Every Apex class enforces sharing rules.
CRUD/FLS is checked before any DML operation using `Schema.sObjectType`
describe calls.

---

## Project Structure

```
salesforce-record-modernization/
│
├── config/
│   └── project-scratch-def.json     Scratch Org definition
│
├── docs/
│   ├── architecture.md              Detailed architecture notes
│   ├── requirements.md              Functional & non-functional requirements
│   ├── diagrams/                    Architecture diagrams
│   └── screenshots/                 UI screenshots
│
├── force-app/main/default/
│   ├── classes/
│   │   ├── controllers/
│   │   │   └── EngagementController.cls
│   │   ├── services/
│   │   │   └── EngagementService.cls
│   │   ├── repositories/
│   │   │   ├── EngagementRepository.cls
│   │   │   ├── AccountRepository.cls
│   │   │   ├── OpportunityRepository.cls
│   │   │   └── ApprovalStepRepository.cls
│   │   ├── dto/
│   │   │   ├── EngagementDTO.cls
│   │   │   ├── AccountSummaryDTO.cls
│   │   │   ├── OpportunitySummaryDTO.cls
│   │   │   ├── ApprovalStepDTO.cls
│   │   │   ├── EngagementStatisticsDTO.cls
│   │   │   └── EngagementWorkspaceDTO.cls
│   │   ├── exceptions/
│   │   │   ├── EngagementRepositoryException.cls
│   │   │   └── EngagementServiceException.cls
│   │   ├── factories/
│   │   │   └── TestDataFactory.cls
│   │   └── tests/
│   │       ├── EngagementRepositoryTest.cls
│   │       ├── EngagementServiceTest.cls
│   │       └── EngagementControllerTest.cls
│   │
│   ├── lwc/
│   │   ├── recordWorkspace/         Container — single wire call
│   │   ├── recordHeader/            Name, status badge, priority
│   │   ├── relatedAccounts/         Related customers datatable
│   │   ├── relatedOpportunities/    Related opportunities datatable
│   │   ├── approvalTimeline/        Visual approval step timeline
│   │   └── actionPanel/             Statistics tiles + Advance Approval button
│   │
│   ├── objects/
│   │   ├── Engagement__c/
│   │   ├── Engagement_Account__c/
│   │   ├── Approval_Step__c/
│   │   └── Opportunity/fields/      Engagement__c lookup field
│   │
│   ├── permissionsets/
│   │   └── Engagement_Hub_User.permissionset-meta.xml
│   ├── flexipages/
│   │   └── Engagement_Record_Page.flexipage-meta.xml
│   └── tabs/
│       └── Engagement__c.tab-meta.xml
│
├── sfdx-project.json
├── .forceignore
├── .gitignore
├── LICENSE
└── README.md
```

---

## Quick Start

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- A Salesforce **Developer Edition** org or **Dev Hub** (for Scratch Orgs)

### Option A — Scratch Org (recommended)

```bash
# 1. Clone the repository
git clone https://github.com/amcloudstudio/salesforce-record-modernization.git
cd salesforce-record-modernization

# 2. Authenticate your Dev Hub (once)
sf org login web --set-default-dev-hub --alias DevHub

# 3. Create a Scratch Org
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias EngagementHub \
  --set-default \
  --duration-days 30

# 4. Deploy the source
sf project deploy start --source-dir force-app

# 5. Open in browser
sf org open
```

### Option B — Developer Edition Org

```bash
# 1. Authenticate
sf org login web --alias MyDevOrg --set-default

# 2. Deploy
sf project deploy start --source-dir force-app

# 3. Open
sf org open
```

### Post-deploy setup

1. **Assign the Permission Set**
   > Setup → Permission Sets → *Engagement Hub User* → Manage Assignments

2. **Create a test Engagement record**
   > App Launcher → Engagements → New

3. **Add child records** (Developer Console or Data Loader)
   - `Engagement_Account__c` — link any Account
   - `Approval_Step__c` — add 3 steps with `Step_Order__c = 1, 2, 3`
   - `Opportunity` — set `Engagement__c` to your Engagement Id

4. **Open the record** — the full LWC workspace appears on the record page.

---

## Running Tests

```bash
# Run all tests and show results in the terminal
sf apex run test --test-level RunLocalTests --wait 10 --result-format human

# Run tests with code coverage
sf apex run test --test-level RunLocalTests --wait 10 --code-coverage
```

**Test classes:**

| Class | Scenarios |
|---|---|
| `EngagementRepositoryTest` | findById (valid / null / deleted), bulk findByIds, updateEngagements (happy path, empty list) |
| `EngagementServiceTest` | getWorkspace (valid / null / deleted), advanceApproval (step advance, full completion → Engagement promoted, no steps, all complete, null Id), amount rollup |
| `EngagementControllerTest` | getEngagementWorkspace + advanceApproval — positive + AuraHandledException on every error path |

---

## Future Improvements

- **Inline edit** — allow editing core Engagement fields directly from
  `recordHeader` using `lightning-record-edit-form`.
- **Reject step action** — add a "Reject" button in `actionPanel` that sets a
  step to Rejected and updates the Engagement status accordingly.
- **Real-time updates** — use Lightning Message Service so sibling components
  can refresh independently without re-fetching the entire workspace.
- **Pagination** — add server-side pagination to `relatedAccounts` and
  `relatedOpportunities` for Engagements with large related lists.
- **Jest unit tests** — add `@salesforce/apex` mocks and Jest tests for each
  LWC component.
- **CI/CD pipeline** — GitHub Actions workflow to deploy to a Scratch Org and
  run Apex tests on every pull request.

---

## License

MIT — see [LICENSE](LICENSE).
