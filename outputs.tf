output "control_center_url" {
  value = "${join(",", formatlist("http://%s:9021", vsphere_virtual_machine.control_center.*.network_interface.0.ipv4_address))}"
}
output "zookeeper.connect" {
  value = "${data.template_file.zookeeper_hosts.rendered}"
}
output "bootstrap.servers" {
  value = "${data.template_file.broker_hosts.rendered}"
}

output "kafka_connect.key.converter" {
  value = "io.confluent.connect.avro.AvroConverter"
}
output "kafka_connect.value.converter" {
  value = "io.confluent.connect.avro.AvroConverter"
}
output "kafka_connect.key.converter.schema.registry.url" {
  value = "${data.template_file.schema_registry_urls.rendered}"
}
output "kafka_connect.value.converter.schema.registry.url" {
  value = "${data.template_file.schema_registry_urls.rendered}"
}

output "kafka_producer.key.serializer" {
  value = "io.confluent.kafka.serializers.KafkaAvroSerializer"
}
output "kafka_producer.key.serializer.schema.registry.url" {
  value = "${data.template_file.schema_registry_urls.rendered}"
}
output "kafka_producer.value.serializer" {
  value = "io.confluent.kafka.serializers.KafkaAvroSerializer"
}
output "kafka_producer.value.serializer.schema.registry.url" {
  value = "${data.template_file.schema_registry_urls.rendered}"
}

output "z_kafka-avro-console-consumer" {
  value = "kafka-avro-console-consumer --new-consumer --bootstrap-server ${data.template_file.broker_hosts.rendered} --property schema.registry.url=${data.template_file.schema_registry_urls.rendered} --topic <topic name>"
}


