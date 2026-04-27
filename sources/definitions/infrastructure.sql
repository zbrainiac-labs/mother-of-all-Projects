DEFINE WAREHOUSE {{wh}}
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'XSMALL warehouse with 1-minute auto-suspend for cost optimization';

DEFINE STAGE {{db}}.{{schema}}.IOTI_RAW_ST_DATA_LANDING
    COMMENT = 'Internal stage for IOT data file uploads';
