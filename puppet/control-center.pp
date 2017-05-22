include ::confluent::control::center

package { 'parted':
  ensure => latest
} ->
file { '/data':
  ensure => directory
} ->
exec { 'parted /dev/sdb --script -- mklabel gpt\ mkpart primary ext4 0 -1':
  unless => '/sbin/blkid -t TYPE=ext4 /dev/sdb1',
  path   => ['/bin', '/sbin']
} ->
exec { 'mkfs.ext4 -m 0 /dev/sdb1':
  unless => '/sbin/blkid -t TYPE=ext4 /dev/sdb1',
  path   => ['/bin', '/sbin']
} -> mount { '/data':
  ensure  => 'mounted',
  device  => '/dev/sdb1',
  fstype  => 'ext4',
  options => 'noatime',
  target  => '/etc/fstab',
} ->
file { '/data/control-center':
  ensure  => directory,
  owner   => 'control-center',
  group   => 'control-center',
  recurse => true,
  require => User['control-center'],
  before  => Service['control-center']
}

# Exec['kafka-systemctl-daemon-reload'] -> Service['control-center']