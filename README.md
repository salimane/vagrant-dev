Set up my vagrant development box
=======================================

Installation
------------

* Install git, ruby
* Install virtualbox using the packages at [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* run the following commands:

```shell
gem install puppet specific_install
gem specific_install -l git://github.com/maestrodev/librarian-puppet.git
vagrant plugin install vagrant-vbguest
vagrant box add vagrant-dev http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-1204-x64.box
git clone https://github.com/salimane/vagrant-dev.git
cd vagrant-dev/puppet
librarian-puppet install --clean
vagrant up
vagrant ssh
```

Installed components
--------------------

* zsh
* nginx
* golang
* heroku toolbelt
* sysctl configurations for lot of connections
* rbenv
* rails
* node.js
* npm
* percona mysql server
* postgresql
* redis
* php-fpm env + xdebug + xhprof + phpunit


Hints
-----

**Startup speed**

To speed up the startup process after the first run, use:

```shell
vagrant up --no-provision
```
It just starts the virtual machine without provisioning of the puppet recipes.

