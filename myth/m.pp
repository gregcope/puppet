# set some defaults before we go...
$mysqlPassword = 

# lets make sure we have 0.27 installed
package { 'libmyth-0.27-0':
    ensure => installed,
}

# and that the service has upgraded
# restart mythbackend
exec { 'restartmythtvbackend':
    logoutput => true,
    command => '/usr/bin/service mythtv-backend restart',
    unless => '/bin/grep "Upgrading to MythTV schema version 1317" /var/log/mythtv/mythbackend.log && /bin/grep "(UpgradeTVDatabaseSchema) Database schema upgrade complete." /var/log/mythtv/mythbackend.log',
    require => Package [ 'libmyth-0.27-0' ],
}
 
# tweak mysql to my liking
file { '/etc/mysql/conf.d/mythtv-tweaks.cnf':
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    content => "[mysqld]\n# The following values were partly taken from:\n# http://www.gossamer-threads.com/lists/mythtv/users/90942#90942\n# and http://www.mythtv.org/wiki/Tune_MySQL\nkey_buffer_size = 64M\n# max_allowed_packet = 8M\ntable_cache = 256\nsort_buffer_size = 48M\nnet_buffer_length = 1M\n# thread_cache_size = 4\nquery_cache_type = 1\nquery_cache_size = 32M\nquery_cache_limit = 3M\ntmp_table_size = 32M\nmax_heap_table_size = 32M\n# don't do binary logs for mythconverg\nbinlog_ignore_db = mythconverg",
    require => Package [ 'libmyth-0.27-0' ],
}

# tweak X
file { '/home/myth/.xinitrc':
    ensure => present,
    mode => '0644',
    owner => myth,
    group => myth,
    content => "{\nxset s off\nxset -dpms\n}",
}

# install optimise myth cron.daily file
file { '/etc/cron.daily/optimize_mythdb':
    ensure => present,
    mode => '0755',
    content => "#!/bin/sh\n\nOPT_MYTHDB='/usr/share/doc/mythtv-backend/contrib/maintenance/optimize_mythdb.pl'\nLOG='/var/log/mythtv/optimize_mythdb.log'\n\necho \"Started \${OPT_MYTHDB} on `date`\" >> \${LOG}\n\${OPT_MYTHDB} >> \${LOG}\necho \"Finished \${OPT_MYTHDB} on `date`\" >> \${LOG}",
    require => Exec [ 'restartmythtvbackend' ],
}

# ensure mixer is on to allow sound in myth
# unless it is already set
exec { 'amixeriec958':
    logoutput => true,
    command => '/usr/bin/amixer set \'IEC958\',1 on',
    unless => '/usr/bin/amixer get \'IEC958\',1 | /bin/grep -F \'[on]\''
}

# ensure vol is max for myth
# unless it is already set
exec { 'amixermaster':
    command => '/usr/bin/amixer set \'Master\',0 Playback 64',
    unless => '/usr/bin/amixer get \'Master\',0  | /bin/grep -F \'Playback 64 [100%] [0.00dB] [on]\''
}

# update the DefaultVideoPlaybackProfile to VDPAU Normal unless already set
# uses $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetDefaultVideoPlaybackProfile':
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"VDPAU Normal\" WHERE value=\"DefaultVideoPlaybackProfile\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"DefaultVideoPlaybackProfile\" AND data=\"VDPAU Normal\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update the AudioOutputDevice to Nvidia,Dev=0 unless it is already set
# uses $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetAudioOutputDevice':
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"ALSA:hdmi:CARD=NVidia,DEV=0\" WHERE value=\"AudioOutputDevice\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"AudioOutputDevice\" AND data=\"ALSA:hdmi:CARD=NVidia,DEV=0\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update NetworkControlEnabled to 1 unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetNetworkControlEnabled':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"1\" WHERE value=\"NetworkControlEnabled\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"NetworkControlEnabled\" AND data=\"1\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update Language to en_GB unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetLanguage':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"en_GB\" WHERE value=\"Language\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"Language\" AND data=\"en_GB\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update DateFormat to ddd d MMM yyyy unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetDateFormat':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"ddd d MMM yyyy\" WHERE value=\"DateFormat\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"DateFormat\" AND data=\"ddd d MMM yyyy\"' | /bin/grep 1",
    require => Package [ 'libmyth-0.27-0' ],
}

