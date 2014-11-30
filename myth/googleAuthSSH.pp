class googleAuthSSH {

  #
  # Install and configure Google Authenticator 2FA for ssh on Ubuntu 12.04
  # 2FA is disbled for local networks to save hassel 
  #

  # lifted in part from;
  # http://blog.remibergsma.com/2013/06/08/playing-with-two-facor-authentication-in-linux-using-google-authenticator/

  # we will not enable this for the localnetwork
  # if you do not want this functionality then just have an empty string
  $localnetworkCidr = "192.168.1.0/24"

  # Add the internet IP if we are logging in from the lan
  # via the public IP
  $publicIPCidr = "80.229.1.98/32"

  # install package
  package { 'libpam-google-authenticator': }

  # Enable ssh - ChallengeResponseAuthentication yes
  # if package is installed
  # tell sshd to restart
  augeas { 'sshd_config':
    context => '/files/etc/ssh/sshd_config',
    changes => 'set ChallengeResponseAuthentication yes',
    require => Package [ 'libpam-google-authenticator' ],
    notify => Service [ 'ssh' ],
  }
  
  # create a sensible access-local.conf file
  # so that we can skip 2FA from local networks
  # no restart required as PAM will just pick this up
  if $localnetworkCidr != '' {

    # add the locallan to /etc/security/access-local.conf
    # if not already there
    # make sure package is installed
    exec { 'addLANToAccessLocal':
      logoutput => true,
      command => "/bin/echo '+ : ALL : $localnetworkCidr' >> /etc/security/access-local.conf",
      unless => "/bin/grep '+ : ALL : $localnetworkCidr' /etc/security/access-local.conf",
      require => Package [ 'libpam-google-authenticator' ],
    }

    # add the Local bypass to /etc/security/access-local.conf
    # only if not there
    # make sure package and LAN is installed
    exec { 'addLocalToAccessLocal':
      logoutput => true,
      command => "/bin/echo '+ : ALL : LOCAL' >> /etc/security/access-local.conf",
      unless => "/bin/grep '+ : ALL : LOCAL' /etc/security/access-local.conf",
      require => [ Package [ 'libpam-google-authenticator' ], Exec [ 'addLANToAccessLocal'  ] ],
    }

    # added the catchall deny to /etc/security/access-local.conf
    # unless already there
    # make sure other bits and package are installed
    exec { 'addDenyToAccessLocal':
      logoutput => true,
      command => "/bin/echo '- : ALL : ALL' >> /etc/security/access-local.conf",
      unless => "/bin/grep '\\- : ALL : ALL' /etc/security/access-local.conf",
      require => [ Package [ 'libpam-google-authenticator' ], Exec [ 'addLocalToAccessLocal' ] ],
    }

    if $publicIPCidr != '' {
      # if publicIPCidr is set, make sure it is in
      # /etc/security/access-local.conf
      # only if not there
      # make sure package and other bits are there
      exec { 'addPublicIPCidrToAccessLocal':
        logoutput => true,
	command => "/usr/bin/perl -p -i -e 'BEGIN{undef \$/;} s#\\+ : ALL : $localnetworkCidr#\\+ : ALL : $localnetworkCidr\n\\+ : ALL : $publicIPCidr#' /etc/security/access-local.conf",
	unless => "/bin/grep '+ : ALL : $publicIPCidr' /etc/security/access-local.conf -A 1 | /bin/grep '+ : ALL : $localnetworkCidr'",
	require => [ Package [ 'libpam-google-authenticator' ], Exec [ 'addDenyToAccessLocal' ] ],
      }
    }

    # edit /etc/pam.d/sshd and ensure these next three lines are at the end
    # #these lines have to be at the end
    # auth [success=1 default=ignore] pam_access.so accessfile=/etc/security/access-local.conf
    # auth required pam_google_authenticator.so
    # first line says skip if the access-local condition is met (ie skip for local access)
    # require the package, sshd ChallengeResponseAuthentication and access-local.conf
    # makes me feel unclean but works
    exec {'AddtoEndofSshd':
      logoutput => true,
      command => '/bin/echo -en "\n#these lines have to be at the end\nauth [success=1 default=ignore] pam_access.so accessfile=/etc/security/access-local.conf\nauth required pam_google_authenticator.so" >> /etc/pam.d/sshd',
      unless => '/bin/grep -Pzo \'\n^#these lines have to be at the end\n^auth \[success=1 default=ignore\] pam_access.so accessfile=/etc/security/access-local.conf\n^auth required pam_google_authenticator.so\' /etc/pam.d/sshd',
      require => [ Package [ 'libpam-google-authenticator' ], Exec [ 'addDenyToAccessLocal' ], Augeas [ 'sshd_config' ] ],
      notify => Service [ 'ssh' ],
    }
  } else {
    # we do not want to limit for localnetwork so just exec without that config
    exec {'AddtoEndofSshd':
      logoutput => true,
      command => '/bin/echo -en "\n#these lines have to be at the end\nauth [success=1 default=ignore] pam_access.so\nauth required pam_google_authenticator.so" >> /etc/pam.d/sshd',
      unless => '/bin/grep -Pzo \'\n^#these lines have to be at the end\n^auth \[success=1 default=ignore\] pam_access.so\n^auth required pam_google_authenticator.so\' /etc/pam.d/sshd',
      require => [ Package [ 'libpam-google-authenticator' ], Exec [ 'addDenyToAccessLocal' ], Augeas [ 'sshd_config' ] ],
      notify => Service [ 'ssh' ],
    }
  }

  # service to call a restart on
  service { 'ssh':
    ensure => running,
  }

}

include googleAuthSSH
