
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
Package { ensure => 'installed' }

class { 'apt':
  always_apt_update    => true,
  disable_keys         => undef,
  proxy_host           => false,
  proxy_port           => '8080',
  purge_sources_list   => false,
  purge_sources_list_d => false,
  purge_preferences_d  => false
}

apt::source { 'puppetlabs':
  location   => 'http://apt.puppetlabs.com',
  repos      => 'main',
  key        => '4BD6EC30',
  key_server => 'pgp.mit.edu',
}


  #
  # Class: systemUpdate
  #
  # Manages systemUpdate.
  #
  # Usage:
  # include systemUpdate
  #
  class systemUpdate {

      #exec { 'apt-get update':
      #command => 'sudo apt-get update',
      #timeout => 0
      #}

      #exec { 'apt-get upgrade':
      #command => 'sudo apt-get upgrade -m -y --force-yes',
      #timeout => 0,
      #require => Exec['apt-get update'],
      #}

      $sysPackages = [ 'build-essential', 'zlib1g-dev', 'libssl-dev', 'libreadline-gplv2-dev', 'ssh', 'aptitude', 'zsh', 'git' , 'software-properties-common', 'language-pack-zh-hans-base']
      package { $sysPackages:
          ensure => 'installed',
          #require => Exec['apt-get upgrade'],
      }
  }
  #Exec['apt-get update'] -> Package <| |>
  #Exec['apt-get upgrade'] -> Package <| |>
  include systemUpdate




  # puppet
  package { 'puppet':
    ensure => latest
  }

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
          source  => 'file:///usr/share/zoneinfo/Asia/Shanghai',
          require => Package['tzdata']
      }
  }

  include timezone

  # Definition: add_user
  #
  # Description
  #
  # Parameters:
  #  $name -
  #  $uid -
  #  $shell -
  #  $groups -
  #  $sshkeytype -
  #  $sshkey -
  #
  # Actions:
  #
  # Requires:
  #  This definition has no requirements.
  #
  # Sample Usage:
  #  add_user { 'salimane':
  #  uid         => 5001,
  #  shell       => '/bin/zsh',
  #  groups => ['sudo', 'admin'],
  #  sshkeytype  => 'ssh-rsa',
  #  sshkey      => ''
  # }
  define add_user ($uid, $shell, $groups, $sshkeytype, $sshkey) {

  $username = $title

  user { $username:
      comment    =>  $username,
      home       => "/home/${username}",
      shell      => $shell,
      uid        => $uid,
      managehome => true,
      groups     => $groups
  }

  group { $username:
      gid     => $uid,
      require => USER[$username]
  }

  file { "/home/${username}/":
      ensure  => directory,
      owner   => $username,
      group   => $username,
      mode    => '0750',
      require => [ USER[$username], GROUP[$username] ];


 "/home/${username}/.ssh":
      ensure  => directory,
      owner   => $username,
      group   => $username,
      mode    => '0700',
      require => FILE["/home/${username}/"];

 "/home/${username}/.ssh/authorized_keys":
      ensure  => present,
      owner   => $username,
      group   => $username,
      mode    => '0600',
      require =>FILE["/home/${username}/"]
  }

  ssh_authorized_key{ $username:
      ensure  => present,
      user    => $username,
      type    => $sshkeytype,
      key     => $sshkey,
      name    => $username,
      require => FILE["/home/${username}/.ssh/authorized_keys"]
  }
  }

  # add user salimane
  add_user { 'salimane':
      uid        => 5001,
      shell      => '/bin/zsh',
      groups     => ['sudo'],
      sshkeytype => 'ssh-rsa',
      sshkey     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDT2yEfwTAsvOqWCzCas/JmIjuVvMtVN+1g/ZRpdxNvyTep9kYLodcKOMg77RpiqDGdhJVH3XpXbfWE8zGihc1CN1KymhO5L3WhlaAsViDYqirrMPtlOwO897sCmF8TfL7aPWGU4RBQKUv9DfdBzHUaDBOufZZS6bgtMCzqoiWM5n0kjOpZ9imX+53kZJ288wGrF/GahFe17y+q5n0D8If6kZ2mMUjBVW6oCYlLWE0HEZaZt+1R4no1P3keiZ2hn9DIhKytJivrI9aQdAymzpAtRiykzErTGhO6ZK0n9ukXMb9sqWL+4pbCvERs6BRetmVvIb6zT4mpy0xhjhpy8uzH'
  }


