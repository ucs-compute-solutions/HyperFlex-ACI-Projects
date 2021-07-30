
#-----------------------------------------------------------------------------------
# Variables for Cisco APIC 
#-----------------------------------------------------------------------------------

# Cisco APIC Access Info 

variable "hxv_e_aci_apic" {
  description = "Cisco APIC Access Info"
  type = map
}

#-----------------------------------------------------------------------------------------
# Variables for ACI Fabric Access Policies for Access Layer Connectivity to HX Edge nodes
#-----------------------------------------------------------------------------------------

# Infra VLAN Pool and IDs for access layer connectivity to HX Edge nodes
variable "hxv_e_infra_vlan_pool_name" {
  description = "Infra VLAN Pool Name for HX Edge Cluster"
}
variable "hxv_e_infra_ib_mgmt_vlan_id" {
  description = "InBand Mgmt. VLAN ID (HX Edge Infra)"  
}
variable "hxv_e_infra_vmotion_vlan_id" {
  description = "vMotion VLAN ID (HX Edge Infra)"  
}
variable "hxv_e_infra_stordata_cl0_vlan_id" {
  description = "Storage Data VLAN ID for this cluster (CL0) (HX Edge Infra)"  
}

# ACI Domain Type for HX Edge Cluster nodes
variable "hxv_e_phy_domain_name" {
  description = "ACI Domain type for HX Edge Cluster nodes"
}

# AAEP for HX Edge Cluster nodes
variable "hxv_e_aaep_name" {
  description = "Attachable Access Entity Profile (AAEP) for HX Edge Cluster nodes"
}

# IPG and IPR for access ports that connect to HX Edge Cluster nodes
variable "hxv_e_leaf_ipg_name" {
  description = "Interface Policy Group (IPG) for access ports that connect to HX Edge nodes"
}
variable "hxv_e_leaf_ipr_name" {
  description = "Interface Profile (IPR) for access ports that connect to HX Edge nodes"
}

# Port Selector Name and ports that connect to HX Edge nodes 
variable "hxv_e_leaf_port_selector_name" {
  description = "Port Selector name for ports that connect to HX Edge nodes"
}
variable "hxv_e_from_module" {
  description = "Leaf switch card/module that the first HX Edge node connects to"
}
variable "hxv_e_from_port" {
  description = "Leaf switch port that the first HX Edge node connects to"
}
variable "hxv_e_to_module" {
  description = "Leaf switch card/module that the last HX Edge node connects to"
}
variable "hxv_e_to_port" {
  description = "Leaf switch port that the last HX Edge node connects to"
}

# Leaf Switch(s) Profile Name
variable "hxv_e_leaf_spr_name" {
  description = "Switch Profile Name for Leaf switch(s) that connect to HX Edge nodes"
}
# Leaf Switch Selector Name
variable "hxv_e_leaf_switch_selector_name" {
  description = "Leaf switch selector name"
}
# Leaf Switch Node IDs
variable "hxv_e_leaf_1_node_id" {
  description = "Node ID for the first leaf switch"
}
variable "hxv_e_leaf_2_node_id" {
  description = "Node ID for the second leaf switch"
}
# Leaf Switch Port IDs
variable "hxv_e_leaf_ports" {
  description = "Leaf switch ports that connect to HX Edge nodes"
}

#-----------------------------------------------------------------------------------
# Variables for ACI Infrastructure Tenant Configuration
#-----------------------------------------------------------------------------------

variable "hxv_e_infra_tenant_name" {
  description = "Infra Tenant for HX Edge cluster"
}
variable "hxv_e_infra_vrf_name" {
  description = "Infra VRF for HX Edge cluster"
}
variable "hxv_e_infra_mgmt_bd_name" {
  description = "Infra IB-MGMT BD for HX Edge cluster"
} 
variable "hxv_e_infra_vmotion_bd_name" {
  description = "Infra vMotion BD for HX Edge cluster"
} 
variable "hxv_e_infra_stordata_cl0_bd_name" {
  description = "Infra Storage Data BD for HX Edge cluster"
} 

variable "hxv_e_ib_mgmt_bd_subnet_ip" {
  description = "Default GW and Subnet for IB-MGMT"
  type = string
}

variable "hxv_e_infra_mgmt_ap_name" {
  description = "Infra IB-MGMT AP for HX Edge cluster"
} 
variable "hxv_e_infra_vmotion_ap_name" {
  description = "Infra vMotion AP for HX Edge cluster"
} 
variable "hxv_e_infra_stordata_ap_name" {
  description = "Infra Storage Data AP for HX Edge cluster"
} 

variable "hxv_e_infra_mgmt_epg_name" {
  description = "Infra IB-MGMT EPG for HX Edge cluster"
} 
variable "hxv_e_infra_vmotion_epg_name" {
  description = "Infra vMotion EPG for HX Edge cluster"
} 
variable "hxv_e_infra_stordata-cl0_epg_name" {
  description = "Infra Storage Data EPG for HX Edge cluster"
}  

variable "hxv_e_l3out" {
  description = "Existing L3Out info for connectivity outside the ACI fabric"
  type = map
}

#-----------------------------------------------------------------------------------
# Variables for ACI VMM Integration - Domain, VLAN Pool, VLAN Range
#-----------------------------------------------------------------------------------

variable "hxv_e_vmm_domain" {
  description = "ACI Domain type for VMM Integration"
  type = map
}

# Infra VLAN Pool and IDs for access layer connectivity to HX Edge n
variable "hxv_e_vmm_vlan_pool_name" {
  description = "VLAN Pool Name for VMM Integration"
}
variable "hxv_e_vmm_vlan_id_start" {
  description = "Starting VLAN ID for VMM Integration"  
}
variable "hxv_e_vmm_vlan_id_end" {
  description = "Ending VLAN ID for VMM Integration"  
}

#-----------------------------------------------------------------------------------
# Variables for APIC <--> VMM Integration - VMM Controller Info
#-----------------------------------------------------------------------------------

#variable "hxv_e_vmm_domain" {
#  description = "VMM Domain Info for VMM integration"
#  type = map
#} 

variable "hxv_e_vmm_controller" {
  description = "VMM Controller info for ACI VMM integration"
  type = map
}

#-----------------------------------------------------------------------------------
# Variables for VMware vSphere Configuration done via VMware vCenter
#-----------------------------------------------------------------------------------

# VMware vCenter Access Info - note that this could be identical to vmm_controller 
# info used for APIC <--> VMM Integration but keeping it separate nevertheless


variable "hxv_e_vmware_vcenter" {
  description = "VMware vCenter Info"
  type = map
}


variable "hxv_e_vmware_esxi_hosts" {
  description = "List of MGMT IPs for ESXi hosts in the HX Edge cluster"
  type = list(string)
}

variable "hxv_e_vmware_vmotion_vswitch" {
  description = "vMotion vSwitch info for ESXi hosts in the HX Edge cluster"
  # object({<ATTR NAME> = <TYPE>, ... })
  type = object({name = string, network_adapters = list(string), active_nics = list(string), standby_nics=list(string),
  vmotion_pg_name = string, vmotion_vlan_id = string, vmotion_vmk_ip_prefix = string, vmotion_vmk_ip_netmask = string, 
  vmotion_vmk_gw = string, vmotion_vmk_netstack = string}) 
}
variable "hxv_e_vmware_vm_network_vswitch_name" {
  description = "name of VM Network vSwitch Intersight HX Installer"
}











