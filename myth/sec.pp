$ossecWuiVersion='0.8'
$arachniVersion="0.4.5.2-0.4.2.1"
$httphostname='www.webarmadillo.net'
$dnstld='webarmadillo.net'
$ossecsha1sum=1f813e057d8726a0f0db3a712f87d2db6973551b

#lsbdistcodename facter for precise
#fqdn is facter for full hostname

# done: 
# tune ossec (local users)
# monitor itself http://www.immutablesecurity.com/index.php/tag/ossec/page/2/
# monitor these ubuntu files
# — /var/log/messages
# — /var/log/auth.log
# — /var/log/syslog
# — /var/log/mail.info
# — /var/log/dpkg.log
# adddns (util.sh) monitoring for domains (www.webarmadillo.net)
# adddns (util.sh) monitoring for domains (webarmadillo.net)
# addsite (util.sh) monitoring for domains (www.webarmadillo.net)
#
# todo:
# https://github.com/comotion/VSF
# monitor ossec with zabbix - stats from http://www.immutablesecurity.com/index.php/tag/ossec/page/2/
# http://www.thefanclub.co.za/how-to/how-install-apache2-modsecurity-and-modevasive-ubuntu-1204-lts-server mod security?
#
# referances:
# http://www.security-marathon.be/?p=951
# https://github.com/nzin/puppet-ossec/blob/master/templates/10_ossec.conf.erb
# http://dcid.me/blog/2011/10/3woo-alerting-on-dns-ip-address-changes/
# SSL confg;
# http://security.stackexchange.com/questions/51680/optimal-web-server-ssl-cipher-suite-configuration/51730#51730
# https://www.ssllabs.com/ssltest/analyze.html

# ensure root cannot login directly
# Stop DNS lookups so that ssh logins are not delayed
# restart ssh
augeas { '/etc/ssh/sshd_config':
    context => '/files/etc/ssh/sshd_config',
    changes => [ 'set PermitRootLogin no', 'set UseDNS no'],
    notify => Service [ 'ssh' ],
}


# config to restart ssh
service { 'ssh':
    ensure => 'running',
    enable => 'true',
    require => Augeas [ '/etc/ssh/sshd_config' ]
}

# add some packages
package { 'chkrootkit': }
package { 'rkhunter': }
package { 'ossec-hids-local': 
    require => Exec [ 'aptGetUpdate' ]
}
package { 'apache2': }

# config to restart ossec
service { 'ossec-hids-local':
    ensure => 'running',
    enable => 'true',
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ] ],
}

# download ossec-wui checksum
exec { 'curlOssecWuiChecksum':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/curl -OsS http://www.ossec.net/files/ossec-wui-${ossecWuiVersion}-checksum.txt",
    unless => "/bin/ls /tmp/ossec-wui-${ossecWuiVersion}-checksum.txt"
}

# download ossec-wui and checksum
exec { 'curlOssecWui':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/curl -OsS http://www.ossec.net/files/ossec-wui-${ossecWuiVersion}.tar.gz",
    unless => "/usr/bin/sha1sum -c /tmp/ossec-wui-${ossecWuiVersion}-checksum.txt",
    require => Exec [ 'curlOssecWuiChecksum' ],
}

# download arachni checksum
exec { 'curlArachniChecksum':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/curl -OsS http://downloads.arachni-scanner.com/arachni-${arachniVersion}-linux-x86_64.tar.gz.sha1",
    unless => "/bin/ls /tmp/arachni-${arachniVersion}-linux-x86_64.tar.gz.sha1"
}

# download arachni if checksum is found
exec { 'curlArachni':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/curl -OsS http://downloads.arachni-scanner.com/arachni-${arachniVersion}-linux-x86_64.tar.gz",
    unless => "/bin/echo \"`/bin/cat /tmp/arachni-${arachniVersion}-linux-x86_64.tar.gz.sha1`  arachni-${arachniVersion}-linux-x86_64.tar.gz\" | /usr/bin/sha1sum -c -",
    require => Exec [ 'curlArachniChecksum' ],

}

