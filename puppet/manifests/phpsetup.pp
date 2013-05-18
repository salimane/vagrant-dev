# == Class: phpsetup
#
class phpsetup ($username = 'vagrant') {
    include php::fpm
    php::fpm::pool {  'www':
        listen      => '/tmp/php-fpm.sock',
        listen_type => 'unix',
    }

    php::module {
        [ 'curl', 'gd', 'geoip','imagick','imap','intl','mcrypt','memcache','memcached','pgsql','pspell','snmp','sqlite','xdebug','xmlrpc','xsl',]:
            notify => Class['php::fpm::service'];

        [ 'apc', ]:
            notify         => Class['php::fpm::service'],
            package_prefix => 'php-';

        [ 'mysql']:
           require => Class['mysqlsetup'];
    }

    file { '/etc/php5/conf.d/php.custom.ini':
        ensure => file,
        notify => Class['php::fpm::service'],
    }

    if defined(Package['php-pear']) != true{
        package { 'php-pear':
            ensure => present,
        }
    }

    file_line {
        'php-ini-display-errors':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'display_errors = On',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-memory-limit':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'memory_limit = 256M',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-datetime':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'date.timezone = Asia/Shanghai',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-disable-func':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'disable_functions = ',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-error-reporting':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'error_reporting = E_ALL | E_STRICT',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-startup-error':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'display_startup_errors = On',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-error_log':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'error_log = /var/log/php_errors.log',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

        'php-ini-phar-readonly':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => 'phar.readonly = Off',
            require => File['/etc/php5/conf.d/php.custom.ini'],
            notify  => Class['php::fpm::service'];

    }

    exec {
        'composer':
            command => "curl -s https://getcomposer.org/installer | php && mv composer.phar /home/${username}/bin/composer && chmod +x /home/${username}/bin/composer ",
            unless  => "[ -f /home/${username}/bin/composer ]",
            require => [Class['php::fpm'], File["/home/${username}/bin"]],
            cwd     => "/home/${username}",
            user    => $username,
            group   => $username,
            timeout => 0;

        'composer-update':
            command => "/home/${username}/bin/composer self-update",
            require => Exec['composer'],
            user    => $username,
            group   => $username,
            timeout => 0;

        'box':
            command => "curl -s http://box-project.org/installer.php | php && mv box.phar /home/${username}/bin/box && chmod +x /home/${username}/bin/box ",
            unless  => "[ -f /home/${username}/bin/box ]",
            require => [Class['php::fpm'], File["/home/${username}/bin"]],
            cwd     => "/home/${username}",
            user    => $username,
            group   => $username,
            timeout => 0;

        'box-update':
            command => "/home/${username}/bin/box update",
            require => Exec['box'],
            user    => $username,
            group   => $username,
            timeout => 0;

        'clone_boris':
            cwd     =>"/home/${username}/htdocs",
            group   => $username,
            user    => $username,
            command => "git clone git://github.com/d11wtq/boris.git /home/${username}/htdocs/boris",
            creates => "/home/${username}/htdocs/boris",
            require => [Package['git'], USER[$username]];

        'boris':
            command => "/home/${username}/bin/box build && mv boris.phar /home/${username}/bin/boris && chmod +x /home/${username}/bin/boris ",
            unless  => "[ -f /home/${username}/bin/boris ]",
            require => [Exec['box-update'], Exec['clone_boris']],
            cwd     => "/home/${username}/htdocs/boris",
            user    => $username,
            group   => $username,
            timeout => 0;

        'phpcs-fixer':
            command => "wget http://cs.sensiolabs.org/get/php-cs-fixer.phar -O /home/${username}/bin/phpcs-fixer && chmod +x /home/${username}/bin/phpcs-fixer ",
            unless  => "[ -f /home/${username}/bin/phpcs-fixer ]",
            require => [Class['php::fpm'], File["/home/${username}/bin"]],
            cwd     => "/home/${username}",
            user    => $username,
            group   => $username,
            timeout => 0;

        'phpcs-fixer-update':
            command => "/home/${username}/bin/phpcs-fixer self-update",
            require => Exec['phpcs-fixer'],
            user    => $username,
            group   => $username,
            timeout => 0;

        'pear-upgrade':
            command => 'pear upgrade PEAR && pear config-set auto_discover 1',
            require => [Package['build-essential'], Package['php-pear']];

        'phpunit-install':
            command => 'pear install pear.phpunit.de/PHPUnit',
            unless  => '[ -f /usr/bin/phpunit ]',
            require => [Exec['pear-upgrade']],
    }

    nginx::resource::upstream { 'php_backend':
        ensure  => present,
        members => [ 'unix:/tmp/php-fpm.sock', ],
    }

    import 'xhprof.pp'
    include xhprof
}
