-- RULE 14/15: Cross-database and cross-schema dependencies
-- These rules scan the deps.csv output, not SQL directly.
-- Example lines that trigger:
-- cross_db_true
-- cross_schema_true

-- Valid: Same-schema reference
CREATE OR REPLACE VIEW IOTI_RAW_VW_LOCAL AS SELECT SENSOR_ID FROM IOTI_RAW_TB_SENSOR_DATA;

-- Creates cross_schema dependency
CREATE OR REPLACE VIEW IOTI_RAW_VW_CROSS_SCHEMA AS
SELECT iot.SENSOR_ID, geo.CITY FROM IOTI_RAW_TB_SENSOR_DATA iot
JOIN REF_RAW_V001.REFA_RAW_TB_GEOLOC geo ON iot.SENSOR_ID = geo.SENSOR_ID;
