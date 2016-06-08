# Summary

The goal of `capistrano-cook` is to make single-server Rails hosting solutions a breeze to set up. It started out as a collection of the recipes presented on [RailsCasts](http://railscasts.com) on server provisioning based on Capistrano. Since then, the recipes have been extended and adapted. `capistrano-cook` has primarily been tested on Ubuntu 12.04 LTS.

# Getting Started

Add to your Gemfile:

````ruby
gem 'capistrano-cook', :git => 'https://github.com/subsis/capistrano-cook.git', :require => false
````

Also, add `gem "unicorn", :group => :production`, if you haven't already. Then run:

````bash
bundle install
````

To use the default configuration, add the following to your `config/deploy.rb` file:

````ruby
require "capistrano-cook"
````

This will include recipes for the default setup (see below for a description). If you want to customize your deployment setup, [check out the wiki](https://github.com/Subsis/capistrano-cook/wiki).

You need to configure Capistrano as you would otherwise. The following is an example of a minimal `config/deploy.rb`-file:

````ruby
require "bundler/capistrano"
require "capistrano-cook"

server "77.66.59.249", :app, :web, :db, :primary => true

set :domain,    "mydomain.com"
set :rails_env, :production

set :application, "myappname"
set :user,        "myappname"

set :scm,         "git"
set :repository,  "git@github.com:myorganization/myappname.git"
set :branch,      "production"
set :deploy_to,   "/var/www/#{application}"
set :deploy_via,  :remote_cache

set :use_sudo,      true

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true
````

Now you're ready to set up the server, and we need to create a deployment user (you will be prompted for the password of the `root`-user):

````bash
cap root:add_user
````

This will create a sudo user with the same name as your app, and prompt for a password. Then install the required packages:

````bash
cap deploy:install
````

You're now ready to set up your app, and deploy it for the first time:

````bash
cap deploy:setup deploy:cold
````

This will create deployment folder structure under `/var/www/myappname`, create the database, install your app as a service, and configure Nginx.

# Default Stack

The default stack is configured as follows:

* MySQL 5.7
* Nginx (from `ppa:nginx/stable`)
* Ruby 1.9.3-p125
* rbenv
* Unicorn with rolling restarts (as describe in [RailsCast 373](http://railscasts.com/episodes/373-zero-downtime-deployment). Installed as an sysinit service. Defaults to 2 workers processes.
* Monit monitors Unicorn worker processes, and gracefully restarts workers that use more than 120MB RAM, or an average of 25% CPU over 2 minutes.
* logrotate with weekly rotation, 10 weeks compressed history.
* nodejs (from `ppa:chris-lea/node.js`) for asset precompilation.
