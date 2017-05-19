include ::confluent::kafka::broker
package{'parted':
  ensure => latest
} ->
file { '/data':
  ensure => directory
} ->
file { '/data/kafka':
  ensure  => directory,
  require => User['kafka'],
} -> exec{'parted /dev/sdb --script -- mklabel gpt\ mkpart primary ext4 0 -1':
  unless => '/sbin/blkid -t TYPE=ext4 /dev/sdb1',
  path   => ['/bin', '/sbin']
} ->
exec { 'mkfs.ext4 -m 0 /dev/sdb1':
  unless => '/sbin/blkid -t TYPE=ext4 /dev/sdb1',
  path   => ['/bin', '/sbin']
} -> mount { '/data/kafka':
  ensure  => 'mounted',
  device  => '/dev/sdb',
  fstype  => 'ext4',
  options => 'noatime',
  target  => '/etc/fstab',
  before  => Service['kafka']
}