# Definition: dotfilesSetup
  #
  # Description
  #
  # Parameters:
  #
  # Actions:
  #
  # Requires:
  #  This definition has no requirements.
  #
  # Sample Usage:
  #  dotfilesSetup
define  dotfilesSetup() {

  $username = 'salimane'
  $home_dir = "/home/${username}"
  if(!defined(Package['git'])) {
    package { 'git': ensure => present,}
  }
  if(!defined(Package['zsh'])) {
    package { 'zsh': ensure => present,}
  }
  if(!defined(Package['curl'])) {
    package { 'curl': ensure => present,}
  }

  exec { "chsh -s /bin/zsh ${username}":
    unless  => "grep -E '^${username}.+:/bin/zsh$' /etc/passwd",
    require => [ Package['zsh'], USER[$username]]
  }

  file { "/home/${username}/htdocs":
    ensure => 'directory',
    owner  => 'salimane',
  }

  file { "${home_dir}/bin":
    ensure => 'directory',
    owner  => 'salimane',
  }

  exec { 'clone_dotfiles':
    cwd     =>"${home_dir}/htdocs",
    user    => $username,
    command => "git clone https://github.com/salimane/dotfiles.git ${home_dir}/htdocs/dotfiles",
    creates => "${home_dir}/htdocs/dotfiles",
    require => [Package['git'], Package['zsh'], Package['curl'], USER[$username], File["${home_dir}/htdocs"]]
  }

  file {
    "${home_dir}/.zshrc":
        ensure => link,
        target => "${home_dir}/htdocs/dotfiles/zsh/.zshrc",
        require => Exec['clone_dotfiles'];

    "${home_dir}/.wgetrc":
        ensure => link,
        target => "${home_dir}/htdocs/dotfiles/wget/.wgetrc",
        require => Exec['clone_dotfiles'];

    "${home_dir}/.nanorc":
    ensure => link,
    target => "${home_dir}/htdocs/dotfiles/nano/.nanorc",
    require => Exec['clone_dotfiles'];

    "${home_dir}/.gitconfig":
    ensure => link,
    target => "${home_dir}/htdocs/dotfiles/git/.gitconfig",
    require => Exec['clone_dotfiles'];

    "${home_dir}/.gitattributes":
    ensure => link,
    target => "${home_dir}/htdocs/dotfiles/git/.gitattributes",
    require => Exec['clone_dotfiles'];

    "${home_dir}/.gemrc":
    ensure => link,
    target => "${home_dir}/htdocs/dotfiles/rb/.gemrc",
    require => Exec['clone_dotfiles'];

    "${home_dir}/.valgrindrc":
    ensure => link,
    target => "${home_dir}/htdocs/dotfiles/valgrind/.valgrindrc",
    require => Exec['clone_dotfiles'];
  }


  exec { 'copy-binfiles':
    cwd     => "${home_dir}/htdocs/dotfiles",
    user    => $username,
    command => "cp bin/* ${home_dir}/bin/ && chmod +x ${home_dir}/bin/*",
    require => Exec['clone_dotfiles'],
  }

}

dotfilesSetup{'salimane':}

class { 'ntp':
      ensure     => running,
      servers    => [ 'time.apple.com iburst', 'pool.ntp.org iburst' ],
      autoupdate => true,
}


