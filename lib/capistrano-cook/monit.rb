require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/server/monit.rb')).first
