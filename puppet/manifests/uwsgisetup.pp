# == Class: uwsgisetup
#
class uwsgisetup {

    class { 'uwsgi':
        python => 'present',
    }
}
