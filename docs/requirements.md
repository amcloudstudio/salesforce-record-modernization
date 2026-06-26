# Requirements

## Problem Statement

Legacy enterprise record pages often render every related list and field on
a single dense page, making it hard for users to find the information they
need. This project demonstrates how to modernize that experience with a
componentized Lightning Web Component record page backed by a clean,
layered Apex architecture.

## Functional Requirements

1. Display core engagement details (name, status, stage, priority, dates).
2. Display related Accounts ("customers") linked to the engagement.
3. Display related Opportunities linked to the engagement, with a rollup of
   total open/won amount.
4. Display an approval timeline showing ordered steps and their status.
5. Allow a user to advance the engagement to the next approval step via an
   action button.
6. Display summary statistics (counts, sums) for the engagement.

## Non-Functional Requirements

- No SOQL/DML inside loops; all data access must be bulk-safe.
- Apex classes must declare sharing (`with sharing`).
- CRUD/FLS must be respected before any DML.
- No hardcoded Ids, credentials, or secrets.
- Apex code must be covered by unit tests with positive and negative
  scenarios, using a `TestDataFactory` for record creation.
- The LWC layer must contain no SOQL and no business logic.

## Out of Scope

- Authentication/SSO concerns (assumes a logged-in Salesforce user).
- Multi-currency/multi-language support.
- Integration with external systems.
