
#--------------------------------------------------------------------------------------------------
# OPTIONAL: Sample Application Tenant Configuration for Apps hosted on HX Edge Cluster
# Configurable from APIC GUI at: "Tenant"
# Creates Application Tenant, Application Profile, Bridge Domains and EPG
#--------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------
# Create Application Tenant and associated Application Profiles, Bridge Domains and EPGs
#--------------------------------------------------------------------------------------------------

resource "aci_tenant" "HXV-E-Application-A" {
  description = "Application Tenant Hosted on Hyperflex Edge RL1-Site1"
  name = "HXV-E-Application-A"
}

resource "aci_vrf" "HXV-E-Application-A_VRF" {
  tenant_dn = aci_tenant.HXV-E-Application-A.id
  name      = "HXV-E-Application-A_VRF"
}

resource "aci_bridge_domain" "HXVe-App-A_BD" {
  tenant_dn                 = "${aci_tenant.HXV-E-Application-A.id}"
  description               = "App-A - App Tenant A hosted on HX Edge Cluster"
  name                      = "HXVe-App-A_BD"
  arp_flood                 = "no"
  ep_move_detect_mode       = "garp"
  host_based_routing        = "no"
  unicast_route             = "yes" 
  relation_fv_rs_ctx        = aci_vrf.HXV-E-Application-A_VRF.id  
  #relation_fv_rs_bd_to_out = [data.aci_l3_outside.SharedL3Out-West-Pod1_RO.id]
}

resource "aci_subnet" "HXVe-App-A_BD_Subnet" {
  parent_dn   = "${aci_bridge_domain.HXVe-App-A_BD.id}"
  description = "subnet"
  #ip         = "${var.HXVe-IB-MGMT_BD_Subnet_IP}"
  ip          = "172.19.167.254/24"
  scope       = ["public", "shared"]
    } 


resource "aci_application_profile" "HXVe-App-A_AP" {
  tenant_dn  = "${aci_tenant.HXV-E-Application-A.id}"
  name       = "HXVe-App-A_AP"
}


resource "aci_application_epg" "HXVe-App-A_EPG" {
  application_profile_dn = "${aci_application_profile.HXVe-App-A_AP.id}"
  name                   = "HXVe-App-A_EPG"
  description            = "Application - App-A EPG hosted on HX Edge Cluster"
  flood_on_encap         = "disabled"
  relation_fv_rs_bd      = aci_bridge_domain.HXVe-App-A_BD.id
  #relation_fv_rs_dom_att = aci_vmm_domain.vds.id
  }

#--------------------------------------------------------------------------------------------------
# Map EPG to VMM Domain
#--------------------------------------------------------------------------------------------------


resource "aci_epg_to_domain" "HXVe-Site1-RL1-EPG1-Dynamic-Mapping" {
  #depends_on           = [aci_vmm_domain.vds]
  application_epg_dn    = "${aci_application_epg.HXVe-App-A_EPG.id}"
  tdn                   = "${aci_vmm_domain.vds.id}"
  vmm_allow_promiscuous = "accept"
  vmm_forged_transmits  = "reject"
  vmm_mac_changes       = "accept"
  instr_imedcy          = "immediate"
  res_imedcy            = "immediate"
}

