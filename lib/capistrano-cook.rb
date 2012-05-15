require 'capistrano'
require 'capistrano/cli'
require 'helpers'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/server/nginx.rb')).first
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/server/unicorn.rb')).first
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/db/mysql.rb')).first
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/ruby/nodejs.rb')).first
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/ruby/rbenv.rb')).first
load Dir.glob(File.join(File.dirname(__FILE__), '/recipes/ruby/gems_dependences.rb')).first
load Dir.glob(File.join(File.dirname(__FILE__), '/assets.rb')).first
