class railssetup {

    $username = 'salimane'
    $home_dir = "/home/${username}"
    $rubyversion = '1.9.3'
    #package {['libreadline5-dev']: ensure => 'installed'}


     exec {
        'clone_rbenv':
            cwd     =>"${home_dir}",
            user    => $username,
            command => "git clone git://github.com/sstephenson/rbenv.git ${home_dir}/.rbenv && git clone git://github.com/sstephenson/ruby-build.git ${home_dir}/.rbenv/plugins/ruby-build && git clone https://github.com/sstephenson/rbenv-gem-rehash.git ${home_dir}/.rbenv/plugins/rbenv-gem-rehash && git clone https://github.com/sstephenson/rbenv-vars.git ${home_dir}/.rbenv/plugins/rbenv-vars && git clone https://github.com/sstephenson/rbenv-default-gems.git ${home_dir}/.rbenv/plugins/rbenv-default-gems && git clone https://github.com/chriseppstein/rbenv-each.git ${home_dir}/.rbenv/plugins/rbenv-each && git clone https://github.com/rkh/rbenv-update.git ${home_dir}/.rbenv/plugins/rbenv-update && git clone https://github.com/rkh/rbenv-whatis.git ${home_dir}/.rbenv/plugins/rbenv-whatis && git clone https://github.com/rkh/rbenv-use.git ${home_dir}/.rbenv/plugins/rbenv-use && exec /bin/zsh -l && . /home/salimane/.zshrc",
            unless => '[ ! -d "${home_dir}/.rbenv" ]',
            require => [Package['git'], USER[$username], File["${home_dir}/.zshrc"]];

        'ruby':
            cwd     =>"${home_dir}",
            path => [ '${home_dir}/.rbenv/bin', '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
            user    => $username,
            command => "rbenv install --list | grep '${rubyversion}-p[0-9]' | tail -1 | xargs rbenv install && exec $SHELL -l",
            onlyif => "[  ! -d '${home_dir}/.rbenv/versions/$(rbenv install --list | grep '${rubyversion}-p[0-9]' | tail -1 | tr -d ' ')' ]";

        'ruby-default':
            cwd     =>"${home_dir}",
            path => [ '${home_dir}/.rbenv/bin', '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
            user    => $username,
            command => "rbenv install --list | grep '${rubyversion}-p[0-9]' | tail -1 | xargs rbenv global",
            require => Exec['ruby'];

        'rbenv-update':
            cwd     =>"${home_dir}",
            path => [ '${home_dir}/.rbenv/bin', '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
            user    => $username,
            command => "rbenv update",
            require => Exec['clone_rbenv'];

        'rails-gem':
            cwd     =>"${home_dir}",
            path => [ '${home_dir}/.rbenv/bin', '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
            user    => $username,
            command => "gem install specific_install rails bundler unicorn",
            require => Exec['ruby-default'];

    }
}
