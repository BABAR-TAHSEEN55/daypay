-- Runs once , when the Postgres data volume is first created!
-- Once database per service : each service owns its own database

CREATE DATABASE wallet;
CREATE DATABASE auth;
CREATE DATABASE transfer;
