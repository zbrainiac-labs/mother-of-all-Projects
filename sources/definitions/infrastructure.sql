DEFINE WAREHOUSE {{wh}}
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for IOT workloads';

DEFINE STAGE {{db}}.{{schema}}.IOTI_RAW_ST_DATA_LANDING
    COMMENT = 'Internal stage for IOT data file uploads';
