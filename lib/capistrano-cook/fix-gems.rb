require 'capistrano'
require 'capistrano/cli'
require 'capistrano-cook/helpers'

Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/recipes/*.rb')).sort.each { |f| load f }
load Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), '/recipes/ruby/gems_dependences.rb')).first
