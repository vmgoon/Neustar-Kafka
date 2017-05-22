package { 'java-1.8.0-openjdk':
  ensure => installed,
}

file { '/etc/puppet/hiera':
  ensure => 'directory',
} ->
file {'/etc/puppet/hiera.yaml':
  ensure => present,
  content => '---
:backends:
  - yaml
:yaml:
  :datadir: "/etc/puppet/hiera"
:hierarchy:
  - "common"'
}

service{'firewalld':
  ensure => stopped,
  enable => false
}