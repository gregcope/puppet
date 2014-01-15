# set some defaults before we go...
$wpt_key = '61c74f0abc0cc3c018963bf72191aff6'
$wpt_server = '54.194.28.77'
$wptmonitor_JobProcessorKey = 'e7df7cd2ca07f4f1ab415d457a6e1c13'
$wptmysqlDB=wpt_monitor
$wptmysqluser=wpt
$wptmysqlpass=64hasdw1

# create WPT DB user
exec { 'createMysqlWPTUser':
    logoutput => true,
    command => "/usr/bin/mysql -e 'create user \"$wptmysqluser\"@\"localhost\" IDENTIFIED BY \"$wptmysqlpass\"; GRANT ALL on $wptmysqlDB.* to \"$wptmysqluser\"@\"localhost\";'",
    unless => "/usr/bin/mysql -e 'select count(*) from mysql.user WHERE user=\"$wptmysqluser\"' | /bin/grep 1",
}

# set the DB user/password
file { '/var/www/WPT-server-master/wptmonitor/settings/bootstrap.ini':
    ensure => present,
    content => "login=$wptmysqluser\npassword=$wptmysqlpass\n",
    mode => '0644',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],    
}

# ensure apache installed/started
service { 'apache2':
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Package['apache2'],
}

# enable expires if note enabled
exec { 'apacheExpires':
    logoutput => true,
    command => '/usr/sbin/a2enmod expires',
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/expires.load",
    require => Package[ 'apache2' ],
    notify => Exec['restart-apache2']
}

# enable headers if not enabled
exec { 'apacheHeaders':
    logoutput => true,
    command => '/usr/sbin/a2enmod headers',
    unless => '/bin/readlink -e /etc/apache2/mods-enabled/headers.load',
    require => Package[ 'apache2' ],
    notify => Exec['restart-apache2']
}   

# enable deflate if not enabled
exec { 'apacheDeflate':
    logoutput => true,
    command => '/usr/sbin/a2enmod deflate',
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/deflate.load",
    require => Package[ 'apache2' ],
    notify => Exec['restart-apache2']
}   

# enabled rewrite if note enabled
exec { 'apacheRewrite':
    logoutput => true,
    command => '/usr/sbin/a2enmod rewrite',
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load",
    require => Package[ 'apache2' ],
    notify => Exec['restart-apache2']
}   

# enabled ssl if not enabled
exec { 'apacheSsl':
   logoutput => true,
   command => '/usr/sbin/a2enmod ssl',
   unless => "/bin/readlink -e /etc/apache2/mods-enabled/ssl.load",
   require => Package[ 'apache2' ],
   notify => Exec['restart-apache2']
}   

# enabled default ssl site
exec { 'enableDefaultSsl':
    logoutput => true,
    command => '/usr/sbin/a2ensite default-ssl',
    unless => '/bin/readlink -e /etc/apache2/sites-enabled/default-ssl',
    notify => Exec['restart-apache2'],
    require => Package[ 'apache2' ],
}

#Exec[ 'apt-dist-updgrade' ] -> Package <| |>

# install some packages :-)
package { 'php-apc': }
package { 'imagemagick': }
package { 'php5-imagick': }
package { 'ffmpeg': }
package { 'apache2': }
package { 'libapache2-mod-php5': }
package { 'zip': }
package { 'vim': ensure => 'installed'}
package { 'sysstat': }
package { 'iotop': }
package { 'denyhosts': }
package { 'mailutils': }
package { 'smartmontools': }
package { 'ethtool': }
package { 'atop': }
package { 'logwatch': }
package { 'lynx': }
package { 'ntp': }
package { 'vim-puppet': }
package { 'bsd-mailx': }
package { 'augeas-tools': ensure => 'installed' }
package { 'puppet-lint': }
package { 'php5': }
package { 'php5-ffmpeg': }
package { 'libimage-exiftool-perl': }
package { 'libjpeg-turbo-progs': }
package { 'php5-gd': }
package { 'libphp-pclzip': }
package { 'php5-curl': }
package { 'mysql-server': }
package { 'php5-mysql': }

