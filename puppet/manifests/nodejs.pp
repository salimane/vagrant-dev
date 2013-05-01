class { 'nodejs':
  dev_package => true
}

package {

    'less':
        #ensure  => latest,
        provider => 'npm',
        require  => Class['nodejs'];
}