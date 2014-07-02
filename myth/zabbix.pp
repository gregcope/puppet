$zabbixversion='2.2'

# Done
# Install Zabbix

# To do
# Config Zabbix for an ubuntu host
# Config Myth
# Config Apache

#lsbdistcodename facter for precise
#fqdn is facter for full hostname

# add the zabbix Apt config files
# if they have not already been added
exec { 'addZabbixAptConfig':
    logoutput => true,
    command => '/usr/bin/wget --quiet http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+precise_all.deb && dpkg  --install zabbix-release_2.2-1+precise_all.deb',
    unless => '/usr/bin/dpkg --get-selections | grep zabbix',
}

# install packages
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
    command => '/usr/bin/perl -p -i -e "s/.*date.timezone =.*/date.timezone = $timezone/g" /etc/php5/apache2/php.ini',
    unless => '/bin/grep "^date.timezone = $timezone" /etc/php5/apache2/php.ini',
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

package { 'php5': }
package { 'apache2': }
package { 'libapache2-mod-php5': }

