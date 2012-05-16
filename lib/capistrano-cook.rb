require 'capistrano'
require 'capistrano/cli'
require 'helpers'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb'       )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__), '/recipes/assets/*.rb')).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__), '/recipes/db/*.rb'    )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__), '/recipes/ruby/*.rb'  )).sort.each { |f| load f }
Dir.glob(File.join(File.dirname(__FILE__), '/recipes/server/*.rb')).sort.each { |f| load f }
