Capistrano::Configuration.instance.load do
  def template(from, to)
    if File.exists?("deploy/templates/#{from}")
      logger.info "using template form #{File.absolute_path('deploy/template/' + from)}"
      erb = File.read("deploy/templates/#{from}")
    else
      erb = File.read(File.expand_path("templates/#{from}", File.dirname(__FILE__)))
    end
    put ERB.new(erb).result(binding), to
  end

  def set_default(name, *args, &block)
    set(name, *args, &block) unless  exists?(name)
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
end
