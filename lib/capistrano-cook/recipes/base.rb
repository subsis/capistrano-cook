require "digest"

puts ""
puts "In base.rb"
puts "Capistrano responds to instance: #{Capistrano::Configuration.respond_to?(:instance)}"
puts "Capistrano.instance responds to load: #{Capistrano::Configuration.instance.respond_to?(:load)}"
puts ""

Capistrano::Configuration.instance.load do
  def template(from, to)
    if File.exists?("deploy/templates/#{from}")
      logger.info "using template form #{File.absolute_path('deploy/template/' + from)}"
      erb = File.read("deploy/templates/#{from}")
    else
      erb = File.read(File.expand_path("templates/#{from}", File.dirname(File.expand_path(__FILE__))))
    end
    put ERB.new(erb).result(binding), to
  end

  def set_default(name, *args, &block)
    set(name, *args, &block) unless  exists?(name)
  end

  def generate_password(len=16)
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user}--")[0,len]
  end


  namespace :deploy do
    desc "Install everything on server"
    task :install do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install python-software-properties curl build-essential git-core libssl-dev"
    end

    desc "fix privilages for shared folders"
    task :setup_privilages do
      run "#{sudo} chown -R #{user} #{shared_path}"
      run "#{sudo} chown -R #{user} #{deploy_to}"
    end
    after "deploy:setup", "deploy:setup_privilages"
  end

  namespace :root do
    desc "create depoly user and add proper privilages"
    task :add_user do
      set_default(:usr_password) { Capistrano::CLI.password_prompt "Password for new user:" }
      set :base_user, user
      set :user, 'root'
      begin
        run "addgroup admin"
      rescue Capistrano::CommandError => e
        logger.info "group admin already exists."
      end
      run "useradd -s /bin/bash -G admin -mU #{base_user}"
      run "echo '#{usr_password}' >  tmp_pass"
      run "echo '#{usr_password}' >> tmp_pass"
      run "passwd #{base_user} < tmp_pass"
      run "rm tmp_pass"
      set :user, base_user
    end
  end
end
