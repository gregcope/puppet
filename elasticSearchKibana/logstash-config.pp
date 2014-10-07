file { '/etc/logstash/conf.d/10-syslog.conf':
    ensure => present,
    mode => '0644',
    content => "filter {\n  if [type] == 'syslog' {\n    grok {\n      match => { 'message' => '%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\\[%{POSINT:syslog_pid}\\])?: %{GREEDYDATA:syslog_message}' }\n      add_field => [ 'received_at', '%{@timestamp}' ]\n      add_field => [ 'received_from', '%{host}' ]\n    }\n    syslog_pri { }\n    date {\n      match => [ 'syslog_timestamp', 'MMM  d HH:mm:ss', 'MMM dd HH:mm:ss' ]\n    }\n  }\n}\n",
}
