exec { "puppet module install puppetlabs-stdlib":
  path    => "/usr/bin:/usr/sbin:/bin",
  onlyif  => "test `puppet module list | grep puppetlabs-stdlib | wc -l` -eq 0"
}
