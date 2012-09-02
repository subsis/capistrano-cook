require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/recipes/*.rb')).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/recipes/assets/*.rb')).sort.each { |f| load f }
