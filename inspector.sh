#!/bin/bash

read -p "what is your k8s cluster? 
(AKS,EKS,GKE): " cluster

if ! [[ "$cluster" =~ ^(GKE|EKS|AKS|eks|gke|aks)$ ]]; then echo "cluster type is wrong";exit ; fi

script=$(echo $cluster | tr '[:upper:]' '[:lower:]')".sh"

echo "running $script ..."

/bin/bash $script