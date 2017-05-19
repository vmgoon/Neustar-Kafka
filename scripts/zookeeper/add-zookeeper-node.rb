#!/usr/bin/env ruby

require 'yaml'

server_id = ARGV[0]
host_name = ARGV[1]

OUTPUT_FILE = File.join('hiera', 'zookeeper_common.yaml')

if File.exists?(OUTPUT_FILE)
  settings = YAML.load_file(OUTPUT_FILE)
else
  settings = {
      'confluent::zookeeper::config' => {

      },
      'confluent::zookeeper::environment_settings' => {
          'KAFKA_HEAP_OPTS' => {
              'value' => '-Xmx4000M'
          }
      }
  }
end

server_settings = {
    "server.#{server_id}" => {
        'value' => "#{host_name}:2888:3888"
    }
}

settings['confluent::zookeeper::config'] = settings['confluent::zookeeper::config'].merge(server_settings)

zookeeper_hosts=[]
settings['confluent::zookeeper::config'].each do |key, value|
  inner_value = value['value']

  if inner_value =~ /^(.+):\d+:\d+$/
    zookeeper_hosts << "#{$1}:2181"
  end
end

settings['zookeeper::hosts'] = zookeeper_hosts

puts settings.to_yaml

File.write(OUTPUT_FILE, settings.to_yaml)