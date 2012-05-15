require 'capistrano'
require 'capistrano/cli'
require 'helpers'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }

if exists?(:assets) && assets == :local
  load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/assets/local_precompile.rb')).first
else
  load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/assets/lazy_precompile.rb')).first
