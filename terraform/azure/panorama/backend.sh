#!/usr/bin/env bash -
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

RESOURCE_GROUP_NAME=
STORAGE_ACCOUNT_NAME=
CONTAINER_NAME=

# Create resource group 
# az account list-locations
az group create --name $RESOURCE_GROUP_NAME --location southcentralus

# create mgmt vnet
az network vnet create --resource-group ${RESOURCE_GROUP_NAME} --name ssg-vnet-mgmt-southcentralus \
  --address-prefixes 10.11.43.224/27

# Create storage account
az storage account create --resource-group ${RESOURCE_GROUP_NAME} --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryptio
n-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query
 [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key=${ACCOUNT_KEY}

export ARM_ACCESS_KEY=$ACCOUNT_KEY
# terraform {   
# backend "azurerm" {     
# storage_account_name  = "rgpaloscus6175"     
# container_name        = "rg-palo-scus-tstate"     
# key                   = "terraform.tfstate"   
# } 
#}
