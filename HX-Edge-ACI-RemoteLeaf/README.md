# Terraform Repository for the Cisco HyperFlex Edge with Cisco ACI Remote Leaf solution

## Table of Contents
* [Overview](Overview)
* [Solution Topology](Solution-Topology)
* [Solution Software](Solution-Software)
* [Prerequisites](Prerequisites)
* [Terraform Scripts](Terraform-Scripts)
* [Terraform Version](Terraform-Version)
* [Terraform Providers](Terraform-Providers)
* [Solution Deployment](Solution-Deployment) 
  - [Clone Github Collection](Clone-Github-Collection)
  - [Update Variables](Update-Variables)
  - [Execute Terraform Plans](Execute-Terraform-Plans)
* [Resources](Resources)

## Overview 

This repository contains the Terraform (TF) plans for deploying the ACI portion of the design for the [Cisco HyperFlex (HX) Edge with ACI Remote Leaf (RL) solution](https://www.cisco.com/c/en/us/td/docs/unified_computing/ucs/UCS_CVDs/hx_edge_4_5_aci_terraform.html).   

The Terraform plans were used to provision the following aspects of the solution:

 1.  Setup Access Layer Connectivity from ACI Remote Leaf switches to HyperFlex Edge Cluster Nodes 
 2.  Setup Infrastructure Tenant (VRF, BD, AP, EPG) for HX Edge cluster to enable In-Band Mgmt, Storage, and vMotion connectivity 
 3.  (Optional) Modify default ACI Fabric QoS Classes to accomodate the newly deployed HX Edge cluster 
 4.  (Optional) Import the Intersight HX Installer deployed `hx-vm-network` vSwitch as a Terraform resource 
 5.  (Optional) Remove the uplink vNICs used by the `hx-vm-network` vSwitch so that it can be used by a VMware vDS  
 6.  (Optional) Setup Cisco APIC for VMM integration with VMware vCenter that manages the vSphere cluster hosted on HX Edge  
 7.  (Optional) Deploy Application Tenant and EPGs for App. VMs  using ACI VMM integration to dynamically provision the virtual networking for use by App. VMs

## Solution Topology

A high level view of the solution topology is shown below. 

![image](https://user-images.githubusercontent.com/24396268/127541945-00e9d981-cbca-406c-8a4b-28a4a861559d.png)

## Solution Software
The software versions of the components validated in this solution are:  

* Cisco HyperFlex Edge: 4.5(1a)
* Cisco ACI Fabric - APIC: 4.2(6h) 
* VMware vCenter Server, VMware ESXi: 7.0 Update 1d (17491101) 

## Prerequisites

 *  Basic understanding of how traffic forwarding works in an ACI fabric, and the ACI constructs and policies used to implement it
 *  Review the [Cisco ACI Remote Leaf Architecture white paper](https://www.cisco.com/c/en/us/solutions/collateral/data-center-virtualization/application-centric-infrastructure/white-paper-c11-740861.html) for an in-depth understanding of the remote leaf design 
 *  The main Cisco ACI fabric site that the remote site will be mapped to, is assumed to be up and operational with connectivity to the Inter-Pod network (IPN) that will interconnect the sites. Note: The ACI fabric design and the Inter-Pod network design is outside the scope of this white paper and assumed to be in place before the remote leaf site is brought up. 
 *  Management Workstation for executing Terraform scripts. It should be Linux-based workstation with tools such as GIT and an IDE (for e.g. VSCode) deployed to clone this repo, and to edit and execute the Terraform plans.
 *  Physically deploy the relevant components and establish connectivity between the components. Also perform any initial device configuration that is needed. Verify that the Remote Leaf site is up and operation with connectivity to the main ACI site across the Inter-Pod network. The HyperFlex Edge servers should also be physically connected to the leaf switches with the necessary configuration to bring the link up on the ACI Remote leaf switches.  

   
## Terraform Scripts

The Terraform plans in the solution directory: `HX-Edge-ACI-RemoteLeaf` directory are summarized below. 

1. _HXVe-ACI-1-FabrAccPolCfg.tf_:  
   - Provisions access layer connectivity from ACI remote leaf switches to HX Edge cluster nodes
2. _HXVe-ACI-2-InfraTenantCfg.tf_:  
   - Provisions Infrastructure connectivity for HX Edge cluster (In-Band Management, Storage Data, and vMotion)
   - Maps Storage Data traffic class to the highest priority QoS class in the Cisco ACI fabric
3. _HXVe-ACI-3-QoSCfg.tf_:
   - Modifies default ACI Fabric QoS Classes to accomodate the newly deployed HX Edge cluster 
4. _HXVe-VMW-4-vCenterCfg-beforeImport.tf_:
   - Imports the Intersight HX Installer deployed `hx-vm-network` vSwitch as a Terraform resource
5. _HXVe-VMW-5-vCenterCfg-afterImport.tf_:
   - Removes the uplink vNICs used by the `hx-vm-network` vSwitch so that it can be used by a VMware vDS 
6. _HXVe-ACI-6-VMMIntegCfg.tf_:
   - Provisions Cisco ACI VMM integration with VMware vCenter that manages the vSphere cluster hosted on HX Edge
7. _HXVe-ACI-7-AppTenantCfg.tf_:
   - Deploys Application Tenant and EPGs for App. VMs  using ACI VMM integration to dynamically provision the virtual networking for use by App. VMs

Note: 
- TF Plans [1] and [2] must be complete before Cisco Intersight begins the installation of the HX Edge cluster
- TF Plans [3] through [7] are optional

## Terraform Version

The Terraform version used to validate the scripts in this repo is:
```
CiscoTerraFormProjects % terraform -version
Terraform v0.15.5
```
## Terraform Providers

The Terraform Providers used by the Terraform scripts are: 
```
terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = "0.7.0"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.0.0"
    }
  }
}
```

##  Solution Deployment 

To deploy a VMware based Virtual Server Infrastructure (VSI) on a HX edge cluster connected to a pair of remote leaf switches, the ACI fabric needs to be provisioned. The automated povisioning of the ACI fabric using Terraform can be executed as outlined below. 

###  Clone Github Collection

Clone the GitHub collection named `HyperFlex-ACI-Projects` to a new empty folder on the management workstation. Cloning the collection creates a local copy, which is then used to run the Terraform plans that have been created for this solution. 

To clone the GitHub collection, complete the following steps from the management workstation:

1.	Create a new folder for the project. The GitHub collection will be cloned to a folder inside this one, named `HyperFlex-ACI-Projects`.
2.	Change directories to the newly created folder.
3.	Clone the GitHub collection using the command: `git clone https://github.com/ucs-compute-solutions/HyperFlex-ACI-Projects`
4.	Change directories to the folder with the collection named `HyperFlex-ACI-Projects`. 

### Update Variables

Define the variables that should be used to configure the ACI fabric in the `variables.auto.tfvars` file. In Terraform, the variables are declared in the `variables.tf` file. The values for these variables are then specified in a separate file called `variables.auto.tfvars`. For each remote site being deployed with HX Edge cluster connected to ACI remote leaf switches, the included `variables.auto.tfvars` file can be modified, or a copy can be made and referenced when running the script. 

### Execute Terraform Plans

1. **Terraform Init**

- The _init_ command is used to initialize the Terraform environment for the script being run. Any additional provider modules, such as the Cisco ACI provider, are   downloaded and all prerequisites are checked. This initialization only needs to be run once per script, and subsequent runs only need to execute plan and apply.   
- To initialize the environment, via the CLI change to the `HyperFlex-ACI-Projects` folder where the GitHub repository was cloned, then execute:
```
terraform init
```
2. **Terraform Plan**

- The _plan_ command is used to evaluate the Terraform script for any syntax errors or other problems. The script will be evaluated against the existing environment and a list of planned actions will be shown. If there are no errors and the planned actions appear correct, then it is safe to proceed to running the apply command in the next step. 

- To evaluate the Terraform plan, via the CLI change to the `HyperFlex-ACI-Projects` folder where the GitHub repository was cloned, then execute:
```
terraform plan HXVe-ACI-1-FabrAccPolCfg.tf
terraform plan HXVe-ACI-2-InfraTenantCfg.tf
```
3. **Terraform Apply**

- The _apply_ command will deploy the new configuration. This command will repeat the planning phase and then ask for confirmation to continue with creating the new resources. 
- To execute the Terraform plan, via the CLI change to the `HyperFlex-ACI-Projects` folder where the GitHub repository was cloned, then execute:
```
terraform apply HXVe-ACI-1-FabrAccPolCfg.tf
terraform apply HXVe-ACI-2-InfraTenantCfg.tf
```

## Resources
For more information, see: 
* [Cisco ACI Programmability](https://developer.cisco.com/docs/aci/#!introduction/aci-programmability)
* [Cisco ACI Provider - CodeExchange](https://developer.cisco.com/codeexchange/github/repo/ciscoecosystem/terraform-provider-aci)
