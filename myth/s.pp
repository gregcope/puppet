# set some defaults before we go...
$mysqlPassword = '!!m21cat'

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

# Ensure that expires, headers and deflate are on!
# stop puppet running on this host
service { 'puppet':
    ensure => stopped,
}

# set the root reservation to 0% unless set - dangerous I know...
exec {'tunefs0sda1':
    logoutput => true,
    command => '/sbin/tune2fs -m 0 /dev/sda1',
    unless => '/sbin/tune2fs -l /dev/sda1 | grep -v "Reserved block count:     0"'
}

# setup the cron for the etc backup as root - has to be for certain files in /etc
# only run after the backup mount is on
cron { 'etc_backup':
    command => '/backups/scripts/etc_backup',
    user => root,
    hour => 2,
    minute => 17,
    require => Mount['/backups'],
}

# setup the mysql backup by only after the backup mount is on
cron { 'mysql_backup':
    command => '/backups/scripts/mysql_backup',
    user => root,
    hour => 3,
    minute => 23,
    require => Mount['/backups'],
}

# Create mysql backup usersunless it is done.
# Subscribe to changes to the cron change
exec { 'createMysqlBackupUser':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'create user \"backup\"@\"localhost\" IDENTIFIED BY \"foobaz\"; GRANT SELECT, LOCK TABLES, EVENT on *.* to \"backup\"@\"localhost\";'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mysql.user WHERE user=\"backup\"' | /bin/grep 1",
    subscribe => Cron['mysql_backup'],
}

# Run the backup script to make sure it is all cushty
# only if updated, and the backup user is there
exec { 'runMysqlBackupScriptCheck':
        logoutput => true,
    command => '/backups/scripts/mysql_backup',
    subscribe => Exec['createMysqlBackupUser'],
    refreshonly => true,
}

# put the morning shipping forcast email cron in as greg
# require the backups mount and greg user is there
cron { 'shippingForcastEmail0643':
    command => '/backups/scripts/shippingForcastEmail',
    user => greg,
    hour => 6,
    minute => 43,
    require => [ Mount['/backups'], User['greg'] ],
}

# put the midday shipping forcast email cron in as greg
# require the backup mount and greg user
cron { 'shippingForcastEmail1243':
    command => '/backups/scripts/shippingForcastEmail',
    user => greg,
    hour => 12,
    minute => 43,
    require => [ Mount ['/backups'], User['greg'] ],
}

# put the shipping forcast script on the backup mount
# require the backup mount and greg user
file {'shippingForcastEmail':
    ensure => present,
    path    => '/backups/scripts/shippingForcastEmail',
    mode    => '0755',
    require => [ Mount['/backups'], User['greg'] ],
}

# put the hostfile entry in for qnap
# require the network interface change
host { 'qnap.webarmadillo.net':
    ip => '192.168.0.50',
    comment => 'Added by puppet',
    host_aliases => 'qnap',
    require => [ File['/etc/network/interfaces'] ],
}

# unpack /var/cache/apt/archives from tar
# unless a file exists that we know to be in the tar
exec { 'unpackAptCache':
    logoutput => true,
    cwd => '/var/cache/apt',
    command => '/bin/tar -xvf /home/myth/nfs/archives.tar',
    unless => '/bin/ls /var/cache/apt/archives/libmyth-0.27-0_2%3a0.27.0+fixes.20131115.4ca9300-0ubuntu0mythbuntu2_amd64.deb' 
}

# run apt-update
# if the 0.27 myth source has been added
#exec { 'apt-update':
#    logoutput => true,
#    command => '/usr/bin/apt-get update',
#    require => [ Exec [ 'unpackAptCache' ], File [ '/etc/apt/sources.list.d/mythbuntu-0_27-precise.list' ] ],
#}

# run apt dist-upgrade
# aslong as update has run
#exec { 'apt-dist-updgrade':
#    logoutput => true,
#    timeout => 0,
#    command => '/usr/bin/apt-get -y dist-upgrade',
#    require => [ Exec [ 'unpackAptCache' ], Exec [ 'apt-update' ] ],
#    require => Exec [ 'apt-update' ],
#    refreshonly => true,
#}

