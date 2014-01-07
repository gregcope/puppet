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
# so that we can skip 2FA from local networks
# no restart required as PAM will just pick this up
file {'/etc/security/access-local.conf':
    ensure => present,
    mode => 0644,
    content => "# Two-factor can be skipped on local network\n+ : ALL : 192.168.0.0/24\n+ : ALL : LOCAL\n- : ALL : ALL\n"
}

# edit /etc/pam.d/sshd and ensure these lines are at the end
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
    require => [ Package [ 'libpam-google-authenticator' ], File [ '/etc/security/access-local.conf' ], Augeas [ 'sshd_config' ] ],
    notify => Service [ 'ssh' ],
}

service { 'ssh':
    ensure => running,
}
