provider "vsphere" {
  vsphere_server = "${var.vcenter_server}"
  password = "${var.vcenter_password}"
  user = "${var.vcenter_username}"
  allow_unverified_ssl = true
}

resource "vsphere_folder" "confluent_folder" {
  datacenter = "${var.vcenter_datacenter}"
  path = "confluent"
}

resource "vsphere_folder" "environment_folder" {
  datacenter = "${var.vcenter_datacenter}"
  path = "${vsphere_folder.confluent_folder.path}/${var.environment_name}"
}

resource "vsphere_folder" "kafka_folder" {
  datacenter = "${var.vcenter_datacenter}"
  path = "${vsphere_folder.environment_folder.path}/kafka"
}

resource "vsphere_folder" "kafka_connect_folder" {
  datacenter = "${var.vcenter_datacenter}"
  path = "${vsphere_folder.kafka_folder.path}/connect"
}

resource "vsphere_folder" "zookeeper_folder" {
  datacenter = "${var.vcenter_datacenter}"
  path = "${vsphere_folder.environment_folder.path}/zookeeper"
}

resource "vsphere_folder" "schema_registry_folder" {
  datacenter = "${var.vcenter_datacenter}"
  path = "${vsphere_folder.environment_folder.path}/schema-registry"
}

resource "vsphere_virtual_machine" "zookeeper" {
  count = 3
  folder = "${vsphere_folder.zookeeper_folder.path}"
  datacenter = "${var.vcenter_datacenter}"
  "disk" {
    datastore = "${var.vcenter_datastore}"
    template = "${var.template_name}"
    type = "thin"
  }
  memory = "${var.zookeeper_memory_mb}"
  name = "${var.environment_name}-zookeeper-${format("%03d", count.index+1)}"
  domain = "${var.domain_name}"
  "network_interface" {
    label = "${var.vcenter_default_network}",
  }
  vcpu = "${var.zookeeper_vcpu_count}"

  provisioner "file" {
    source = "puppet/initial.pp"
    destination = "/tmp/initial.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${self.name}.${self.domain}",
    ]
  }

  provisioner "file" {
    source = "hiera/hiera.yaml"
    destination = "/etc/puppet/hiera.yaml"
  }

  provisioner "local-exec" {
    command = "./scripts/zookeeper/add-zookeeper-node.rb ${count.index} ${self.network_interface.0.ipv4_address}"
  }

  provisioner "file" {
    source = "puppet/zookeeper.pp"
    destination = "/tmp/zookeeper.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/initial.pp",
    ]
  }

  provisioner "local-exec" {
    command = "./scripts/zookeeper/create-node-hiera.rb ${count.index}"
  }

  provisioner "file" {
    source = "hiera/zookeeper.${count.index}.yaml"
    destination = "/etc/puppet/hiera/common.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/zookeeper.pp",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    password = "${var.ssh_password}"
  }
}



data "template_file" "zookeeper_hosts" {
  template = "$${zookeeper_ips}"
  vars {
    zookeeper_ips = "${join(",", formatlist("%s:2181", vsphere_virtual_machine.zookeeper.*.network_interface.0.ipv4_address))}"
  }
}

resource "vsphere_virtual_machine" "broker" {
  count = 5
  folder = "${vsphere_folder.kafka_folder.path}"
  datacenter = "${var.vcenter_datacenter}"
  "disk" {
    datastore = "${var.vcenter_datastore}"
    template = "${var.template_name}"
    type = "thin"
  }
  "disk" {
    datastore = "${var.vcenter_datastore}"
    size = 100,
    type = "thin"
    name = "${format("broker-%02d", count.index + 1)}-data.vmdk"
  }
  memory = "${var.broker_memory_mb}"
  name = "${var.environment_name}-broker-${format("%03d", count.index+1)}"
  domain = "${var.domain_name}"
  "network_interface" {
    label = "${var.vcenter_default_network}",
  }
  vcpu = "${var.broker_vcpu_count}"

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${self.name}.${self.domain}",
    ]
  }

  provisioner "file" {
    source = "puppet/initial.pp"
    destination = "/tmp/initial.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/initial.pp",
    ]
  }

  provisioner "file" {
    source = "hiera/hiera.yaml"
    destination = "/etc/puppet/hiera.yaml"
  }

  provisioner "local-exec" {
    command = "./scripts/kafka/create-node-hiera.rb ${count.index} '${data.template_file.zookeeper_hosts.rendered}'"
  }

  // Init must run before we can transfer over the file.
  provisioner "file" {
    source = "hiera/kafka.${count.index}.yaml"
    destination = "/etc/puppet/hiera/common.yaml"
  }

  provisioner "file" {
    source = "puppet/kafka.pp"
    destination = "/tmp/kafka.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/kafka.pp",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    password = "${var.ssh_password}"
  }
}

data "template_file" "broker_hosts" {
  template = "$${broker_ips}"
  vars {
    broker_ips = "${join(",", formatlist("%s:9092", vsphere_virtual_machine.broker.*.network_interface.0.ipv4_address))}"
  }
}


