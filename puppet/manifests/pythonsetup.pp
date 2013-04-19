# == Class: pythonsetup
#
class pythonsetup {

    $username = 'salimane'
    $home_dir = "/home/${username}"

    file { "${home_dir}/pip.requirements.txt":
      content => "Fabric>=1.6.0
RunSnakeRun>=2.0.2b1
autopep8>=0.8.7
bpython>=0.12
pep8>=1.4.5
pycallgraph>=0.5.1
redis>=2.7.2
repoze.profile>=2.0b1",
    }

    class { 'python':
        version    => 'system',
        dev        => true,
        virtualenv => true,
    }

    python::requirements { "${home_dir}/pip.requirements.txt":
        virtualenv => 'system',
        require => File["${home_dir}/pip.requirements.txt"]
    }
}
