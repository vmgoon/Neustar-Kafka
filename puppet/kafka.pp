include ::confluent::kafka::broker
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
file { '/data/kafka':
  ensure  => directory,
  owner   => 'kafka',
  group   => 'kafka',
  recurse => true,
  require => User['kafka'],
  before  => Service['kafka']
}

package{'confluent-rebalancer':
  before  => Service['kafka']
}