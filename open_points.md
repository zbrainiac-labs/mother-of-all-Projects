# Open Points - mother-of-all-Projects Review

> Review date: 2026-04-27
> Reviewed against: [DataOpsBackbone SQL Linting Rules and Regex Patterns](https://github.com/zbrainiac-labs/DataOpsBackbone#sql-linting-rules-and-regex-patterns) (Rules 1-28)

## Status Legend

| Symbol | Meaning |
|--------|---------|
| PASS | Compliant, no action needed |
| FAIL | Violation found, fix required |
| NEG-TEST | Intentional violation for SonarQube negative validation |
| PARTIAL | Some occurrences comply, others do not |
| N/A | Rule not exercised in this project |

## Priority Legend

| Prio | Meaning |
|------|---------|
| 1 | Critical - must fix before production use |
| 2 | Important - should fix in next iteration |
| 3 | Nice-to-have - cosmetic or minor improvement |

---

## DCM-Managed Files (`sources/definitions/`)

These files are deployed via DCM and represent the production-grade objects.
Items marked **NEG-TEST** are intentional violations designed to generate SonarQube issues in the [DataOpsBackbone](https://github.com/zbrainiac-labs/DataOpsBackbone) showcase.

| # | Rule | File(s) | Status | Prio | Finding / Proposal |
|---|------|---------|--------|------|--------------------|
| 1 | R20: Disallow FLOAT/DOUBLE | `sources/definitions/tables.sql:3-14` | NEG-TEST | - | `IOT_RAW` table uses `FLOAT` for all 12 sensor columns (SENSOR_0 through SENSOR_11). Intentional negative validation test for SonarQube Rule 20. |
| 2 | R10: Table names must follow `{DOM}{COMP}_{MAT}_{TB}_` pattern | `sources/definitions/tables.sql:1` | NEG-TEST | - | Table `IOT_RAW` does not follow the `{DOM}{COMP}_{MAT}_TB_` naming pattern. Intentional negative validation test for SonarQube Rule 10. The second table `IOTI_RAW_TB_WH_SIZE_RECOMMENDATION` is the compliant counterpart. |
| 3 | R22: CREATE TABLE must include COMMENT | `sources/definitions/tables.sql` | PASS | - | Both DEFINE TABLE statements include COMMENT. |
| 4 | R12: Dynamic Table names must follow `{DOM}{COMP}_{MAT}_{DT}_` pattern | `sources/definitions/analytics.sql:1` | NEG-TEST | - | Dynamic table `IOTI_RAW_DT_IOT_MIRROR` -- intentional negative validation test for SonarQube Rule 12. |
| 5 | R25: Dynamic Tables must specify TARGET_LAG | `sources/definitions/analytics.sql:3` | PASS | - | `TARGET_LAG = '5 MINUTES'` is specified. |
| 6 | R13: Stage names must follow `{DOM}{COMP}_{MAT}_{ST}_` pattern | `sources/definitions/infrastructure.sql:8` | PASS | - | `IOTI_RAW_ST_DATA_LANDING` is compliant. |
| 7 | R3: Disallow hardcoded database/schema prefix in CREATE | `sources/definitions/*.sql` | PASS | - | All definitions use `{{db}}.{{schema}}` Jinja templating -- fully portable. |
| 8 | R6: Disallow hardcoded USE statements | `sources/definitions/*.sql` | PASS | - | No USE statements in definition files. |
| 9 | R11: View names must follow `{DOM}{COMP}_{MAT}_{VW}_` pattern | `sources/definitions/serve.sql` | PASS | - | All views (`IOTI_RAW_VW_ALL_SENSORS`, `IOTI_RAW_VW_SENSOR_12`, `IOTI_RAW_VW_SENSOR_102_AVG`) are compliant. |

---

## Pre/Post Deploy Files

These files intentionally contain rule violations as **negative validation tests** for SonarQube.

| # | Rule | File(s) | Status | Prio | Finding / Proposal |
|---|------|---------|--------|------|--------------------|
| 10 | R6: Disallow USE ROLE | `pre_deploy.sql:1` | NEG-TEST | - | `USE ROLE ACCOUNTADMIN;` -- intentional negative validation test for SonarQube Rule 6. Also triggers R17. |
| 11 | R17: Disallow ACCOUNTADMIN usage | `pre_deploy.sql:1` | NEG-TEST | - | `USE ROLE ACCOUNTADMIN` -- intentional negative validation test for SonarQube Rule 17. |
| 12 | R3: Disallow hardcoded database/schema prefix | `post_deploy.sql:1-11` | NEG-TEST | - | Hardcoded `DATAOPS.IOT_RAW_V001.` prefix -- intentional negative validation test for SonarQube Rule 3. |
| 13 | R20: Disallow FLOAT/DOUBLE | `post_deploy.sql:14-25` | NEG-TEST | - | `UNIFORM(0::FLOAT, ...)` casts -- intentional negative validation test for SonarQube Rule 20. |

---

## Rule Test Files (intentional violations for SonarQube testing)

These files are **designed to contain violations** to validate that SonarQube catches them. The review below checks that both "good" and "bad" examples exist for each rule and that they are realistic.

| # | Rule | File(s) | Status | Prio | Finding / Proposal |
|---|------|---------|--------|------|--------------------|
| 14 | R1-R6: Safety rules | `workload/rule_test_01_06_safety.sql` | PASS | - | Good and bad examples present for all 6 rules. |
| 15 | R7: TIMESTAMP_NTZ/LTZ | `workload/rule_test_07_data_type.sql` | PASS | - | Good and bad examples present. |
| 16 | R8-R28: Naming rules | `workload/rule_test_08_28_naming.sql` | PASS | - | All rules R8-R13, R26-R28 have positive+negative pairs. R9 bad example fixed. R10, R11, R12 test cases added. |
| 17 | R14-R15: Dependency rules | `workload/rule_test_14_15_dependencies.sql` | PASS | - | Clear examples with explanatory comments. |
| 18 | R16-R18: Security rules | `rule_test_16_18_security.sql` | PASS | - | Good/bad examples for GRANT ALL, ACCOUNTADMIN, and plaintext passwords. |
| 19 | R19-R25: Data quality + performance rules | `workload/rule_test_19_22_data_quality.sql` | PASS | - | All rules R19-R25 have positive+negative pairs. R20 cleaned up with FLOAT/DOUBLE/REAL examples. R21 (VARCHAR) and R22 (COMMENT) test cases added. R23 (ORDER BY in views) restored. |
| 20 | R23-R25: Performance rules | `rule_test_23_25_performance.sql` | PASS | - | Good/bad examples present. |
| 21 | Rule coverage | N/A | PASS | - | All 28 rules now have positive+negative test pairs across the rule_test files. |

---

## Workload Files (TastyBytes Vignettes)

These are educational/demo scripts. They intentionally use non-DCM patterns but are scanned by SonarQube as a **negative test** (expected to generate findings).

| # | Rule | File(s) | Status | Prio | Finding / Proposal |
|---|------|---------|--------|------|--------------------|
| 22 | R6: USE DATABASE/SCHEMA/ROLE | `workload/vignette-*.sql`, `workload/setup.sql`, `workload/tb_introduction.sql`, `S360_Monitoring_SH.sql` | FAIL | 3 | All vignette files use `USE DATABASE`, `USE SCHEMA`, `USE ROLE` extensively. Expected for tutorial content. **Proposal:** If these files are scanned, consider adding a SonarQube exclusion pattern or tagging them with `-- sonar:off` comment blocks. Otherwise accept as known technical debt. |
| 23 | R3: Hardcoded database/schema prefix | `workload/setup.sql`, `workload/tb_introduction.sql`, all vignettes | FAIL | 3 | All CREATE statements use `tb_101.raw_pos.`, `tb_101.harmonized.` etc. **Proposal:** Same as #22 -- either exclude from scan or accept as demo debt. |
| 24 | R17: ACCOUNTADMIN usage | `workload/vignette-1.sql:24,345`, `workload/setup.sql:102,185`, `workload/vignette-4.sql:183,471,532`, `workload/vignette-5.sql:20` | FAIL | 3 | Tutorial scripts use ACCOUNTADMIN. Expected for educational context. **Proposal:** Document as accepted in SonarQube quality profile or exclude workload folder. |
| 25 | R4: GRANT to PUBLIC | `workload/setup.sql:650-651` | FAIL | 2 | `GRANT SELECT ON VIEW ... TO ROLE PUBLIC` in setup.sql. **Proposal:** Replace with a dedicated functional role (e.g., `TB_READER`) instead of PUBLIC. |
| 26 | R16: GRANT ALL PRIVILEGES | `workload/setup.sql`, `workload/tb_introduction.sql` | FAIL | 2 | Extensive use of `GRANT ALL ON SCHEMA ...` and `GRANT ALL ON WAREHOUSE ...` throughout. **Proposal:** Replace with explicit privilege lists (SELECT, INSERT, USAGE, etc.) following least-privilege principle. |
| 27 | R7: TIMESTAMP_NTZ | `workload/setup.sql:316`, `workload/tb_introduction.sql:244` | FAIL | 2 | `order_ts TIMESTAMP_NTZ(9)` in table definition. **Proposal:** Change to `TIMESTAMP_TZ(9)`. |
| 28 | R20: FLOAT/DOUBLE | `workload/setup.sql:309`, `workload/tb_introduction.sql:237` | FAIL | 2 | `location_id FLOAT` in `order_header` table. **Proposal:** Change to `NUMBER(19,0)` matching the location table. |
| 29 | R21: VARCHAR without explicit length | `workload/setup.sql`, `workload/tb_introduction.sql` | FAIL | 3 | `VARCHAR(16777216)` is used everywhere. While technically an explicit length, `16777216` is the Snowflake max default and provides no governance value. **Proposal:** Use meaningful lengths (e.g., `VARCHAR(255)`, `VARCHAR(100)`) for production-like examples. |
| 30 | R22: CREATE TABLE without COMMENT | `workload/setup.sql:234-337`, `workload/tb_introduction.sql` | FAIL | 3 | Most `CREATE TABLE` statements in setup/introduction files lack `COMMENT`. Some views have comments, but tables do not. **Proposal:** Add table-level COMMENTs to all CREATE TABLE statements. |
| 31 | R19: SELECT * | `workload/vignette-1.sql:97,115,311`, `workload/setup.sql:367,474,480,485` | FAIL | 3 | Multiple `SELECT * FROM ...` statements in tutorial scripts. **Proposal:** Accept as tutorial convenience or add explicit column lists. |
| 32 | R23: ORDER BY in view definitions | `workload/setup.sql:491-501` | FAIL | 3 | View `analytics.japan_menu_item_sales_feb_2022` contains `ORDER BY date`. **Proposal:** Remove ORDER BY from view definition; let consuming queries handle sort. |
| 33 | R24: COPY INTO without ON_ERROR | `workload/setup.sql:557-593`, `workload/tb_introduction.sql:380-409` | FAIL | 2 | All `COPY INTO` statements lack `ON_ERROR` clause. **Proposal:** Add `ON_ERROR = 'CONTINUE'` or `ON_ERROR = 'ABORT_STATEMENT'` to each COPY INTO. |
| 34 | R5: DROP without IF EXISTS | `workload/vignette-1.sql:290` | FAIL | 3 | `DROP TABLE raw_pos.truck_details;` without `IF EXISTS`. **Proposal:** Add `IF EXISTS` (note: this is intentional in the tutorial to demonstrate UNDROP). |
| 35 | R8: Schema names must follow `{DOMAIN}_{MATURITY}_` prefix | `workload/setup.sql:20-38` | FAIL | 3 | Schemas like `raw_pos`, `raw_customer`, `harmonized`, `analytics`, `governance`, `semantic_layer` do not follow `{DOMAIN}_{MATURITY}_vNNN` pattern. **Proposal:** Accept as TastyBytes demo convention or rename to follow standard (e.g., `TB_RAW_V001`). |
| 36 | R9: Schema names must end with `_vNNN` | `workload/setup.sql:20-38` | FAIL | 3 | No version suffix on any schema. **Proposal:** Same as #35. |
| 37 | R10-R13: Object naming patterns | `workload/setup.sql`, `workload/tb_introduction.sql` | FAIL | 3 | Tables (`country`, `franchise`, `truck`), views (`orders_v`), stages (`s3load`, `menu_stage`) do not follow `{DOM}{COMP}_{MAT}_{TYPE}_` pattern. **Proposal:** Accept as TastyBytes demo convention. |

---

## Structural / Project-Level Issues

| # | Category | Status | Prio | Finding / Proposal |
|---|----------|--------|------|--------------------|
| 38 | Intentional garbled lines | NEG-TEST | - | `workload/rule_test_08_28_naming.sql:8` and `workload/rule_test_19_22_data_quality.sql:7` contain intentional garbled/repeated text as negative validation tests for SonarQube. |
| 39 | Duplicate rule test files | PASS | - | Root-level duplicates removed. All rule test files consolidated in `workload/` only. |
| 40 | Missing rule test coverage | PASS | - | All 28 rules now covered with positive+negative test pairs. R10, R11, R12 added to `rule_test_08_28_naming.sql`. R21, R22 added to `rule_test_19_22_data_quality.sql`. |
| 41 | `test_sql_1.sql` intentional bad SQL | NEG-TEST | - | `workload/test_sql_1.sql` contains intentional negative tests: missing commas between columns (line 1) and `SELECT * FROM customer;` (R19). |
| 42 | `S360_Monitoring_SH.sql` violates multiple rules | FAIL | 3 | Contains `USE DATABASE`, `USE SCHEMA`, `USE WAREHOUSE` (R6), hardcoded references (R3), and `SELECT *` patterns. **Proposal:** Either exclude from SonarQube scanning or refactor to use templated references. |
| 43 | `output_dependencies.csv` is empty | FAIL | 2 | `dependencies/output_dependencies.csv` is empty. This file is generated at CI runtime by `snowflake-extract-dependencies_v1.sh`. **Proposal:** Add a `.gitkeep` or sample content with a comment explaining it is auto-generated. Also add the file to `.gitignore` if it should not be committed. |
| 44 | post_deploy.sql not templated | NEG-TEST | - | Hardcoded `DATAOPS.IOT_RAW_V001.` prefixes -- intentional negative validation test for SonarQube Rule 3. |
| 45 | DCM manifest only has DEV target | PASS | 3 | `manifest.yml` only defines a `DEV` target. **Proposal:** Consider adding `TE1`, `UAT`, `PRD` targets as examples to demonstrate multi-environment deployment. |
| 46 | Missing .gitignore entries | FAIL | 3 | `.gitignore` is minimal (68 bytes). **Proposal:** Add entries for `.scannerwork/`, `out/`, `dependencies/output_dependencies.csv`, `.DS_Store`, `.idea/`, `.vscode/`, `*.zip`. |
| 47 | Workflow hash verification | PASS | - | `github-workflow-verification_v1.sh` provides SHA256 integrity check for the workflow file. Good practice. |
| 48 | README.md outdated | PASS | - | README rewritten to reflect current project state: DCM, naming conventions, 28 linting rules, sqlunit, workload/vignettes, project structure, deployment flow. |
| 49 | `local-github-process/export_sonarqube_h2.sh` obsolete | PASS | - | Removed. SonarQube uses PostgreSQL now; H2 export script and directory deleted. |
| 50 | `sqlunit/.DS_Store` | PASS | - | Already untracked via `.gitignore`. Local file removed. |
| 51 | `dependencies/output_dependencies.csv` | PASS | - | Already untracked via `.gitignore`. Local empty file removed; CI generates at runtime. |
| 52 | Org transfer to zbrainiac-labs | PASS | - | Both repos transferred. All GitHub URLs updated. Git remotes updated. |
| 53 | Workflow updated for org runner | PASS | - | `runs-on` changed to `[self-hosted, runner-org-zbrainiac-labs]`. SHA256 hash updated in verification script. |
| 54 | runner1 removed from DataOpsBackbone | PASS | - | Per-repo runner for mother-of-all-Projects removed from `docker-compose.yml`. |
| 55 | runner4 removed from DataOpsBackbone | PASS | - | Duplicate org runner with hardcoded token removed. Token should be rotated. |
| 56 | E2E regression test plan | PASS | - | Created at `DataOpsBackbone/docs/E2E_REGRESSION_TEST_PLAN.md`. |

---

## Summary

| Priority | Count | Description |
|----------|-------|-------------|
| **Prio 1** | 0 | None remaining |
| **Prio 2** | 7 | Important: duplicate files, GRANT ALL/PUBLIC, TIMESTAMP_NTZ, COPY without ON_ERROR |
| **Prio 3** | 14 | Nice-to-have: vignette conventions, VARCHAR lengths, ORDER BY in views, gitignore, manifest targets, .DS_Store, empty CSV |

### Recommended Action Order

1. **Consolidate duplicate rule test files** (#39) -- repo hygiene
2. **Address GRANT to PUBLIC** (#25) -- security best practice
