require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Capistrano::Configuration.instance.load do
  set :http_server, :apache2
end

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/server/apache2.rb')).first
