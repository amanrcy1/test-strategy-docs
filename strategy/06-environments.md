# 6. Environment Strategy

## Environment Overview

PayFlow maintains five distinct environments, each serving a specific purpose in the software delivery lifecycle. Environments are provisioned using Infrastructure as Code (Terraform) and are deployed on AWS EKS.

```
┌──────────────────────────────────────────────────────────────────┐
│                     Environment Pipeline                          │
│                                                                  │
│  ┌─────┐    ┌─────┐    ┌─────────┐    ┌──────┐    ┌──────────┐ │
│  │Local│───▶│ CI  │───▶│ Staging │───▶│ Perf │───▶│Production│ │
│  │ Dev │    │     │    │         │    │      │    │          │ │
│  └─────┘    └─────┘    └─────────┘    └──────┘    └──────────┘ │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Environment Specifications

### Local Development

| Attribute | Details |
|-----------|---------|
| Purpose | Developer unit and integration testing |
| Infrastructure | Docker Compose on developer machines |
| Services | All PayFlow services + PostgreSQL + Redis + Kafka (dockerized) |
| External Dependencies | Mocked via WireMock containers |
| Data | Seed scripts with synthetic test data |
| Access | Individual developer only |
| Refresh Cycle | On-demand (developer controls lifecycle) |
| Monitoring | Local logs only (stdout) |

**Configuration:**
- Services run on localhost with port mapping
- Database seeded with 100 synthetic accounts and 1,000 transactions
- Feature flags default to all-enabled for development
- No TLS between local services (simplified networking)

### CI Environment

| Attribute | Details |
|-----------|---------|
| Purpose | Automated test suite execution on every PR and push |
| Infrastructure | GitHub Actions runners (ubuntu-latest) with service containers |
| Services | Service under test + direct dependencies (containerized) |
| External Dependencies | WireMock stubs, Testcontainers for databases |
| Data | Programmatically generated per test run (isolated) |
| Access | Automated pipelines only |
| Refresh Cycle | Ephemeral — created per workflow run, destroyed after |
| Monitoring | GitHub Actions logs + Allure reports as artifacts |

**Configuration:**
- Each workflow run gets a fresh environment (no state leakage)
- PostgreSQL and Redis run as GitHub Actions service containers
- Kafka uses Testcontainers for integration tests
- Tests run in parallel across matrix builds (3 Node versions × 3 browsers)
- Maximum execution time: 15 minutes per workflow

### Staging

| Attribute | Details |
|-----------|---------|
| Purpose | Pre-release validation, full integration testing, UAT |
| Infrastructure | AWS EKS cluster (t3.medium nodes, 3-node pool) |
| Services | Full PayFlow platform (all microservices deployed) |
| External Dependencies | Sandbox environments from banking partners (where available), stubs for others |
| Data | Anonymized production subset (10% sample), refreshed weekly |
| Access | QA team, product owners, select developers |
| Refresh Cycle | Deployed on every merge to `develop` branch |
| Monitoring | DataDog APM, CloudWatch logs, Slack alerting |

**Configuration:**
- Mirrors production architecture at reduced scale (1/5th capacity)
- Real TLS certificates (Let's Encrypt staging)
- Feature flags controlled independently from production
- Banking partner sandbox APIs integrated (Stripe test mode, partner sandboxes)
- Data anonymization pipeline runs weekly from production snapshot

### Performance

| Attribute | Details |
|-----------|---------|
| Purpose | Load testing, stress testing, capacity planning |
| Infrastructure | AWS EKS cluster (c5.2xlarge nodes, 6-node pool, production-equivalent) |
| Services | Full PayFlow platform at production scale |
| External Dependencies | High-fidelity stubs with realistic latency simulation |
| Data | Generated high-volume dataset (2.5M accounts, 50M transactions) |
| Access | QA engineers, SRE team |
| Refresh Cycle | On-demand, provisioned for scheduled performance test windows |
| Monitoring | Full observability stack (DataDog, Grafana, custom dashboards) |

**Configuration:**
- Infrastructure matches production specs (instance types, autoscaling policies)
- Database pre-loaded with production-scale data volume
- Network conditions simulate real-world latency to partner APIs
- k6 load generators run from multiple AWS regions
- Tests scheduled during off-peak hours to avoid cost spikes
- Environment torn down after test window to control costs

### Production

| Attribute | Details |
|-----------|---------|
| Purpose | Live service, synthetic monitoring, canary deployments |
| Infrastructure | AWS EKS (multi-AZ, auto-scaling 3-20 nodes per region) |
| Services | Full PayFlow platform (2 regions: us-east-1, eu-west-1) |
| External Dependencies | Live banking partner APIs, real card network connections |
| Data | Real customer data (encrypted, access-controlled) |
| Access | SRE team for deployment, read-only monitoring for QA |
| Refresh Cycle | Continuous deployment (canary → progressive rollout) |
| Monitoring | Full observability, PagerDuty alerting, SLA dashboards |

**Testing in Production:**
- Synthetic monitoring: Automated payment flows every 5 minutes using dedicated test accounts
- Canary analysis: New deployments serve 5% traffic, compared against baseline for 30 minutes
- Feature flag gradual rollout: New features exposed to 1% → 10% → 50% → 100%
- Chaos engineering: Controlled failure injection during maintenance windows only

## Data Management Strategy

| Environment | Data Source | Sensitive Data Handling | Refresh Frequency |
|-------------|-----------|------------------------|-------------------|
| Local Dev | Seed scripts (synthetic) | No real data ever | On developer reset |
| CI | Generated per test run | No real data ever | Every run (ephemeral) |
| Staging | Production snapshot (anonymized) | PII masked/tokenized | Weekly |
| Performance | Generated at scale | Synthetic, statistically representative | Per test window |
| Production | Real customer data | Full encryption, RBAC, audit logging | N/A (live) |

**Anonymization Rules:**
- Names → randomly generated from name corpus
- Emails → `user_{hash}@test.payflow.internal`
- Phone numbers → `+1-555-{random 7 digits}`
- Account numbers → `TEST-{random 10 digits}`
- Transaction amounts → preserved (for realistic distribution)
- Dates → preserved (for realistic temporal patterns)

## Environment Promotion Gates

```
Local Dev → CI:        PR created, linting passes
CI → Staging:          All CI tests pass, code review approved, PR merged to develop
Staging → Performance: Staging E2E suite green, release candidate tagged
Performance → Prod:    Performance targets met, security scan clean, change approval
```
