Set up my vagrant development box
=================================

Installation
------------

-	Install git, ruby
-	Install virtualbox using the packages at [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)
-	Install vagrant using the installation instructions in the [Getting Started document](http://www.vagrantup.com/downloads.html)
-	run the following commands:

```shell
vagrant plugin install vagrant-hostmanager
mkdir -p $HOME/src && cd $HOME/src
git clone https://github.com/salimane/vagrant-dev.git
cd vagrant-dev
bundle install
cd puppet && librarian-puppet install
vagrant up
vagrant provision
vagrant ssh
```

Installed components
--------------------

-	zsh
-	nginx
-	golang
-	uwsgi + python plugin
-	python + virtualenv + pip
-	sun jdk 7
-	sysctl configurations for lot of connections
-	rvm + ruby
-	node.js + npm
-	mysql server
-	postgresql
-	redis
-	memcached
-	php-fpm env + xdebug + xhprof + phpunit + boris
-	heroku toolbelt
-	weighttp

Hints
-----

**Provisioning**

To provision again in case of update or errors while the virtual machine is already up, use:

```shell
vagrant provision
```

It just runs puppet to apply manifests without restarting the virtual machine.

**Startup speed**

To speed up the startup process after the first run, use:

```shell
vagrant up --no-provision
```

It just starts the virtual machine without provisioning of the puppet recipes.
