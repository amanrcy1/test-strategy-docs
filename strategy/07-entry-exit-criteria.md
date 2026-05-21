# 7. Entry and Exit Criteria

## Purpose

Entry and exit criteria define the quality gates that must be satisfied before testing begins (entry) and before testing is considered complete (exit) at each level. These criteria prevent wasted effort on unstable builds and ensure consistent release quality.

## Unit Testing

### Entry Criteria

| # | Criterion | Verification Method |
|---|-----------|-------------------|
| U-E1 | Code compiles without errors | Build step succeeds |
| U-E2 | All dependencies are resolved and available | Package manager install succeeds |
| U-E3 | Test fixtures and mock data are current with schema | Schema version check in test setup |
| U-E4 | Developer has run code formatting and linting locally | Pre-commit hooks pass |

### Exit Criteria

| # | Criterion | Target | Verification Method |
|---|-----------|--------|-------------------|
| U-X1 | All unit tests pass | 100% pass rate | Test runner report |
| U-X2 | Line coverage meets threshold | ≥ 85% aggregate | Coverage reporter (Istanbul/JaCoCo) |
| U-X3 | No critical/high SAST findings | 0 findings | Snyk code scan |
| U-X4 | Mutation testing score (critical modules only) | ≥ 70% killed | Stryker/PIT report |

---

## Integration Testing

### Entry Criteria

| # | Criterion | Verification Method |
|---|-----------|-------------------|
| I-E1 | Unit test exit criteria met | CI pipeline unit stage green |
| I-E2 | All dependent services are deployed and healthy | Health check endpoints return 200 |
| I-E3 | Database schema is migrated to current version | Migration runner completes without error |
| I-E4 | Message broker topics exist and consumers are connected | Kafka admin client verification |
| I-E5 | External service stubs are configured | WireMock scenario verification endpoint |

### Exit Criteria

| # | Criterion | Target | Verification Method |
|---|-----------|--------|-------------------|
| I-X1 | All integration tests pass | 100% pass rate | Test runner report |
| I-X2 | No database deadlocks observed during test execution | 0 deadlocks | PostgreSQL pg_stat_activity monitoring |
| I-X3 | No unhandled message broker errors | 0 dead-letter messages | Kafka DLQ consumer count |
| I-X4 | API response times within threshold | P95 < 500ms | Test execution metrics |
| I-X5 | Contract tests pass for all consumer-provider pairs | 100% verified | Pact verification report |

---

## End-to-End Testing

### Entry Criteria

| # | Criterion | Verification Method |
|---|-----------|-------------------|
| E-E1 | Integration test exit criteria met | CI pipeline integration stage green |
| E-E2 | Staging environment fully deployed (all services) | Deployment manifest verified, health checks pass |
| E-E3 | Test data seeded (accounts, balances, history) | Seed script execution report |
| E-E4 | Third-party sandboxes accessible | Connectivity check to partner APIs |
| E-E5 | Feature flags configured to match target release state | Feature flag audit report |
| E-E6 | No P1/P2 bugs open from previous E2E cycle | Bug tracker query |

### Exit Criteria

| # | Criterion | Target | Verification Method |
|---|-----------|--------|-------------------|
| E-X1 | Critical user journeys pass | 100% pass rate | Allure report — critical tag filter |
| E-X2 | Overall E2E pass rate | ≥ 95% | Allure report summary |
| E-X3 | No new P1 (critical) defects found | 0 unresolved P1s | Bug tracker |
| E-X4 | P2 (high) defects triaged and accepted/deferred | All P2s have disposition | Bug tracker audit |
| E-X5 | All flaky tests identified and quarantined | Flaky tests labeled, not blocking | Test report flaky flag |
| E-X6 | Accessibility scan clean | 0 WCAG 2.1 AA violations | axe-core report |

---

## Performance Testing

### Entry Criteria

| # | Criterion | Verification Method |
|---|-----------|-------------------|
| P-E1 | E2E exit criteria met (functional correctness confirmed) | E2E pipeline stage green |
| P-E2 | Performance environment provisioned at production scale | Infrastructure diff report |
| P-E3 | Test data loaded at production volume | Data generation script report |
| P-E4 | Baseline metrics from previous release available | Metrics archive accessible |
| P-E5 | Monitoring and APM tools active and recording | Dashboard connectivity verified |
| P-E6 | No other workloads running on performance environment | Resource utilization < 10% |

### Exit Criteria

| # | Criterion | Target | Verification Method |
|---|-----------|--------|-------------------|
| P-X1 | Transaction processing throughput | ≥ 3,000 TPS sustained for 30 min | k6 summary report |
| P-X2 | Response time under load | P95 < 500ms, P99 < 1000ms | k6 percentile report |
| P-X3 | Error rate under load | < 0.1% | k6 error metrics |
| P-X4 | No memory leaks detected | Heap growth < 5% over test duration | APM memory profiling |
| P-X5 | Autoscaling triggers correctly | Pods scale within 60s of threshold | K8s HPA event log |
| P-X6 | No performance regression vs. previous release | < 10% degradation on key metrics | Baseline comparison report |

---

## Security Testing

### Entry Criteria

| # | Criterion | Verification Method |
|---|-----------|-------------------|
| S-E1 | Application is in a stable, testable state | Latest staging deployment healthy |
| S-E2 | Security testing tools configured and updated | Tool version and rule update check |
| S-E3 | Test accounts for all roles/permission levels available | Account provisioning script |
| S-E4 | Scope document approved by security team | Signed scope document |
| S-E5 | Previous security findings have been triaged | Finding tracker — all items have status |

### Exit Criteria

| # | Criterion | Target | Verification Method |
|---|-----------|--------|-------------------|
| S-X1 | SAST findings (critical/high) | 0 unresolved | Snyk dashboard |
| S-X2 | DAST findings (critical/high) | 0 unresolved | ZAP scan report |
| S-X3 | Dependency vulnerabilities (critical) | 0 critical CVEs | Snyk SCA report |
| S-X4 | PCI-DSS automated controls | 100% pass | Compliance test suite report |
| S-X5 | Penetration test findings (critical/high) | 0 unresolved | Pen test report |
| S-X6 | All findings documented with remediation plan | 100% triaged | Security tracker |

---

## Release Criteria (Production Deployment Gate)

### Final Go/No-Go Checklist

| # | Criterion | Owner | Sign-off Required |
|---|-----------|-------|:-----------------:|
| R1 | All test level exit criteria met | QA Lead | ✅ |
| R2 | No open P1 or unaccepted P2 defects | QA Lead | ✅ |
| R3 | Security scan clean (zero critical/high) | Security Lead | ✅ |
| R4 | Performance targets met | Performance Engineer | ✅ |
| R5 | Rollback plan documented and tested | SRE Lead | ✅ |
| R6 | Release notes reviewed | Product Manager | ✅ |
| R7 | Change advisory board approval (if applicable) | Change Manager | ✅ |
| R8 | Monitoring dashboards and alerts configured for new features | SRE Lead | ✅ |

### Suspension Criteria

Testing will be suspended if any of the following occur:

1. **Environment instability**: More than 3 environment-caused test failures in a 1-hour window
2. **Critical defect found**: P1 defect that blocks further meaningful test execution
3. **Data corruption**: Test data integrity compromised requiring re-seeding
4. **Security incident**: Active security concern requiring immediate investigation
5. **External dependency outage**: Third-party service unavailable with no stub fallback

### Resumption Criteria

Testing resumes when:
- Root cause of suspension is identified and resolved
- Environment stability is confirmed (30-minute clean run)
- Test data integrity is verified
- QA Lead approves resumption