# for webpagetest monitor
package { 'php-pear': }
package { 'php5-sqlite': }
# these are needed for pecl_http
# http://pmellor.wordpress.com/2013/05/13/adding-http-to-php-on-ubuntu-12-04-lts/
package { 'libcurl3': }
package { 'php5-dev': }
package { 'libcurl4-gnutls-dev': }
package { 'libmagic-dev': }
package { 'make': }
package { 'php-http': }
package { 'libpcre3-dev': }

# make sure some are removed!
package { 'heirloom-mailx': ensure => 'absent' }
package { 'xscreensaver': ensure => 'absent' }
package { 'network-manager': ensure => 'absent' }
package { 'isc-dhcp-client': ensure => 'absent' }
package { 'isc-dhcp-common': ensure => 'absent' }

# set a good expires config
file { '/etc/apache2/mods-available/expires.conf':
    ensure => present,
    content => "<IfModule mod_expires.c>\n\tExpiresActive On\n\tExpiresByType application/x-javascript \"access plus 1 year\"\n\tExpiresByType application/javascript \"access plus 1 year\"\n\tExpiresByType text/css \"access plus 1 year\"\n\tExpiresByType image/* \"access plus 1 year\"\n</IfModule>",
    mode => '0644',
    require => Package [ 'apache2' ]
}

# set a good deflate config
file { '/etc/apache2/mods-enabled/deflate.conf':
    ensure => present,
    content => "IfModule mod_deflate.c>\n\n\t# stuff to deflate\n\tAddOutputFilterByType DEFLATE text/plain text/html text/xml text/css\n\tAddOutputFilterByType DEFLATE application/xml application/xhtml+xml\n\tAddOutputFilterByType DEFLATE application/rss+xml application/atom+xml\n\tAddOutputFilterByType DEFLATE application/javascript text/javascript application/x-javascript\n\n\t#DeflateCompressionLevel 9\n\n\t# work arounds for older browsers\n\tBrowserMatch ^Mozilla/4 gzip-only-text/html\n\tBrowserMatch ^Mozilla/4\\.0[678] no-gzip\n\tBrowserMatch \\bMSI[E] !no-gzip !gzip-only-text/html\n\tBrowserMatch \\bMSIE\s6.0 gzip-only-text/html\n\n\t# Make sure proxies don't deliver the wrong content\n\tHeader append Vary User-Agent env=!dont-vary\n\n\t# logging for testing only\n\tDeflateFilterNote Input instream\n\tDeflateFilterNote Output outstream\n\tDeflateFilterNote Ratio ratio\n\t# logs out size / insize % of orig size\n\tLogFormat '\"%r\" %{outstream}n/%{instream}n (%{ratio}n%%)' deflate\n\tCustomLog /var/log/apache2/deflate_log deflate\n</IfModule>",
    mode => '0644',
    require => Package [ 'apache2' ]
}

# remove etags
file { '/etc/apache2/conf.d/etags.conf':
    ensure => present,
    content => 'FileETag none',
    mode => '0644',
    require => Package [ 'apache2' ]

}

# update /etc/default/console-setup and reduce ttys to 3!
exec { 'updateConsoleSetup':
     logoutput => true,
     command => '/usr/bin/perl -p -i -e \'s!ACTIVE_CONSOLES="/dev/tty\[1\-6\]"!ACTIVE_CONSOLES="/dev/tty\[1\-2\]"!\'     /etc/default/console-setup',
     unless => '/bin/grep \'ACTIVE_CONSOLES="/dev/tty\[1\-2\]"\' /etc/default/console-setup',
}

# remove all the unused tty's
file { '/etc/init/tty3.conf':
    ensure => absent,
    require => Exec [ 'updateConsoleSetup' ],
}
file { '/etc/init/tty4.conf':
    ensure => absent,
    require => Exec [ 'updateConsoleSetup' ],
}
file {'/etc/init/tty5.conf':
    ensure => absent,
    require => Exec [ 'updateConsoleSetup' ],
}
file {'/etc/init/tty6.conf':
    ensure => absent,
}

