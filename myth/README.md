myth
====

Puppet modules for installing configuring myth

* i.pp is the inital puppet module to configure the network and remove nasty, nasty Ubuntu network managers
* s.pp is the main module for configuring the host, users, apache modules (inc pagespeed and spdy), cron jobs, NFS mounts, hostsfiles, etc..
* I then usually run apt-get update && apt-get dist-upgrade to upgrade all the packages and take the host to myth 0.27 - doing this within puppet upsets myth, because it goes interactive (and seems to drop some sql tables - mythconverg.mythwebsessiions).   Channels icons are downloaded by mythbackend setup to "~/.mythtv/channels/" - you'll need to tar that up!
* m.pp configures myth - Basically configures the sound, and myth - it needs some local sql files and channel icons - to create these yourself run mythbackend setup and the channel icons are downloaded (see above)

To recrete the SQL file, post config;

`mysqldump -uroot -p mythconverg capturecard cardinput channel videosource channelgroupnames channel settings > mythconverg.sql`

__You will need to change the `$mysqlPassword = foo` at the top of s.pp and m.pp to YOUR mysql root password (and NO mine is not foo!)__
