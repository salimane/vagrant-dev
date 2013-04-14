class phpsetup {
    include php::fpm
    php::fpm::pool {  'www':
        listen      => '/tmp/php-fpm.sock',
        listen_type => 'unix',
    }

    php::module {
        [ 'curl', 'gd', 'geoip','imagick','imap','intl','mcrypt','memcache','memcached','mysql','pgsql','pspell','snmp','sqlite','xdebug','xmlrpc','xsl',]:
            notify => Class['php::fpm::service'];

        [ 'apc', ]:
            notify         => Class['php::fpm::service'],
            package_prefix => 'php-',
    }

    file { '/etc/php5/conf.d/php.custom.ini':
        ensure => file,
        notify => Class['php::fpm::service'],
    }

    file_line {
        'php-ini-display-errors':
            path   => '/etc/php5/conf.d/php.custom.ini',
            line   => 'display_errors = On',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify => Class['php::fpm::service'];

        'php-ini-memory-limit':
            path   => '/etc/php5/conf.d/php.custom.ini',
            line   => 'memory_limit = 256M',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify => Class['php::fpm::service'];

        'php-ini-datetime':
            path   => '/etc/php5/conf.d/php.custom.ini',
            line   => 'date.timezone = Asia/Shanghai',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify => Class['php::fpm::service'],
    }

    exec {
        'composer':
            command => 'curl -s https://getcomposer.org/installer | php && mv composer.phar /home/salimane/bin/composer && chmod +x /home/salimane/bin/composer ',
            unless  => '[ -f /home/salimane/bin/composer ]',
            require => Class['php::fpm'],
            cwd     => '/home/salimane',
            user    => 'salimane',
            group   => 'salimane',
            timeout => 0;

        'composer-update':
            command => '/home/salimane/bin/composer self-update',
            require => Exec['composer'],
            user    => 'salimane',
            group   => 'salimane',
            timeout => 0;

        'phpcs-fixer':
            command => 'wget http://cs.sensiolabs.org/get/php-cs-fixer.phar -O /home/salimane/bin/phpcs-fixer && chmod +x /home/salimane/bin/phpcs-fixer ',
            unless  => '[ -f /home/salimane/bin/phpcs-fixer ]',
            require => Class['php::fpm'],
            cwd     => '/home/salimane',
            user    => 'salimane',
            group   => 'salimane',
            timeout => 0;
    }
}
