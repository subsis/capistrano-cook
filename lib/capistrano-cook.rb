require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/capistrano-cook/recipes/*.rb'       )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/capistrano-cook/recipes/server/*.rb')).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/capistrano-cook/recipes/db/*.rb'    )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/capistrano-cook/recipes/ruby/*.rb'  )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/capistrano-cook/recipes/assets/*.rb')).sort.each { |f| load f }
