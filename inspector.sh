#!/bin/bash

echo "detect the cluster ...";

if [[ ! -z $(kubectl cluster-info dump | grep -e 'eks') ]]
then
  cluster="EKS";
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'gke') ]]
then
  cluster="GKE"; 
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'aks') ]]
then
  cluster="AKS";   
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'lke') ]]
then
  cluster="LKE";  
elif [[ ! -z $(kubectl cluster-info dump | grep -e 'doks') ]]
then
  cluster="DOKS";  
else
  echo "this cluster is not supported";exit;
fi

script=$(echo $cluster | tr '[:upper:]' '[:lower:]')".sh"

echo "your are running $cluster cluster"
echo "running $script ..."
echo $'\n';

/bin/bash $script