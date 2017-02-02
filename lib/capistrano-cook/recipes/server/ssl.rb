Capistrano::Configuration.instance(:must_exist).load do
  set_default(:install_ssl, false)
  namespace :ssl do
    desc "Install Let's Encrypt"
    task :install, :roles => :web do
      run "#{sudo} apt-get -y install letsencrypt"
    end

    desc "Setup Let's Encrypt certificate"
    task :setup, :roles => :web do
      template "letsencrypt_cron.erb", "/tmp/letsencrypt_cron"
      run "#{sudo} letsencrypt certonly --webroot -w #{current_path}/public -d #{domain}"
      run "#{sudo} crontab /tmp/letsencrypt_cron"
    end

    after "deploy:install" do
      install if install_ssl == true
    end

    # Must be setup *after* application is deployed and live.
    after "deploy:cold" do
      setup if install_ssl == true
    end
  end
end
