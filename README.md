

## Configure your environment

You need to fill out this information.

```hcl-terraform
vcenter_server = 
vcenter_username = 
vcenter_password = 
vcenter_datacenter = 
template_name = 
environment_name = 
vcenter_default_network = 
vcenter_cluster = 
vcenter_datastore = 
domain_name = 
ssh_username = 
ssh_password = 
```

## Save the output!

At the end of the run you will see something like the example below. This is your configuration to connect to your new cluster.

```
bootstrap.servers = 10.10.1.206:9092,10.10.1.200:9092,10.10.1.199:9092,10.10.1.198:9092,10.10.1.195:9092
control_center_url = http://10.10.1.209:9021
kafka_connect.key.converter = io.confluent.connect.avro.AvroConverter
kafka_connect.key.converter.schema.registry.url = http://10.10.1.196:8081,http://10.10.1.197:8081
kafka_connect.value.converter = io.confluent.connect.avro.AvroConverter
kafka_connect.value.converter.schema.registry.url = http://10.10.1.196:8081,http://10.10.1.197:8081
kafka_producer.key.serializer = io.confluent.kafka.serializers.KafkaAvroSerializer
kafka_producer.key.serializer.schema.registry.url = http://10.10.1.196:8081,http://10.10.1.197:8081
kafka_producer.value.serializer = io.confluent.kafka.serializers.KafkaAvroSerializer
kafka_producer.value.serializer.schema.registry.url = http://10.10.1.196:8081,http://10.10.1.197:8081
z_kafka-avro-console-consumer = kafka-avro-console-consumer --new-consumer --bootstrap-server 10.10.1.206:9092,10.10.1.200:9092,10.10.1.199:9092,10.10.1.198:9092,10.10.1.195:9092 --property schema.registry.url=http://10.10.1.196:8081,http://10.10.1.197:8081 --topic <topic name>
zookeeper.connect = 10.10.1.193:2181,10.10.1.194:2181,10.10.1.192:2181
```