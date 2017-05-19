output "broker_public_ips" {
  value = ["${vsphere_virtual_machine.broker.*.network_interface/ipv4_address}"]
}