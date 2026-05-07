# Mother-of-all-Projects

[![Update Local Repository and Run Sonar Scanner](https://github.com/zbrainiac-labs/mother-of-all-Projects/actions/workflows/update-local-repo.yml/badge.svg)](https://github.com/zbrainiac-labs/mother-of-all-Projects/actions/workflows/update-local-repo.yml)

**A reference project for fully automated DataOps pipelines -- combining SQL code quality, declarative schema deployment (DCM), naming conventions, and regression testing with SonarQube and GitHub Actions on Snowflake.**

---

## Overview

This repository is the **application layer** of the [DataOps Unchained](https://github.com/zbrainiac-labs/DataOpsBackbone) architecture. It demonstrates:

- SQL linting via **SonarQube** (28 regex rules) + **SQLFluff** (style rules)
- Declarative schema deployment via **Snowflake DCM** (Database Change Management)
- Automated **SQL validation testing** (SQLUnit) with clone-per-build isolation
- **Naming conventions** enforcement for databases, schemas, and all object types
- **Reusable CI/CD pipeline** from [DataOpsBackbone](https://github.com/zbrainiac-labs/DataOpsBackbone)
- Release packaging and versioned GitHub Releases

---

## Architecture

This project is part of the **zbrainiac-labs** organization with a shared infrastructure:

1. **This repository** -- SQL source code, DCM definitions, rule test files, validation tests.
2. **[DataOps Backbone](https://github.com/zbrainiac-labs/DataOpsBackbone)** -- Dockerized infrastructure (SonarQube + PostgreSQL, GitHub org runner, reusable workflow, Unit Test History viewer).

All repos in the org share the same [reusable workflow](https://github.com/zbrainiac-labs/DataOpsBackbone/.github/workflows/dataops-pipeline.yml).

![overview infrastructure](images/DataOps_infra_overview.png)

---

## Project Structure

```
.
├── manifest.yml                          # DCM project manifest (targets, Jinja templating)
├── pre_deploy.sql                        # Bootstrap: CREATE DB/SCHEMA/DCM PROJECT (Jinja)
├── post_deploy.sql                       # Seed data: WH recommendations + sensor data (Jinja)
├── sources/definitions/                  # DCM-managed object definitions (DEFINE syntax)
│   ├── tables.sql                        #   DEFINE TABLE (OPS_RAW, WH_SIZE_RECOMMENDATION)
│   ├── serve.sql                         #   DEFINE VIEW (sensor views)
│   ├── analytics.sql                     #   DEFINE DYNAMIC TABLE (OPS_MIRROR)
│   ├── infrastructure.sql                #   DEFINE WAREHOUSE + STAGE
│   └── access.sql                        #   GRANT statements
├── workload/                             # Rule test files + TastyBytes vignettes
│   ├── rule_test_01_06_safety.sql        #   Safety rules (R1-R6) positive+negative
│   ├── rule_test_07_data_type.sql        #   Data type rules (R7)
│   ├── rule_test_08_28_naming.sql        #   Naming rules (R8-R13, R26-R28)
│   ├── rule_test_14_15_dependencies.sql  #   Dependency rules (R14-R15)
│   ├── rule_test_16_18_security.sql      #   Security rules (R16-R18)
│   ├── rule_test_19_22_data_quality.sql  #   Data quality + performance (R19-R25)
│   ├── rule_test_23_25_performance.sql   #   Performance rules (R23-R25)
│   ├── test_sql_1.sql                    #   Intentional bad SQL
│   ├── setup.sql                         #   TastyBytes full setup
│   ├── vignette-1.sql ... vignette-5.sql #   TastyBytes tutorial vignettes
│   └── S360_Monitoring_SH.sql            #   Monitoring queries
├── sqlunit/
│   └── tests.sqltest                     # SQL validation tests (Jinja-rendered at runtime)
├── .github/workflows/
│   └── update-local-repo.yml             # Thin caller to reusable workflow
└── open_points.md                        # Review findings and improvement tracker
```

---

## Snowflake Objects

| Object | Database | Schema | Notes |
|--------|----------|--------|-------|
| DCM Project | `DATAOPS` | `OPS_RAW_V001` | `MOTHER_OF_ALL_PROJECTS` |
| Jinja template db | `OPS_DEV` | `OPS_RAW_v001` | Resolved from manifest |
| Tables | `OPS_DEV` | `OPS_RAW_v001` | `OPS_RAW`, `IOTI_RAW_TB_WH_SIZE_RECOMMENDATION` |
| Views | `OPS_DEV` | `OPS_RAW_v001` | `IOTI_RAW_VW_ALL_SENSORS`, `IOTI_RAW_VW_SENSOR_12`, `IOTI_RAW_VW_SENSOR_102_AVG` |
| Dynamic Table | `OPS_DEV` | `OPS_RAW_v001` | `IOTI_RAW_DT_OPS_MIRROR` |
| Stage | `OPS_DEV` | `OPS_RAW_v001` | `IOTI_RAW_ST_DATA_LANDING` |
| Warehouse | - | - | `MD_TEST_WH` |

---

## Naming Conventions

All Snowflake object names use **UPPERCASE** with underscore separators.

### Database: `{DOMAIN}_{ENV}`

| Position | Element     | Description                                    |
|----------|-------------|------------------------------------------------|
| 1-3      | Domain      | 3-char business domain (IOT, CLR, PAY, CRM, REF) |
| 4-7      | Environment | `_DEV`, `_TE1`, `_UAT`, `_PRD`                |

Examples: `CLR_DEV`, `PAY_PRD`, `OPS_TE1`, `OPS_DEV`

### Schema: `{DOMAIN}_{MATURITY}_v{NNN}`

| Position | Element  | Description                          |
|----------|----------|--------------------------------------|
| 1-3      | Domain   | Same 3-char domain code              |
| 4-8      | Maturity | `_RAW_`, `_CUR_`, `_AGG_`, `_GOL_`  |
| 9-12     | Version  | `V001` -- `V999`                     |

Examples: `CLR_RAW_v001`, `OPS_AGG_v012`, `OPS_RAW_v001`

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

Each rule has **positive and negative test cases** in the `workload/rule_test_*.sql` files.

Enforcement via:
- **SonarQube Text Plugin** -- 28 regex-based rules
- **SQLFluff** -- style rules (indentation, spacing, aliases, JOIN qualification)

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

## CI/CD Pipeline

This project uses the **reusable workflow** from DataOpsBackbone. The local workflow file is a thin caller:

```yaml
jobs:
  pipeline:
    uses: zbrainiac-labs/DataOpsBackbone/.github/workflows/dataops-pipeline.yml@main
    with:
      SOURCE_DATABASE: DATAOPS
      SOURCE_SCHEMA: OPS_RAW_V001
      DCM_PROJECT_IDENTIFIER: DATAOPS.OPS_RAW_V001.MOTHER_OF_ALL_PROJECTS
      DCM_TARGET: DEV
      CLONE_PER_BUILD: true
    secrets: inherit
```

### Pipeline Steps

1. **Pre-deploy** -- Jinja-rendered `pre_deploy.sql` (CREATE DB/SCHEMA/DCM PROJECT)
2. **Extract dependencies** -- DDL + cross-schema refs for R14/R15
3. **SQLFluff lint** -- style analysis (exported to SonarQube)
4. **SonarQube scan** -- 28 regex rules + SQLFluff findings
5. **Quality Gate** -- continue-on-error (showcase has intentional violations)
6. **DCM deploy** -- declarative schema deployment
7. **Post-deploy** -- Jinja-rendered seed data
8. **Clone schema** -- zero-copy clone for isolated regression testing
9. **SQL validation tests** -- SQLUnit against cloned schema (16 tests)
10. **Drop clone** -- cleanup
11. **Package + Release** -- zip and GitHub Release

---

## SQL Validation Tests (SQLUnit)

Test definitions in `sqlunit/tests.sqltest` are Jinja-rendered at runtime and validate:

- Row counts and data ranges (OPS_RAW: 5000 rows, SENSOR_ID 1-101)
- NULL checks on sensor columns
- Object existence (tables, views, dynamic tables)
- View correctness (row count matches, filter logic)
- Seed data deployment (WH recommendations: 6 rows)

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
- GitHub org runner registered for `zbrainiac-labs`
- `SNOW_CONFIG_B64` secret configured on the repo

### Steps

1. Run `DataOps_init.sql` from [DataOpsBackbone](https://github.com/zbrainiac-labs/DataOpsBackbone) to create Snowflake objects
2. Start infrastructure: `./start.sh` in DataOpsBackbone
3. Push to `main` -- the pipeline triggers automatically
4. Check SonarQube at `http://localhost:9000` for rule findings
5. Check SQLUnit test history at `http://localhost:8080`

---

## Related

- [DataOps Backbone](https://github.com/zbrainiac-labs/DataOpsBackbone) -- Infrastructure stack + reusable workflow
- [SQL Linting Rules Reference](https://github.com/zbrainiac-labs/DataOpsBackbone#sql-linting-rules-and-regex-patterns) -- Full 28-rule documentation
- [Cross-Repo Alignment](https://github.com/zbrainiac-labs/DataOpsBackbone/blob/main/docs/CROSS_REPO_ALIGNMENT.md) -- All 6 repos aligned
- [E2E Regression Test Plan](https://github.com/zbrainiac-labs/DataOpsBackbone/blob/main/docs/E2E_REGRESSION_TEST_PLAN.md)
