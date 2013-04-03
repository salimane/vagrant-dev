
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

  exec { 'copy-dotfiles':
    cwd     => "${home_dir}/htdocs/dotfiles",
    user    => $username,
    command => "cp zsh/.zshrc  wget/.wgetrc  nano/.nanorc valgrind/.valgrindrc  git/.gitconfig git/.gitignore git/.gitattributes ${home_dir}/ && cp bin/* ${home_dir}/bin/ && chmod +x ${home_dir}/bin/*",
    unless  => 'ls .zshrc',
    require => Exec['clone_dotfiles'],
  }

}

dotfilesSetup{'salimane':}

class { 'ntp':
  ensure     => running,
  servers    => [ 'time.apple.com iburst', 'pool.ntp.org iburst' ],
  autoupdate => true,
}



