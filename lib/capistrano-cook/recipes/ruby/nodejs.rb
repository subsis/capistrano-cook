Capistrano::Configuration.instance(:must_exist).load do
  set_default(:install_nodejs, true)
  namespace :nodejs do
    desc "Install the latest relase of Node.js"
    task :install, :roles => :app do
      run "#{sudo} add-apt-repository -y ppa:chris-lea/node.js"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install nodejs"
    end
    after "deploy:install" do
      logger.info "Node js installation: #{install_nodejs}"
      install if install_nodejs == true
    end
  end
end
