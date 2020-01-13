#!/bin/bash

set -e

kubectl get pods --all-namespaces

# Create sig-build namespace first
kubectl apply -f namespace.yaml

# Permissions
kubectl apply -f role-admin.yaml
kubectl apply -f role-webhook.yaml

# Add GitHub webhook validator for trigger event-listener
kubectl apply -f webhook-deployment.yaml

# Tasks for tf/build repo
kubectl apply -f build-tasks.yaml
kubectl apply -f build-pipeline.yaml
kubectl apply -f build-triggers.yaml

