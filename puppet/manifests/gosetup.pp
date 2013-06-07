# == Class: gosetup
#
class gosetup {

    package { 'system-golang':
        ensure => 'absent',
        name   => ['golang', 'golang-go'],
    }

    include apt

    apt::ppa { 'ppa:gophers/go':
        require => Package['system-golang'],
    }

    package {
        'golang-stable':
            ensure  => latest,
            require => [ Apt::Ppa['ppa:gophers/go']];
    }
}
