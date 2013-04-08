class basic{
  # run apt-get update before anything else runs
  class {'basic::aptupdate': stage => first} ->
  class {"basic::packages":}
}

# just some packages
class basic::packages{
  package{['tmux', 'curl']: }
}

# brings the system up-to-date after importing it with Vagrant
# runs only once after booting (checks /tmp/apt-get-update existence)
class basic::aptupdate{
  exec{'aptupdate':
    command => 'apt-get -y autoremove --purge; apt-get -y autoclean --purge; apt-get  -y -f install; apt-get update; touch /tmp/apt-get-updated',
    #unless => "test -e /tmp/apt-get-updated"
  }
}
