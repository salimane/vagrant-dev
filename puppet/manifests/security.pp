# == Class: security
#
class security {

    package { ['fail2ban', 'htop', 'molly-guard', 'etckeeper', 'logwatch']:
        ensure => present,
    }

    $username = 'salimane'
    $home_dir = "/home/${username}"
}