resource "vsphere_virtual_machine" "schema_registry" {
  count = 2
  folder = "${vsphere_folder.schema_registry_folder.path}"
  datacenter = "${var.vcenter_datacenter}"
  "disk" {
    datastore = "${var.vcenter_datastore}"
    template = "${var.template_name}"
    type = "thin"
  }
  memory = "${var.schema_registry_memory_mb}"
  name = "${var.environment_name}-schema-registry-${format("%03d", count.index+1)}"
  domain = "${var.domain_name}"
  "network_interface" {
    label = "${var.vcenter_default_network}",
  }
  vcpu = "${var.schema_registry_vcpu_count}"

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${self.name}.${self.domain}",
    ]
  }

  provisioner "file" {
    source = "puppet/initial.pp"
    destination = "/tmp/initial.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/initial.pp",
    ]
  }

  provisioner "file" {
    source = "hiera/hiera.yaml"
    destination = "/etc/puppet/hiera.yaml"
  }

  provisioner "local-exec" {
    command = "./scripts/schema-registry/create-node-hiera.rb ${count.index} '${data.template_file.zookeeper_hosts.rendered}'"
  }

  provisioner "file" {
    source = "puppet/initial.pp"
    destination = "/tmp/initial.pp"
  }

  // Init must run before we can transfer over the file.
  provisioner "file" {
    source = "hiera/schema-registry.${count.index}.yaml"
    destination = "/etc/puppet/hiera/common.yaml"
  }

  provisioner "file" {
    source = "puppet/schema-registry.pp"
    destination = "/tmp/schema-registry.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/schema-registry.pp",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    password = "${var.ssh_password}"
  }
}

data "template_file" "schema_registry_urls" {
  template = "$${schema_registry_ips}"
  vars {
    schema_registry_ips = "${join(",", formatlist("http://%s:8081", vsphere_virtual_machine.schema_registry.*.network_interface.0.ipv4_address))}"
  }
}

resource "vsphere_virtual_machine" "kafka_connect" {
  count = 2
  folder = "${vsphere_folder.kafka_connect_folder.path}"
  datacenter = "${var.vcenter_datacenter}"
  "disk" {
    datastore = "${var.vcenter_datastore}"
    template = "${var.template_name}"
    type = "thin"
  }
  memory = "${var.kafka_connect_memory_mb}"
  name = "${var.environment_name}-kafka-connect-${format("%03d", count.index+1)}"
  domain = "${var.domain_name}"
  "network_interface" {
    label = "${var.vcenter_default_network}",
  }
  vcpu = "${var.kafka_connect_vcpu_count}"

  provisioner "file" {
    source = "puppet/initial.pp"
    destination = "/tmp/initial.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${self.name}.${self.domain}",
    ]
  }

  provisioner "file" {
    source = "hiera/hiera.yaml"
    destination = "/etc/puppet/hiera.yaml"
  }

  provisioner "local-exec" {
    command = "./scripts/kafka/connect/create-node-hiera.rb ${count.index} '${data.template_file.broker_hosts.rendered}' '${data.template_file.schema_registry_urls.rendered}'"
  }

  // Init must run before we can transfer over the file.
  provisioner "file" {
    source = "hiera/kafka-connect.${count.index}.yaml"
    destination = "/etc/puppet/hiera/common.yaml"
  }

  provisioner "file" {
    source = "puppet/kafka-connect.pp"
    destination = "/tmp/kafka-connect.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/kafka-connect.pp",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    password = "${var.ssh_password}"
  }
}

data "template_file" "kafka_connect_hosts" {
  template = "$${schema_registry_ips}"
  vars {
    schema_registry_ips = "${join(",", formatlist("%s:8083", vsphere_virtual_machine.kafka_connect.*.network_interface.0.ipv4_address))}"
  }
}


resource "vsphere_virtual_machine" "control_center" {
  count = 1
  folder = "${vsphere_folder.environment_folder.path}"
  datacenter = "${var.vcenter_datacenter}"
  "disk" {
    datastore = "${var.vcenter_datastore}"
    template = "${var.template_name}"
    type = "thin"
  }
  memory = "${var.control_center_memory_mb}"
  name = "${var.environment_name}-control-center-${format("%03d", count.index+1)}"
  domain = "${var.domain_name}"
  "network_interface" {
    label = "${var.vcenter_default_network}",
  }
  vcpu = "${var.control_center_vcpu_count}"

  provisioner "file" {
    source = "puppet/initial.pp"
    destination = "/tmp/initial.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${self.name}.${self.domain}",
    ]
  }

  provisioner "file" {
    source = "hiera/hiera.yaml"
    destination = "/etc/puppet/hiera.yaml"
  }

  provisioner "local-exec" {
    command = "./scripts/control-center/create-node-hiera.rb ${count.index} '${data.template_file.zookeeper_hosts.rendered}' '${data.template_file.broker_hosts.rendered}' '${data.template_file.kafka_connect_hosts.rendered}'"
  }

  // Init must run before we can transfer over the file.
  provisioner "file" {
    source = "hiera/control-center.${count.index}.yaml"
    destination = "/etc/puppet/hiera/common.yaml"
  }

  provisioner "file" {
    source = "puppet/control-center.pp"
    destination = "/tmp/control-center.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply /tmp/control-center.pp",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    password = "${var.ssh_password}"
  }
}