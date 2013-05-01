# == Class: security
#
class security($username = 'vagrant') {

    package { ['fail2ban', 'htop', 'molly-guard', 'etckeeper', 'logwatch']:
        ensure => present,
    }

    $home_dir = "/home/${username}"
}
