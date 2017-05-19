#!/usr/bin/env ruby

require 'yaml'

server_id = ARGV[0]

INPUT_FILE = File.join('hiera', 'zookeeper_common.yaml')
OUTPUT_FILE = File.join('hiera', "zookeeper.#{server_id}.yaml")

settings = YAML.load_file(INPUT_FILE)

settings['confluent::zookeeper::zookeeper_id'] = server_id
settings.delete('zookeeper::hosts')
puts settings.to_yaml

puts "Writing #{OUTPUT_FILE}"
File.write(OUTPUT_FILE, settings.to_yaml)