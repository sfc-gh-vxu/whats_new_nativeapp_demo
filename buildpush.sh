#!/bin/bash
DB_NAME="spcs_na_db"
SCHEMA_NAME="public"
REPO="images_ujagtap"

BACKEND_IMAGE="eap_backend"
FRONTEND_IMAGE="eap_frontend"
ROUTER_IMAGE="eap_router"
BACKEND_WH="backend_wh"

#Make sure the target repository exists
snow sql -q "create database if not exists $DB_NAME"
snow sql -q "create schema if not exists $DB_NAME.$SCHEMA_NAME"
snow sql -q "create image repository if not exists $DB_NAME.$SCHEMA_NAME.$REPO"
snow sql -q "create warehouse if not exists $BACKEND_WH"

REPO_URL=$(snow spcs image-repository url $REPO --database $DB_NAME --schema $SCHEMA_NAME)

#Login to the repository
snow spcs image-registry login

#Build Docker image for backend for Snowpark Container Services
cd services/backend && docker build --platform linux/amd64 -t $BACKEND_IMAGE . && cd ../..

#Build Docker image for frontend for Snowpark Container Services
cd services/frontend && docker build --platform linux/amd64 -t $FRONTEND_IMAGE . && cd ../..

#Build Docker image for router for Snowpark Container Services
cd services/router && docker build --platform linux/amd64 -t $ROUTER_IMAGE . && cd ../..

#Push backend Docker image to Snowpark Container Services
docker image tag $BACKEND_IMAGE $REPO_URL/$BACKEND_IMAGE
docker image push $REPO_URL/$BACKEND_IMAGE

#Push frontend Docker image to Snowpark Container Services
docker image tag $FRONTEND_IMAGE $REPO_URL/$FRONTEND_IMAGE
docker image push $REPO_URL/$FRONTEND_IMAGE

#Push router Docker image to Snowpark Container Services
docker image tag $ROUTER_IMAGE $REPO_URL/$ROUTER_IMAGE
docker image push $REPO_URL/$ROUTER_IMAGE