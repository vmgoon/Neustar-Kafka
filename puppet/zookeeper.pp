include ::confluent::zookeeper

service{'firewalld':
  ensure => stopped,
  enable => false
}

Package['confluent-kafka-2.11'] -> Service['zookeeper']