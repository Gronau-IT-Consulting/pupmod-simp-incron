# This class manages /etc/incron.allow and /etc/incron.deny and the
# incrond service.
#
# @param users
#   An Array of additional incron users, using the defined type
#   incron::user.
#
class incron (
  Array[String] $users = []
) {
  if $facts['os']['name'] in ['RedHat','CentOS'] {
    $_incron_package = 'incron'
    $_incron_service = 'incrond'
  }
  elsif $facts['os']['name'] in ['Debian','Ubuntu'] {
    $_incron_package = 'incron'
    $_incron_service = 'incron'
  }
  else {
    fail("OS '${facts['os']['name']}' not supported by '${module_name}'")
  }

  $users.each |String $user| {
    ::incron::user { $user: }
  }
  ::incron::user { 'root': }

  concat { '/etc/incron.allow':
    owner          => 'root',
    group          => 'root',
    mode           => '0400',
    ensure_newline => true,
    warn           => true
  }

  file { '/etc/incron.deny':
    ensure => 'absent'
  }

  package { $_incron_package:
    ensure => latest
  }

  service { $_incron_service:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['incron']
  }
}
