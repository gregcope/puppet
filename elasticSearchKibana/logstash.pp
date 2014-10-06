#
# https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04
# http://logstash.net/docs/1.4.2/tutorials/getting-started-with-logstash
# http://logstash.net/docs/1.4.1/inputs/syslog
# http://christophe.vandeplas.com/search/label/elk
# http://christophe.vandeplas.com/2014/06/setting-up-single-node-elk-in-20-minutes.html
# http://www.ericvb.com/archives/getting-started-on-centralized-logging-with-logstash-elasticsearch-and-kibana
# http://logstash.net/docs/1.1.6/tutorials/metrics-from-logs

# install the logstash 1.3 Apt repo
# only if we have have exec'ed installing the key
# and if we have run, run apt-get update:$

file { '/etc/apt/sources.list.d/logstash1.3.list':
    ensure => present,
    mode => '0644',
    content => "deb http://packages.elasticsearch.org/logstash/1.3/debian stable main",
    require => Exec [ 'addElasticSearchGPGKey' ],
    notify => Exec [ 'aptGetUpdate' ],
}

# added the addElasticSearchGPGKey key
# unless it is already there!
exec { 'addElasticSearchGPGKey':
    logoutput => true,
    cwd => '/tmp',
    command => '/usr/bin/wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -',
    unless => '/usr/bin/apt-key list | /bin/grep D88E42B4',
}

# run apt get Update
# so that our package list is uptodate
exec { "aptGetUpdate":
    logoutput => true,
    command => "/usr/bin/apt-get update",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
}

# elastic search needs Java
# went for openjdk to avoid the oracle nastyness and get something that is 
# updated
# Would have liked openjdk-8...
package { 'openjdk-7-jre-headless':
    ensure => latest,
}

# install logstash
# only if we have the repo, updated, and openJava 7 installed
package { 'logstash':
    ensure => latest,
    require => [ Exec [ 'aptGetUpdate' ], File [ '/etc/apt/sources.list.d/logstash1.4.list' ], Package [ 'openjdk-7-jre-headless' ] ],
}

# install logstash-contrib
# only if we have the repo, updated, and openJava 7 installed
package { 'logstash-contrib':
    ensure => latest,
    require => [ Exec [ 'aptGetUpdate' ], File [ '/etc/apt/sources.list.d/logstash1.4.list' ], Package [ 'openjdk-7-jre-headless' ] ],
}

service { 'logstash':
    ensure => 'running',
    enable => 'true',
    require => [ Package [ 'logstash' ] ],
}

# add logstash user to adm group on ubuntu so that they can read log files etc.
# restart logstash
# only if logstash is installed
user { "logstash":
    ensure => present,
    require => Package [ 'logstash' ],
    notify => Service [ 'logstash' ],
    groups => "adm",
    membership => minimum,
}

