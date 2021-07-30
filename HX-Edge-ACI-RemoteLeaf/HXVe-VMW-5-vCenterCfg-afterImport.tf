
#----------------------------------------------------------------------------------------------------
# This plan is for VMware vSphere configuration done via VMware vCenter.
# It is only necessary for changing the default setup deployed by Intersight HX edge installer. 
# The changes made in this plan are for:
# - configuring vMotion uplinks, port-group and VMKernel port (or use HX post-installer script)
# - migrating default vSwitch for VM networks deployed by HX installer to VMware vDS. This is done by 
#   importing the default 'hx-vm-network' vSwitch into terraform, removing the uplinks, and then 
#   using those uplinks on the vDS switch deployed buring APIC <--> VMM Integration
#----------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------
# Configure 'vmotion' vSwitch deployed Intersight HX Edge Installer - deployed on each host 
#----------------------------------------------------------------------------------------------------

# Import the 'vmotion' vSwitch deployed by Intersight HX Edge Installer
# Note: You must import vSwitch for each host individually using vmware host-id for the ESXi host 
# -> From VMware vCenter GUI, browse to Hosts and select host and ID will be in the URL
# Importing is necessary to make configuration changes from terraform
# Terraform will now manage 'vmotion' vswitch originally deployed by Intersight HX Edge Installer
#
# After IMPORT of vMotion vSwitch
#
# Configure uplinks on the 'vmotion' vswitch that was imported into Terraform
resource "vsphere_host_virtual_switch" "vmotion" {
  count            = "${length(var.hxv_e_vmware_esxi_hosts)}"
  name             = var.hxv_e_vmware_vmotion_vswitch.name
  host_system_id   = "${data.vsphere_host.host[count.index].id}"
  network_adapters = var.hxv_e_vmware_vmotion_vswitch.network_adapters
  active_nics      = var.hxv_e_vmware_vmotion_vswitch.active_nics
  standby_nics     = var.hxv_e_vmware_vmotion_vswitch.standby_nics
}

# resource "vsphere_host_port_group" "vmotion-pg" {}
resource "vsphere_host_port_group" "vmotion-pg" {
  count                = "${length(var.hxv_e_vmware_esxi_hosts)}"
  name                 = var.hxv_e_vmware_vmotion_vswitch.vmotion_pg_name
  vlan_id              = var.hxv_e_vmware_vmotion_vswitch.vmotion_vlan_id
  host_system_id       = "${data.vsphere_host.host[count.index].id}"
  virtual_switch_name  = vsphere_host_virtual_switch.vmotion[count.index].name
}

resource "vsphere_vnic" "vmk2" {
  count     = "${length(var.hxv_e_vmware_esxi_hosts)}"
  host      = "${data.vsphere_host.host[count.index].id}"
  portgroup = vsphere_host_port_group.vmotion-pg[count.index].name
  ipv4 {
    ip      = "${var.hxv_e_vmware_vmotion_vswitch.vmotion_vmk_ip_prefix}${count.index + 11}"
    netmask = var.hxv_e_vmware_vmotion_vswitch.vmotion_vmk_ip_netmask
    gw      = var.hxv_e_vmware_vmotion_vswitch.vmotion_vmk_gw
  }
  #netstack  = "vmotion"
  netstack  = var.hxv_e_vmware_vmotion_vswitch.vmotion_vmk_netstack
}

#--------------------------------------------------------------------------------------------------
# Remove uplinks from 'vswitch-hx-vm-network' vswitch created by Intersight HX Edge Installer  
#--------------------------------------------------------------------------------------------------


# After IMPORT of VM Network vSwitch
resource "vsphere_host_virtual_switch" "vswitch-hx-vm-network" {
  count         = "${length(var.hxv_e_vmware_esxi_hosts)}"
  name          = var.hxv_e_vmware_vm_network_vswitch_name 
  network_adapters = [ ]
  active_nics  = [ ]
  standby_nics = [ ]
  host_system_id = "${data.vsphere_host.host[count.index].id}"
}

