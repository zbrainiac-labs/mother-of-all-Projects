CREATE DATABASE IF NOT EXISTS {{ db }}
COMMENT = 'Development database for IOT domain - mother-of-all-Projects showcase';

CREATE SCHEMA IF NOT EXISTS {{ db }}.{{ schema }}
COMMENT = 'Raw data landing zone for IOT sensor data';

CREATE WAREHOUSE IF NOT EXISTS {{ wh }}
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for IOT workloads';

CREATE DCM PROJECT IF NOT EXISTS {{ db }}.{{ schema }}.MOTHER_OF_ALL_PROJECTS;
