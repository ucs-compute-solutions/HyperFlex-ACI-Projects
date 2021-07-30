#----------------------------------------------------------------------------------------------------
# Configures APIC <--> VMM integration for dynamic provisioning of virtual networking for applications 
# hosted on HX Edge cluster. Configurable from Cisco APIC GUI at: "Virtual Networking > VMM Domains".
# In this integration, APIC deploys and manages the virtual distributed switch. 
# Provisions VMM domain, VLAN pools and provides APIC the necessary VMM Controller info
# NOTE: Each host by added to the switch manually from VMware vCenter 
#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Create VLAN Pool for APIC <--> VMM Integration
#---------------------------------------------------------------------------------------------------

# Define a VMM VLAN Pool
resource "aci_vlan_pool" "HXVe-VMM-VLANs_Pool" {
  name       = var.hxv_e_vmm_vlan_pool_name
  alloc_mode = "dynamic"
}

# VLANs (or ranges) for above VLAN pool
resource "aci_ranges" "HXVe-VMM_VLANs" {
  vlan_pool_dn = aci_vlan_pool.HXVe-VMM-VLANs_Pool.id
  from         = var.hxv_e_vmm_vlan_id_start
  to           = var.hxv_e_vmm_vlan_id_end
  alloc_mode   = "inherit"
  role         = "external"
}

#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Provide the VMM Controller, Credentials and Domain info for APIC <--> VMM integration
#---------------------------------------------------------------------------------------------------

resource "aci_rest" "rest_hxv_e_vmm_aaep" {
  path       = "/api/node/mo/uni/infra/attentp-HXVe_AAEP.json"
  payload    = <<EOF
{
    "infraRsDomP": {
        "attributes": {
            "tDn": "uni/vmmp-VMware/dom-HXVe-vDS",
            "status": "created,modified"
        },
        "children": []
    }
}
EOF
}

resource "aci_rest" "rest_hxv_e_vmm_vswitch_policy" {
  path       = "/api/node/mo/uni.json"
  payload = <<EOF
{
    "vmmDomP": {
        "attributes": {
            "dn": "uni/vmmp-VMware/dom-HXVe-vDS",
            #"status": "created,modified"
        },
        "children": [
            {
            "vmmVSwitchPolicyCont":{
                "attributes":{
                    "dn":"uni/vmmp-VMware/dom-HXVe-vDS/vswitchpolcont",
                    "status":"created,modified"
                },
                "children":[ 
                       {
                        "vmmRsVswitchOverrideLldpIfPol":{
                            "attributes":{
                               "tDn":"uni/infra/lldpIfP-LLDP-Enabled",
                               "status":"created,modified"
                            }
                        }
                       },
                       {
                        "vmmRsVswitchOverrideCdpIfPol":{
                           "attributes":{
                               "tDn":"uni/infra/cdpIfP-CDP-Enabled",
                               "status":"created,modified"
                           }
                        }
                       }
                ]
            
            }
          }
        ]
    }
}
EOF
}


# Specify the Domain type and associate it to the VLAN Pool 
resource "aci_vmm_domain" "vds" {
  provider_profile_dn          = var.hxv_e_vmm_domain.provider_profile_dn
  name                         = var.hxv_e_vmm_domain.name
  annotation                   = "orchestrator:terraform"
  relation_infra_rs_vlan_ns    = aci_vlan_pool.HXVe-VMM-VLANs_Pool.id
}

resource "aci_vmm_controller" "HXVe-VMM-vCenter" {
  vmm_domain_dn       = aci_vmm_domain.vds.id
  name                = var.hxv_e_vmm_controller.name
  annotation          = "orchestrator:terraform"
  dvs_version         = "unmanaged"
  host_or_ip          = var.hxv_e_vmm_controller.host_or_ip
  inventory_trig_st   = "autoTriggered"
  mode                = "default"
  port                = "0"
  root_cont_name      = var.hxv_e_vmm_controller.dc
  scope               = "vm"
  stats_mode          = "disabled"
  relation_vmm_rs_acc = aci_vmm_credential.HXVe-VMM-Credentials.id
}

resource "aci_vmm_credential" "HXVe-VMM-Credentials" {
  vmm_domain_dn = aci_vmm_domain.vds.id
  name          = var.hxv_e_vmm_controller.credentials
  annotation    = "orchestrator:terraform"
  pwd           = var.hxv_e_vmm_controller.pwd
  usr           = var.hxv_e_vmm_controller.usr
}

#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Provision vSwitch Policy Group for APIC <--> VMM Integraton 
#---------------------------------------------------------------------------------------------------


# Re-uses previously created under Fabric Access Policies for the vSwitch Policy Group
#resource "aci_v_switch_policy_group" "HXVe-VMM-vSwitch_PG" {
#  vmm_domain_dn  = aci_vmm_domain.vds.id
#  vmm_rs_vswitch_override_lldp_if_pol = aci_lldp_interface_policy.LLDP-Enabled.id
#  vmm_rs_vswitch_override_cdp_if_pol = aci_cdp_interface_policy.CDP-Enabled.id
  #vmm_rs_vswitch_override_lacp_pol = "NOT USED FOR HX EDGE"
#}
#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# Provision 2 uplinks on vDS created by APIC <--> VMM Integraton (uses REST API)
#---------------------------------------------------------------------------------------------------
#resource "aci_rest" "HXVe-VMM-vDS-Uplinks" {
#  path = "/api/node/mo/uni/vmmp-VMware/dom-$hxv_e_vmm_domain.name/uplinkpcont.json"
#  class_name = "uplinkpcont"
#  content = {
#    "annotation" : "orchestrator:terraform"
#   "numOfUplinks": "2"
#  }
#}