# add Apache ossec-wui auth config
file { '/etc/apache2/conf.d/ossec-wui-auth':
    ensure => present,
    content => "<Location /ossec-wui>\n\tOrder deny,allow\n\tAuthType Basic\n\tAuthName ossec-wui\n\tAuthUserFile /etc/apache2/web-htpassword\n\tRequire valid-user\n\tSatisfy any\n\tDeny from all\n\tAllow from 192.168.0.0/24 127.0.0.1\n\tSatisfy Any\n</Location>",
    mode => '0644',
    notify => Service [ 'apache2' ],
    require => Package [ 'apache2' ],
}

# add www-data to ossec group
user { 'www-data':
    groups => 'ossec',
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ] ],
}

# ensure the ossec-wui perms are correct
file { '/var/www/ossec-wui':
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data',
    recurse => true,
    require => Exec [ 'mvOssecWui' ],
}

# ensure the ossec-wui/tmp dirs are correct
file { '/var/www/ossec-wui/tmp':
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data',
    mode => '0770',
    require => File [ '/var/www/ossec-wui' ],
}

# unpack the targz if everything else is done
exec { 'untgzOssecWui':
    logoutput => true,
    cwd => '/tmp',
    user => 'www-data',
    command => "/bin/tar -zxf /tmp/ossec-wui-${ossecWuiVersion}.tar.gz",
    unless => '/bin/ls -la /var/www/ossec-wui/index.php',
    require => [ Exec [ 'aptGetUpdate' ], User [ 'www-data' ], Exec [ 'curlOssecWui' ], Package [ 'ossec-hids-local' ], Package [ 'apache2' ] ],
}

# move the ossec-wui-version to ossec-wui ...
exec { 'mvOssecWui':
    logoutput => true,
    cwd => '/tmp',
    command => "/bin/mv ossec-wui-${ossecWuiVersion} /var/www/ossec-wui",
    unless => '/bin/ls -la /var/www/ossec-wui/index.php',
    require => Exec [ 'untgzOssecWui' ],
    notify => Service [ 'apache2' ],
}

# set Apache ServerTokens Prod
exec { 'apacheServerTokens':
    logoutput => true,
    unless => '/bin/grep "ServerTokens Prod" /etc/apache2/conf.d/security',
    command => '/usr/bin/perl -p -i -e "s/^ServerTokens.*$/ServerTokens Prod/" /etc/apache2/conf.d/security',
    notify => Service [ 'apache2' ],
}

# apache service restart config
service { 'apache2':
    ensure => 'running',
    enable => 'true',
}

# Ensure the chrootkit.cong is ok
file { '/etc/chkrootkit.conf':
    ensure => present,
    mode => '0644',
    require => Package [ 'chkrootkit' ],
    content => "RUN_DAILY=\"true\"\n#Added /usr/lib/pymodules/python2.7/.path GJJC 20131212\nRUN_DAILY_OPTS=\"-q -e /usr/lib/pymodules/python2.7/.path\"\nDIFF_MODE=\"true\"\n",
}

#
# if chkrootkit has gone off, tidy up as it should have bleated in email
# needs config to have been changed
file { '/etc/cron.daily/XXXresetCheckrootkit':
    ensure => present,
    mode => '0755',
    require => File [ '/etc/chkrootkit.conf' ],
    content => "#!/bin/sh\n\nif /usr/bin/diff -u /var/log/chkrootkit/log.expected /var/log/chkrootkit/log.today ; then\n\texit 0\nelse\n\t/bin/cp -a -f /var/log/chkrootkit/log.today /var/log/chkrootkit/log.expected\n\t/bin/echo \"Reset /var/log/chkrootkit/log.expected on `date`\" | /usr/bin/mail -s 'Reset /var/log/chkrootkit/log.expected' root\nfi\n",
}

# Ensure the rkhunter.conf is ok
file { '/etc/rkhunter.conf.local':
    ensure => present,
    mode => '0644',
    content => "SCRIPTWHITELIST=/usr/bin/unhide.rb\nMAIL-ON-WARNING=\"root\"\nALLOWHIDDENDIR=\"/dev/.udev\"\nALLOWHIDDENFILE=\"/dev/.blkid.tab\"\nALLOWDEVFILE=\"/dev/.initramfs\"\n"
}

