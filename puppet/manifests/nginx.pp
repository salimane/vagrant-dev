
 apt::ppa { 'ppa:nginx/development':  }

class { 'nginx':
  require => Apt::Ppa['ppa:nginx/development']
}
