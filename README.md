# Engagement Hub

A demo Salesforce application that modernizes a legacy record-detail
experience into a clean, componentized Lightning Web Component (LWC) page,
backed by a layered Apex architecture (Controller → Service → Repository).

> This is an original, fictitious demo project. It contains no employer
> code, data, business logic, or screenshots.

## Status

Work in progress — see [docs/architecture.md](docs/architecture.md) and
[docs/requirements.md](docs/requirements.md) for the current design.
Full documentation (overview, technologies, design decisions, screenshots,
future improvements) will be completed once implementation is finished.

## Project Structure

```
force-app/main/default/
  classes/
    controllers/   Apex Controllers (thin, AuraEnabled boundary)
    services/       Business logic
    repositories/    SOQL/DML data access
    dto/            Wrapper classes for data crossing the LWC boundary
    exceptions/      Custom exception types
    factories/       TestDataFactory
    tests/           Unit tests
  lwc/
    recordWorkspace/      Container component
    recordHeader/         Header / status badge
    relatedAccounts/      Related customers panel
    relatedOpportunities/ Related opportunities panel
    approvalTimeline/     Approval timeline panel
    actionPanel/           Action buttons / statistics
  objects/
  permissionsets/
  layouts/
  flexipages/
  customLabels/
  tabs/
docs/
  architecture.md
  requirements.md
  screenshots/
  diagrams/
```

## License

MIT — see [LICENSE](LICENSE).
