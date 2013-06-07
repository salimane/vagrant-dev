# == Class: nodejssetup
#
class nodejssetup {
    class { 'nodejs':
      dev_package => false
    }

    package {
        'less':
            #ensure  => latest,
            provider => 'npm',
            require  => Class['nodejs'];
    }
}