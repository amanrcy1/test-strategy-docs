# 8. Defect Management

## Defect Lifecycle

```
┌──────────┐    ┌───────────┐    ┌──────────┐    ┌─────────┐    ┌────────┐
│   New    │───▶│  Triaged  │───▶│ Assigned │───▶│  Fixed  │───▶│ Closed │
│          │    │           │    │          │    │         │    │        │
└──────────┘    └───────────┘    └──────────┘    └─────────┘    └────────┘
     │               │                │               │
     │               ▼                ▼               ▼
     │          ┌─────────┐    ┌───────────┐    ┌──────────┐
     │          │Rejected │    │  Deferred │    │ Reopened │
     │          │(Not Bug)│    │           │    │          │
     │          └─────────┘    └───────────┘    └──────────┘
     │
     ▼
┌──────────┐
│Duplicate │
└──────────┘
```

## Severity Classification

| Severity | Definition | Examples | SLA (Response) | SLA (Resolution) |
|:--------:|-----------|----------|:--------------:|:----------------:|
| **P1 — Critical** | System unusable, data loss/corruption, security breach, financial impact | Payment processing failure, authentication bypass, data breach | 30 minutes | 4 hours |
| **P2 — High** | Major feature broken, no workaround, significant user impact | Cannot complete payment flow, incorrect balance display, settlement failure | 2 hours | 24 hours |
| **P3 — Medium** | Feature partially broken, workaround exists, moderate user impact | Notification delay, report export error with manual alternative, slow page load | 8 hours | 5 business days |
| **P4 — Low** | Cosmetic issue, minor inconvenience, edge case | Typo in confirmation message, slight layout shift, tooltip misalignment | 24 hours | Next sprint |

## Defect Report Template

Every defect report must include the following fields:

```markdown
## Bug Report

**Title:** [Concise description of the issue]

**Severity:** P1 / P2 / P3 / P4
**Priority:** Critical / High / Medium / Low
**Component:** [Service or module affected]
**Environment:** [Where discovered: CI, Staging, Performance, Production]
**Build/Version:** [Release tag or commit SHA]
**Reporter:** [Name]
**Date Found:** [YYYY-MM-DD]

### Description
[2-3 sentence summary of the issue and its user impact]

### Steps to Reproduce
1. [Precondition]
2. [Action]
3. [Action]
4. [Observed result]

### Expected Result
[What should happen]

### Actual Result
[What actually happened]

### Evidence
- Screenshots/Screen recordings: [attachment]
- Logs: [relevant log snippet or link]
- Network trace: [HAR file or API response]

### Impact Assessment
- Users affected: [count or percentage]
- Financial impact: [estimated if applicable]
- Workaround available: Yes/No — [description if yes]

### Technical Notes
[Root cause hypothesis, related code areas, suggested fix approach]
```

## Triage Process

### Daily Triage Meeting (15 minutes)

**Participants:** QA Lead, Dev Lead, Product Owner
**Frequency:** Daily at 09:30 during active testing phases; 3x/week otherwise
**Agenda:**
1. Review new defects (5 min)
2. Assign severity and priority (5 min)
3. Assign owner and target sprint/release (5 min)

### Triage Decision Framework

```
Is it reproducible?
├── No → Request more info, move to "Needs Info"
└── Yes
    └── Is it a regression?
        ├── Yes → Automatic P2+ severity, assign to sprint
        └── No
            └── Assess business impact
                ├── Financial/Security/Data risk → P1 or P2
                ├── Feature broken, no workaround → P2
                ├── Feature broken, workaround exists → P3
                └── Cosmetic/Edge case → P4
```

## Defect Metrics and Reporting

### Key Metrics Tracked

| Metric | Calculation | Target | Review Cadence |
|--------|------------|--------|---------------|
| Defect Discovery Rate | New defects / week | Trending down sprint-over-sprint | Weekly |
| Defect Escape Rate | Production defects / total defects found | < 5% | Per release |
| Mean Time to Detect (MTTD) | Time from introduction to discovery | < 1 sprint | Per release |
| Mean Time to Resolution (MTTR) | Time from report to verified fix | P1: < 4h, P2: < 24h | Weekly |
| Defect Reopen Rate | Reopened defects / total fixed defects | < 10% | Per sprint |
| Test Effectiveness | Defects found in test / total defects | > 90% | Per release |
| Defect Density | Defects per KLOC (thousand lines of code) | < 5 per KLOC | Per release |

### Sprint-Level Dashboard

The defect dashboard displays:
- Open defect count by severity (bar chart)
- Defect aging (time in each state)
- Discovery phase breakdown (unit, integration, E2E, production)
- Top defect-producing components (Pareto chart)
- SLA compliance percentage

### Release-Level Report

Each release includes a quality summary with:
- Total defects found during testing cycle
- Defects by severity breakdown
- Defect escape count (found post-release)
- Comparison against previous 3 releases (trend)
- Root cause categories (code logic, integration, configuration, environment)

## Defect Prevention

### Root Cause Analysis (RCA)

For every P1 and P2 defect, a mini-RCA is conducted:

| Step | Action | Output |
|------|--------|--------|
| 1 | Identify root cause | Technical cause documented |
| 2 | Determine injection phase | When was the defect introduced (design, code, config) |
| 3 | Determine escape reason | Why wasn't it caught earlier |
| 4 | Define prevention action | Specific improvement (new test, rule, process change) |
| 5 | Implement prevention | PR with test/fix, process update committed |

### Continuous Improvement Actions

- **Test gap analysis**: After every escaped defect, add a test that would have caught it
- **Flaky test management**: Quarantine flaky tests immediately, fix within 2 sprints
- **Code review checklist**: Update based on common defect root causes
- **Static analysis rules**: Add custom rules for repeated defect patterns
- **Knowledge sharing**: Monthly "Bug of the Month" presentation highlighting learnings

## Tools

| Tool | Purpose | Integration |
|------|---------|-------------|
| GitHub Issues | Defect tracking and lifecycle management | Native to repository |
| GitHub Projects | Sprint board and workflow automation | Linked to Issues |
| Allure | Test execution reporting with failure details | CI pipeline artifact |
| DataDog | Production defect detection and alerting | APM + log monitoring |
| Slack | Real-time P1/P2 notifications | GitHub + DataDog webhooks |

## Escalation Path

```
P4/P3: QA Engineer → Dev Team (normal sprint flow)
P2:    QA Lead → Dev Lead → resolved within 24h
P1:    QA Lead → Engineering Manager → CTO (if > 2h without fix)
        → Incident commander assigned
        → War room opened
        → Stakeholder communication every 30 minutes
```
