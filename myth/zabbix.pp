$zabbixversion='2.2'
$discovery_disk.pl_sha='cb7d986b707f40ca0affa52de2b5a39b8365ac6d'
#
# Should be called as;
#
# sudo facter_zabbixmysqlpassword='PUTYOURPASSWORDHERE' puppet apply zabbix.pp
# 
# to find your zabbic password
# sudo grep 'dbc_dbpass=' /etc/dbconfig-common/zabbix-server-mysql.conf 
#
#
# install based on
# https://www.zabbix.com/documentation/2.2/manual/installation/install_from_packages#debianubuntu
#
# Done
# Install Zabbix
#
# 
#
# To do
# Config Zabbix for an ubuntu host
# Config Myth
# Config Apache
# http://blog.zabbix.com/zabbix-2-2-features-part-6-returning-values-from-webpages/2256/
# http://blog.zzservers.com/2010/04/zabbix-ossec-open-source-compliance-and-security-monitoring/
#lsbdistcodename facter for precise
#fqdn is facter for full hostname

# add the zabbix Apt config files
# if they have not already been added
exec { 'addZabbixAptConfig':
    logoutput => true,
    command => '/usr/bin/wget --quiet http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+precise_all.deb && dpkg  --install zabbix-release_2.2-1+precise_all.deb',
    unless => '/usr/bin/dpkg --get-selections | grep zabbix',
}

# install server packages
package { 'zabbix-server-mysql': }
package { 'zabbix-frontend-php': } 

# what ever the post_max_size make it 16M
exec { 'phppost_max_size':
    command => '/usr/bin/perl -p -i -e "s/post_max_size =.*/post_max_size = 16M/g" /etc/php5/apache2/php.ini',
    unless => '/bin/grep "^post_max_size = 16M" /etc/php5/apache2/php.ini',
    notify => Exec[ 'restart-apache2' ],   
    require => [ Package [ 'apache2' ], Package [ 'php5' ], Package [ 'libapache2-mod-php5' ] ],
}

# what ever the max_execution_time make it 300
exec { 'phpmax_execution_time':
    command => '/usr/bin/perl -p -i -e "s/max_execution_time =.*/max_execution_time = 300/g" /etc/php5/apache2/php.ini',
    unless => '/bin/grep "^max_execution_time = 300" /etc/php5/apache2/php.ini',
    notify => Exec[ 'restart-apache2' ],   
    require => [ Package [ 'apache2' ], Package [ 'php5' ], Package [ 'libapache2-mod-php5' ] ],
}

# what ever the max_execution_time make it 300
exec { 'phpmax_input_time':
   command => '/usr/bin/perl -p -i -e "s/max_input_time =.*/max_input_time = 300/g" /etc/php5/apache2/php.ini',
   unless => '/bin/grep "^max_input_time = 300" /etc/php5/apache2/php.ini',
   notify => Exec[ 'restart-apache2' ],          
   require => [ Package [ 'apache2' ], Package [ 'php5' ], Package [ 'libapache2-mod-php5' ] ],
}

# what ever the date.timezone is change it to facter timezone
exec { 'phpdate_timezone':
    command => "/usr/bin/perl -p -i -e 's/.*date.timezone =.*/date.timezone = $timezone/g' /etc/php5/apache2/php.ini",
    unless => "/bin/grep '^date.timezone = $timezone' /etc/php5/apache2/php.ini",
    notify => Exec[ 'restart-apache2' ],
    require => [ Package [ 'apache2' ], Package [ 'php5' ], Package [ 'libapache2-mod-php5' ] ],
}

# restart apache if called
exec { 'restart-apache2':
    command => '/usr/sbin/service apache2 restart',
    refreshonly => true,
    logoutput => true,
    require => Package [ 'apache2' ]
}

# some sensible things to make sure are installed for php
package { 'php5': }
package { 'apache2': }
package { 'libapache2-mod-php5': }

# install agent
package { 'zabbix-agent': }

package { 'zabbix-get': }

# zabbix agent mysql needs a .my.cnf to connect to the DB
# Ubuntu config has /var/lib/zabbix as zabbix HOME dir which does not exist!!!
# in /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf ... go figure
file { '/var/lib/zabbix/.my.cnf': 
    ensure => present,
    mode => '0600',
    owner => 'zabbix',
    group => 'zabbix',
    content => "[client]\nuser=zabbix\npassword=$zabbixmysqlpassword\n",
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
}

