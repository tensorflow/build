#!/bin/bash

: ${PROJECT:=tensorflow-build-224104}
: ${CLUSTER_NAME:=tf-build-dev}
: ${CLUSTER_REGION:=us-central1}
: ${CLUSTER_ZONE:=${CLUSTER_REGION}-a}

: ${TKN_PIPELINE_VERSION:=v0.9.0}
: ${TKN_TRIGGERS_VERSION:=v0.1.0}
: ${TKN_DASHBOARD_VERSION:=v0.4.0}

# Check if cluster is running
gcloud container clusters describe ${CLUSTER_NAME} --project=${PROJECT} --zone=${CLUSTER_ZONE} >/dev/null
if [[ $? -eq 1 ]]; then
    echo "ERROR: GKE cluster does not exist" >&2
    echo "" >&2
    echo "This will create a GKE cluster and install Tekton" >&2

    read -r -p "Are you sure? [y/N] " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Quitting ..." >&2
        exit 1
    fi

    set -e

    # Create GKE cluster
    gcloud beta container clusters create ${CLUSTER_NAME} \
        --project ${PROJECT} \
        --zone ${CLUSTER_ZONE} \
        --no-enable-basic-auth \
        --release-channel "regular" \
        --machine-type "n1-standard-2" \
        --num-nodes "1" \
        --image-type "COS" \
        --disk-type "pd-standard" \
        --disk-size "100" \
        --metadata disable-legacy-endpoints=true \
        --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
        --enable-stackdriver-kubernetes \
        --enable-vertical-pod-autoscaling \
        --enable-ip-alias \
        --network "projects/${PROJECT}/global/networks/default" \
        --subnetwork "projects/${PROJECT}/regions/${CLUSTER_REGION}/subnetworks/default" \
        --default-max-pods-per-node "110" \
        --addons HorizontalPodAutoscaling,HttpLoadBalancing \
        --enable-autoupgrade \
        --enable-autorepair

    # Make current user a cluster admin
    kubectl create clusterrolebinding cluster-admin-binding \
        --clusterrole=cluster-admin \
        --user=$(gcloud config get-value core/account)

fi

set -e

# get creds for kubectl
gcloud container clusters get-credentials ${CLUSTER_NAME} --project=${PROJECT} --zone=${CLUSTER_ZONE}

# Install tekton pipelines on new cluster
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/${TKN_PIPELINE_VERSION}/release.yaml

# Install tekton triggers on new cluster
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/${TKN_TRIGGERS_VERSION}/release.yaml

# Install tekton dashboard
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/previous/${TKN_DASHBOARD_VERSION}/release.yaml

# New cluster should have a 'tekton-pipelines' namespace and several tekton pods
kubectl get pods --all-namespaces

# Apply all the configs except triggers
# Trigger needs the validator service image built first
./apply.sh --install

