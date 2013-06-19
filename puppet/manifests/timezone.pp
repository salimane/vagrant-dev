#
# Class: timezone
#
# Manages timezone.
#
# Usage:
# include timezone
#
class timezone {
    package { 'tzdata': }

    file { '/etc/localtime':
        source  => 'file:///usr/share/zoneinfo/Europe/Berlin',
        require => Package['tzdata']
    }

    class { 'ntp':
      ensure     => running,
      servers    => [ 'time.apple.com iburst', 'pool.ntp.org iburst' ],
      autoupdate => true,
    }
}


