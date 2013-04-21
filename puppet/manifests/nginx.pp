
exec {
    'nginxkey':
        command => 'wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key',
        unless  => 'test -e /home/salimane/nginx_signing.key',
        cwd     => '/home/salimane',
        timeout => 0;
}

apt::source { 'nginx':
    location => 'http://nginx.org/packages/ubuntu',
    repos    => 'nginx',
    require  => Exec['nginxkey']
}


#apt::ppa { 'ppa:nginx/development':  }

class { 'nginx':
  require => Apt::Source['nginx']
}