# add an ossec ppa
file { '/etc/apt/sources.list.d/nicolas-zin-precise.list':
    ensure => present,
    mode => '0644',
    content => "deb http://ppa.launchpad.net/nicolas-zin/ossec-ubuntu/ubuntu precise main\ndeb-src http://ppa.launchpad.net/nicolas-zin/ossec-ubuntu/ubuntu precise main\n",
}

# added the nicolas-zin key
# unless it is already there!
exec { 'addnicolasZinPrecisekey':
    logoutput => true,
    command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x66eb6ad20c4ff926',
    unless => '/usr/bin/apt-key list | /bin/grep 0C4FF926',
    require => File [ '/etc/apt/sources.list.d/nicolas-zin-precise.list' ],
}

# run apt-get after KeyInstall
exec { "aptGetUpdate":
    command => "/usr/bin/apt-get update",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
    require => Exec [ 'addnicolasZinPrecisekey'  ],
}


# create /var/log/chkrootkit/log.expected if it does not exist
exec { '/var/log/chkrootkit/log.expected':
    logoutput => true,
    unless => '/bin/ls /var/log/chkrootkit/log.expected',
    command => '/etc/cron.daily/chkrootkit && /bin/cp -a /var/log/chkrootkit/log.today /var/log/chkrootkit/log.expected',
    require => File [ '/etc/chkrootkit.conf' ],
}

# update ossec email_to in /var/ossec/etc/ossec.conf
# from <email_to>daniel.cid@xxx.com</email_to>
# to <email_to>root@localhost</email_to>
# requires ossec install
exec { 'updateOssecEmail':
    logoutput => true,
    unless => '/bin/grep "<email_to>root@localhost</email_to>" /var/ossec/etc/ossec.conf',
    command => '/usr/bin/perl -p -i -e "s/<email_to>.*<\/email_to>/<email_to>root\@localhost<\/email_to>/" /var/ossec/etc/ossec.conf',
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ], Exec [ 'copyCurlOssec.conf' ] ],
    notify => Service [ 'ossec-hids-local' ],
}

# update ossec smtp server in /var/ossec/etc/ossec.conf
# from <smtp_server>smtp.xxx.com.</smtp_server>
# to <smtp_server>localhost</smtp_server>
# requires ossec install
exec { 'updateOssecsmtp':
    logoutput => true,
    unless => '/bin/grep "<smtp_server>localhost</smtp_server>" /var/ossec/etc/ossec.conf',
    command => '/usr/bin/perl -p -i -e "s/<smtp_server>.*<\/smtp_server>/<smtp_server>localhost<\/smtp_server>/" /var/ossec/etc/ossec.conf',
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ], Exec [ 'copyCurlOssec.conf' ] ],
    notify => Service [ 'ossec-hids-local' ],
}

# update ossec email from in /var/ossec/etc/ossec.conf
# from <email_from>ossecm@ossec.xxx.com.</email_from>
# to <email_from>ossec@$fqdn</email_from>
# requires ossec install
exec { 'updateOssecemailfrom':
    logoutput => true,
    unless => "/bin/grep '<email_from>ossec@$fqdn</email_from>' /var/ossec/etc/ossec.conf",
    command => "/usr/bin/perl -p -i -e 's/<email_from>.*<\\/email_from>/<email_from>ossec\\@$fqdn<\\/email_from>/' /var/ossec/etc/ossec.conf",
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ], Exec [ 'copyCurlOssec.conf' ] ],
    notify => Service [ 'ossec-hids-local' ],
}

file { '/etc/cron.daily/ossecStats.sh':
    ensure => file,
    mode => '0755',
    content => "#!/bin/bash\n\necho Ossec daily stats for `/bin/hostname --fqdn` on `/bin/date`\necho \"\n\"\n#Reset counters\nCOUNT=0\nEPSSUM=0\nEPSAVG=0\n#Source OSSEC Dir\n. /etc/ossec-init.conf\n\nfor i in \$(grep 'Total events for day' \${DIRECTORY}/stats/totals/*/*/ossec-totals-*.log | cut -d: -f3); do\n\tCOUNT=\$((COUNT+1))\n\tDAILYEVENTS=\$i\n\tEPSSUM=\$((\$DAILYEVENTS+\$EPSSUM))\ndone\n\nEPSAVG=`echo \"scale=3; \$EPSSUM/\$COUNT/86400\" | /usr/bin/bc -l`\n\necho Ossec total lifetime number of events colected is: \$EPSSUM\necho Ossec total daily number of events average is: \$((\$EPSSUM/\$COUNT))\necho Ossec daily events per second average is: \$EPSAVG\n",
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ] ],
}

