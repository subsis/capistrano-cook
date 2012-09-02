require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Dir.glob(File.join(File.dirname(__DIR__), '/recipes/*.rb')).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__DIR__), '/recipes/assets/*.rb')).sort.each { |f| load f }
