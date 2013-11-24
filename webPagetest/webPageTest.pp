# set some defaults before we go...
$webpagetestVersion = '2.13'
$webpagetestzipmd5sum = '1997e1ad5e70d9dd2276ae9d6cbc75de'
$wpt_key = '61c74f0abc0cc3c018963bf72191aff6'
$wpt_server = '54.194.0.124'

# should not need to change anything below this line
$apache2_sites = '/etc/apache2/sites'
$apache2_mods = '/etc/apache2/mods'

class apache2 {

   # Define an apache2 site. Place all site configs into
   # /etc/apache2/sites-available and en-/disable them with this type.
   #
   # You can add a custom require (string) if the site depends on packages
   # that aren't part of the default apache2 package. Because of the
   # package dependencies, apache2 will automagically be included.
   define site ( $ensure = 'present' ) {
      case $ensure {
         'present' : {
            exec { "/usr/sbin/a2ensite $name":
               unless => "/bin/readlink -e ${apache2_sites}-enabled/$name",
               notify => Exec['reload-apache2'],
               require => Package[$require],
            }
         }
         'absent' : {
            exec { "/usr/sbin/a2dissite $name":
               onlyif => "/bin/readlink -e ${apache2_sites}-enabled/$name",
               notify => Exec['reload-apache2'],
               require => Package['apache2'],
            }
         }
         default: { err ( "Unknown ensure value: '$ensure'" ) }
      }
   }

   # Define an apache2 module. Debian packages place the module config
   # into /etc/apache2/mods-available.
   #
   # You can add a custom require (string) if the module depends on
   # packages that aren't part of the default apache2 package. Because of
   # the package dependencies, apache2 will automagically be included.
   define module ( $ensure = 'present', $require = 'apache2' ) {
      case $ensure {
         'present' : {
            exec { "/usr/sbin/a2enmod $name":
               unless => "/bin/readlink -e ${apache2_mods}-enabled/${name}.load",
               notify => Exec['force-reload-apache2'],
               require => Package[$require],
            }
         }
         'absent': {
            exec { "/usr/sbin/a2dismod $name":
               onlyif => "/bin/readlink -e ${apache2_mods}-enabled/${name}.load",
               notify => Exec['force-reload-apache2'],
               require => Package['apache2'],
            }
         }
         default: { err ( "Unknown ensure value: '$ensure'" ) }
      }
   }

   # Notify this when apache needs a reload. This is only needed when
   # sites are added or removed, since a full restart then would be
   # a waste of time. When the module-config changes, a force-reload is
   # needed.
   exec { 'reload-apache2':
      command => '/etc/init.d/apache2 reload',
      refreshonly => true,
   }

   exec { 'force-reload-apache2':
      command => '/etc/init.d/apache2 force-reload',
      refreshonly => true,
   }

   # We want to make sure that Apache2 is running.
   service { 'apache2':
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      require => Package['apache2'],
   }
}

# Ensure that expires, headers, deflate, ssl, rewrite are on!
class apache inherits apache2 {
    apache2::module { 'expires':
        ensure => present
    }
    apache2::module { 'headers':
        ensure => present
    }
    apache2::module { 'deflate':
        ensure => present
    }
    apache2::module { 'ssl':
        ensure => present
    }
    apache2::module { 'rewrite':
        ensure => present
    }
    apache2::site { 'default-ssl':
        ensure => present
    }
}

# add a mail alias file
# require the root, postmaster and logcheck aliases
file { '/etc/aliases':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    alias => 'aliases',
    require => Mailalias [ 'root', 'postmaster', 'logcheck' ];
}

# run the newaliases command if any of the subscribed mail aliases have been added
exec { 'newaliases':
    logoutput => true,
    command => '/usr/bin/newaliases',
    refreshonly => true,
    subscribe => [ Mailalias ['root'], Mailalias ['postmaster'], Mailalias ['logcheck'], Mailalias['greg'] ];
}

# mail alias to gregcope@gmail.com
mailalias { 'greg':
    name => 'greg',
    recipient => 'gregcope@gmail.com',
}

# alias root to gregcope@gmail.com
mailalias { 'root':
    name => 'root',
    recipient => 'gregcope@gmail.com',
}

