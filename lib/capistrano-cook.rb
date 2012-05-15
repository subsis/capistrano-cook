require 'capistrano'
require 'capistrano/cli'
require 'helpers'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
load "/recipes/server/nginx"
load "/recipes/server/unicorn"
load "/recipes/db/mysql"
load "/recipes/ruby/nodejs"
load "/recipes/ruby/rbenv"
load "assets"
