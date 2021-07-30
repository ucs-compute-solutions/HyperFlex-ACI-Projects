#----------------------------------------------------------------------------------------------------
# Modifies default QoS classes for HX Edge cluster to ensure higher bandwidth for each class.
# Configurable from Cisco APIC GUI at: "Fabric > Access Policies > Policies > Global > QOS Class".
# The storage data EPG for HX edge cluster is then mapped to Level 1 QoS class to ensure
# it receives a higher priority service. 
# 
# NOTE: 
#  - A native terraform resource is not available for this configuration - so REST API is used.
#  - !! Cisco highly recommends that you monitor the HX edge traffic to baseline and understand the 
#       the service requirements for all traffic hosted on the HX Edge cluster.
#  - !! Modifying the QoS classes impacts the entire ACI fabric and all traffic traversing the fabric
#  - !! Use with caution
#---------------------------------------------------------------------------------------------------

# QoS Class - Level 1 
resource "aci_rest" "rest_qos_class1_hx_edge" {
  path = "/api/node/mo/uni/infra/qosinst-default/class-level1/sched.json"
  class_name ="qosSched"
  content = {
    "annotation" : "orchestrator:terraform"
    "bw" : "25"
  }
}

# QoS Class - Level 2
resource "aci_rest" "rest_qos_class2_hx_edge" {
  path = "/api/node/mo/uni/infra/qosinst-default/class-level2/sched.json"
  class_name ="qosSched"
  content = {
    "annotation" : "orchestrator:terraform"
    "bw" : "25"
  }
}

# QoS Class - Level 3
resource "aci_rest" "rest_qos_class3_hx_edge" {
  path = "/api/node/mo/uni/infra/qosinst-default/class-level3/sched.json"
  class_name ="qosSched"
  content = {
    "annotation" : "orchestrator:terraform"
    "bw" : "20"
  }
}

# QoS Class - Level 4
resource "aci_rest" "rest_qos_class4_hx_edge" {
  path = "/api/node/mo/uni/infra/qosinst-default/class-level4/sched.json"
  class_name ="qosSched"
  content = {
    "annotation" : "orchestrator:terraform"
    "bw" : "6"
  }
}

# QoS Class - Level 5
resource "aci_rest" "rest_qos_class5_hx_edge" {
  path = "/api/node/mo/uni/infra/qosinst-default/class-level5/sched.json"
  class_name ="qosSched"
  content = {
    "annotation" : "orchestrator:terraform"
    "bw" : "6"
  }
}

# QoS Class - Level 6
resource "aci_rest" "rest_qos_class6_hx_edge" {
  path = "/api/node/mo/uni/infra/qosinst-default/class-level6/sched.json"
  class_name ="qosSched"
  content = {
    "annotation" : "orchestrator:terraform"
    "bw" : "6"
  }
}


#---------------------------------------------------------------------------------------------------