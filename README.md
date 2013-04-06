Set up my vagrant development box
=======================================

Installation
------------

* Install virtualbox using the packages at [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* run the following commands:

```shell
sudo gem install librarian-puppet
vagrant plugin install vagrant-vbguest
vagrant box add vagrant-dev http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-1204-x64.box
git clone https://github.com/salimane/vagrant-dev.git
cd vagrant-dev/puppet
librarian-puppet init
vagrant up
vagrant ssh
```

Installed components
--------------------


Hints
-----

**Startup speed**

To speed up the startup process after the first run, use:

```shell
vagrant up --no-provision
```
It just starts the virtual machine without provisioning of the puppet recipes.