define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'",
                require => File[$file]
            }
        }
        absent: {
            exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
              onlyif => "/bin/grep -qFx '${line}' '${file}'",
              require => File[$file]
            }

            # Use this resource instead if your platform's grep doesn't support -vFx;
            # note that this command has been known to have problems with lines containing quotes.
            # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
            # }
        }
    }
}

file { '/etc/ssh/sshd_config':

  }

line { 'dns':
    ensure => 'absent',
    file => '/etc/ssh/sshd_config',
    line => 'UseDNS no';

    'rootlogin':
    file => '/etc/ssh/sshd_config',
    line => 'PermitRootLogin no';
}

apt::ppa { 'ppa:nginx/development': }

class { 'nginx':
      require => Apt::Ppa['ppa:nginx/development']
}


class mysqlSetup {

  apt::source { 'percona':
    location    => 'http://repo.percona.com/apt',
    release     => $lsbdistcodename,
    repos       => 'main',
    include_src => true,
    key         => 'CD2EFD2A',
    key_server  => 'keys.gnupg.net',
  }

  apt::pin { 'Percona Development Team': priority => 1001 }

  package { 'percona-server-server-5.5':
    ensure  => installed,
    require => [ Apt::Source['percona']];

    'percona-server-client-5.5':
    ensure  => installed,
    require => [ Apt::Source['percona']];


    'libmysqlclient-dev':
    ensure  => installed,
    require => [ Apt::Source['percona']];
  }

  service { 'mysql':
    ensure => 'running',
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package['percona-server-server-5.5'],
  }

    # Equivalent to /usr/bin/mysql_secure_installation without providing or setting a password
    exec { 'mysql_secure_installation':
        command => '/usr/bin/mysql -uroot -e "DELETE FROM mysql.user WHERE User=\'\'; DELETE FROM mysql.user WHERE User=\'root\' AND Host NOT IN (\'localhost\', \'127.0.0.1\', \'::1\'); DROP DATABASE IF EXISTS test; FLUSH PRIVILEGES;" mysql',
        require => Service['mysql'],
    }

}

include mysqlSetup

include postgresql::server



include java7

class { 'nodejs':
      dev_package => true
}

package { 'less':
  #ensure   => latest,
  provider => 'npm';
}

class phpSetup {
include php::fpm
php::fpm::pool {  'www':
      listen => '/tmp/php-fpm.sock',
      listen_type => 'unix',
}

php::module { [ 'curl', 'gd', 'geoip','imagick','imap','intl','mcrypt','memcache','memcached','mysql','pgsql','pspell','snmp','sqlite','xdebug','xmlrpc','xsl',]:
        notify => Class['php::fpm::service'],
}

php::module { [ 'apc', ]:
        notify => Class['php::fpm::service'],
        package_prefix => 'php-',
}

file { '/etc/php5/conf.d/php.custom.ini':
        ensure => file,
        notify => Class['php::fpm::service'],
}

line {
  'php-ini-display-errors':
    file => '/etc/php5/conf.d/php.custom.ini',
    line => ['display_errors = On'],
    notify => Class['php::fpm::service'];

 'php-ini-memory-limit':
    file => '/etc/php5/conf.d/php.custom.ini',
    line => ['memory_limit = 256M'],
    notify => Class['php::fpm::service'];

 'php-ini-datetime':
    file => '/etc/php5/conf.d/php.custom.ini',
    line => ['date.timezone = Asia/Shanghai'],
    notify => Class['php::fpm::service'],
}

exec { 'composer':
  command => 'curl -s https://getcomposer.org/installer | php && mv composer.phar /home/salimane/bin/composer && chmod +x /home/salimane/bin/composer ',
  unless => 'test -e /home/salimane/bin/composer',
  require => Class['php::fpm'],
  cwd => '/home/salimane',
  user   => 'salimane',
  group   => 'salimane',
  timeout => 0
}
exec { '/home/salimane/bin/composer self-update':
  require => Exec['composer'],
  user   => 'salimane',
  group   => 'salimane',
  timeout => 0
}
}

include phpSetup