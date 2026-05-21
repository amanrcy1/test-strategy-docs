# 3. Risk Assessment

## Risk Assessment Methodology

Each business risk is evaluated on two dimensions:

- **Likelihood** (1–5): Probability of the risk materializing in a given release cycle
  - 1 = Rare (less than once per year)
  - 2 = Unlikely (once per year)
  - 3 = Possible (once per quarter)
  - 4 = Likely (once per month)
  - 5 = Almost certain (every release)

- **Impact** (1–5): Severity of business consequences if the risk materializes
  - 1 = Negligible (cosmetic issues, no user impact)
  - 2 = Minor (workaround available, minimal user friction)
  - 3 = Moderate (partial service degradation, user complaints)
  - 4 = Major (service outage, financial loss, regulatory concern)
  - 5 = Critical (data breach, significant financial loss, regulatory action)

**Risk Score** = Likelihood × Impact

**Coverage Priority Mapping:**
- Score 15–25: **Critical** — Automated tests in every pipeline, dedicated test scenarios
- Score 10–14: **High** — Automated regression, regular manual exploratory testing
- Score 5–9: **Medium** — Automated coverage with periodic review
- Score 1–4: **Low** — Basic smoke tests, monitored in production

## Risk Matrix

| ID | Business Risk | Likelihood | Impact | Score | Coverage Priority |
|----|--------------|:----------:|:------:|:-----:|:-----------------:|
| R1 | Payment transaction duplication or loss during concurrent processing | 3 | 5 | 15 | **Critical** |
| R2 | PCI-DSS compliance violation exposing cardholder data | 2 | 5 | 10 | **High** |
| R3 | Banking partner API breaking changes causing failed settlements | 4 | 4 | 16 | **Critical** |
| R4 | Race condition in balance updates leading to negative balances | 3 | 5 | 15 | **Critical** |
| R5 | Authentication bypass allowing unauthorized account access | 2 | 5 | 10 | **High** |
| R6 | Cross-border FX calculation errors causing financial discrepancies | 3 | 4 | 12 | **High** |
| R7 | Platform unavailability during peak transaction periods | 3 | 4 | 12 | **High** |
| R8 | Fraudulent transactions passing detection thresholds | 4 | 3 | 12 | **High** |
| R9 | Data migration errors during schema changes corrupting user records | 2 | 4 | 8 | **Medium** |
| R10 | Third-party identity verification service outage blocking onboarding | 3 | 2 | 6 | **Medium** |

## Risk Details and Mitigations

### R1: Transaction Duplication/Loss (Critical)

**Scenario:** Under high concurrency or network partitions, the same payment could be processed twice or silently dropped, leading to incorrect balances.

**Test Mitigation:**
- Idempotency key validation tests with concurrent duplicate requests
- Chaos testing with network partitions during active transactions
- Automated reconciliation tests comparing ledger entries against source events
- Property-based tests for transaction state machine transitions

### R2: PCI-DSS Compliance Violation (High)

**Scenario:** Cardholder data appears in logs, API error responses, or is stored unencrypted due to code changes.

**Test Mitigation:**
- Automated security scanning (SAST/DAST) in every PR pipeline
- Log output inspection tests verifying no PAN/CVV patterns in output
- Encryption-at-rest verification tests for database fields
- Annual penetration testing with interim quarterly scans

### R3: Banking Partner API Breaking Changes (Critical)

**Scenario:** A banking partner changes their API response format or introduces new validation rules without notice, causing settlement failures.

**Test Mitigation:**
- Consumer-driven contract tests (Pact) for each banking integration
- Schema validation tests against recorded response samples
- Periodic live integration verification (daily health checks)
- Circuit breaker and fallback behavior tests

### R4: Race Condition in Balance Updates (Critical)

**Scenario:** Simultaneous send and receive operations on the same account produce incorrect final balance due to read-modify-write races.

**Test Mitigation:**
- Concurrency tests with parallel transactions on shared accounts
- Database isolation level verification tests
- Pessimistic locking validation under contention
- Property-based tests: sum of all transactions = final balance

### R5: Authentication Bypass (High)

**Scenario:** A flaw in session management, token validation, or biometric fallback allows unauthorized access to user accounts.

**Test Mitigation:**
- OWASP Top 10 security test suite execution per release
- Token expiration and refresh flow tests
- Session fixation and replay attack tests
- Privilege escalation boundary tests (user A cannot access user B data)

### R6: FX Calculation Errors (High)

**Scenario:** Currency conversion applies stale rates, incorrect rounding, or wrong margin percentages, causing overcharging or undercharging.

**Test Mitigation:**
- Unit tests with known rate fixtures covering all rounding scenarios
- Integration tests verifying rate freshness (staleness detection)
- Boundary tests at regulation-mandated maximum markup thresholds
- Cross-currency transfer E2E tests with amount reconciliation

### R7: Platform Unavailability During Peak (High)

**Scenario:** The system cannot handle peak load (3x normal traffic) during promotional events, causing timeouts and failed payments.

**Test Mitigation:**
- Load tests simulating 3x peak traffic (450K+ transactions)
- Autoscaling trigger verification tests
- Graceful degradation tests (queue backpressure, rate limiting)
- Chaos engineering: kill pods during load test, verify recovery

### R8: Fraud Bypassing Detection (High)

**Scenario:** Fraudulent transaction patterns evolve and bypass the ML-based fraud detection model, resulting in unauthorized charges.

**Test Mitigation:**
- Model accuracy regression tests against labeled fraud datasets
- Rule engine boundary tests (velocity limits, geo-anomaly detection)
- A/B test framework for model version comparison
- Synthetic fraud pattern injection tests

### R9: Data Migration Corruption (Medium)

**Scenario:** Database schema migrations introduce data loss, type coercion errors, or orphaned records.

**Test Mitigation:**
- Rollback verification tests for every migration
- Data integrity assertions pre/post migration on staging
- Canary migration on production subset before full rollout

### R10: Identity Verification Outage (Medium)

**Scenario:** The third-party KYC provider (Onfido) goes down, blocking new user onboarding.

**Test Mitigation:**
- Circuit breaker tests for identity service timeout
- Fallback flow tests (queued verification, manual review path)
- Service health monitoring with alerting
