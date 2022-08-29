#!/bin/bash

echo "detect the cluster ...";

if [[ ! -z $(kubectl cluster-info dump | grep -e 'aws' -e 'eks') ]]
then
  cluster="EKS";
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'gcp' -e 'gke') ]]
then
  cluster="GKE"; 
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'azure' -e 'aks') ]]
then
  cluster="AKS";   
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'linode' -e 'lke') ]]
then
  cluster="LKE";  
else
  echo "this cluster is not supported";exit;
fi

script=$(echo $cluster | tr '[:upper:]' '[:lower:]')".sh"

echo "your are running $cluster cluster"
echo "running $script ..."
echo $'\n';

/bin/bash $script