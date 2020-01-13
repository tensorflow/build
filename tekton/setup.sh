#!/bin/bash

: ${CLUSTER_NAME:=tf-build-dev}
: ${CLUSTER_ZONE:=us-central1-a}
: ${TKN_PIPELINE_VERSION:=v0.9.0}
: ${TKN_TRIGGERS_VERSION:=v0.1.0}

# Create GKE cluster
gcloud container clusters create $CLUSTER_NAME --zone=$CLUSTER_ZONE

# Make current user a cluster admin
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)

# Install tekton pipelines on new cluster
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/${TKN_PIPELINE_VERSION}/release.yaml

# Install tekton triggers on new cluster
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/${TKN_TRIGGERS_VERSION}/release.yaml

kubectl get pods --all-namespaces

# Create sig-build namespace first
kubectl apply -f namespace.yaml

# Permissions
kubectl apply -f role-admin.yaml
kubectl apply -f role-webhook.yaml

# Tasks for tf/build repo
kubectl apply -f build-tasks.yaml
kubectl apply -f build-pipeline.yaml
kubectl apply -f build-triggers.yaml
