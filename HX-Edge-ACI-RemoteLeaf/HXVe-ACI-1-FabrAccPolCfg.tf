
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

provider "aci" {
  username = var.hxv_e_aci_apic.usr
  password = var.hxv_e_aci_apic.pwd
  url      = var.hxv_e_aci_apic.url
  insecure = true
}


#---------------------------------------------------------------------------------------------------
# Configure Access Layer Connectivity to HX Edge Cluster Nodes
# This is also configurable from the Cisco APIC GUI at: "Fabric > Access Policies"
# Creates policies that enable infrastructure connectivity for Inband Mgmt, vMotion and Storage Data traffic
# EPGs created in the Infrastructure Tenant are also mapped to the access layer in this plan
#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Step 1: Create VLAN Pool, Domain and AAEP
#---------------------------------------------------------------------------------------------------

# Create Static VLAN Pool for HyperFlex Infrastructure Connectivity 
resource "aci_vlan_pool" "HXVe_VLANs" {
    name        = var.hxv_e_infra_vlan_pool_name
    description = "Infra VLAN Pool for HX Edge cluster"
    alloc_mode  = "static"
}

# Add a static VLAN ID to the VLAN Pool - for HX Inband Mgmt
resource "aci_ranges" "mgmt_vlans" {
    vlan_pool_dn = aci_vlan_pool.HXVe_VLANs.id
    from         = var.hxv_e_infra_ib_mgmt_vlan_id
    to           = var.hxv_e_infra_ib_mgmt_vlan_id
    alloc_mode   = "inherit"
    role         = "external"
}

# Add a static VLAN ID to the VLAN Pool - for HX vMotion 
resource "aci_ranges" "vMotion_vlans" {
    vlan_pool_dn = aci_vlan_pool.HXVe_VLANs.id
    from         = var.hxv_e_infra_vmotion_vlan_id
    to           = var.hxv_e_infra_vmotion_vlan_id
    alloc_mode   = "inherit"
    role         = "external"
}

# Add a static VLAN ID to the VLAN Pool - for HX Storage Data 
resource "aci_ranges" "storage_data_vlans" {
    vlan_pool_dn = aci_vlan_pool.HXVe_VLANs.id
    from         = var.hxv_e_infra_stordata_cl0_vlan_id
    to           = var.hxv_e_infra_stordata_cl0_vlan_id
    alloc_mode   = "inherit"
    role         = "external"
}

# Specify the Domain type and associate it to the VLAN Pool 
resource "aci_physical_domain" "HXVe_Domain" {
  name                      = var.hxv_e_phy_domain_name
  relation_infra_rs_vlan_ns = aci_vlan_pool.HXVe_VLANs.id
}

# Specify the Attachable Access Entity Profile and associate it to the Domain
resource "aci_attachable_access_entity_profile" "HXVe_AAEP" {
  description             = "AAEP for HX Edge Cluster nodes"
  name                    = var.hxv_e_aaep_name
  relation_infra_rs_dom_p = [aci_physical_domain.HXVe_Domain.id]
}

#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Step 2: Create Access Layer Interface Policies: Link Speed, CDP, LLDP, VLAN Scope, Spanning Tree
#         Configurable from Cisco APIC GUI: Fabric > Access Policies > Policies > Interface
#         Follows ACI best-practice naming convention and re-use policies whenever possible
#         Note: New policies are created here but one can also use previously defined policies 
#---------------------------------------------------------------------------------------------------

# Access Interface Policy - Link Level (Speed, FEC)
# Note: FEC configuration is for the specific Leaf model and when using 25GbE
resource "aci_fabric_if_pol" "Nexus-YC-EX-25Gbps" {
  name        = "Nexus-YC-EX-25Gbps"
  description = "For Nexus 93180YC-EX Leaf switches - AOC "
  fec_mode    = "cl74-fc-fec"
  speed       = "25G"
}

# Access Interface Policies - CDP  
resource "aci_cdp_interface_policy" "CDP-Enabled" {
  name        = "CDP-Enabled"
  admin_st    = "enabled"
}
resource "aci_cdp_interface_policy" "CDP-Disabled" {
  name        = "CDP-Disabled"
  admin_st    = "disabled"
}

# Access Interface Policies - LLDP Interface
resource "aci_lldp_interface_policy" "LLDP-Enabled" {
  description = "Enable LLDP"
  name        = "LLDP-Enabled"
  admin_rx_st = "enabled"
  admin_tx_st = "enabled"
} 
resource "aci_lldp_interface_policy" "LLDP-Disabled" {
  description = "Disable LLDP"
  name        = "LLDP-Disabled"
  admin_rx_st = "disabled"
  admin_tx_st = "disabled"
} 

