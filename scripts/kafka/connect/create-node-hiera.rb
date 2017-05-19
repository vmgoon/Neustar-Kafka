#!/usr/bin/env ruby
require 'yaml'

server_id = ARGV[0]
broker_hosts = ARGV[1]
schema_registry_hosts = ARGV[2]

INPUT_FILE = File.join('hiera', 'zookeeper_common.yaml')
OUTPUT_FILE = File.join('hiera', "kafka-connect.#{server_id}.yaml")

settings = {
    'confluent::kafka::connect::distributed::config' => {
        'bootstrap.servers' => {
            'value' => broker_hosts
        },
        'key.converter' => {
            'value' => 'io.confluent.connect.avro.AvroConverter'
        },
        'value.converter' => {
            'value' => 'io.confluent.connect.avro.AvroConverter'
        },
        'key.converter.schema.registry.url' => {
            'value' => schema_registry_hosts
        },
        'value.converter.schema.registry.url' => {
            'value' => schema_registry_hosts
        },
    }
}

puts settings.to_yaml

puts "Writing #{OUTPUT_FILE}"
File.write(OUTPUT_FILE, settings.to_yaml)