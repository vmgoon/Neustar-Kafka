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

}

variable "environment_name" {
  description = "The name of the environment for this cluster."
}

variable "template_name" {

}

variable "ssh_username" {}

variable "ssh_password" {}

variable "zookeeper_memory_mb" {
  default = 8192
}

variable "zookeeper_vcpu_count" {
  default = 2
}

variable "broker_memory_mb" {
  default = 16384
}

variable "broker_vcpu_count" {
  default = 4
}

variable "schema_registry_memory_mb" {
  default = 4096
}

variable "schema_registry_vcpu_count" {
  default = 2
}

variable "kafka_connect_memory_mb" {
  default = 8192
}

variable "kafka_connect_vcpu_count" {
  default = 2
}


variable "control_center_memory_mb" {
  default = 8192
}

variable "control_center_vcpu_count" {
  default = 2
}