# update ShortDateFormat to ddd d unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetShortDateFormat':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"ddd d\" WHERE value=\"ShortDateFormat\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"ShortDateFormat\" AND data=\"ddd d\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update TimeFormat to hh:mm unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetTimeFormat':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"hh:mm\" WHERE value=\"TimeFormat\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"TimeFormat\" AND data=\"hh:mm\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update MasterMixerVolume to 100 unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetMasterMixerVolume':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"100\" WHERE value=\"MasterMixerVolume\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"MasterMixerVolume\" AND data=\"100\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update PCMMixerVolume to 100 unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetPCMMixerVolume':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"100\" WHERE value=\"PCMMixerVolume\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"PCMMixerVolume\" AND data=\"100\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update LiveTVIdleTimeout to 120 unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetLiveTVIdleTimeout':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'INSERT into mythconverg.settings (value,data,hostname) VALUES (\"LiveTVIdleTimeout\", \"120\", \"s\")'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"LiveTVIdleTimeout\" AND data=\"120\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update PlaybackWatchList to 0 unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetPlaybackWatchList':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"0\" WHERE value=\"PlaybackWatchList\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"PlaybackWatchList\" AND data=\"0\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update MythArchiveDateFormat to %a %d %b %Y unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetMythArchiveDateFormat':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"%a %d %b %Y\" WHERE value=\"MythArchiveDateFormat\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"MythArchiveDateFormat\" AND data=\"%a %d %b %Y\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update MythArchiveTimeFormat to %H:%M unless it is already set
# uses the $hostname for the settings table
# do this after 0.27 install
exec { 'mythsetMythArchiveTimeFormat':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"%H:%M\" WHERE value=\"MythArchiveTimeFormat\" AND hostname=\"$hostname\"'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname=\"$hostname\" AND value=\"MythArchiveTimeFormat\" AND data=\"%H:%M\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update AutoExpireWatchedPriority to 1 unless it is already set
# do this after 0.27 install
exec { 'mythsetAutoExpireWatchedPriority':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"1\" WHERE value=\"AutoExpireWatchedPriority\" AND hostname is NULL'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname is NULL AND value=\"AutoExpireWatchedPriority\" AND data=\"1\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update RecordPreRoll to 30 unless it is already set
# do this after 0.27 install
exec { 'mythsetRecordPreRoll':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"30\" WHERE value=\"RecordPreRoll\" AND hostname is NULL'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname is NULL AND value=\"RecordPreRoll\" AND data=\"30\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# update RecordOverTime to 120 unless it is already set
# do this after 0.27 install
exec { 'mythsetRecordOverTime':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'UPDATE mythconverg.settings SET data=\"120\" WHERE value=\"RecordOverTime\" AND hostname is NULL'",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.settings where hostname is NULL AND value=\"RecordOverTime\" AND data=\"120\"' | /bin/grep 1",
    require => Exec [ 'restartmythtvbackend' ],
}

# import myth settings
# unless already imported
# mysqldump -uroot -p mythconverg capturecard cardinput channel videosource channelgroupnames channelscan_channel channelscan_dtv_multiplex codecparams dtv_multiplex inputgroup > /tmp/mythconverg.sql
# mysql -uroot -p mythconverg < /home/myth/nfs/mythconverg.sql
# do this after 0.27 install
exec { 'importMythconvergeSQL':
    logoutput => true,
    command => "/usr/bin/mysql -uroot -p$mysqlPassword mythconverg < /home/myth/nfs/mythconverg.sql",
    unless => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'select count(*) from mythconverg.channel' | /bin/grep 55",
    require => Exec [ 'restartmythtvbackend' ],
}
