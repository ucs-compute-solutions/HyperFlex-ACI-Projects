provider "vsphere" {
  user           = var.hxv_e_vmware_vcenter.vsphere_usr
  password       = var.hxv_e_vmware_vcenter.vsphere_pwd
  vsphere_server = var.hxv_e_vmware_vcenter.vsphere_server_ip

  # if using a self-signed cert
  allow_unverified_ssl = true
}

#----------------------------------------------------------------------------------------------------
# This plan is for VMware vSphere configuration done via VMware vCenter.
# It is only necessary for changing the default setup deployed by Intersight HX edge installer. 
# The changes made in this plan are for:
# - configuring vMotion uplinks, port-group and VMKernel port (or use HX post-installer script)
# - migrating default vSwitch for VM networks deployed by HX installer to VMware vDS. This is done by 
#   importing the default 'hx-vm-network' vSwitch into terraform, removing the uplinks, and then 
#   using those uplinks on the vDS switch deployed buring APIC <--> VMM Integration
#----------------------------------------------------------------------------------------------------

# Read in the vsphere data center info where the HX Edge cluster is deployed
data "vsphere_datacenter" "HX-E-ACI" {
  name = var.hxv_e_vmware_vcenter.dc_name
}

#----------------------------------------------------------------------------------------------------
# Configure 'vmotion' vSwitch deployed Intersight HX Edge Installer - deployed on each host 
#----------------------------------------------------------------------------------------------------

data "vsphere_host" "host" {
  count           = "${length(var.hxv_e_vmware_esxi_hosts)}"
  name            = "${var.hxv_e_vmware_esxi_hosts[count.index]}"
  datacenter_id   = "${data.vsphere_datacenter.HX-E-ACI.id}"
}
# Import the 'vmotion' vSwitch deployed by Intersight HX Edge Installer
# Note: You must import vSwitch for each host individually using vmware host-id for the ESXi host 
# -> From VMware vCenter GUI, browse to Hosts and select host and ID will be in the URL
# Importing is necessary to make configuration changes from terraform
# Terraform will now manage 'vmotion' vswitch originally deployed by Intersight HX Edge Installer
#
# READ !!!!
# Uncomment the line below for Importing the vSwitch 
# 
#resource "vsphere_host_virtual_switch" "vmotion" {}
#
# READ !!!!
# Re-comment the above line after import and configure uplinks for the vMotion switch as follows
#
# The remaining configurations are done after importing the vMotion switch
#

#--------------------------------------------------------------------------------------------------
# Remove uplinks from 'vswitch-hx-vm-network' vswitch created by Intersight HX Edge Installer  
#--------------------------------------------------------------------------------------------------

# Import the 'vswitch-hx-vm-network' vSwitch deployed by Intersight HX Edge Installer
# Importing is necessary to make configuration changes from terraform
# Terraform will now manage 'vswitch-hx-vm-network' vswitch originally deployed by Intersight 
# HX Edge Installer but note that it will not be used and can be destroyed. VMware vDS deployed 
# during APIC <---> VMM integration will be used and APIC will manage that vDS
#
# Uncomment the line below for Importing the vSwitch 
# READ !!!!
#
#resource "vsphere_host_virtual_switch" "vswitch-hx-vm-network" {}
#
# READ !!!!
# Re-comment the above line after import and remove uplinks for the vswitch as follows
# 
# 



