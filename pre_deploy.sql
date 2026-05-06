CREATE DATABASE IF NOT EXISTS {{ db }}
COMMENT = 'Development database for IOT domain - mother-of-all-Projects showcase';

CREATE SCHEMA IF NOT EXISTS {{ db }}.{{ schema }}
COMMENT = 'Raw data landing zone for IOT sensor data';

CREATE DCM PROJECT IF NOT EXISTS {{ db }}.{{ schema }}.MOTHER_OF_ALL_PROJECTS;
