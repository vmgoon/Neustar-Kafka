variable "vcenter_server" {
  description = "Host running VmWare VCenter"
}

variable "vcenter_username" {
  description = "Username to connect with VCenter with."
}

variable "vcenter_password" {
  description = "Password to connect with VCenter with."
}

variable "vcenter_datacenter" {
  description = "Datacenter in VSphere"
}

variable "vcenter_cluster" {
  description = "Cluster in vsphere"
}

variable "vcenter_datastore" {
  description = "Datastore to store things on"
}

variable "vcenter_default_network" {
  description = "Network to attach the virtual machines to"
}

variable "domain_name" {
  description = "The DNS domain name for instances."
}

variable "environment_name" {
  description = "The name of the environment for this cluster."
}

variable "template_name" {
  description = "The name of the template in vsphere"
}

variable "ssh_username" {
  description = "The username to ssh to the instance with."
}

variable "ssh_password" {
  description = "The password to ssh to the instance with."
}

variable "zookeeper_memory_mb" {
  default = 8192
  description = "The amount of memory in mb to allocate to zookeeper instances."
}

variable "zookeeper_vcpu_count" {
  default = 2,
  description = "The number of vcpu(s) to allocate to zookeeper instances."
}

variable "broker_memory_mb" {
  default = 16384
  description = "The amount of memory in mb to allocate to broker instances."
}

variable "broker_vcpu_count" {
  default = 4
  description = "The number of vcpu(s) to allocate to broker instances."
}

variable "schema_registry_memory_mb" {
  default = 4096
  description = "The amount of memory in mb to allocate to schema registry instances."
}

variable "schema_registry_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to schema registry instances."
}

variable "kafka_connect_memory_mb" {
  default = 8192
  description = "The amount of memory in mb to allocate to kafka connect instances."
}

variable "kafka_connect_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to kafka connect instances."
}


variable "control_center_memory_mb" {
  default = 8192
  description = "The number of vcpu(s) to allocate to control center instances."
}

variable "control_center_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to control center instances."
}