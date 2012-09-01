require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/capistrano-cook/recipes/*.rb'       )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/capistrano-cook/recipes/server/*.rb')).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/capistrano-cook/recipes/db/*.rb'    )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/capistrano-cook/recipes/ruby/*.rb'  )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__)[0...-3], '/capistrano-cook/recipes/assets/*.rb')).sort.each { |f| load f }
