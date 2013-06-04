# == Class: nodedefault
#
class nodedefault {

    import 'timezone.pp'
    import 'adduser.pp'
    import 'puppetsetup.pp'
    import 'sshsetup.pp'
    import 'dotfiles.pp'
    import 'nginxsetup.pp'
    import 'phpsetup.pp'
    import 'mysqlsetup.pp'
    import 'postgresql.pp'
    import 'nodejs.pp'
    import 'railssetup.pp'
    import 'redissetup.pp'
    import 'sysctlsetup.pp'
    import 'gosetup.pp'
    import 'heroku.pp'
    import 'weighttp'
    import 'security'
    import 'memcachedsetup'
    import 'pythonsetup.pp'
    import 'uwsgisetup'

    include apt
    include timezone
    include puppetsetup
    include sshsetup
    include nginxsetup
    include java7
    include mysqlsetup
    include redissetup
    include sysctlsetup
    include gosetup
    include heroku
    include monit
    include security
    include memcachedsetup
    include uwsgisetup

}