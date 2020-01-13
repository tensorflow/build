#!/bin/bash

: ${PROJECT:=perfinion}
: ${CLUSTER_NAME:=tf-build-dev}
: ${CLUSTER_REGION:=us-central1}
: ${CLUSTER_ZONE:=${CLUSTER_REGION}-a}

: ${TKN_PIPELINE_VERSION:=v0.9.0}
: ${TKN_TRIGGERS_VERSION:=v0.1.0}

# Check if cluster is running
gcloud container clusters describe ${CLUSTER_NAME} --zone=${CLUSTER_ZONE}
if [[ $? -eq 1 ]]; then
    echo "ERROR: GKE cluster does not exist" >&2
    echo "" >&2
    echo "This will create a GKE cluster and install Tekton" >&2

    read -r -p "Are you sure? [y/N] " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Quitting ..." >&2
        exit 1
    fi
fi

set -e

# Create GKE cluster
gcloud container clusters create ${CLUSTER_NAME} \
    --project ${PROJECT} \
    --zone ${CLUSTER_ZONE} \
    --no-enable-basic-auth \
    --cluster-version "1.13.11-gke.14" \
    --machine-type "n1-standard-1" \
    --num-nodes "1" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --enable-cloud-logging \
    --enable-cloud-monitoring \
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

# Install tekton pipelines on new cluster
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/${TKN_PIPELINE_VERSION}/release.yaml

# Install tekton triggers on new cluster
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/${TKN_TRIGGERS_VERSION}/release.yaml

kubectl get pods --all-namespaces

# Create sig-build namespace first
kubectl apply -f namespace.yaml

