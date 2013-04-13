class railssetup {

    $username = 'salimane'
    $home_dir = "/home/${username}"
    $rubyversion = '1.9.3-p392'
    #package {['libreadline5-dev']: ensure => 'installed'}

    rbenv::install { $username:
        group => $username,
        home  => "${home_dir}",
    }

    rbenv::plugin {
        'rbenv-gem-rehash':
            user   => $username,
            source => "git://github.com/sstephenson/rbenv-gem-rehash.git";

        'rbenv-vars':
            user   => $username,
            source => "git://github.com/sstephenson/rbenv-vars.git";

        'rbenv-each':
            user   => $username,
            source => "git://github.com/chriseppstein/rbenv-each.git";

        'rbenv-update':
            user   => $username,
            source => "git://github.com/rkh/rbenv-update.git";

        'rbenv-whatis':
            user   => $username,
            source => "git://github.com/rkh/rbenv-whatis.git";

        'rbenv-use':
            user   => $username,
            source => "git://github.com/rkh/rbenv-use.git";

        'rbenv-default-gems':
            user   => $username,
            source => "git://github.com/sstephenson/rbenv-default-gems.git";
    }

    rbenv::compile { $rubyversion:
        user   => $username,
        home   => "${home_dir}",
        global => true
    }

    rbenv::gem { ['specific_install', 'rails', 'bundle', 'unicorn', 'capistrano']:
        user    => $username,
        ruby    => $rubyversion,
        ensure  => latest,
        require => Rbenv::Compile["${rubyversion}"],
    }
}
