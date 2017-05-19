package { 'java-1.8.0-openjdk':
  ensure => installed,
}

file { '/etc/puppet/hiera':
  ensure => 'directory',
}
