myth
====

Puppet modules for installing configuring myth

* i.pp is the inital puppet module to configure the network and remove nasty, nasty Ubuntu network managers
* s.pp is the main module for configuring the host, users, apache modules (inc pagespeed and spdy), cron jobs, NFS mounts, hostsfiles, etc..
* I then usually run apt-get update && apt-get dist-upgrade to upgrade all the packages and take the host to myth 0.27 - doing this within puppet upsets myth, because it goes interactive (and seems to drop some sql tables - mythconverg.mythwebsessiions).   Channels icons are downloaded by mythbackend setup to "~/.mythtv/channels/" - you'll need to tar that up!
* m.pp configures myth - Basically configures the sound, and myth - it needs some local sql files and channel icons - to create these yourself run mythbackend setup and the channel icons are downloaded (see above)

To recrete the SQL file, post config;

`mysqldump -uroot -p mythconverg capturecard cardinput channel videosource channelgroupnames channelgroup settings > mythconverg.sql`

__You will need to run this as sudo facter_mysqlpassword='PUT YOU MYSQL PASSWORD HERE' puppet apply s.pp__ 

ie;

To run
''''''
    sudo puppet apply i.pp
    sudo facter_mysqlpassword='bla' puppet apply s.pp
    sudo apt-get update && apt-get dist-upgrade
    sudo facter_mysqlpassword='bla' puppet apply m.pp
