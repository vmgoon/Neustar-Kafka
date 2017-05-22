#!/usr/bin/env ruby
require 'yaml'

server_id = ARGV[0]
broker_ip = ARGV[1]
zookeeper_hosts = ARGV[2]

INPUT_FILE = File.join('hiera', 'zookeeper_common.yaml')
OUTPUT_FILE = File.join('hiera', "kafka.#{server_id}.yaml")

zookeeper_settings = YAML.load_file(INPUT_FILE)

settings = {
    'confluent::kafka::broker::broker_id' => server_id,
    'confluent::kafka::broker::config' => {
        'zookeeper.connect' => {
            'value' => zookeeper_hosts
        },
        'log.dirs' => {
            'value' => '/data/kafka'
        },
        'auto.create.topics.enable' => {
            'value' => false
        },
        'advertised.listeners' => {
            'value' => "PLAINTEXT://#{broker_ip}:9092"
        },
        'metric.reporters' => {
            'value' => 'io.confluent.metrics.reporter.ConfluentMetricsReporter'
        },
        'confluent.metrics.reporter.bootstrap.servers' => {
            'value' => 'localhost:9092'
        },
        'confluent.metrics.reporter.zookeeper.connect' => {
            'value' => zookeeper_hosts
        }
    },
    'confluent::kafka::broker::environment_settings' => {
        'KAFKA_HEAP_OPTS' => {
            'value' => '-Xmx8192M'
        }
    }
}

puts settings.to_yaml

puts "Writing #{OUTPUT_FILE}"
File.write(OUTPUT_FILE, settings.to_yaml)