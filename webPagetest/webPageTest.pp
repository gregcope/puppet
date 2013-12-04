# set some defaults before we go...
$webpagetestVersion = '2.13'
$webpagetestzipmd5sum = '1997e1ad5e70d9dd2276ae9d6cbc75de'
$wpt_key = '61c74f0abc0cc3c018963bf72191aff6'
$wpt_server = '54.194.28.77'

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
    subscribe => [ File['/etc/init/tty3.conf'], File['/etc/init/tty4.conf'], File['/etc/init/tty5.conf'], File['/etc/    init/tty6.conf'], Exec [ 'updateConsoleSetup' ] ],
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

# Create docroot
file { '/var/www/webpagetest': 
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0755',
    require => Package [ 'apache2' ],
}

# Ensure Apache user can write to the relevant dirs
# after we've installed the files into the docroot!
file { [ '/var/www/webpagetest/tmp', '/var/www/webpagetest/results', '/var/www/webpagetest/work/jobs', '/var/www/webpagetest/work/video', '/var/www/webpagetest/logs' ]:
     ensure => directory,
     owner => 'www-data',
     group => 'www-data',
     mode => '0775',
     require => Exec [ 'unzipinstallwebpagetest' ],
}

# simple config file
file { '/etc/apache2/conf.d/webpagetest.conf':
    ensure => present,
    mode => '0644',
    content => "<Directory \"/var/www/webpagetest\">\n\tAllowOverride All\n\tOrder allow,deny\n\tAllow from all\n</Directory>\n<VirtualHost *:80>\n\tDocumentRoot /var/www/webpagetest\n</VirtualHost>\n",
    require => Package [ 'apache2' ],
    notify => Exec[ 'restart-apache2' ],
}

# download the zip!
# unless the md5sum is borked!
exec { 'wgetwebpagetest':
    cwd => '/tmp',
    command => "/usr/bin/wget --quiet https://github.com/WPO-Foundation/webpagetest/releases/download/$webpagetestVersion/webpagetest_$webpagetestVersion.zip",
    unless => "/usr/bin/md5sum /tmp/webpagetest_$webpagetestVersion.zip | /bin/grep $webpagetestzipmd5sum",
    logoutput => true,
    user => root,
    require => Package [ 'apache2' ]
}

# unzip the wpt zip in /tmp and mv the www files to the doc root (/var/www/webpagetest/)
# after the zip package has been installed, and we wgett'ed the zip and created the docroot!
exec { 'unzipinstallwebpagetest':
    logoutput => true,
    cwd => '/tmp',
    user => 'root',
    command => "/usr/bin/unzip /tmp/webpagetest_$webpagetestVersion.zip && /bin/mv /tmp/www/* /var/www/webpagetest/",
    # I know not perfect!
    unless => '/bin/ls -la /var/www/webpagetest/index.php',
    require => [ Package ['zip' ], Exec [ 'wgetwebpagetest' ], File [ '/var/www/webpagetest' ] ],
}

exec { 'moveHtaccessToo':
    logoutput => true,
    cwd => '/tmp',
    user => 'root',
    command => "/bin/mv /tmp/www/.htaccess /var/www/webpagetest/",
    # I know not perfect!
    unless => '/bin/ls -la /var/www/webpagetest/.htaccess',
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# set the location of the wpt server IP
# after we've installed wpt files into docroot
exec { 'setwptServeIP':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/wpt_server=www.yourserver.com/wpt_server=$wpt_server/g\" /var/www/webpagetest/settings/locations.ini",
    unless => "/bin/grep \"wpt_server=$wpt_server\" /var/www/webpagetest/settings/locations.ini",
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# set our wpt key
# after we've installed wpt files into docroot
exec { 'setwptkey':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/wpt_key=SecretKey/wpt_key=$wpt_key/g\" /var/www/webpagetest/settings/locations.ini",
    unless => "/bin/grep \"wpt_key=$wpt_key\" /var/www/webpagetest/settings/locations.ini",
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the locations.ini.EC2-sample
# after we've installed wpt files into docroot
# notify to change wpt settings (x2)
exec { 'renameLocationsIniEC2Sample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/locations.ini.EC2-sample /var/www/webpagetest/settings/locations.ini',
    unless => '/bin/ls -la /var/www/webpagetest/settings/locations.ini',
    require => Exec [ 'unzipinstallwebpagetest' ],
    notify => [ Exec [ 'setwptkey' ], Exec [ 'setwptServeIP' ], Exec [ 'setKeyinLocations.ini' ] ],
}

# set another secrete key
exec { 'setKeyinLocations.ini':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/^key=SecretKey/key=$wpt_key/g\" /var/www/webpagetest/settings/locations.ini"    ,
    unless => "/bin/grep \"^key=$wpt_key\" /var/www/webpagetest/settings/locations.ini",
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the ec2.ini.sample
# after we've installed wpt files into docroot
exec { 'renameEc2IniSample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/ec2.ini.sample /var/www/webpagetest/settings/ec2.ini',
    unless => '/bin/ls -la /var/www/webpagetest/settings/ec2.ini',
    require => Exec [ 'unzipinstallwebpagetest' ]
}

# rename the settings.ini.sample
# after we've installed wpt files into docroot
exec { 'renameSettingsIniSample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/settings.ini.sample /var/www/webpagetest/settings/settings.ini',
    unless => '/bin/ls -la /var/www/webpagetest/settings/settings.ini',
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the keys.ini.sample
# after we've installed wpt files into docroot
exec { 'renameKeysIniSample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/keys.ini.sample /var/www/webpagetest/settings/keys.ini',
    unless => '/bin/ls -la /var/www/webpagetest/settings/keys.ini',
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the connectivity.ini.sample
# after we've installed wpt files into docroot
exec { 'renameConnectivityIniSample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/connectivity.ini.sample /var/www/webpagetest/settings/connectivity.ini',
    unless => '/bin/ls -la /var/www/webpagetest/settings/connectivity.ini',
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the about.inc settings sample
# after we've installed wpt files into docroot
exec { 'renameAboutIncSample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/about.inc.sample /var/www/webpagetest/settings/about.inc',
    unless => '/bin/ls -la /var/www/webpagetest/settings/about.inc',
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the custom.css.sample
# after we've installed wpt files into docroot
 exec { 'renameCustomCssSample':
     logoutput => true,
     command => '/bin/mv /var/www/webpagetest/settings/custom.css.sample /var/www/webpagetest/settings/custom.css',
     unless => '/bin/ls -la /var/www/webpagetest/settings/custom.css',
     require => Exec [ 'unzipinstallwebpagetest' ],
}

# rename the feeds.inc.sample
# after we've installed wpt files into docroot
exec { 'renamefeedsIncSample':
    logoutput => true,
    command => '/bin/mv /var/www/webpagetest/settings/feeds.inc.sample /var/www/webpagetest/settings/feeds.inc',
    unless => '/bin/ls -la /var/www/webpagetest/settings/feeds.inc',
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# disable IE7
# perl -p -i -e 's/(^1=.+_IE7)/;$1/g' locations.ini
# egrep '^1=.+_IE7' locations.ini

