# A 3 Tier Web App with Native Apps and Snowpark Container Services

This is a sample three tier web app built with Snowpark container services and packaged as a native app.

## Getting Started

### Prerequisites

* Snow CLI
* Docker Desktop
* Access to Snowpark Container Services in one of the Public Preview Accounts
* Access to Native Apps and SPCS integration in one of the Public Preview Accounts
* Ingress for Snowpark Container Services
  ```
    USE ROLE ACCOUNTADMIN;
    CREATE SECURITY INTEGRATION IF NOT EXISTS snowservices_ingress_oauth
        TYPE = oauth
        OAUTH_CLIENT = snowservices_ingress
        ENABLED = true;
  ```

### Step by Step Guide

* Install Snowcli and setup connection to a Snowflake account
* Build the container images and push them to a snowflake account by executing
```
./buildpush.sh
```
* Create an application package by uploading the code and create a running application instance from this app package
```
snow app run
```