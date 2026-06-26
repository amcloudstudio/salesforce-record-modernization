# Architecture

## Overview

Engagement Hub is a demo Lightning application that replaces a legacy,
monolithic record-detail page with a componentized Lightning Web Component
(LWC) experience. It is an original, fictitious use case — it does not
contain any employer code, data, or business logic.

The domain model centers on a custom object, `Engagement__c`, representing a
generic business record (e.g. a deal, project, or case) that moves through a
multi-step approval process and has related Accounts and Opportunities.

## Layering

```
LWC (presentation only)
   |  no SOQL, no business logic
   v
Apex Controller   -- thin pass-through, input shaping only
   v
Apex Service      -- business logic, validation, orchestration
   v
Apex Repository   -- SOQL only, field-level selection, bulk-safe
   v
Database
```

Each layer has a single responsibility:

- **LWC** renders data and dispatches user intent. It never queries the
  database directly and contains no business rules.
- **Controller** (`@AuraEnabled` boundary) validates that it is being called
  with sane inputs and delegates to a Service. No business logic lives here.
- **Service** implements business rules (status transitions, approval
  progression, statistics calculation) and enforces CRUD/FLS checks before
  delegating data access to a Repository.
- **Repository** is the only layer that issues SOQL/DML. It selects only the
  fields it needs, is bulk-safe, and returns sObjects or thin projections to
  the Service layer, which maps them into DTOs for the Controller.

## Data Model

- `Engagement__c` — the primary record (Name, Status, Stage, Priority, dates,
  notes).
- `Engagement_Account__c` — junction object linking `Engagement__c` to
  standard `Account` records ("related customers").
- `Opportunity.Engagement__c` — lookup field added to standard `Opportunity`
  linking it back to an `Engagement__c`.
- `Approval_Step__c` — child records representing ordered steps in the
  approval timeline (Step Order, Status, Approver Name, Completed Date).

## DTOs

All data crossing the Controller/LWC boundary uses explicit wrapper classes
(never `Map<String, Object>`):

- `EngagementDTO`
- `AccountSummaryDTO`
- `OpportunitySummaryDTO`
- `ApprovalStepDTO`
- `EngagementStatisticsDTO`

## Performance & Governor Limits

- No SOQL or DML inside loops; repositories accept and return collections.
- The record workspace LWC issues a single Apex call (`getEngagementWorkspace`)
  that aggregates engagement, accounts, opportunities, approval steps, and
  statistics in one round trip, rather than one call per panel.
- Repositories select only the fields required by their DTOs.

## Security

- All Apex classes use `with sharing`.
- Services check CRUD/FLS via `Schema.sObjectType` describe checks before
  insert/update operations.
- No hardcoded record Ids, credentials, or secrets.

## Error Handling

Custom exception types (`EngagementServiceException`,
`EngagementRepositoryException`) are thrown for predictable failure modes and
translated into `AuraHandledException` at the Controller boundary so client
code receives clean, user-presentable error messages.
