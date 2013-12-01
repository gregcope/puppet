# WebPageTest Private instance Puppet manifest #

__Ok - its a huge bodge of a manifest and I will burn in Puppet style hell__

Based on: https://sites.google.com/a/webpagetest.org/docs/private-instances

Notes;
* Aimed at Ubuntu 12.04 LTS - YMMV
* You need to change a few lines at the top of the file
* If a new release comes out you need to update the `$webpagetestVersion`
* Download the release and md5sum it and update the `$webpagetestzipmd5sum`
* Change the `wpt_key` and `wpt_server` to your settings
* To install `sudo puppet apply webPageTest.pp`
* Send bug reports, money, gifts to <gregcope@gmail.com>, complaints to /dev/null, if it breaks you get to keep all the bits
* Njoy!

To get an EC Server instance up and running;
* lauch it (12.04 TLS)!
* login (hint `ssh -i YOUR KEY.pm ubunut@${EC2InstancepublicIP}`)
* run an update `sudo apt-get update`
* run an upgrade `sudo apt-get -y upgrade`
* install puppet  `sudo apt-get -y install puppet`
* get the manifest `wget https://raw.github.com/gregcope/puppet/master/webPagetest/webPageTest.pp`
* Change the `wpt_key` and `wpt_server` (hint ${EC2InstancepublicIP})
* run the manifest `sudo puppet apply webPageTest.pp`
* End:  profit?

To get an EC Test instance up and running;
# Login, Choose a region
# Goto Cloud formation and create a stack - give it a nice name like "WebPageTest"
# Chose the upload template option and upload webpageAutoScalingPolicy.json
# Click, Click until you hit "Launch" and click that
# Wait about 5 mins and you should see the relevant option appear in the WPT server location feilds
# If it does not work check the WPT log file tail -f /var/log/apache2/other_vhosts_access.log | grep ${LOCATION}
