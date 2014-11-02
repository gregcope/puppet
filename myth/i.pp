# reset network config
# let the network restart script know we've changed
file { '/etc/network/interfaces':
  ensure => 'present',
  owner => 'root',
  group => 'root',
  mode => '0644',
  content => "auto lo\niface lo inet loopback\n\tauto eth0\niface eth0 inet static\n\taddress 192.168.0.6\n\tnetmask 255.255.255.0\n\tnetwork 192.168.0.0\n\tbroadcast 192.168.0.255\n\tgateway 192.168.0.1\ndns-nameservers 208.67.220.220 208.67.222.222",
  notify => Exec['restarteth0'],
}

# restart network if we need to
exec { 'restarteth0':
  logoutput => true,
  command => '/sbin/ifdown eth0 && /sbin/ifup eth0',
  refreshonly => true
}

# remove some nasty ubuntu stuff we do not want/need
package { 'network-manager': ensure => 'absent' }
package { 'isc-dhcp-client': ensure => 'absent' }
package { 'isc-dhcp-common': ensure => 'absent' }