# change Server in /etc/zabbix/zabbix_agentd.conf
# from localhost to our server (facter) ipaddress (this host)
exec {'zabbixAgentdServer':
    logoutput => true,
    unless => "/bin/grep Server=$ipaddress /etc/zabbix/zabbix_agentd.conf",
    command => "/usr/bin/perl -p -i -e 's/Server=.*/Server=$ipaddress/g' /etc/zabbix/zabbix_agentd.conf",
    notify => Service [ 'zabbix-agent' ],
    require => Package [ 'zabbix-agent' ],
}

# change ServerActive in /etc/zabbix/zabbix_agentd.conf
# from localhost to our server (facter) ipaddress (this host)
exec {'zabbixAgentdServerActive':
    logoutput => true,
    unless => "/bin/grep ServerActive=$ipaddress /etc/zabbix/zabbix_agentd.conf",
    command => "/usr/bin/perl -p -i -e 's/ServerActive=.*/ServerActive=$ipaddress/g' /etc/zabbix/zabbix_agentd.conf",
    notify => Service [ 'zabbix-agent' ],
    require => Package [ 'zabbix-agent' ],
}

# need to ensure the dir is there!!!
file { '/var/lib/zabbix':
    ensure => 'directory',
    owner => 'zabbix',
    group => 'zabbix',
    mode => '0770'
}

exec { 'setfqdnInzabbixAgentId':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e 's/.*HostnameItem=.*/HostnameItem=system.hostname/g' /etc/zabbix/zabbix_agentd.conf && /usr/bin/perl -p -i -e 's/^Hostname=.*/#Hostname=Zabbix Server/g' /etc/zabbix/zabbix_agentd.conf",
    unless => "/bin/grep '^HostnameItem=system.hostname' /etc/zabbix/zabbix_agentd.conf && /bin/grep -v '^HostnameItem=' /etc/zabbix/zabbix_agentd.conf",
    notify => Service [ 'zabbix-agent' ],
    require => Package [ 'zabbix-agent' ],
}


# not really needed but we want to bouce it after config changes
service { 'zabbix-agent':
    ensure => 'running',
    enable => 'true',
}

# diskstats agent config file
# from http://www.muck.net/19/getting-hard-disk-performance-stats-from-zabbix
file { '/etc/zabbix/zabbix_agentd.d/userparameter_disk.conf':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    content => "UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$4}'\nUserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk \'{print \$\$7}\'\nUserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$8}'\nUserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$11}'\nUserParameter=custom.vfs.dev.io.active[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$12}'\nUserParameter=custom.vfs.dev.io.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$13}'\nUserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$6}'\nUserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$10}'",
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
}

# dns response time command
# /usr/bin/dig www.google.com | grep "Query time" | awk '{print $4}'
file { '/etc/zabbix/zabbix_agentd.d/userparameter_dns.conf':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    content => "UserParameter=custom.dns.response.time[*],/usr/bin/dig +nocmd +noall +stats +time=2 \$1 | grep 'Query time' | awk '{print \$\$4}'\nUserParameter=custom.dns.response.type[*],/usr/bin/dig +nocmd +noall +answer +time=2 \$1 | head -1 | awk '{print \$\$4}'\nUserParameter=custom.dns.response.record[*],/usr/bin/dig +short +time=2 \$1 | head -1",
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
}

file { '/etc/zabbix/zabbix_agentd.d/userparameter_ntpd.conf':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
    content => "UserParameter=custom.ntpd.remote,/usr/bin/ntpq -p | grep '*' | awk '{print \$1}'\nUserParameter=custom.ntpd.offset,/usr/bin/ntpq -p | grep '*' | awk '{print \$9}'"
}