# download and install https://github.com/gregcope/stuff/raw/master/myth/ossec.conf
# make a backup and make sure the perms are correct
# unless the sha1sum is cosher
exec { 'curlOssec.conf':
    logoutput => true,
    cwd => '/var/ossec/etc',
    command => '/usr/bin/curl -OsS https://github.com/gregcope/stuff/raw/master/myth/ossec-ubuntu.conf && chmod 400 /var/ossec/etc/ossec-ubuntu.conf',
    unless => "/usr/bin/sha1sum /var/ossec/etc/ossec-ubuntu.conf | /bin/grep $ossecsha1sum",
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ] ],
    notify => Service [ 'ossec-hids-local' ],
}

# Copy downloaded ossec config file unless it has been copied in
# make backup, ensure perms are correct
exec { 'copyCurlOssec.conf':
    logoutput => true,
    cwd => '/var/ossec/etc',
    command => '/bin/mv /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.`date +%Y%m%dT%H%M%S` && cp /var/ossec/etc/ossec-ubuntu.conf /var/ossec/etc/ossec.conf && chmod 400 /var/ossec/etc/ossec.conf',
    unless => '/bin/grep "edits by Greg" /var/ossec/etc/ossec.conf',
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ], Exec [ 'curlOssec.conf' ] ],
}

# Add DNS check for webarmadillo.net
# Unless this is in the config <command>host -W 5 -t NS webarmadillo.net; host -W 5 -t A webarmadillo.net | sort</command>
exec { 'ossecDNScheckfortld':
    logoutput => true,
    unless => "/bin/grep '<command>host -W 5 -t NS $dnstld; host -W 5 -t A $dnstld | sort</command>' /var/ossec/etc/ossec.conf",
    command => "/var/ossec/bin/util.sh adddns $dnstld",
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ], Exec [ 'copyCurlOssec.conf' ] ],
    notify => Service [ 'ossec-hids-local' ],
}

# Add DNS check for www.webarmadillo.net
# Unless this is in the config <command>host -W 5 -t NS www.webarmadillo.net; host -W 5 -t A www.webarmadillo.net | sort</command>
exec { 'ossecDNScheckforwww':
    logoutput => true,
    unless => "/bin/grep '<command>host -W 5 -t NS $httphostname; host -W 5 -t A $httphostname | sort</command>' /var/ossec/etc/ossec.conf",
    command => "/var/ossec/bin/util.sh adddns $httphostname",
    notify => Service [ 'ossec-hids-local' ],
}

# Add web check for www.webarmadillo.net
# unless this is in the config <command>lynx --connect_timeout 10 --dump www.webarmadillo.net | head -n 10</command>
exec { 'ossecWEBcheckforwww':
    logoutput => true,
    unless => "/bin/grep '<command>lynx --connect_timeout 10 --dump $httphostname | head -n 10</command>' /var/ossec/etc/ossec.conf",
    command => "/var/ossec/bin/util.sh addsite $httphostname",
    require => [ Package [ 'ossec-hids-local' ], Exec [ 'aptGetUpdate' ], Exec [ 'copyCurlOssec.conf' ] ],
    notify => Service [ 'ossec-hids-local' ],
}

# config host.allow to allow private network
# assumes we want eth0 to work
# facter -p | grep 192
# facter -p | grep 255
# $network_eth0 /$netmask_eth0
exec { 'hostsAllow':
    logoutput => true,
    command => "/bin/echo 'ALL: $network_eth0/$netmask_eth0' >> /etc/hosts.allow",
    unless => "/bin/grep 'ALL: $network_eth0/$netmask_eth0' /etc/hosts.allow",
}