# Access Interface Policies - VLAN Scope
resource "aci_l2_interface_policy" "VLAN-Scope-Local" {
  description = "VLAN Scope is Local"
  name        = "VLAN-Scope-Local"
  vlan_scope  = "portlocal"
}
resource "aci_l2_interface_policy" "VLAN-Scope-Global" {
  description = "VLAN Scope is Global"
  name        = "VLAN-Scope-Global"
  vlan_scope  = "global"
}

# Access Interface Policies - Spanning Tree 
resource "aci_spanning_tree_interface_policy" "BPDU-FG-Enabled" {
  name = "BPDU-FG-Enabled"
  ctrl = ["bpdu-filter", "bpdu-guard"]
}
resource "aci_spanning_tree_interface_policy" "BPDU-FG-Disabled" {
  name = "BPDU-FG-Disabled"
  ctrl = ["unspecified"]
}

#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Step 3: Create Interface Policy Group and Profile for access ports that connect to HX Edge nodes
#         Configurable from Cisco APIC GUI: Fabric > Access Policies > Interfaces > Leaf Interfaces
#---------------------------------------------------------------------------------------------------

# Interface Policy Group (IPG) for access ports that connect to HX Edge Nodes
resource "aci_leaf_access_port_policy_group" "HXVe_IPG" {
    description                   = "Access Interface Policy Group for Leaf Switch"
    name                          = var.hxv_e_leaf_ipg_name
    relation_infra_rs_h_if_pol    = aci_fabric_if_pol.Nexus-YC-EX-25Gbps.id
    relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.CDP-Enabled.id
    relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.LLDP-Enabled.id
    relation_infra_rs_l2_if_pol   = aci_l2_interface_policy.VLAN-Scope-Local.id
    relation_infra_rs_stp_if_pol  = aci_spanning_tree_interface_policy.BPDU-FG-Enabled.id
    relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.HXVe_AAEP.id
}

# Interface Profile (IPR) for access ports that connect to HX Edge Nodes
resource "aci_leaf_interface_profile" "HXVe-Leaf_IPR" {
    description = "Remote Leaf Interface Profile"
    name        = var.hxv_e_leaf_ipr_name
}

# Access Port Selector Name for Leaf switch(s) ports that connect to HX Edge Nodes
resource "aci_access_port_selector" "HXVe-Leaf_ports" {
    leaf_interface_profile_dn      = aci_leaf_interface_profile.HXVe-Leaf_IPR.id
    description                    = "Interface/Port Selectors for Leaf Switch"
    name                           = var.hxv_e_leaf_port_selector_name
    access_port_selector_type      = "range"
    relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.HXVe_IPG.id
} 
# Specify Leaf Switch(s) ports that connect to HX Edge Nodes
resource "aci_access_port_block" "HXV-E_p1_1-4" {
    access_port_selector_dn = aci_access_port_selector.HXVe-Leaf_ports.id
    name                    = "HXV-E_p1_1-4"
    from_card               = var.hxv_e_from_module
    from_port               = var.hxv_e_from_port
    to_card                 = var.hxv_e_to_module
    to_port                 = var.hxv_e_to_port
}

#---------------------------------------------------------------------------------------------------



#---------------------------------------------------------------------------------------------------
# Step 4: Create Leaf Switch Profile for Access Leaf switch(s) that connect to HX Edge nodes
#         From Cisco APIC GUI menu: Fabric > Access Policies > Switches > Leaf Switches
#---------------------------------------------------------------------------------------------------

# Leaf Switch Profile (SPR)
resource "aci_leaf_profile" "HXVe-Leaf_SPR" {
    name                         = var.hxv_e_leaf_spr_name
    relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.HXVe-Leaf_IPR.id]
}

# Switches Selector Name for Leaf switch(s) that connect to HX Edge Nodes
resource "aci_leaf_selector" "HXVe-Site1-RL-Pair" {
    leaf_profile_dn         = aci_leaf_profile.HXVe-Leaf_SPR.id
    name                    = var.hxv_e_leaf_switch_selector_name
    switch_association_type = "range"
}

# Specify Node ID for switches
resource "aci_node_block" "HXVe-Site1-RL-Pair_NID" {
    switch_association_dn = aci_leaf_selector.HXVe-Site1-RL-Pair.id
    name                  = "HXVe-Site1-RL1-Pair_NID"
    from_                 = var.hxv_e_leaf_1_node_id 
    to_                   = var.hxv_e_leaf_2_node_id
}

#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Step 5 - Map HX Infra EPGs to Physical Domain
#---------------------------------------------------------------------------------------------------

