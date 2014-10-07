#
# https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04
#

# install the logstash-forwarder repo
# only if we have have exec'ed installing the key
# and if we have run, run apt-get update
file { '/etc/apt/sources.list.d/logstashforwarder.list':
    ensure => present,
    mode => '0644',
    content => "deb http://packages.elasticsearch.org/logstashforwarder/debian stable main",
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

# install logstash-forwarder
# only if we have the repo, updated, and openJava 7 installed
package { 'logstash-forwarder':
    ensure => latest,
    require => [ Exec [ 'aptGetUpdate' ], File [ '/etc/apt/sources.list.d/logstashforwarder.list' ] ],
}

#file { '/etc/logstash/conf.d/10-syslog.conf':
#    ensure => present,
#    mode => '0644',
#    content => "filter {\n  if [type] == 'syslog' {\n    grok {\n      match => { 'message' => '%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\\[%{POSINT:syslog_pid}\\])?: %{GREEDYDATA:syslog_message}' }\n      add_field => [ 'received_at', '%{@timestamp}' ]\n      add_field => [ 'received_from', '%{host}' ]\n    }\n    syslog_pri { }\n    date {\n      match => [ 'syslog_timestamp', 'MMM  d HH:mm:ss', 'MMM dd HH:mm:ss' ]\n    }\n  }\n}\n",
#    require => [ Package [ 'logstash' ] ],
#}

#file { '/etc/logstash-forwarder':
#    ensure => present,
#    mode => '0644',
#    content => "{\n  'network': {\n    'servers': [ '192.168.0.6:5000' ],\n    'timeout': 15,\n    'ssl ca': '/etc/logstash/logstash-forwarder.crt'\n  },\n  'files': [\n      {\n      'paths': [\n        '/var/log/syslog',\n        '/var/log/auth.log'\n       ],\n      'fields': { 'type': 'syslog' }\n     }\n   ]\n}\n",
#    require => [ Package [ 'logstash-forwarder' ] ],
#}

service { 'logstash-forwarder':
    ensure => 'running',
    enable => 'true',
    #require => [ Package [ 'logstash-forwarder' ], File [ '/etc/pki/tls/certs/logstash-forwarder.crt' ], File [ '/etc/logstash-forwarder' ] ],
    require => [ Package [ 'logstash-forwarder' ] ],
}

# add logstash user to adm group on ubuntu so that they can read log files etc.
# restart logstash
# only if logstash is installed
user { "logstash":
    ensure => present,
    require => Package [ 'logstash-forwarder' ],
    notify => Service [ 'logstash-forwarder' ],
    groups => "adm",
    membership => minimum,
}

