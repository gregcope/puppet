$kibanaVersion='3.1.0'

# download kibana
# unless file is there...
exec { 'curlkibanatargz':
    logoutput => true,
    cwd => '/tmp',
    command => "/usr/bin/curl -OsS https://download.elasticsearch.org/kibana/kibana/kibana-${kibanaVersion}.tar.gz",
    unless => "/bin/ls /tmp/kibana-${kibanaVersion}.tar.gz",
}

# make sure the perms/dir is there
file { '/var/www/kibana':
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data',
    recurse => true,
}

# unpack download
# unless not already unpacked
exec { 'untgzkibana':
    logoutput => true,
    user => 'www-data',
    cwd => '/tmp',
    command => "/bin/tar -zxf /tmp/kibana-${kibanaVersion}.tar.gz",
    unless => "/bin/ls -la /tmp/kibana-${kibanaVersion}/index.html",
    require => [ Exec [ 'curlkibanatargz' ] ],
}

# This is the actual install of kibana
# require;
#     that we have unzipped the tar
#     created the webroot
#     And secured the apache config
exec { 'cpkibana':
    logoutput => true,
    cwd => "/tmp/kibana-${kibanaVersion}",
    user => 'www-data',
    command => "/bin/cp -r * /var/www/kibana/",
    unless => '/bin/ls -la /var/www/kibana/index.html',
    require => [ Exec [ 'untgzkibana' ], File [ '/var/www/kibana' ], File [ '/etc/apache2/conf.d/kibana-auth' ] ],
}

# add Apache kibana authconfig
# Do not require auth for localhost or local subnet
# otherwise use our standard http passwd file
file { '/etc/apache2/conf.d/kibana-auth':
     ensure => present,
     content => "<Location /kibana>\n\tOrder deny,allow\n\tAuthType Basic\n\tAuthName Kibana\n\tAuthUserFile /etc/apache2/web-htpassword\n\tRequire valid-user\n\tSatisfy any\n\tDeny from all\n\tAllow from 192.168.0.0/24 127.0.0.1\n\tSatisfy Any\n</Location>",
     mode => '0644',
     notify => Service [ 'apache2' ],
     require => Package [ 'apache2' ],
}

# although this are often already here
# puppet barfs if not declared in this file
package { 'apache2': }
package { 'elasticsearch': }

# apache service restart config
service { 'apache2':
    ensure => 'running',
    enable => 'true',
}

# going to redirect kibana to use a secured /kibana/elasticsearch for 
# elasticsearch to secure it from the world
# http://blog.eslimasec.com/2014/05/elastic-security-deploying-logstash.html
# http://serverfault.com/questions/521096/secure-logstash-and-elasticsearch
file { '/etc/apache2/conf.d/kibana.conf':
    ensure => present,
    #content => "ProxyRequests off\nProxyPass /elasticsearch/ http://localhost:9200/\n<Location /elasticsearch/>\n\tProxyPassReverse /\n\tSSLRequireSSL\n</Location>\n",
    content => "ProxyRequests off\nProxyPass /kibana/elasticsearch/ http://localhost:9200/\n<Location /kibana/elasticsearch/>\n\tProxyPassReverse /\n</Location>\n",
    mode => '0644',
    notify => Service [ 'apache2' ],
    require => [ Package [ 'apache2' ], Exec [ 'apacheProxy' ] ],
}

# We need the proxy module
# a2enmod it unless already there 
# restart apache if this runs
exec { 'apacheProxy':
    logoutput => true,
    command => '/usr/sbin/a2enmod proxy',
    unless => '/bin/readlink -e /etc/apache2/mods-enabled/proxy.load',
    require => Package[ 'apache2' ],
    notify => Service [ 'apache2' ],
}

# We need the proxy_http module
# a2enmod it unless already there 
# restart apache if this runs
exec { 'apacheProxyHttp':
    logoutput => true,
    command => '/usr/sbin/a2enmod proxy_http',
    unless => '/bin/readlink -e /etc/apache2/mods-enabled/proxy_http.load',
    require => Package[ 'apache2' ],
    notify => Service [ 'apache2' ],
}

# adjust kibana config to connect to the right relative URI for where we have
# put elasticsearch
# under kibana as this as a loction config stanza
# require that we have copied kibana in
exec { 'updateKibanaConfig.js':
    logoutput => true,
    unless => '/bin/grep \'    elasticsearch: "/kibana/elasticsearch/",\' /var/www/kibana/config.js',
    command => '/usr/bin/perl -p -i -e \'s/^    elasticsearch:(.*)$/    elasticsearch: "\/kibana\/elasticsearch\/"\,/\' /var/www/kibana/config.js',
    require => [ Exec ['cpkibana'] ],
}
