Capistrano::Configuration.instance(:must_exist).load do
  namespace :memcached do
    desc "Install Memcached server"
    task :install, :roles => :web do
      run "#{sudo} apt-get -y install memcached"
    end

    after "deploy:install" do
      install
    end
  end
end
