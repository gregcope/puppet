ossecWuiVersion=0.8
#lsbdistcodename facter for precise
#fqdn is facter for full hostname

# to do
# tune ossec (local users)
# adddns (util.sh) monitoring for domains (www/s.webarmadillo.net)
# monitor itself http://www.immutablesecurity.com/index.php/tag/ossec/page/2/
# monitor ossec with zabbix - stats from http://www.immutablesecurity.com/index.php/tag/ossec/page/2/


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
package { 'ossec-hids-local': }
package { 'apache2': }

# config to restart ossec
service { 'ossec-hids-local':
    ensure => 'running',
    enable => 'true',
}

# download ossec-wui and checksum
exec { 'wgetOssecWui':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/wget http://www.ossec.net/files/ossec-wui-$ossecWuiVersion.tar.gz && /usr/bin/wget http://www.ossec.net/files/ossec-wui-$ossecWuiVersion-checksum.txt",
    unless => "/usr/bin/sha1sum -c /tmp/ossec-wui-$ossecWuiVersion-checksum.txt",
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
}

# ensure the ossec-wui perms are correct
file { '/var/www/ossec-wui':
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data'
}

# ensure the ossec-wui/tmp dirs are correct
file { '/var/www/ossec-wui/tmp':
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data',
    mode => '0770',
}

# unpack the targz if everything else is done
exec { 'untgzOssecWui':
    logoutput => true,
    cwd => '/var/www',
    user => 'www-data',
    command => '/bin/tar -C /var/www/ossec-wui -zxf /tmp/ossec-wui-$ossecWuiVersion.tar.gz',
    creates => '/var/www/ossec-wui/index.php',
    require => [ File [ '/var/www/ossec-wui/tmp' ], User [ 'www-data' ], File [ '/var/www/ossec-wui' ], Exec [ 'wgetOssecWui' ], Package [ 'ossec-hids-local' ], Package [ 'apache2' ] ],
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
    require => Exec [ 'addnicolasZinPrecisekey' ]
}

# added the nicolas-zin key
# unless it is already there!
exec { 'addnicolasZinPrecisekey':
    logoutput => true,
    command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x66eb6ad20c4ff926',
    unless => '/usr/bin/apt-key list | /bin/grep 0C4FF926'
}

# create /var/log/chkrootkit/log.expected if it does not exist
exec { '/var/log/chkrootkit/log.expected':
    logoutput => true,
    unless => '/bin/ls /var/log/chkrootkit/log.expected',
    command => '/etc/cron.daily/chkrootkit && /bin/cp -a /var/log/chkrootkit/log.today /var/log/chkrootkit/log.expected',
    require => File [ '/etc/chkrootkit.conf' ],
}