# alias postmaster to gregcope@gmail.com
mailalias { 'postmaster':
    name => 'postmaster',
    recipient => 'root',
}

# alais logcheck to root
mailalias { 'logcheck':
    name => 'logcheck',
    recipient => 'root',
}

#Exec[ 'apt-dist-updgrade' ] -> Package <| |>

# install some packages :-)
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

# setup basic auth for mythweb from non-lan IPs
file { '/etc/apache2/mythweb-auth':
    ensure => present,
    content => "<Location /mythweb>\n\tAuthType Basic\n\tAuthName mythweb\n\tAuthUserFile /etc/apache2/web-htpassword\n\tRequire valid-user\n\tSatisfy any\n\tDeny from all\n\tAllow from 192.168.0.0/24\n</Location>",
    mode => '0644',
    require => Package [ 'apache2' ],
}

# create a htpasswrod file for mythweb
file { '/etc/apache2/web-htpassword':
    ensure => present,
    content => 'greg:Q4Z1zApK61s8I',
    mode => '0644',
    require => Package [ 'apache2' ]
}

# set a good expires config
file { '/etc/apache2/mods-available/expires.conf':
    ensure => present,
    content => "<IfModule mod_expires.c>\n\tExpiresActive OnExpiresByType application/x-javascript \"access plus 1 year\"\n\tExpiresByType application/javascript \"access plus 1 year\"\n\tExpiresByType text/css \"access plus 1 year\"\n\tExpiresByType image/* \"access plus 1 year\"\n</IfModule>",
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

# configure logwatch
# require the package
file { '/etc/logwatch/conf/logwatch.conf':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => "LogDir = /var/log\nTmpDir = /var/cache/logwatch\nOutput = stdout\nFormat = text\nEncode = none\nMailTo = root\nMailFrom = Logwatch\nRange = yesterday\nDetail = High\nService = All\nmailer = \"/usr/sbin/sendmail -t\"",
    require => Package['logwatch'],
}

# some reason this is/was missing :-(
file { '/var/cache/logwatch':
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => '0755',
}

# remove all the unused tty's
file { '/etc/init/tty3.conf':
    ensure => absent,
}
file { '/etc/init/tty4.conf':
    ensure => absent,
}
file {'/etc/init/tty5.conf':
    ensure => absent,
}
file {'/etc/init/tty6.conf':
    ensure => absent,
}

# reload init, if anything has changed to those files!
exec { 'reload-init':
    logoutput => true,
    command => '/sbin/init q',
   subscribe => [ File['/etc/init/tty3.conf'], File['/etc/init/tty4.conf'], File['/etc/init/tty5.conf'], File['/etc/init/tty6.conf'] ],
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
    device => 'cloudimg-rootfs',
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
    require => Package [ 'apache2' ]
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
file { '/etc/apache2/webpagetest.conf':
    ensure => present,
    mode => '0644',
    content => "<Directory \"/var/www/webpagetest\">\nAllowOverride all\n\tOrder allow,deny\n\tAllow from all\n</Directory>\n<VirtualHost *:80>\n\tDocumentRoot /var/www/webpagetest\n</VirtualHost>\n",
    require => Package [ 'apache2' ]
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
    command => "/usr/bin/unzip /tmp/webpagetest_$webpagetestVersion.zip && mv /tmp/www/* /var/www/webpagetest/",
    # I know not perfect!
    unless => '/bin/ls -la /var/www/webpagetest/index.php',
    require => [ Package ['zip' ], Exec [ 'wgetwebpagetest' ], File [ '/var/www/webpagetest' ] ],
}

# set the location of the wpt server IP
# after we've installed wpt files into docroot
exec { 'setwptServeIP':
    logoutput => true,
    command => "/usr/bin/perl -p -i -e \"s/wpt_server=www.yourserver.com/wpt_server=$wpt_server/g\" /var/www/webpagetest/settings/locations.ini",
    unless => "/bin/grep \"wpt_server=$wpt_server\" /var/www/webpagetest/settings/locations.ini",
    require => Exec [ 'unzipinstallwebpagetest' ],
}

# set out wpt key
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
    notify => [ Exec [ 'setwptkey' ], Exec [ 'setwptServeIP' ] ],
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


