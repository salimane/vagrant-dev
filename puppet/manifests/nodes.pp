
node default {

    import 'sysupdate.pp'
    import 'timezone.pp'
    import 'adduser.pp'
    import 'dotfiles.pp'
    import 'nginx.pp'
    import 'phpsetup.pp'
    import 'mysqlsetup.pp'
    import 'postgresql.pp'
    import 'nodejs.pp'

    include sysupdate
    include timezone
    include dotfiles
    include phpsetup
    include mysqlsetup

    #exec { "aptupdate":
        #refreshonly => true,
        #command => 'apt-get -y autoremove --purge && apt-get -y autoclean --purge && apt-get  -y -f install && apt-get update',
        #onlyif => '/bin/sh -c "[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null"',
    #}

    exec { 'aptupgrade':
        command => "apt-get upgrade",
        require => Exec['aptupdate']
    }

    apt::source { 'puppetlabs':
        location   => 'http://apt.puppetlabs.com',
        repos      => 'main',
        key        => '4BD6EC30',
        key_server => 'pgp.mit.edu',
    }

    # puppet
    package {
        'puppet':
            ensure => latest;

        'less':
            #ensure  => latest,
            provider => 'npm',
            require => Class['nodejs'];
    }

    # add user salimane
    adduser { 'salimane':
        uid        => 5001,
        shell      => '/bin/zsh',
        groups     => ['sudo'],
        sshkeytype => 'ssh-rsa',
        sshkey     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDT2yEfwTAsvOqWCzCas/JmIjuVvMtVN+1g/ZRpdxNvyTep9kYLodcKOMg77RpiqDGdhJVH3XpXbfWE8zGihc1CN1KymhO5L3WhlaAsViDYqirrMPtlOwO897sCmF8TfL7aPWGU4RBQKUv9DfdBzHUaDBOufZZS6bgtMCzqoiWM5n0kjOpZ9imX+53kZJ288wGrF/GahFe17y+q5n0D8If6kZ2mMUjBVW6oCYlLWE0HEZaZt+1R4no1P3keiZ2hn9DIhKytJivrI9aQdAymzpAtRiykzErTGhO6ZK0n9ukXMb9sqWL+4pbCvERs6BRetmVvIb6zT4mpy0xhjhpy8uzH'
    }

    include dotfiles

    file { '/etc/ssh/sshd_config':  }

    file_line { 'rootlogin':
        path    => '/etc/ssh/sshd_config',
        line    => 'PermitRootLogin no',
        require => File['/etc/ssh/sshd_config']
    }

    Exec['aptupdate'] -> Package <| |>

    include sysupdate
    include timezone
    include java7
    include mysqlsetup
    include phpsetup
}
