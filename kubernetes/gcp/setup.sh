#!/bin/bash - 
#===============================================================================
#
#          FILE: setup.sh
# 
#         USAGE: ./setup.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Franklin D. (@theDevilsVoice), 
#  ORGANIZATION: 
#       CREATED: 07/20/2020 21:27
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

gcloud auth application-default login
gcloud config set project $GOOGLE_PROJECT 

gcloud projects list

docker build -f ./docker/Dockerfile -t franklin-resume:v1 .
docker tag franklin-resume:v1 us.gcr.io/$GOOGLE_PROJECT/franklin-resume:v1
gcloud docker -- push us.gcr.io/m$GOOGLE_PROJECT/franklin-resume:v1

gcloud config set container/cluster franklin-resume
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

gcloud container clusters create franklin-cluster --zone us-central1-a --num-nodes 1
kubectl create -f gcp/webapp-deployment.yaml
kubectl apply -f gcp/webapp-deployment.yaml
