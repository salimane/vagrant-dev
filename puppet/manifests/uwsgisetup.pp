# == Class: uwsgisetup
#
class uwsgisetup {

    include uwsgi

    uwsgi::plugin {
         'python':
            ensure => present;
    }
}
