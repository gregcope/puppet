#
#
#

# install the Elastic Search 1.3 Apt repo
# only if we have have exec'ed installing the key
# and if we have run, run apt-get update
file { '/etc/apt/sources.list.d/elasticSearch1.3.list':
    ensure => present,
    mode => '0644',
    content => "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main",
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

# install elasticSearch
# only if we have an uptodate package list, have apt-get updated and also installed openjdk7
package { 'elasticsearch':
    ensure => latest,
    require => [ Exec [ 'aptGetUpdate' ], File [ '/etc/apt/sources.list.d/elasticSearch1.3.list' ], Package [ 'openjdk-7-jre-headless' ] ],
}

# elastic search needs Java
# went for openjdk to avoid the oracle nastyness and get something that is 
# updated
# Would have liked openjdk-8...
package { 'openjdk-7-jre-headless':
    ensure => latest,
}

service { 'elasticsearch':
    ensure => 'running',
    enable => 'true',
    require => [ Package [ 'elasticsearch' ] ],
}

# only allow elastic search from localhost so that we can secure it to Apache
# http://blog.eslimasec.com/2014/05/elastic-security-deploying-logstash.html
# update config file
# only if it needs it
# restart elasticSearch
exec { 'updateElasticeSearchPort':
    logoutput => true,
    unless => '/bin/grep "network.host: 127.0.0.1" /etc/elasticsearch/elasticsearch.yml', 
    command => '/bin/echo "network.host: 127.0.0.1" >> /etc/elasticsearch/elasticsearch.yml',
    notify => Service [ 'elasticsearch' ],
}

