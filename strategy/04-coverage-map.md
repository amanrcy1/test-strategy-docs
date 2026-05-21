# 4. Test Coverage Map

## Coverage Strategy Overview

This coverage map defines the testing approach for each test type across PayFlow's application areas. Coverage targets are informed by the risk assessment (Section 3) and prioritize critical business flows.

## Unit Tests

| Application Area | Components Covered | Entry Criteria | Target Coverage |
|-----------------|-------------------|----------------|:---------------:|
| Transaction Processor | Payment validation, routing logic, idempotency checks, state transitions | Code compiles, dependencies mocked | 90% line coverage |
| Ledger Service | Double-entry accounting logic, balance calculations, reconciliation algorithms | Isolated from DB, deterministic inputs | 95% line coverage |
| FX Engine | Rate conversion, rounding rules, margin calculation, currency pair validation | Fixed rate fixtures, no external calls | 95% line coverage |
| Fraud Detection Rules | Velocity checks, geo-anomaly scoring, pattern matching rules | Model outputs mocked | 85% line coverage |
| User Authentication | Token generation, validation, refresh, session management | Crypto functions mocked with known keys | 90% line coverage |
| Notification Service | Template rendering, recipient routing, retry logic | External services mocked | 80% line coverage |

**Overall Unit Test Target: 85% aggregate line coverage across all services**

**Entry Criteria for Execution:**
- Source code compiles without errors
- All external dependencies are mocked or stubbed
- Test data fixtures are available and deterministic
- Developer has run linting and formatting checks

## Integration Tests

| Application Area | Components Covered | Entry Criteria | Target Coverage |
|-----------------|-------------------|----------------|:---------------:|
| Payment Processing Pipeline | Transaction Processor → Ledger → Settlement Engine | All services deployed in CI environment, DB seeded | 100% of critical paths |
| Banking Partner Integrations | PayFlow → Partner API Gateway (8 partners) | Contract test stubs available, network accessible | 100% of API endpoints used |
| Database Operations | Service → PostgreSQL (CRUD, transactions, migrations) | Test database provisioned with schema applied | 90% of query patterns |
| Event Streaming | Producer → Kafka → Consumer chains | Kafka broker running in CI, topics created | 100% of event types |
| Cache Layer | Service → Redis (sessions, rate limits, cached data) | Redis instance running, flush between tests | 85% of cache patterns |
| External Services | PayFlow → Onfido, Fraud Model, Notification | Wiremock stubs configured from recorded traffic | 100% of integration points |

**Overall Integration Test Target: 95% of inter-service communication paths tested**

**Entry Criteria for Execution:**
- All dependent services are healthy (health check endpoints return 200)
- Test database is migrated to current schema version
- Message broker topics exist and are empty
- Stub services are configured with expected responses
- Previous test run artifacts are cleaned up

## End-to-End (E2E) Tests

| Application Area | User Journeys Covered | Entry Criteria | Target Coverage |
|-----------------|----------------------|----------------|:---------------:|
| User Onboarding | Registration → KYC → First deposit → Account activation | Full staging environment deployed, identity service available | 100% of onboarding paths |
| P2P Payments | Initiate → Confirm → Process → Notify recipient | Sender and recipient accounts exist with sufficient balance | 100% of payment flows |
| Merchant Payments | Scan QR → Enter amount → Authenticate → Confirm | Merchant account configured, terminal simulated | 100% of checkout variants |
| Bill Splitting | Create group → Add members → Split → Collect | Multiple test accounts with relationships | 90% of split scenarios |
| Dispute Resolution | Flag transaction → Submit evidence → Review → Resolve | Historical transactions exist, support agent account available | 80% of dispute paths |
| Account Management | Profile update → Password change → Device management → Close account | Active account with transaction history | 90% of settings flows |

**Overall E2E Test Target: 100% of critical user journeys, 80% of secondary flows**

**Entry Criteria for Execution:**
- Staging environment fully deployed and passing smoke tests
- Test data seeded (accounts, balances, transaction history)
- Third-party integrations available (or realistic stubs for unreliable services)
- Previous E2E run completed without environment-level failures
- Feature flags configured to match production state

## Performance Tests

| Application Area | Scenarios Covered | Entry Criteria | Target/Goal |
|-----------------|-------------------|----------------|:-----------:|
| Transaction Processing | Sustained load: 3,000 TPS for 30 minutes | Performance environment provisioned at production-equivalent scale | P95 < 500ms, P99 < 1000ms, 0% errors |
| Peak Load Handling | Spike: 0 → 10,000 TPS ramp over 2 minutes | Autoscaling enabled, baseline metrics recorded | Scale within 60s, no 5xx during ramp |
| Database Under Load | 5,000 concurrent read/write operations | Production-size dataset loaded (anonymized) | Query P95 < 50ms, no deadlocks |
| API Gateway | 50,000 concurrent connections sustained | Load balancer configured, connection pooling active | No connection refused, P95 < 200ms |
| Settlement Batch | Process 500,000 pending settlements | Settlement queue populated, partner stubs configured | Complete within 2-hour window |
| Mobile App Cold Start | App launch to interactive on mid-range device | APK/IPA installed on device farm | < 3 seconds to interactive |

**Overall Performance Target: Meet all SLA thresholds under 3x expected peak load**

**Entry Criteria for Execution:**
- Performance environment is isolated (no other workloads)
- Baseline metrics captured from previous run for comparison
- Monitoring and APM tools configured and recording
- Test data volume matches production scale
- Autoscaling policies match production configuration

## Security Tests

| Application Area | Test Activities | Entry Criteria | Target/Goal |
|-----------------|----------------|----------------|:-----------:|
| Authentication & Authorization | OWASP Top 10 testing, token manipulation, privilege escalation, session hijacking | Application deployed, test accounts with various roles | Zero critical/high findings |
| Data Protection | PII detection in logs/responses, encryption verification, key rotation testing | Access to log aggregation, database inspection tools | Zero PII leakage findings |
| API Security | Input validation, injection attacks (SQL, NoSQL, command), rate limiting bypass | API documentation available, Burp Suite configured | Zero injection vulnerabilities |
| Network Security | TLS configuration, certificate pinning validation, mTLS between services | Network scanning tools configured, cert inventory available | TLS 1.3 only, no weak ciphers |
| Dependency Vulnerabilities | SCA scanning for known CVEs in dependencies | Package manifests accessible, vulnerability database updated | Zero critical CVEs, high CVEs patched within 7 days |
| Compliance Controls | PCI-DSS automated checks, data residency verification, audit log integrity | Compliance checklist mapped to automated tests | 100% of automatable controls pass |

**Overall Security Target: Zero critical/high severity findings in production-bound releases**

**Entry Criteria for Execution:**
- Application is in a stable, testable state (no known crashes)
- Security testing tools licensed and configured
- Test accounts available for each role/permission level
- Scope approval obtained (especially for penetration testing)
- Previous security findings have been triaged (known accepted risks documented)

## Coverage Gaps and Mitigation

| Gap | Reason | Mitigation |
|-----|--------|-----------|
| Real banking partner end-to-end | Cannot test live banking in non-prod | Contract tests + periodic prod synthetic transactions |
| Physical device biometric testing | Device farm has limited biometric simulation | Manual testing on physical devices pre-release |
| Disaster recovery full rehearsal | Cost and coordination overhead | Annual DR drill, automated backup verification monthly |
| Regulatory changes (new markets) | Unpredictable timing | Quarterly compliance review, configurable rule engine |
