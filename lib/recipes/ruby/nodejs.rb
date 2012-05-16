Capistrano::Configuration.instance.load do
  set_default(:nodejs, true)
  namespace :nodejs do
    desc "Install the latest relase of Node.js"
    task :install, roles: :app do
      run "#{sudo} add-apt-repository -y ppa:chris-lea/node.js"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install nodejs"
    end
    after "deploy:install", "nodejs:install" if nodejs == true
  end
end
