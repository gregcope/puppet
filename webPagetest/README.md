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
1. Login to AWS, lauch an ubtunu AMI (12.04 TLS)!  
2. login (hint `ssh -i YOUR KEY.pm ubunut@${EC2InstancepublicIP}`)  
3. run an update `sudo apt-get update`  
4. run an upgrade `sudo apt-get -y upgrade`  
5. install puppet  `sudo apt-get -y install puppet`  
6. get the manifest `wget https://raw.github.com/gregcope/puppet/master/webPagetest/webPageTest.pp`  
7. Change the `wpt_key` and `wpt_server` (hint ${EC2InstancepublicIP})  
8. run the manifest `sudo puppet apply webPageTest.pp`  
9. End:  profit?  

To get an EC Test instance up and running;  
1. Login to AWS, Choose a region  
2. Goto Cloud formation and create a stack - give it a nice stack name like `WebPageTest`  
3. Chose the upload template option and upload `webpageAutoScalingPolicy.json`  
4. Click, Click until you hit "Launch" and click that  
5. Wait about 5 mins and you should see the relevant option appear in the WPT server location fields  
6a. If it does not work check the WPT log file `tail -f /var/log/apache2/other_vhosts_access.log | grep ${LOCATION}`  
6b. If it is not polling the server (check for its IP), terminate instance, ASG will start another and repeat from no 5. downwards  
6c. If it is still not working you get to keep all the bits  
7. Send the new location lots of tests - you should see new instances spawn and take load (check the HTTP log file) and then be terminated after 10 minutes of low CPU  