# reload init, if anything has changed to those files!
exec { 'reload-init':
    logoutput => true,
    command => '/sbin/init q',
    subscribe => [ File['/etc/init/tty3.conf'], File['/etc/init/tty4.conf'], File['/etc/init/tty5.conf'], File['/etc/init/tty6.conf'], Exec [ 'updateConsoleSetup' ] ],
    refreshonly => true
}

# enabled logcompression
file { '/etc/logrotate.d/compress':
    ensure => present,
    mode => '0644',
    content => 'compress'
}

# remount / with noatime,nodiratime opts
mount { '/':
    ensure => present,
    device => 'LABEL=cloudimg-rootfs',
    atboot => yes,
    fstype => ext4,
    dump => 0,
    pass => 1,
    options => 'noatime,nodiratime,errors=remount-ro'
}

# enable sar collection
# require augeas
augeas { '/etc/default/sysstat':
    context => '/files/etc/default/sysstat',
    changes => [ 'set ENABLED true' ],
    require => Package['augeas-tools'],
}

# restart apache if called
exec { 'restart-apache2':
    command => '/usr/sbin/service apache2 restart',
    refreshonly => true,
    logoutput => true,
    require => Package [ 'apache2' ]
}

# what ever the post_max_size make it 16M
exec { 'phpinipostmaxsize':
    command => '/usr/bin/perl -p -i -e "s/post_max_size =.*/post_max_size = 16M/g" /etc/php5/apache2/php.ini',
    unless => '/bin/grep "^post_max_size = 16M" /etc/php5/apache2/php.ini',
    notify => Exec[ 'restart-apache2' ],
    require => [ Package [ 'apache2' ], Package [ 'php5' ], Package [ 'libapache2-mod-php5' ] ],
}

# what ever the upload_max_filesize make it 16M
exec { 'phpiniuploadmaxsize':
    command => '/usr/bin/perl -p -i -e "s/upload_max_filesize =.*/upload_max_filesize = 16M/g" /etc/php5/apache2/php.ini',
    unless => '/bin/grep "^upload_max_filesize = 16M" /etc/php5/apache2/php.ini',
    require => [ Package [ 'apache2' ], Package [ 'php5' ], Package [ 'libapache2-mod-php5' ] ],
    notify => Exec[ 'restart-apache2' ],
}

# create another doco root for jpvincent WPT-server-master
file { '/var/www/WPT-server-master':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0755',
    require => Package [ 'apache2' ],
}

