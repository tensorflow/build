#!/bin/bash

set -e

kubectl get pods --all-namespaces

# Create sig-build namespace first
kubectl apply -f namespace.yaml

# Permissions
kubectl apply -f role-admin.yaml
kubectl apply -f role-webhook.yaml

# Tasks for tf/build repo
kubectl apply -f build-tasks.yaml
kubectl apply -f build-pipeline.yaml

# Initial cluster setup should not apply build-triggers.
# Tne trigger event listener needs the validator image
# built first so kick off a PipelineRun to build everything,
# then apply the webhook and triggers later
if [[ $1 == "--install" ]]; then
    # PipelineRun to build the linxcpu build image and webhook validator
    kubectl apply -f build-pipeline-run.yaml

else
    # Add GitHub webhook validator for trigger event-listener
    kubectl apply -f webhook-deployment.yaml

    # Triggers and ingress for GitHub webhook
    kubectl apply -f build-triggers.yaml
fi