# In-Band Mgmt EPG -> Domain
resource "aci_epg_to_domain" "HXVe-IB-MGMT_EPG_ToDomain" {

  application_epg_dn    = "${aci_application_epg.HXVe-IB-MGMT_EPG.id}"
  tdn                   = "${aci_physical_domain.HXVe_Domain.id}"
}
# vMotion EPG -> Domain
resource "aci_epg_to_domain" "HXVe-vMotion_EPG_ToDomain" {

  application_epg_dn    = "${aci_application_epg.HXVe-vMotion_EPG.id}"
  tdn                   = "${aci_physical_domain.HXVe_Domain.id}"
}
# Storage Data EPG -> Domain
resource "aci_epg_to_domain" "HXVe-CL0-StorData_EPG_ToDomain" {

  application_epg_dn    = "${aci_application_epg.HXVe-CL0-StorData_EPG.id}"
  tdn                   = "${aci_physical_domain.HXVe_Domain.id}"
}

#---------------------------------------------------------------------------------------------------



#---------------------------------------------------------------------------------------------------
# Step 6: Map HX Infra EPGs to Access Layer Policies for connectivity
#---------------------------------------------------------------------------------------------------

# In-Band Mgmt EPG -> Access Layer Connectivity Policy on 1st Leaf
resource "aci_epg_to_static_path" "HXVe-Site1-RL1-EPG1-Static-Mapping" {
  for_each             = toset(var.hxv_e_leaf_ports)
    application_epg_dn = "${aci_application_epg.HXVe-IB-MGMT_EPG.id}"
    tdn                = "topology/pod-1/paths-151/pathep-[${each.value}]"
    encap              = var.hxv_e_infra_ib_mgmt_vlan_id
    instr_imedcy       = "immediate"
    mode               = "regular"
}
# In-Band Mgmt EPG -> Access Layer Connectivity Policy on 2nd Leaf
resource "aci_epg_to_static_path" "HXVe-Site1-RL2-EPG1-Static-Mapping" {
  for_each             = toset(var.hxv_e_leaf_ports)
    application_epg_dn = "${aci_application_epg.HXVe-IB-MGMT_EPG.id}"
    tdn                = "topology/pod-1/paths-152/pathep-[${each.value}]"
    encap              = var.hxv_e_infra_ib_mgmt_vlan_id
    instr_imedcy       = "immediate"
    mode               = "regular"
}

# vMotion EPG -> Access Layer Connectivity Policy on 1st Leaf
resource "aci_epg_to_static_path" "HXVe-Site1-RL1-EPG2-Static-Mapping" {
  for_each             = toset(var.hxv_e_leaf_ports)
    application_epg_dn = "${aci_application_epg.HXVe-vMotion_EPG.id}"
    tdn                = "topology/pod-1/paths-151/pathep-[${each.value}]"
    encap              = var.hxv_e_infra_vmotion_vlan_id
    instr_imedcy       = "immediate"
    mode               = "regular"
}

# vMotion EPG -> Access Layer Connectivity Policy on 2nd Leaf
resource "aci_epg_to_static_path" "HXVe-Site1-RL2-EPG2-Static-Mapping" {
  for_each             = toset(var.hxv_e_leaf_ports)
    application_epg_dn = "${aci_application_epg.HXVe-vMotion_EPG.id}"
    tdn                = "topology/pod-1/paths-152/pathep-[${each.value}]"
    encap              = var.hxv_e_infra_vmotion_vlan_id
    instr_imedcy       = "immediate"
    mode               = "regular"
}

# Storage Data EPG -> Access Layer Connectivity Policy on 1st Leaf
resource "aci_epg_to_static_path" "HXVe-Site1-RL1-EPG3-Static-Mapping" {
  for_each             = toset(var.hxv_e_leaf_ports)
    application_epg_dn = aci_application_epg.HXVe-CL0-StorData_EPG.id
    tdn                = "topology/pod-1/paths-151/pathep-[${each.value}]"
    encap              = var.hxv_e_infra_stordata_cl0_vlan_id
    instr_imedcy       = "immediate"
    mode               = "regular"
}

# Storage Data EPG -> Access Layer Connectivity Policy on 2nd Leaf
resource "aci_epg_to_static_path" "HXVe-Site1-RL2-EPG3-Static-Mapping" {
  for_each             = toset(var.hxv_e_leaf_ports)
    application_epg_dn = aci_application_epg.HXVe-CL0-StorData_EPG.id
    tdn                = "topology/pod-1/paths-152/pathep-[${each.value}]"
    encap              = var.hxv_e_infra_stordata_cl0_vlan_id
    instr_imedcy       = "immediate"
    mode               = "regular"
}

#---------------------------------------------------------------------------------------------------
