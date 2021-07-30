# -------------------------------------------------------------------------
#  Cisco APIC Access Info
# -------------------------------------------------------------------------
hxv_e_aci_apic = {
  usr = "admin"
  pwd = "<apic_pwd>"
  url = "https://<apic_hostname_or_ip>/"
  }

# -------------------------------------------------------------------------
#  Fabric Access Policies
# -------------------------------------------------------------------------

# HX Edge Infrastructure VLAN Pool name and IDs
hxv_e_infra_vlan_pool_name = "HXVe-Infra_VlanPool"
hxv_e_infra_ib_mgmt_vlan_id = "vlan-118"
hxv_e_infra_vmotion_vlan_id = "vlan-3018"
hxv_e_infra_stordata_cl0_vlan_id = "vlan-3318"

# Domain Name and Attachable Access Entity Profile for HX Edge nodes
hxv_e_phy_domain_name = "HXVe_PhyDomain"
hxv_e_aaep_name = "HXVe_AAEP"

# IPG and IPR for access ports that connect to HX Edge nodes
hxv_e_leaf_ipg_name = "HXVe-Leaf_IPG"
hxv_e_leaf_ipr_name = "HXVe_Leaf_IPR"

# Leaf switch module and ports tha connect to HX Edge nodes
hxv_e_leaf_port_selector_name = "HXVe-Leaf_ports"
hxv_e_from_module = "1"
hxv_e_from_port = "1"
hxv_e_to_module = "1"
hxv_e_to_port = "4"

# Switch Profile Parameters for Leaf switch(s) that connect to HX Edge nodes 
hxv_e_leaf_spr_name = "HXVe-Leaf_SPR"
hxv_e_leaf_switch_selector_name = "HXVe-Leaf_switches"
hxv_e_leaf_1_node_id = "151"
hxv_e_leaf_2_node_id = "152"

# Leaf Switch Ports that connect to HX nodes
hxv_e_leaf_ports = ["eth1/1","eth1/2","eth1/3","eth1/4" ]

# -------------------------------------------------------------------------
#  Infrastructure Tenant Configuration
# -------------------------------------------------------------------------

# Infrastructure Tenant 
hxv_e_infra_tenant_name = "HXV-E-Foundation"
hxv_e_infra_vrf_name = "HXV-E-Foundation_VRF"

hxv_e_infra_mgmt_bd_name = "HXVe-IB-MGMT_BD"
hxv_e_infra_vmotion_bd_name = "HXVe-vMotion_BD"
hxv_e_infra_stordata_cl0_bd_name = "HXVe-CL0-StorData_BD"

hxv_e_ib_mgmt_bd_subnet_ip = "10.9.167.254/24"

hxv_e_infra_mgmt_ap_name = "HXVe-IB-MGMT_AP"
hxv_e_infra_vmotion_ap_name = "HXVe-vMotion_AP"
hxv_e_infra_stordata_ap_name = "HXVe-StorData_AP"

hxv_e_infra_mgmt_epg_name = "HXVe-IB-MGMT_EPG"
hxv_e_infra_vmotion_epg_name = "HXVe-vMotion_EPG"
hxv_e_infra_stordata-cl0_epg_name = "HXVe-CL0-StorData_EPG"

hxv_e_l3out = {
  tenant_name = "common"
  name = "SharedL3Out-West-Pod1_RO"
  contract = "Allow-Shared-L3Out"
}
#-----------------------------------------------------------------------------------
# APIC <--> VMM Integration 
#-----------------------------------------------------------------------------------

hxv_e_vmm_domain = {
  provider_profile_dn = "uni/vmmp-VMware"
  name = "HXVe-vDS"
}

hxv_e_vmm_vlan_pool_name = "HXVe-VMM_VlanPool"
hxv_e_vmm_vlan_id_start = "vlan-3318"
hxv_e_vmm_vlan_id_end = "vlan-3328"

hxv_e_vmm_controller = {
  name = "HXVe-VMM-vCenter"
  credentials = "HXVe-Administrator"
  host_or_ip = "10.99.167.240"
  usr = "administrator@hxv.com"
  pwd = "H1ghV0lt!"
  dc = "HX-E-ACI"
}

#-----------------------------------------------------------------------------------
# VMware vSphere Configuration done via VMware vCenter
#-----------------------------------------------------------------------------------
hxv_e_vmware_vcenter = {
  vsphere_usr = "administrator@hxv.com"
  vsphere_pwd = "<vsphere_pwd>"
  vsphere_server_ip = "<vsphere_server_ip>"
  dc_name = "HX-E-ACI"
  }

hxv_e_vmware_esxi_hosts = [
    "10.9.167.11",
    "10.9.167.12",
    "10.9.167.13",
    "10.9.167.14"
]

hxv_e_vmware_vmotion_vswitch = {
  name = "vmotion"
  network_adapters = ["vmnic8", "vmnic9"]
  active_nics = ["vmnic8"]
  standby_nics = ["vmnic9"]
  vmotion_pg_name = "vmotion-pg"
  vmotion_vlan_id = "3018"
  vmotion_vmk_ip_prefix = "172.0.167."
  vmotion_vmk_ip_netmask = "255.255.255.0"
  vmotion_vmk_gw = "172.0.167.254"
  vmotion_vmk_netstack = "vmotion"
}

hxv_e_vmware_vm_network_vswitch_name = "vswitch-hx-vm-network"

# -------------------------------------------------------------------------
#  Application Tenant Configuration
# -------------------------------------------------------------------------
#Application Tenant
#HXV-E-App-Tenant1_Name = "HXV-E-App1"
#HXV-E-App-VRF1_Name = "HXV-E-App1_VRF"





