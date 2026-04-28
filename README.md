# Mother-of-all-Projects

[![Update Local Repository and Run Sonar Scanner](https://github.com/zbrainiac-labs/mother-of-all-Projects/actions/workflows/update-local-repo.yml/badge.svg)](https://github.com/zbrainiac-labs/mother-of-all-Projects/actions/workflows/update-local-repo.yml)

**A reference project for fully automated DataOps pipelines -- combining SQL code quality, declarative schema deployment (DCM), naming conventions, and regression testing with SonarQube and GitHub Actions on Snowflake.**

---

## Overview

This repository is the **application layer** of the [DataOps Unchained](https://github.com/zbrainiac-labs/DataOpsBackbone) architecture. It demonstrates:

- SQL linting and static analysis via **SonarQube** with 28 regex-based rules
- Declarative schema deployment via **Snowflake DCM** (Database Change Management)
- Automated **SQL validation testing** (SQLUnit) against deployed objects
- **Naming conventions** enforcement for databases, schemas, and all object types
- Release packaging and versioned GitHub Releases

---

## Architecture

This project is split into **two repositories**:

1. **This repository** -- SQL source code, DCM definitions, rule test files, validation tests, and pipeline configuration.
2. **[DataOps Backbone](https://github.com/zbrainiac-labs/DataOpsBackbone)** -- Dockerized infrastructure (SonarQube + PostgreSQL, GitHub self-hosted runners, Unit Test History viewer).

![overview infrastructure](images/DataOps_infra_overview.png)

---

## Project Structure

```
.
├── manifest.yml                          # DCM project manifest (targets, templating)
├── pre_deploy.sql                        # Pre-deployment hooks (resource monitors)
├── post_deploy.sql                       # Post-deployment seed data
├── sources/definitions/                  # DCM-managed object definitions
│   ├── tables.sql                        #   DEFINE TABLE statements
│   ├── serve.sql                         #   DEFINE VIEW statements
│   ├── analytics.sql                     #   DEFINE DYNAMIC TABLE statements
│   ├── infrastructure.sql                #   DEFINE WAREHOUSE / STAGE statements
│   └── access.sql                        #   GRANT statements
├── workload/                             # Rule test files + TastyBytes vignettes
│   ├── rule_test_01_06_safety.sql        #   Safety rules (R1-R6)
│   ├── rule_test_07_data_type.sql        #   Data type rules (R7)
│   ├── rule_test_08_28_naming.sql        #   Naming convention rules (R8-R13, R26-R28)
│   ├── rule_test_14_15_dependencies.sql  #   Dependency rules (R14-R15)
│   ├── rule_test_16_18_security.sql      #   Security rules (R16-R18)
│   ├── rule_test_19_22_data_quality.sql  #   Data quality + performance rules (R19-R25)
│   ├── rule_test_23_25_performance.sql   #   Performance rules (R23-R25)
│   ├── test_sql_1.sql                    #   Intentional bad SQL for SonarQube
│   ├── setup.sql                         #   TastyBytes full setup
│   ├── vignette-1.sql ... vignette-5.sql #   TastyBytes tutorial vignettes
│   └── S360_Monitoring_SH.sql            #   Monitoring queries
├── sqlunit/
│   └── tests.sqltest                     # SQL validation test definitions
├── .github/workflows/
│   └── update-local-repo.yml             # CI/CD pipeline (integrity-checked)
├── github-workflow-verification_v1.sh    # SHA256 workflow integrity check
└── open_points.md                        # Review findings and improvement tracker
```

---

## Naming Conventions

All Snowflake object names use **UPPERCASE** with underscore separators.

### Database: `{DOMAIN}_{ENV}`

| Position | Element     | Description                                    |
|----------|-------------|------------------------------------------------|
| 1-3      | Domain      | 3-char business domain (IOT, CLR, PAY, CRM, REF) |
| 4-7      | Environment | `_DEV`, `_TE1`, `_UAT`, `_PRD`                |

Examples: `CLR_DEV`, `PAY_PRD`, `IOT_TE1`

### Schema: `{DOMAIN}_{MATURITY}_v{NNN}`

| Position | Element  | Description                          |
|----------|----------|--------------------------------------|
| 1-3      | Domain   | Same 3-char domain code              |
| 4-8      | Maturity | `_RAW_`, `_CUR_`, `_AGG_`, `_GOL_`  |
| 9-12     | Version  | `v001` -- `v999`                     |

Examples: `CLR_RAW_v001`, `IOT_AGG_v012`, `REF_CUR_v003`

### Database Objects: `{DOM}{COMP}_{MAT}_{TYPE}_{TEXT}`

| Position | Element     | Description                                         |
|----------|-------------|-----------------------------------------------------|
| 1-3      | Domain      | 3-char business domain                              |
| 4        | Component   | Sub-component letter (I=Ingestion, A=Aggregation, T=Transform) |
| 5-8      | Maturity    | `_RAW`, `_CUR`, `_AGG`, `_GOL`                     |
| 9-12     | Object type | `_TB_`, `_VW_`, `_DT_`, `_ST_`, `_FF_`, `_SP_`, `_TK_` |
| 13+      | Free text   | Business-meaningful name                            |

Examples:
- `IOTI_RAW_TB_SENSOR_DATA` -- IOT domain, Ingestion, raw table
- `IOTI_RAW_VW_ALL_SENSORS` -- IOT domain, Ingestion, raw view
- `IOTI_AGG_DT_HOURLY_STATS` -- IOT domain, Aggregation, dynamic table
- `ICGI_RAW_ST_SWIFT_INBOUND` -- ICG domain, Ingestion, raw stage
- `ICGI_RAW_FF_XML` -- ICG domain, Ingestion, raw file format

---

## SQL Linting Rules (28 Rules)

Each rule has **positive and negative test cases** in the `workload/rule_test_*.sql` files. SonarQube enforces these via regex patterns in the [Community Text Plugin](https://github.com/SonarQubeCommunity/sonar-text-plugin).

Full rule documentation: [DataOpsBackbone -- SQL Linting Rules](https://github.com/zbrainiac-labs/DataOpsBackbone#sql-linting-rules-and-regex-patterns)

| Category | Rules | Test File |
|----------|-------|-----------|
| Safety | R1-R6 (IF NOT EXISTS, hardcoded prefixes, GRANT to PUBLIC, DROP guards, USE statements) | `rule_test_01_06_safety.sql` |
| Data Types | R7 (TIMESTAMP_TZ only) | `rule_test_07_data_type.sql` |
| Naming | R8-R13, R26-R28 (schema, table, view, DT, stage, FF, SP, task patterns) | `rule_test_08_28_naming.sql` |
| Dependencies | R14-R15 (cross-database, cross-schema) | `rule_test_14_15_dependencies.sql` |
| Security | R16-R18 (GRANT ALL, ACCOUNTADMIN, plaintext passwords) | `rule_test_16_18_security.sql` |
| Data Quality | R19-R22 (SELECT *, FLOAT/DOUBLE, VARCHAR length, COMMENT) | `rule_test_19_22_data_quality.sql` |
| Performance | R23-R25 (ORDER BY in views, COPY INTO ON_ERROR, TARGET_LAG) | `rule_test_23_25_performance.sql` |

---

## DCM (Database Change Management)

This project uses Snowflake DCM for declarative schema deployment. Object definitions live in `sources/definitions/` using `DEFINE` syntax with Jinja templating (`{{db}}`, `{{schema}}`, `{{wh}}`).

### Manifest

```yaml
manifest_version: 2
type: DCM_PROJECT
default_target: 'DEV'

targets:
  DEV:
    account_identifier: SFSEEUROPE-ZS28104
    project_name: 'DATAOPS.IOT_RAW_V001.MOTHER_OF_ALL_PROJECTS'
    project_owner: CICD
    templating_config: 'DEV'
```

### Deployment Flow (CI/CD)

1. **SonarQube scan** -- static analysis with all 28 rules
2. **Quality Gate** -- blocks deployment on rule violations
3. **DCM analyze + plan + deploy** -- declarative schema deployment
4. **Clone schema** -- zero-copy clone for regression testing
5. **SQL validation tests** -- SQLUnit against cloned schema
6. **Drop clone** -- cleanup
7. **Package release** -- zip and create GitHub Release

---

## SQL Validation Tests (SQLUnit)

Test definitions in `sqlunit/tests.sqltest` validate deployed objects:

- Row counts and data ranges
- Object existence (tables, views)
- View correctness (row count matches, filter logic)
- Structure deployment (seed data loaded)

---

## TastyBytes Vignettes

The `workload/` directory includes TastyBytes demo scripts that serve as **negative validation tests** for SonarQube -- they intentionally violate naming, security, and data type rules to generate findings:

| File | Topic |
|------|-------|
| `setup.sql` | Full TastyBytes environment setup |
| `vignette-1.sql` | Getting Started with Snowflake |
| `vignette-2.sql` | Simple Data Pipeline with Dynamic Tables |
| `vignette-3-aisql.sql` | AI SQL Functions (SENTIMENT, CLASSIFY, EXTRACT) |
| `vignette-3-copilot.sql` | Snowflake Copilot |
| `vignette-4.sql` | Governance with Horizon |
| `vignette-5.sql` | Apps and Collaboration |

---

## Quick Start

### Prerequisites

- A Snowflake account with the [DataOps Backbone](https://github.com/zbrainiac-labs/DataOpsBackbone) infrastructure running
- GitHub self-hosted runner connected to your repo
- `SNOW_CONFIG_B64` secret configured (auto-generated by `start.sh`)

### Steps

1. Run `DataOps_init.sql` from [DataOpsBackbone](https://github.com/zbrainiac-labs/DataOpsBackbone) to create all Snowflake objects
2. Configure `.env` in DataOpsBackbone with your Snowflake credentials
3. Push to `main` -- the GitHub Actions workflow triggers automatically
4. Check SonarQube at `http://localhost:9000` for rule findings
5. Check SQLUnit test history at `http://localhost:8080`

---

## Related

- [DataOps Backbone](https://github.com/zbrainiac-labs/DataOpsBackbone) -- Infrastructure stack (SonarQube, PostgreSQL, runners)
- [SQL Linting Rules Reference](https://github.com/zbrainiac-labs/DataOpsBackbone#sql-linting-rules-and-regex-patterns) -- Full rule documentation with regex patterns