# Ensure Apache user can write to the relevant dirs
# after we've installed the files into the docroot!
file { [ '/var/www/WPT-server-master/tmp', '/var/www/WPT-server-master/results', '/var/www/WPT-server-master/work/jobs', '/var/www/WPT-server-master/work/video', '/var/www/WPT-server-master/logs' ]:
     ensure => directory,
     owner => 'www-data',
     group => 'www-data',
     mode => '0775',
     require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# simple config file
file { '/etc/apache2/conf.d/WPT-server-master.conf':
    ensure => present,
    mode => '0644',
    content => "<Directory \"/var/www/WPT-server-master\">\n\tAllowOverride All\n\tOrder allow,deny\n\tAllow from all\n</Directory>\n<VirtualHost *:80>\n\tDocumentRoot /var/www/WPT-server-master\n</VirtualHost>\n",
    require => Package [ 'apache2' ],
    notify => Exec[ 'restart-apache2' ],
}

# download jpvincent's WPT-server
exec { 'jpvincentWPT-server':
    cwd => '/tmp',
    command => "/usr/bin/wget --quiet https://github.com/jpvincent/WPT-server/archive/master.zip",
    unless => "/usr/bin/md5sum /tmp/master.zip | /bin/grep d39f7f909ce17b25154753c5ba2cb47b",
    logoutput => true,
    user => root,
    require => Package [ 'apache2' ]
}

# unzip jpvincentWPT-server and mv the www files to the doc root (/var/www/webpagetest/)
# after the zip package has been installed, and we wgett'ed the zip and created the docroot!
exec { 'unzipinstalljpvincentWPT-server':
    logoutput => true,
    cwd => '/tmp',
    user => 'root',
    command => "/usr/bin/unzip /tmp/master.zip && /bin/mv /tmp/WPT-server-master/* /var/www/WPT-server-master/",
    # I know not perfect!
    unless => '/bin/ls -la /var/www/WPT-server-master/index.php',
    require => [ Package ['zip' ], Exec [ 'jpvincentWPT-server' ], File [ '/var/www/WPT-server-master' ] ],
}

exec { 'moveHtaccessToo':
    logoutput => true,
    cwd => '/tmp',
    user => 'root',
    command => "/bin/mv /tmp/WPT-server-master/.htaccess /var/www/WPT-server-master/",
    # I know not perfect!
    unless => '/bin/ls -la /var/www/WPT-server-master/.htaccess',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# set the location of the wpt server IP
# after we've installed wpt files into docroot
exec { 'setwptServeIP':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/wpt_server=www.yourserver.com/wpt_server=$wpt_server/g\" /var/www/WPT-server-master/settings/locations.ini",
    unless => "/bin/grep \"wpt_server=$wpt_server\" /var/www/WPT-server-master/settings/locations.ini",
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# set our wpt key
# after we've installed wpt files into docroot
exec { 'setwptkey':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/wpt_key=SecretKey/wpt_key=$wpt_key/g\" /var/www/WPT-server-master/settings/locations.ini",
    unless => "/bin/grep \"wpt_key=$wpt_key\" /var/www/WPT-server-master/settings/locations.ini",
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the locations.ini.EC2-sample
# after we've installed wpt files into docroot
# notify to change wpt settings (x2)
exec { 'renameLocationsIniEC2Sample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/locations.ini.EC2-sample /var/www/WPT-server-master/settings/locations.ini',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/locations.ini',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
    notify => [ Exec [ 'setwptkey' ], Exec [ 'setwptServeIP' ], Exec [ 'setKeyinLocations.ini' ] ],
}

# set another secrete key
exec { 'setKeyinLocations.ini':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/^key=SecretKey/key=$wpt_key/g\" /var/www/WPT-server-master/settings/locations.ini"    ,
    unless => "/bin/grep \"^key=$wpt_key\" /var/www/WPT-server-master/settings/locations.ini",
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the ec2.ini.sample
# after we've installed wpt files into docroot
exec { 'renameEc2IniSample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/ec2.ini.sample /var/www/WPT-server-master/settings/ec2.ini',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/ec2.ini',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ]
}

# rename the settings.ini.sample
# after we've installed wpt files into docroot
exec { 'renameSettingsIniSample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/settings.ini.sample /var/www/WPT-server-master/settings/settings.ini',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/settings.ini',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the keys.ini.sample
# after we've installed wpt files into docroot
exec { 'renameKeysIniSample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/keys.ini.sample /var/www/WPT-server-master/settings/keys.ini',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/keys.ini',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the connectivity.ini.sample
# after we've installed wpt files into docroot
exec { 'renameConnectivityIniSample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/connectivity.ini.sample /var/www/WPT-server-master/settings/connectivity.ini',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/connectivity.ini',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the about.inc settings sample
# after we've installed wpt files into docroot
exec { 'renameAboutIncSample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/about.inc.sample /var/www/WPT-server-master/settings/about.inc',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/about.inc',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the custom.css.sample
# after we've installed wpt files into docroot
 exec { 'renameCustomCssSample':
     logoutput => true,
     command => '/bin/mv /var/www/WPT-server-master/settings/custom.css.sample /var/www/WPT-server-master/settings/custom.css',
     unless => '/bin/ls -la /var/www/WPT-server-master/settings/custom.css',
     require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# rename the feeds.inc.sample
# after we've installed wpt files into docroot
exec { 'renamefeedsIncSample':
    logoutput => true,
    command => '/bin/mv /var/www/WPT-server-master/settings/feeds.inc.sample /var/www/WPT-server-master/settings/feeds.inc',
    unless => '/bin/ls -la /var/www/WPT-server-master/settings/feeds.inc',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ],
}

# disable IE7
# perl -p -i -e 's/(^1=.+_IE7)/;$1/g' locations.ini
# egrep '^1=.+_IE7' locations.ini

# web page test monitor cron to run jobs
# http://www.wptmonitor.org/home/requirements
cron { 'jobProcessor':
    command => "curl localhost/wptmonitor/jobProcessor.php?key=$wptmonitor_JobProcessorKey >> /var/www/WPT-server-master/wptmonitor/jobProcessor.log",
    user => www-data,
    ensure=> 'present',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ]
}

#cron { 'ec2Processor':
#    command => "curl localhost/wptmonitor/ec2Processor.php?key=$wptmonitor_JobProcessorKey",
#    user => www-data,
#    ensure=> 'present',
#}

# file is needed apparently to stop lines like
# [Tue Jan 14 22:55:52 2014] [error] [client 217.155.57.118] PHP Warning:  fopen(ec2Processor.log): failed to open stream: Permission denied in /var/www/webpagetest/wptmonitor/utils.inc on line 484, referer: http://54.194.28.77/wptmonitor/wptHostStatus.php
# stops errors if readable by webuser
file { '/var/www/WPT-server-master/wptmonitor/jobProcessor.log':
    ensure => 'present',
    mode => '0644',
    owner => 'www-data',
    group => 'www-data',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ]
}

# ec2Processor.log
# stops errors if readable by web user...
file { '/var/www/WPT-server-master/wptmonitor/ec2Processor.log':
    ensure => 'present',
    mode => '0644',
    owner => 'www-data',
    group => 'www-data',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ]
}

# I think this is where it logs...
# to stop [ERROR] [logOutput] Cannot open log file
file { '/var/www/WPT-server-master/wptmonitor/jobProcessor_log.html':
    ensure => 'present',
    mode => '0644',
    owner => 'www-data',
    group => 'www-data',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ]
}

# stops [Tue Jan 14 23:12:02 2014] [error] [client 127.0.0.1] PHP Warning:  parse_ini_file(./QueueStatus.ini): failed to open stream: No such file or directory in /var/www/webpagetest/wptmonitor/wpt_functions.inc on line 1293
file { '/var/www/WPT-server-master/wptmonitor/QueueStatus.ini':
    ensure => 'present',
    mode => '0644',
    owner => 'www-data',
    group => 'www-data',
    require => Exec [ 'unzipinstalljpvincentWPT-server' ]
}

# install pecl_http ... naff I know
exec { 'installpeclHttp':
    logoutput => true,
    command => '/usr/bin/sudo /usr/bin/pecl install pecl_http-1.7.6',
    unless => '/bin/ls -la /usr/lib/php5/20090626/http.so',
    require => [ Package [ 'libpcre3-dev' ], Package [ 'php-http' ], Package [ 'make' ], Package [ 'libcurl3' ], Package [ 'php5-dev' ], Package [ 'libcurl4-gnutls-dev' ], Package [ 'libmagic-dev' ], Package [ 'php5-dev' ] ],
}


# get apache to load the pecl_http extension
# only if exec install worked and apache is installed
# restart apache
file { '/etc/php5/conf.d/pecl_http.ini':
    ensure => 'present',
    content => "; configuration for php pecl_http\nextension=http.so\n",
    mode => '0644',
    require => [ Exec [ 'installpeclHttp' ], Package [ 'apache2' ] ],
    notify => Exec[ 'restart-apache2' ],
}

# fix DB error
# Error: exception 'PDOException' with message 'SQLSTATE[HY000] [14] unable to open database file' in
# and smarty template errors
# from http://www.webpagetest.org/forums/showthread.php?tid=628 
file { [ '/var/www/WPT-server-master/wptmonitor/graph', '/var/www/WPT-server-master/wptmonitor/temp', '/var/www/WPT-server-master/wptmonitor/db', '/var/www/WPT-server-master/wptmonitor/templates_c', '/var/www/WPT-server-master/wptmonitor/graph/cache' ]:
     ensure => directory,
     owner => 'www-data',
     group => 'www-data',
     mode => '0775',
     require => File [ '/etc/php5/conf.d/pecl_http.ini' ],
}

file { [ '/var/www/WPT-server-master/wptmonitor/graph/cache/.xml' ]:
     ensure => file,
     owner => 'www-data',
     group => 'www-data',
     mode => '0644',
     require => File [ '/etc/php5/conf.d/pecl_http.ini' ],
}

