
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

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

      $sysPackages = [ 'build-essential', 'zlib1g-dev', 'libssl-dev', 'libreadline-gplv2-dev', 'ssh', 'aptitude', 'zsh', 'git' ]
      package { $sysPackages:
          ensure => 'installed',
          #require => Exec['apt-get upgrade'],
      }
  }
  #Exec['apt-get update'] -> Package <| |>
  #Exec['apt-get upgrade'] -> Package <| |>
  include systemUpdate


  Package { ensure => 'installed' }

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
      require => [ USER[$username], GROUP[$username] ]
  }

  file { "/home/${username}/.ssh":
      ensure  => directory,
      owner   => $username,
      group   => $username,
      mode    => '0700',
      require => FILE["/home/${username}/"]
  }

  # now make sure that the ssh key authorized files is around
  file { "/home/${username}/.ssh/authorized_keys":
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
      sshkey     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=='
  }




