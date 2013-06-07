# == Class: nodedefault
#
class nodedefault {

    import 'puppetsetup.pp'
    import 'sshsetup.pp'
    import 'nginxsetup.pp'
    import 'mysqlsetup.pp'
    import 'postgresql.pp'
    import 'nodejssetup.pp'
    import 'redissetup.pp'
    import 'sysctlsetup.pp'
    import 'gosetup.pp'
    import 'heroku.pp'
    import 'security'
    import 'memcachedsetup'
    import 'uwsgisetup'

    include java7
    include monit

    include puppetsetup
    include sshsetup
    include nginxsetup
    include mysqlsetup
    include nodejssetup
    include redissetup
    include sysctlsetup
    include gosetup
    include heroku
    include security
    include memcachedsetup
    include uwsgisetup

}