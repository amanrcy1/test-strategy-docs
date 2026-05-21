# 2. Test Scope

## In-Scope Systems

### Core Payment Engine

| Component | Description | Test Focus |
|-----------|-------------|-----------|
| Transaction Processor | Handles payment initiation, validation, routing | Correctness, concurrency, idempotency |
| Ledger Service | Double-entry bookkeeping for all financial movements | Balance consistency, reconciliation |
| Settlement Engine | Batches and settles transactions with banking partners | Timing, retry logic, partial settlement |
| FX Engine | Real-time currency conversion for cross-border payments | Rate accuracy, rounding rules, margin |

### User-Facing Applications

| Application | Platform | Test Scope |
|-------------|----------|-----------|
| PayFlow Mobile | iOS 15+, Android 12+ | E2E flows, biometric auth, push notifications |
| PayFlow Web | Chrome, Firefox, Safari, Edge (latest 2 versions) | Full functional testing, accessibility, responsive |
| Merchant Portal | Web (Chrome, Firefox) | Onboarding, transaction management, reporting |
| Admin Console | Internal web app | User management, compliance workflows, support tools |

### Integration Layer

| Integration | Protocol | Test Approach |
|-------------|----------|--------------|
| Banking Partner APIs (8) | REST/SOAP | Contract tests + integration tests |
| Card Networks (Visa, Mastercard, Amex) | ISO 8583 / REST | Message format validation + E2E |
| Identity Verification (Onfido) | REST | Mock + periodic live verification |
| Fraud Detection (internal ML model) | gRPC | Model accuracy + latency testing |
| Notification Service (FCM, APNs, Email) | REST/SMTP | Delivery verification + template testing |

### Infrastructure

| Component | Test Focus |
|-----------|-----------|
| Kubernetes cluster (EKS) | Scaling, pod recovery, resource limits |
| PostgreSQL (primary DB) | Data integrity, replication lag, backup/restore |
| Redis (caching/sessions) | Cache invalidation, failover, memory limits |
| Kafka (event streaming) | Message ordering, consumer lag, dead letter queue |
| CDN (CloudFront) | Cache headers, purge behavior, geo-routing |

## Out-of-Scope

- Third-party banking partner internal processing
- Physical card manufacturing and issuance
- Customer support ticketing system (Zendesk)
- Marketing analytics platform
- Corporate finance and accounting tools

## Test Levels

```
┌─────────────────────────────────────────────────────┐
│                   E2E / Journey Tests                │
│         (Full user flows across services)            │
├─────────────────────────────────────────────────────┤
│              Integration Tests                       │
│    (Service-to-service, DB, external APIs)           │
├─────────────────────────────────────────────────────┤
│              Component Tests                         │
│       (Individual service in isolation)              │
├─────────────────────────────────────────────────────┤
│                Unit Tests                            │
│      (Functions, classes, business logic)            │
└─────────────────────────────────────────────────────┘
```

## Environment Coverage

| Environment | Purpose | Data |
|-------------|---------|------|
| Local Dev | Developer unit/integration testing | Seed data, mocked externals |
| CI | Automated test suite execution | Synthetic test data |
| Staging | Pre-release validation | Anonymized production subset |
| Performance | Load and stress testing | Generated high-volume data |
| Production | Synthetic monitoring, canary | Read-only synthetic transactions |

## Release Cadence

PayFlow follows a 2-week sprint cycle with the following release gates:

1. **Feature branch**: Unit tests + component tests pass
2. **PR merge to develop**: Full integration test suite passes
3. **Release candidate**: E2E suite + performance baseline + security scan
4. **Production deploy**: Canary with synthetic monitoring for 30 minutes
5. **Post-deploy**: Smoke tests + reconciliation verification
