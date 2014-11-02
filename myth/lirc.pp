class lirc {

  # Configures lircd for my NovaT
  # based on http://parker1.co.uk/mythtv_ubuntu2.php

  # service for lirc
  service { 'lirc':
    ensure => running,
    hasstatus => false
  }

  # add include config for novaT
  # notify the service to restart
  exec { 'includeNovaT':
    logoutput => true,
    command => '/bin/echo "include \"/usr/share/lirc/extras/more_remotes/hauppauge/lircd.conf.hauppauge_novat500\"" >> /etc/lirc/lircd.conf',
    unless => '/bin/grep \'^include "/usr/share/lirc/extras/more_remotes/hauppauge/lircd.conf.hauppauge_novat500"\' /etc/lirc/lircd.conf',
    notify => Service [ 'lirc' ],
  }

  # drop in a config file
  # notify the service to restart
  # this is hardcoded to my host
  # cat /proc/bus/input/devices
  # look for lines with event2 from USB DVD device
  # for novaT on my host; 
  #  Name="IR-receiver inside an USB DVB receiver"
  #  Handlers=kbd event9 
  file { '/etc/lirc/hardware.conf':
    ensure  => file,
    contents => "REMOTE=\"Hauppauge Nova-T 500\"\nREMOTE_DRIVER=\"dev/input\"\nREMOTE_DEVICE=\"/dev/input/event9\"\nREMOTE_LIRCD_CONF=\"hauppauge/lircd.conf.hauppauge_novat500\"\nTRANSMITTER=\"None\"\nSTART_LIRCD=\"true\"\nLOAD_MODULES=\"true\"\nFORCE_NONINTERACTIVE_RECONFIGURATION=\"false\"\n",
    notify => Service [ 'lirc' ],
  }

}

# needed to get the above to run!
include lirc