# track ESTABLISHED network connections
# from http://systembash.com/content/track-tcp-and-udp-connections-with-zabbix/
file { '/etc/zabbix/zabbix_agentd.d/userparameter_tcpstat.conf':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
    content => "UserParameter=proc.net.tcp.count.established,/bin/grep -Ec '[0-9A-F]{8}:[0-9A-F]{4} [0-9A-F]{8}:[0-9A-F]{4} 01' /proc/net/tcp\nUserParameter=sockstat.sockets,/bin/cat /proc/net/sockstat|/bin/grep sockets|/usr/bin/cut -d' ' -f 3\nUserParameter=sockstat.tcp.inuse,/bin/cat /proc/net/sockstat|/bin/grep TCP|/usr/bin/cut -d' ' -f 3\nUserParameter=sockstat.tcp.orphan,/bin/cat /proc/net/sockstat|/bin/grep TCP|/usr/bin/cut -d' ' -f 5\nUserParameter=sockstat.tcp.timewait,/bin/cat /proc/net/sockstat|/bin/grep TCP|/usr/bin/cut -d' ' -f 7\nUserParameter=sockstat.tcp.allocated,/bin/cat /proc/net/sockstat|/bin/grep TCP|/usr/bin/cut -d' ' -f 9\nUserParameter=sockstat.tcp.mem,/bin/cat /proc/net/sockstat|/bin/grep TCP|/usr/bin/cut -d' ' -f 11\nUserParameter=sockstat.udp.inuse,/bin/cat /proc/net/sockstat|/bin/grep UDP:|/usr/bin/cut -d' ' -f 3\nUserParameter=sockstat.udp.mem,/bin/cat /proc/net/sockstat|/bin/grep UDP:|/usr/bin/cut -d' ' -f 5",
}

# add zabbix user to adm group on ubuntu so that they can read log files etc..
user { "zabbix":
    ensure => present,
    require => Package [ 'zabbix-agent' ],
    notify => Service [ 'zabbix-agent' ],
    groups => "adm",
    membership => minimum,
}

# NFS checks
# part from https://www.zabbix.com/forum/showthread.php?t=20363
# stat -f /var/lib/mythtv/videos | grep -o 'Type: [a-zA-Z0-9 \t]\+$' | grep -o ': [a-zA-Z0-9 \t]\+$' | grep -o '[a-zA-Z0-9]\+'^C
# chaged to (so that it also groks ext2/ext3...)
# stat -f /var/lib/mythtv | grep -o 'Type: [a-zA-Z0-9/ \t]\+$' | grep -o ': [a-zA-Z0-9/ \t]\+$' | grep -o '[a-zA-Z0-9/]\+'
# Write 1 byte, delete check (for nfs or anything...) 
# { TIMEFORMAT=%R; time ( ls > /dev/null && pwd > /dev/null ) }
file { '/etc/zabbix/zabbix_agentd.d/userparameter_statTouch.conf':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
    content => "UserParameter=custom.vfs.stat.type[*],/usr/bin/stat -f \$1 | /bin/grep -o \'Type: [a-zA-Z0-9/ \t]\\+$\' | /bin/grep -o \': [a-zA-Z0-9/ \t]\\+$\' | /bin/grep -o \'[a-zA-Z0-9/]\\+\'\nUserParameter=custom.vfs.file.touch[*],/usr/bin/touch \$1\n",
}

# Autodiscovery 
# http://virtuallyhyper.com/2013/06/monitor-disk-io-stats-with-zabbix/
# https://www.zabbix.com/forum/showthread.php?p=104719#post104719
# Param to run autodiscovery script
file { '/etc/zabbix/zabbix_agentd.d/userparameter_discovery.conf':
    ensure => present,
    mode => '0755',
    owner => 'root',
    group => 'root',
    notify => Service [ 'zabbix-agent' ],
    require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
    content => 'UserParameter=custom.disks.discovery_perl,/etc/zabbix/zabbix_agentd.d/discover_disk.pl',
}


# download and install https://github.com/gregcope/stuff/raw/master/myth/discover_disk.pl
# unless the sha1sum is cosher
exec { 'curlOssec.conf':
     logoutput => true,
     cwd => '/etc/zabbix/zabbix_agentd.d',
     command => '/usr/bin/curl -OsS https://github.com/gregcope/stuff/raw/master/myth/discover_disk.pl && chmod 755 /etc/zabbix/zabbix_agentd.d/discover_disk.pl',
     unless => "/usr/bin/sha1sum /etc/zabbix/zabbix_agentd.d/discover_disk.pl | grep $discovery_disk.pl_sha",
     require => [ Package [ 'zabbix-agent' ], File [ '/var/lib/zabbix' ] ],
}
