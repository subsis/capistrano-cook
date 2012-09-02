require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Capistrano::Configuration.instance.load do
  set :db_server, :mysql
end

Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/recipes/*.rb')).sort.each { |f| load f }
load Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/recipes/db/mysql.rb')).first
