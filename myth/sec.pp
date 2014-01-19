$ossecWuiVersion='0.8'
$arachniVersion="0.4.5.2-0.4.2.1"
#lsbdistcodename facter for precise
#fqdn is facter for full hostname

# to do
# done: 
# tune ossec (local users)
# adddns (util.sh) monitoring for domains (www/s.webarmadillo.net)
# monitor itself http://www.immutablesecurity.com/index.php/tag/ossec/page/2/
#
# todo:
# monitor ossec with zabbix - stats from http://www.immutablesecurity.com/index.php/tag/ossec/page/2/
# http://www.thefanclub.co.za/how-to/how-install-apache2-modsecurity-and-modevasive-ubuntu-1204-lts-server mod security?
#
# referances:
# http://www.security-marathon.be/?p=951
# https://github.com/nzin/puppet-ossec/blob/master/templates/10_ossec.conf.erb

# ensure root cannot login directly
augeas { '/etc/ssh/sshd_config':
    context => '/files/etc/ssh/sshd_config',
    changes => [ 'set PermitRootLogin no'],
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
exec { 'wgetOssecWuiChecksum':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/wget http://www.ossec.net/files/ossec-wui-${ossecWuiVersion}-checksum.txt",
    unless => "/bin/ls /tmp/ossec-wui-${ossecWuiVersion}-checksum.txt"
}

# download ossec-wui and checksum
exec { 'wgetOssecWui':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/wget http://www.ossec.net/files/ossec-wui-${ossecWuiVersion}.tar.gz",
    unless => "/usr/bin/sha1sum -c /tmp/ossec-wui-${ossecWuiVersion}-checksum.txt",
    require => Exec [ 'wgetOssecWuiChecksum' ],
}

# download arachni checksum
exec { 'wgetArachniChecksum':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/wget http://downloads.arachni-scanner.com/arachni-${arachniVersion}-linux-x86_64.tar.gz.sha1",
    unless => "/bin/ls /tmp/arachni-${arachniVersion}-linux-x86_64.tar.gz.sha1"
}

# download arachni if checksum is found
exec { 'wgetArachni':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/wget http://downloads.arachni-scanner.com/arachni-${arachniVersion}-linux-x86_64.tar.gz",
    unless => "/bin/echo \"`/bin/cat /tmp/arachni-${arachniVersion}-linux-x86_64.tar.gz.sha1`  arachni-${arachniVersion}-linux-x86_64.tar.gz\" | /usr/bin/sha1sum -c -",
    require => Exec [ 'wgetArachniChecksum' ],
}

# add Apache ossec-wui auth config
file { '/etc/apache2/conf.d/ossec-wui-auth':
    ensure => present,
    content => "<Location /ossec-wui>\n\tAuthType Basic\n\tAuthName ossec-wui\n\tAuthUserFile /etc/apache2/web-htpassword\n\tRequire valid-user\n\tSatisfy any\n\tDeny from all\n\tAllow from 192.168.0.0/24\n</Location>",
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
    require => [ Exec [ 'aptGetUpdate' ], User [ 'www-data' ], Exec [ 'wgetOssecWui' ], Package [ 'ossec-hids-local' ], Package [ 'apache2' ] ],
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
