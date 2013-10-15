require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Capistrano::Configuration.instance.load do
  set :rails_server, :puma
end

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/server/puma.rb')).first
