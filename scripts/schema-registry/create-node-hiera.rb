#!/usr/bin/env ruby
require 'yaml'

server_id = ARGV[0]
zookeeper_hosts = ARGV[1]

INPUT_FILE = File.join('hiera', 'zookeeper_common.yaml')
OUTPUT_FILE = File.join('hiera', "schema-registry.#{server_id}.yaml")

zookeeper_settings = YAML.load_file(INPUT_FILE)

settings = {
    'confluent::kafka::broker::broker_id' => server_id,
    'confluent::schema::registry::config' => {
        'kafkastore.connection.url' => {
            'value' => zookeeper_hosts
        },
    },
}

puts settings.to_yaml

puts "Writing #{OUTPUT_FILE}"
File.write(OUTPUT_FILE, settings.to_yaml)