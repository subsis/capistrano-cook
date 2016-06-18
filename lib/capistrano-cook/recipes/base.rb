require 'capistrano'
require 'digest'
require 'securerandom'

Capistrano::Configuration.instance(:must_exist).load do
  def template(from, to)
    if File.exists?("config/deploy/templates/#{from}")
      logger.info "Using template form #{File.absolute_path('config/deploy/template/' + from)}"
      erb = File.read("config/deploy/templates/#{from}")
    else
      erb = File.read(File.expand_path("templates/#{from}", File.dirname(__FILE__)))
    end
    put ERB.new(erb).result(binding), to
  end

  def set_default(name, *args, &block)
    set(name, *args, &block) unless exists?(name)
  end

  def generate_password(len=16)
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user}--")[0,len]
  end

  def run_interactively(command, server=nil)
    server ||= find_servers_for_task(current_task).first
    exec %Q(ssh #{user}@#{server.host} -t 'cd #{current_path} && #{command}')
  end

  namespace :deploy do
    desc 'Install common libraries on server'
    task :install do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install python-software-properties curl build-essential git-core libssl-dev"
    end

    desc 'Fix priviledges for shared folders'
    task :setup_priviledges do
      run "#{sudo} chown -R #{user} #{shared_path}"
      run "#{sudo} chown -R #{user} #{deploy_to}"
    end
    after 'deploy:setup', 'deploy:setup_priviledges'
  end

  namespace :root do
    desc 'Create deploy user and add proper priviledges'
    task :add_user do
      set_default(:usr_password) { Capistrano::CLI.password_prompt 'Password for new user:' }
      set :base_user, user
      set :user, fetch(:root_user, 'root')
      begin
        run "#{sudo} addgroup admin"
      rescue Capistrano::CommandError => e
        logger.info 'group admin already exists.'
      end
      run "#{sudo} useradd -s /bin/bash -G admin -mU #{base_user}"
      # Set secret in .bashrc:
      run "#{sudo} echo 'export SECRET_KEY_BASE=#{SecureRandom.hex(64)}' >> /home/#{base_user}/.bashrc"
      run "echo '#{usr_password}' >  tmp_pass"
      run "echo '#{usr_password}' >> tmp_pass"
      run "#{sudo} passwd #{base_user} < tmp_pass"
      run 'rm tmp_pass'
      set :user, base_user
    end
  end

  namespace :remote do
    namespace :rails do
      desc 'Connect to remote rails console'
      task :console, :roles => :app do
        run_interactively "bundle exec rails console #{rails_env}"
      end

      desc 'Connect to remote rails console'
      task :dbconsole, :roles => :app do
        run_interactively "bundle exec rails dbconsole #{rails_env}"
      end

      desc 'tail log'
      task :log, :roles => :app do
        run_interactively "tail -n 100 -f ./log/#{rails_env}.log"
      end
    end

    namespace :puma do
      desc 'tail log'
      task :log, :roles => :app do
        run_interactively 'tail -n 100 -f ./log/puma.log'
      end
    end

    desc 'htop'
    task :htop, :roles => :app do
      run_interactively 'htop'
    end
  end
end
