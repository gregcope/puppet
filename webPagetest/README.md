WebPageTest Private instance Webserver Puppet manifest
""""""""""""""""""""""""""""""""""""""""""""""""""""""

__Ok - its a huge bodge of a manifest and I will burn in Puppet style hell__

Notes;
* You need to change a few lines at the top of the file
* If a new release comes out you need to update the `$webpagetestVersion`
* Download the release and md5sum it and update the `$webpagetestzipmd5sum`
* Change the `wpt_key` and `wpt_server` to your settings
* To install `sudo puppet apply webPageTest.pp`
* Send bug reports, money, gifts to <gregcope@gmail.com>, complaints to /dev/null, if it breaks you get to keep all the bits
* Njoy!
