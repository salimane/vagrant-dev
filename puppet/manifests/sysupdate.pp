
class { 'apt':
    always_apt_update    => false,
    disable_keys         => undef,
    proxy_host           => false,
    proxy_port           => '8080',
    purge_sources_list   => false,
    purge_sources_list_d => false,
    purge_preferences_d  => false
}

#
# Class: systemUpdate
#
# Manages systemUpdate.
#
# Usage:
# include systemUpdate
#
class sysupdate {

    #exec { 'apt-get update':
        #command    => 'sudo apt-get update',
        #timeout    => 0
    #}

    #exec { 'apt-get upgrade':
        #command    => 'sudo apt-get upgrade -m -y --force-yes',
        #timeout    => 0,
        #require    => Exec['apt-get update'],
    #}

    $sysPackages = [ 'build-essential', 'zlib1g-dev', 'libssl-dev', 'libreadline-gplv2-dev', 'ssh', 'aptitude', 'zsh', 'git' , 'software-properties-common', 'language-pack-zh-hans-base']
    package { $sysPackages:
        #require => Exec['apt-get upgrade'],
    }
}
#Exec['apt-get update'] -> Package <| |>
#Exec['apt-get upgrade'] -> Package <| |>
