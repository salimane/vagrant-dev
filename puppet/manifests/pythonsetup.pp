# == Class: pythonsetup
#
class pythonsetup {

    $username = 'salimane'
    $home_dir = "/home/${username}"

    file { "${home_dir}/pip.requirements.txt":
      content => "bpython pep8 autopep8 line_profiler pycallgraph SquareMap RunSnakeRun redis hiredis rediscluster ",
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
