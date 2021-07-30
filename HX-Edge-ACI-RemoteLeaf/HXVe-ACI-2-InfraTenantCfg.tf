#--------------------------------------------------------------------------------------------------
# Configure Infrastructure Tenant for HX Edge Cluster 
# This is also configurable from the Cisco APIC GUI at: Tenants
# Creates Infra Tenant, Application Profile, Bridge Domains and EPGs
# Uses an existing shared L3Out from the "common" tenant for connectivty outside the fabric
#--------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------
# Collect information on the existing L3Out for connectivity outside the ACI Fabric
#--------------------------------------------------------------------------------------------------

data "aci_tenant" "common" {
  description = "Tenant for connectivity outside the ACI fabric"
  name        = var.hxv_e_l3out.tenant_name
}

data "aci_l3_outside" "SharedL3Out-West-Pod1_RO" {
 tenant_dn = "${data.aci_tenant.common.id}"
 name      = var.hxv_e_l3out.name
}

data "aci_contract" "Allow-Shared-L3Out" {
  tenant_dn = "${data.aci_tenant.common.id}"
  name      = var.hxv_e_l3out.contract
}

#---------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------
# Create Infra Tenant and associated Application Profiles, Bridge Domains and EPGs
#--------------------------------------------------------------------------------------------------

# Create Infra Tenant 
resource "aci_tenant" "HXV-E-Foundation" {
  description = "Tenant for Hyperflex Edge Infra Connectivity"
  name        = var.hxv_e_infra_tenant_name 
}
# Create Infra Tenant VRF
resource "aci_vrf" "HXV-E-Foundation_VRF" {
  tenant_dn = aci_tenant.HXV-E-Foundation.id
  name      = var.hxv_e_infra_vrf_name
}
# Provision networking for In-Band Mgmt 
resource "aci_bridge_domain" "HXVe-IB-MGMT_BD" {
  tenant_dn                = "${aci_tenant.HXV-E-Foundation.id}"
  description              = "Infra InBand Mgmt BD for HX Edge Cluster"
  name                     = var.hxv_e_infra_mgmt_bd_name
  arp_flood                = "no"
  ep_move_detect_mode      = "garp"
  host_based_routing       = "no"
  unicast_route            = "yes" 
  relation_fv_rs_ctx       = aci_vrf.HXV-E-Foundation_VRF.id  
  relation_fv_rs_bd_to_out = [data.aci_l3_outside.SharedL3Out-West-Pod1_RO.id]
}
# Provision networking for In-Band Mgmt 
resource "aci_subnet" "HXVe-IB-MGMT_BD_Subnet" {
  parent_dn   = "${aci_bridge_domain.HXVe-IB-MGMT_BD.id}"
  description = "subnet"
  ip          = "${var.hxv_e_ib_mgmt_bd_subnet_ip}"
  scope       = ["public", "shared"]
} 
# Provision networking for vMotion
resource "aci_bridge_domain" "HXVe-vMotion_BD" {
  tenant_dn           = "${aci_tenant.HXV-E-Foundation.id}"        
  description         = "Infra - vMotion BD for HX Edge Cluster"        
  name                = var.hxv_e_infra_vmotion_bd_name        
  arp_flood           = "no"        
  ep_move_detect_mode = "garp"        
  host_based_routing  = "no"        
  unicast_route       = "yes"        
  relation_fv_rs_ctx  = aci_vrf.HXV-E-Foundation_VRF.id        
}
# Provision networking for Storage Data
resource "aci_bridge_domain" "HXVe-CL0-StorData_BD" {
  tenant_dn           = "${aci_tenant.HXV-E-Foundation.id}"         
  description         = "Infra - StorData BD for HX Edge Cluster (CL0)"         
  name                = var.hxv_e_infra_stordata_cl0_bd_name         
  arp_flood           = "no"         
  ep_move_detect_mode = "garp"         
  host_based_routing  = "no"         
  unicast_route       = "no"         
  relation_fv_rs_ctx  = aci_vrf.HXV-E-Foundation_VRF.id         
}
# Create Application Profile for In-Band Mgmt 
resource "aci_application_profile" "HXVe-IB-MGMT_AP" {
  tenant_dn = "${aci_tenant.HXV-E-Foundation.id}"
  name      = var.hxv_e_infra_mgmt_ap_name
}
# Create Application Profile for vMotion
resource "aci_application_profile" "HXVe-vMotion_AP" {
  tenant_dn = "${aci_tenant.HXV-E-Foundation.id}"
  name      = var.hxv_e_infra_vmotion_ap_name
}
# Create Application Profile for Storage Data
resource "aci_application_profile" "HXVe-StorData_AP" {
  tenant_dn = "${aci_tenant.HXV-E-Foundation.id}"
  name      = var.hxv_e_infra_stordata_ap_name
}
# Create In-Band Mgmt EPG
resource "aci_application_epg" "HXVe-IB-MGMT_EPG" {
  application_profile_dn  = "${aci_application_profile.HXVe-IB-MGMT_AP.id}"
  name                    = var.hxv_e_infra_mgmt_epg_name
  description             = "Infra - IB MGMT EPG for HX Edge Cluster"
  flood_on_encap          = "disabled"
  relation_fv_rs_bd       = aci_bridge_domain.HXVe-IB-MGMT_BD.id
}
# Create vMotion Mgmt EPG
resource "aci_application_epg" "HXVe-vMotion_EPG" {
  application_profile_dn = "${aci_application_profile.HXVe-vMotion_AP.id}"
  name                   = var.hxv_e_infra_vmotion_epg_name
  description            = "Infra - vMotion EPG for HX Edge Cluster"
  flood_on_encap         = "disabled"
  relation_fv_rs_bd      = aci_bridge_domain.HXVe-vMotion_BD.id
}
# Create Storage Data EPG
resource "aci_application_epg" "HXVe-CL0-StorData_EPG" {
  application_profile_dn = "${aci_application_profile.HXVe-StorData_AP.id}"
  name                   = var.hxv_e_infra_stordata-cl0_epg_name
  description            = "Infra - Storage Data EPG for HX Edge Cluster"
  flood_on_encap         = "disabled"
  prio                   = "level1"
  relation_fv_rs_bd      = aci_bridge_domain.HXVe-CL0-StorData_BD.id
}
# Create contract to enable connectivity outside the ACI Fabric from IB-MGMT
resource "aci_epg_to_contract" "HXVe-IB-MGMT_EPG_Contract" {
  application_epg_dn = "${aci_application_epg.HXVe-IB-MGMT_EPG.id}"
  contract_dn        = "${data.aci_contract.Allow-Shared-L3Out.id}"
  contract_type      = "consumer"
}

#---------------------------------------------------------------------------------------------------
