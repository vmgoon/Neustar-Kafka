#!/usr/bin/env ruby
require 'yaml'

server_id = ARGV[0]
zookeeper_hosts = ARGV[1]
broker_hosts = ARGV[2]
connect_hosts = ARGV[3]

INPUT_FILE = File.join('hiera', 'zookeeper_common.yaml')
OUTPUT_FILE = File.join('hiera', "control-center.#{server_id}.yaml")

settings = {
    'confluent::control::center::config' => {
        'zookeeper.connect' => {
          'value' => zookeeper_hosts
        },
        'bootstrap.servers' => {
          'value' => broker_hosts
        },
        'confluent.controlcenter.connect.cluster' => {
          'value' => connect_hosts
        }
    }
}

puts settings.to_yaml

File.write(OUTPUT_FILE, settings.to_yaml)