# run atp autoremove
# if dist upgrade has run (ie tidy!)
#exec { 'apt-autoremove':
#    logoutput => true,
#    command => '/usr/bin/apt-get -y autoremove',
#    subscribe => Exec [ 'apt-dist-updgrade' ],
#} 

#package { 'libmyth-0.27-0':
#    ensure => installed,
#    require => Exec [ 'apt-dist-updgrade' ]
#}

# add the mythbuntu 0.27 repo file
# require the key to have been added
file { '/etc/apt/sources.list.d/mythbuntu-0_27-precise.list':
    ensure => present,
    mode => '0644',
    content => "deb http://ppa.launchpad.net/mythbuntu/0.27/ubuntu precise main\ndeb-src http://ppa.launchpad.net/mythbuntu/0.27/ubuntu precise main",
    require => Exec [ 'addmythbuntu0.27key' ]
}

# add the mythbuntu xmltv repo file
# require the key to have been added
file { '/etc/apt/sources.list.d/mythbuntu-xmltv-precise.list':
    ensure => present,
    mode => '0644',
    content => 'deb-src http://ppa.launchpad.net/mythbuntu/xmltv/ubuntu precise main',
    require => Exec [ 'addmythbuntu0.27key' ]
}

# added the mythbuntu key
# unless it is already there!
exec { 'addmythbuntu0.27key':
    logoutput => true,
    command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 13551B881504888C',
    unless => '/usr/bin/apt-key list | /bin/grep 504888C'
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

# ensure the videos dir has certain perms
file { '/var/lib/mythtv/videos':
    ensure => 'directory',
    owner => 'mythtv',
    group => 'mythtv',
    mode => '2775'
}

# make videos and NFS mount
# require the dir, and that the host file entry exists
mount { '/var/lib/mythtv/videos':
    ensure  => 'mounted',
    device  => 'qnap.webarmadillo.net:/videos',
    fstype  => 'nfs',
    options => 'noatime,nodiratime,nfsvers=3,auto,intr,soft',
    atboot  => true,
    require => [ File[ '/var/lib/mythtv/videos' ], Host['qnap.webarmadillo.net']],
}

# require the backups dir exists
file { '/backups':
    ensure => 'directory',
    owner => 'root',
    group => 'backup',
    mode => '2775'
}

# make the backups dir an NFS mount
# requires the dir and host file entry
mount { '/backups':
    ensure  => 'mounted',
    device  => 'qnap.webarmadillo.net:/backups',
    fstype  => 'nfs',
    options => 'noatime,nodiratime,nfsvers=3,auto,intr,soft',
    atboot  => true,
    require => [ File[ '/backups' ], Host['qnap.webarmadillo.net']],
}

# make the pictures dir
file { '/var/lib/mythtv/pictures':
        ensure => 'directory',
        owner => 'mythtv',
        group => 'mythtv',
        mode => '2775'
}

# make the pictures dir and NFS mount
# requires the dir and host file entry
mount { '/var/lib/mythtv/pictures':
    ensure  => 'mounted',
    device  => 'qnap.webarmadillo.net:/pictures',
    fstype  => 'nfs',
    options => 'noatime,nodiratime,nfsvers=3,auto,intr,soft',
    atboot  => true,
    require => [ File[ '/var/lib/mythtv/pictures' ], Host['qnap.webarmadillo.net']],
}

#Exec[ 'apt-dist-updgrade' ] -> Package <| |>

# install some packages :-)
package { 'apache2': }
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
package { 'nfs-common': }
package { 'gphoto2': }
package { 'nvidia-319-updates': }
package { 'gnome-menus': }
package { 'dkms': }
package { 'desktop-file-utils': }
package { 'nvidia-settings-319-updates': }
package { 'augeas-tools': ensure => 'installed' }
package { 'mytharchive': }
package { 'libdvdread4': }
package { 'libc-bin': }
package { 'puppet-lint': }

# make sure some are removed!
package { 'heirloom-mailx': ensure => 'absent' }
package { 'xscreensaver': ensure => 'absent' }
package { 'network-manager': ensure => 'absent' }
package { 'isc-dhcp-client': ensure => 'absent' }
package { 'isc-dhcp-common': ensure => 'absent' }

# Allow mail relay from the LAN
augeas { 'postfix-main.cf':
    context => '/files/etc/postfix/main.cf',
    changes => [ 'set mynetworks \'127.0.0.0/8 192.168.1.0/24\'', ],
    require => Package['augeas-tools'],
}

# setup basic auth for mythweb from non-lan IPs
file { '/etc/apache2/mythweb-auth':
    ensure => present,
    content => "<Location /mythweb>\n\tAuthType Basic\n\tAuthName mythweb\n\tAuthUserFile /etc/apache2/web-htpassword\n\tRequire valid-user\n\tSatisfy any\n\tDeny from all\n\tAllow from 192.168.0.0/24\n</Location>",
    mode => '0644',
    notify => Exec['restart-apache2'],
    require => Package [ 'apache2' ],
}

# create a htpasswrod file for mythweb
file { '/etc/apache2/web-htpassword':
    ensure => present,
    content => 'greg:Q4Z1zApK61s8I',
    mode => '0644',
}

# Google verifitcation file
file { '/var/www/googleee2aa49a06a70c0b.html':
    ensure => present,
    content => 'google-site-verification: googleee2aa49a06a70c0b.html',
    mode => '0644',
}

# my index.html file!
file { '/var/www/index.html':
    ensure => present,
    content => "<html><h2>Monitoring Driven Development</h2><p>In a nutshell;\n\n<p><blockquote><i>\"We should no longer create any Intergration, Regression or smoke tests.  These would be replaced by Monitors.</p>\n\n<p>For any notion of functionality testing within Test Driven Development we should create monitors.  When functionality goes live the Monitor should go green\"</i></blockquote>Greg Cope, 2011.\n\n<p>Testing is good, but only shows functionality, integrations or dependencies work at the point of testing.  Systems, and functionality offered often have very long lives in an every changing environment, be it other parts of the Service or Systems that they run on.</p>\n\n<p>Over a system life, Testing is akin to cheering when a rocket leaves the tower (a change event).  Monitoring is akin to watching it all the way to splashdown.</p><p>tangelically, Adjective; To go in a direction that is unanticipated.  Origin: 2011.  Related forms; tan.gent.</p></html>",
    mode => '0644',
}

# set a good expires config
file { '/etc/apache2/mods-available/expires.conf':
    ensure => present,
    content => "<IfModule mod_expires.c>\n\tExpiresActive On\n\tExpiresByType application/x-javascript \"access plus 1 year\"\n\tExpiresByType application/javascript \"access plus 1 year\"\n\tExpiresByType text/css \"access plus 1 year\"\n\tExpiresByType image/* \"access plus 1 year\"\n</IfModule>",
    mode => '0644',
    require => Exec [ 'apacheExpires' ],
    notify => Exec[ 'restart-apache2' ],
}

# set a good deflate config
file { '/etc/apache2/mods-enabled/deflate.conf':
    ensure => present,
    content => "IfModule mod_deflate.c>\n\n\t# stuff to deflate\n\tAddOutputFilterByType DEFLATE text/plain text/html text/xml text/css\n\tAddOutputFilterByType DEFLATE application/xml application/xhtml+xml\n\tAddOutputFilterByType DEFLATE application/rss+xml application/atom+xml\n\tAddOutputFilterByType DEFLATE application/javascript text/javascript application/x-javascript\n\n\t#DeflateCompressionLevel 9\n\n\t# work arounds for older browsers\n\tBrowserMatch ^Mozilla/4 gzip-only-text/html\n\tBrowserMatch ^Mozilla/4\\.0[678] no-gzip\n\tBrowserMatch \\bMSI[E] !no-gzip !gzip-only-text/html\n\tBrowserMatch \\bMSIE\s6.0 gzip-only-text/html\n\n\t# Make sure proxies don't deliver the wrong content\n\tHeader append Vary User-Agent env=!dont-vary\n\n\t# logging for testing only\n\tDeflateFilterNote Input instream\n\tDeflateFilterNote Output outstream\n\tDeflateFilterNote Ratio ratio\n\t# logs out size / insize % of orig size\n\tLogFormat '\"%r\" %{outstream}n/%{instream}n (%{ratio}n%%)' deflate\n\tCustomLog /var/log/apache2/deflate_log deflate\n</IfModule>",
    mode => '0644',
    require => Exec [ 'apacheDeflate' ],
    notify => Exec['restart-apache2'],
}

# remove etags
file { '/etc/apache2/conf.d/etags.conf':
    ensure => present,
    content => 'FileETag none',
    mode => '0644',
    notify => Exec['restart-apache2'],
    require => Package [ 'apache2' ],
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

# add a user ...
# require the group!
user { 'greg':
    ensure => present,
    uid => 1001,
    gid => 'greg',
    groups => ['greg', 'sudo','adm', 'cdrom', 'dip', 'video', 'plugdev', 'mythtv', 'sambashare', 'lpadmin' ],
    shell => '/bin/bash',
    managehome => true,
    require => Group['greg'],
}

# create the group
group { 'greg':
    ensure => present,
    gid => 1001,
}

file { '/home/greg/.vimrc':
    ensure => present,
    owner => 'greg',
    group => 'greg',
    content => "set nu\nfiletype indent on\nset autoindent"
}

file { '/home/myth/.vimrc':
    ensure => present,
    owner => 'myth',
    group => 'myth',
    content => "set nu\nfiletype indent on\nset autoindent"
}

# update /etc/default/console-setup and reduce ttys to 3!
exec { 'updateConsoleSetup':
    logoutput => true,
    command => '/usr/bin/perl -p -i -e \'s!ACTIVE_CONSOLES="/dev/tty\[1\-6\]"!ACTIVE_CONSOLES="/dev/tty\[1\-2\]"!\' /etc/default/console-setup',
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
    require => Exec [ 'updateConsoleSetup' ],
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

# install my cannon photo download script
# requires the backup mount!
file { '/backups/scripts/grabCannonImages':
    ensure => present,
    require => Mount['/backups'],
    mode => '0644',
    content => "#!/bin/sh\n# check for rootness\n#if [ \"$UID\" != \"0\" ]; then\n#	echo \"You must be UID 0 (root) to run this! Hint: sudo\"\n#	# add something like this to /etv/sudoers\n#	# %mythtv ALL = NOPASSWD:/backup/scripts/grabCannonImages\n#	exit 1\n#fi\n# ok; go\n\necho \"running\" > /tmp/import\n# remove dir that has been made by myth\necho $1 > /tmp/mythdir\n\n#DIR to use\nDIR=/var/lib/mythtv/pictures/`date +%Y`/`date +%m`/`date +%d`/`date +%H%M`\necho \"putting stuff in $DIR\" >> /tmp/import\n# create dir + parents, do not moan if exists\nmkdir -p ${DIR}\n# move to dir\ncd ${DIR}\npwd\nchmod -R 775 ${DIR}\n# download images from camera\n/usr/bin/gphoto2 -P\nchmod 644 ${DIR}/*\nls -la\n\nexit 0"
}

# setup amixer
file { '/home/myth/.asoundrc':
    ensure => present,
    mode => '0644',
    owner => 'myth',
    group => 'myth',
    content => "### .asoundrc for Acer Revo\n\npcm.dmixer {\n\ttype dmix\n\tipc_key 1024\n\tipc_key_add_uid false\n\tipc_perm 0660\n\tslave {\n\t\tpcm \"hw:0,3\"\n\t\trate 48000\n\t\tchannels 2\n\t\tformat S32_LE\n\t\tperiod_time 0\n\t\tperiod_size 1024\n\t\tbuffer_time 0\n\t\tbuffer_size 4096\n\t}\n}\n\npcm.!default {\n\ttype plug\n\tslave.pcm \"dmixer\"\n}",
}

# switch the screensaver off
file { '/home/myth/.xscreensaver':
    ensure => absent,
}

# remount / with noatime,nodiratime opts
mount { '/':
    ensure => present,
    device => 'UUID=14798928-e487-4208-bf07-a67f0ed3398f',
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

# install pagespeed deb unless it is not installed
# call notify restart
# https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
exec { 'wgetinstallpageSpeedDeb':
    cwd => '/tmp',
    command => '/usr/bin/wget --quiet https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb && dpkg  --install mod-pagespeed-stable_current_amd64.deb',
    unless => '/usr/bin/dpkg --get-selections | grep mod-pagespeed-stable',
    logoutput => true,
    user => root,
    require => Package [ 'apache2' ],
    notify => Exec['restart-apache2'],
}

# enabled ModPagespeed instrumentation
exec { 'ModPagespeedEnableFilters_add_instrumentation':
    logoutput => true,
    unless => '/bin/grep "    ModPagespeedEnableFilters add_instrumentation" /etc/apache2/mods-available/pagespeed.conf',
    command => '/usr/bin/perl -p -i -e \'s/    # ModPagespeedEnableFilters add_instrumentation/    ModPagespeedEnableFilters add_instrumentation/\' /etc/apache2/mods-available/pagespeed.conf',
    notify => Exec[ 'restart-apache2' ],
    require => Exec [ 'wgetinstallpageSpeedDeb' ],
}

# enable ModPagespeed ReportUnloadTime
exec { 'ModPagespeedReportUnloadTime_on':
    logoutput => true,
    unless => '/bin/grep "    ModPagespeedReportUnloadTime on" /etc/apache2/mods-available/pagespeed.conf',
    command => '/usr/bin/perl -p -i -e \'s/    # ModPagespeedReportUnloadTime on/    ModPagespeedReportUnloadTime on/\' /etc/apache2/mods-available/pagespeed.conf',
    notify => Exec['restart-apache2'],
    require => Exec [ 'wgetinstallpageSpeedDeb' ],
}

# Allow access form LAN
exec { 'AllowFromLAN':
    logoutput => true,
    unless => '/bin/grep "        Allow from 192.168.0.0/24" /etc/apache2/mods-available/pagespeed.conf',
    command => '/usr/bin/perl -p -i -e \'s/        Allow from 127.0.0.1/        Allow from 192.168.0.0\/24/g\' /etc/apache2/mods-available/pagespeed.conf',
    notify => Exec['restart-apache2'],
    require => Exec [ 'wgetinstallpageSpeedDeb' ],
}

# correct the pagespeed cache dir perms to avoid
# [Sun Nov 24 08:56:47 2013] [error] [mod_pagespeed 1.6.29.7-3566 @11078] Failed to mkdir /var/cache/mod_pagespeed/!clean!lock!: Permission denied
file { '/var/cache/mod_pagespeed':
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data',
    mode => '0750',
    require => Exec [ 'wgetinstallpageSpeedDeb' ],
}

# install spdy deb unless it is not installed
# call notify restart
# https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_amd64.deb
exec { 'wgetinstallispdy':
    cwd => '/tmp',
    command => '/usr/bin/wget --quiet https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_amd64.deb && dpkg  --install mod-spdy-beta_current_amd64.deb',
    unless => '/usr/bin/dpkg --get-selections | grep mod-spdy-beta',
    logoutput => true,
    user => root,
    notify => Exec['restart-apache2'],
    require => Package [ 'apache2' ],
}

# restart apache if called
exec { 'restart-apache2':
   command => '/usr/sbin/service apache2 restart',
   refreshonly => true,
   logoutput => true,
}

# add the following ssh key for greg
# ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2ZwRYqYv4GTyqaIWUh0tpqzNolOw/+2o38sdaivqmzjPkUszWoC2eEv9WyvyYLtTG5lLEUvjnZgWtdeRAguLEMBSqdJNzOmMqgZ1J+9/R5JcXB/N5tEwqbVQL+HNZYp+R6AEukM7C7HlGfCfPaVGxSt/4u4Ozb69+hZYjWbbCA6cm84AO6c6WzlaFZ9TrGL+Dn/mON62uFqEC6ii3eyZfCfvw8x3zlroa2W670bV6rfERG0ug0zczoDGxcQALHZMkDEGoIiJaMmgxJjR8rjGkggmryZqXe39Nxx8M3ef44c1LAiq0wnRL0uM2e8Z0md7LpOcrzvO8N5pG/O971RoYw== greg@gmbp
ssh_authorized_key { 'gregsshkey':
    ensure => present,
    key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2ZwRYqYv4GTyqaIWUh0tpqzNolOw/+2o38sdaivqmzjPkUszWoC2eEv9WyvyYLtTG5lLEUvjnZgWtdeRAguLEMBSqdJNzOmMqgZ1J+9/R5JcXB/N5tEwqbVQL+HNZYp+R6AEukM7C7HlGfCfPaVGxSt/4u4Ozb69+hZYjWbbCA6cm84AO6c6WzlaFZ9TrGL+Dn/mON62uFqEC6ii3eyZfCfvw8x3zlroa2W670bV6rfERG0ug0zczoDGxcQALHZMkDEGoIiJaMmgxJjR8rjGkggmryZqXe39Nxx8M3ef44c1LAiq0wnRL0uM2e8Z0md7LpOcrzvO8N5pG/O971RoYw==',
    name => greg-gregpublickey,
    type => 'ssh-rsa',
    user => greg
}

# add greg's key into myth as well!
ssh_authorized_key { 'mythsshkey':
    ensure => present,
    key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2ZwRYqYv4GTyqaIWUh0tpqzNolOw/+2o38sdaivqmzjPkUszWoC2eEv9WyvyYLtTG5lLEUvjnZgWtdeRAguLEMBSqdJNzOmMqgZ1J+9/R5JcXB/N5tEwqbVQL+HNZYp+R6AEukM7C7HlGfCfPaVGxSt/4u4Ozb69+hZYjWbbCA6cm84AO6c6WzlaFZ9TrGL+Dn/mON62uFqEC6ii3eyZfCfvw8x3zlroa2W670bV6rfERG0ug0zczoDGxcQALHZMkDEGoIiJaMmgxJjR8rjGkggmryZqXe39Nxx8M3ef44c1LAiq0wnRL0uM2e8Z0md7LpOcrzvO8N5pG/O971RoYw==',
    name => greg-mythpublickey,
    type => 'ssh-rsa',
    user => myth
}
# untar channels.tgz channels icons
exec { 'untgzChannelIcons':
    logoutput => true,
    cwd => '/home/myth/.mythtv/',
    user => myth,
    command => '/bin/tar -zxf /home/myth/nfs/puppet/channels.tar.gz',
    creates => '/home/myth/.mythtv/channels/bbc_one.jpg'
}

file { '/etc/ssh/ssh_host_rsa_key.pub':
    ensure => file,
    owner => root,
    group => root,
    mode => '0644',
    content => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDg5e+BqlIDQ1Zv91rm2JlKDQMk4S+iSxwpSfpVMKc5PxUebQI+XfvJik6rv2wawoxF9KS8i/aog4UUMufXeD1soRNkUvOv8tgABNC2rh0uoojuVDg7cIKaTVcCJzeWWEhxxKncjbYuwXoGw7nCK5GamYstrFnNnPYTr0a/wNikqn6oKviAtFn2lxRycqXdB2FgjZk2GOdJY07GQieYLN+Aq+l0xL+TWoPOExFCvpbI95F3Q6fAkeCYkvPmagUlQBiV2dRlfZEcBKNs1CKdLG37p8ypoXqrWQj3Cz1GAFEJLFY3tP/7CHqi+e5TNmrKiiyO3qSOiw8s/Z84nqC8xYyP root@mythbuntu\n",

}

file { '/etc/ssh/ssh_host_rsa_key':
    ensure => file,
    owner => root,
    group => root,
    mode => '0600',
    content => "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA4OXvgapSA0NWb/da5tiZSg0DJOEvokscKUn6VTCnOT8VHm0C\nPl37yYpOq79sGsKMRfSkvIv2qIOFFDLn13g9bKETZFLzr/LYAATQtq4dLqKI7lQ4\nO3CCmk1XAic3llhIccSp3I22LsF6BsO5wiuRmpmLLaxZzZz2E69Gv8DYpKp+qCr4\ngLRZ9pcUcnKl3QdhYI2ZNhjnSWNOxkInmCzfgKvpdMS/k1qDzhMRQr6WyPeRd0On\nwJHgmJLz5moFJUAYldnUZX2RHASjbNQinSxt+6fMqaF6q1kI9ws9RgBRCSxWN7T/\n+wh6ovnuUzZqyoosjt6kjosPLP2fOJ6gvMWMjwIDAQABAoIBAQDaZ9KhrOM6kgF2\neNRJjR3IoTxla17UEHdHzbUTWE19tbpvstNT9/eWsP9XoW19y2NoaH43MQGYgykR\nBaLLSNT2ErN/YWOQgpir5AFA93QVnvi14wo9BzV+Xg9aYvWDxzaLbb68Fs9PNsun\nmBpk6+TaK7TS5SbNHFqJoVVm0QRTXAGu2Ekz/cVH2n5LGlP+dn6pluweJVj+KlSW\ndsjnLTI4BdmB73FbDg1wTUAdhcVt6gRlRhFFyHV9VhC+mck8XWUCvfCIyxUTZWLs\nY8GmDHyf9Sr2UcQwZ81imFEEmefp+rIs+bXtFG9bszcShDqiq2yWTJlxpnP0cwg0\nD8wk+ujhAoGBAPaUQU/L09YAZfuKFkd1zhrD2lr6HqSJPymRfIo8ANMdMJVkd5l0\ntCfds4nMP58oGelzbrXQz8d5l6RAt/C1gOb7/vWs7hvfeT5w8rfg7HEPCiMZ637p\nzJIKdwJigxkriGkavEDwi2yHWpIfPQ5pmDUnhEPtDSmiyzJWsfOGAYJfAoGBAOl9\nn4swkTTbPTtlhkwEoHrTTPodvXBWXXwAGi+zLqtafdotK3DWD8MGfTQ/BlSQraL/\ne1mTdpw9u+pHPt+aVBorpNIzV81AM/TITcDzSmxVHMFxoxvTQ1LczgIQ1kQfSkCP\ntWOXLfBB/jggxC1f1rv9xED3WCtAOxIXLQdb3QPRAoGAGY7qaiP9dBwcdgMtJgEO\n+PU+B9oPHQzg0CU1XHq1tyw6YfHE99IB7nPrbSgPnCai8PC3E/9t2gY/cpYGutuF\nXevW1I41LAxw28kHT4nv2BQv/81q/H+tZaHSDhw57Hz3qbVMuAp22Sv6dlToljrZ\nvQC4k/XZPGyUVUZpMY29UE8CgYB3EQSm6iFiHtreyyrs4P8lI1OByGCuRJxve23f\nHTSTVRYQiDA63i4zeb+nQOxte0nQcQ/p4fT+P8zv71z0kbKJle/68Qu5MyBLl0lv\nN6GgFNcRHm3a5qTSQJ8dFpDtNDedLKuHGbTna//Dh5ICwXizbPkDWB6yD5MP6pmf\nwwy1wQKBgBRRq5WgTt4HmolfHYhiuAVm6fTxzyHDHEnYUjZXhGzxHvQN21aQpzDX\ngwpphAIz+9nGUvXsyE6z+K8dFfHVcjaIlGDvMNJjaSy+JTv5cJ4akrY0fUSXFbw8\n/mDri7W3Rrvqku3bxEZnk8cFc6PRbv+BwxNyOkYY9NnqUjB+nQvk\n-----END RSA PRIVATE KEY-----\n"
}

# aliase file
file { '/home/myth/.bash_aliases':
    ensure => present,
    owner => 'myth',
    group => 'myth',
    mode => '0644',
    content => 'alias update="sudo apt-get update && sudo apt-get upgrade; sync;sync;sync"',
}

# aliase file
file { '/home/greg/.bash_aliases':
    ensure => present,
    owner => 'greg',
    group => 'greg',
    mode => '0644',
    content => 'alias update="sudo apt-get update && sudo apt-get upgrade; sync;sync;sync"',
}

# set the time, first install a package
package { 'tzdata': }

# set the timezone
file { '/etc/timezone':
    content => "Etc/UTC\n"
}

# update tzdata
# needs the timezone file to be correct and have the tzpackage
exec { 'runDpkgReconfigureTzdata':
    logoutput => true,
    # ubuntu insanity.....
    command => '/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata',
    require => [ File [ '/etc/timezone' ], Package [ 'tzdata' ] ],
    unless => '/bin/grep UTC0 /etc/localtime',
}
