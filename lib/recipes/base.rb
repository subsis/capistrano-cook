Capistrano::Configuration.instance.load do
  def template(from, to)
    erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
    put ERB.new(erb).result(binding), to
  end

  def set_default(name, *args, &block)
    set(name, *args, &block) unless  exists?(name)
  end

  namespace :deploy do
    desc "Install everything on server"
    task :install do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install python-software-properties curl build-essential git-core"
    end

    desc "setup privilages for shared folders"
    task :setup_privilages do
      run "#{sudo} chown -R #{user} #{shared_path}"
      run "#{sudo} chown -R #{user} #{release_path}"
    end
    after "deploy:setup", "deploy:setup_privilages"
  end
end
