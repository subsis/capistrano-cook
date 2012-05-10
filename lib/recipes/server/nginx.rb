Capistrano::Configuration.instance.load do
  set_default(:nginx_template, "nginx_unicorn.erb")

  namespace :nginx do
    task :install, roles: :web do
      run "#{sudo} add-apt-repository ppa:nginx/stable"
      run "#{sudo} apt-get -y update "
      run "#{sudo} apt-get -y install nginx"
      start
    end
    after "deploy:install", "nginx:install"

    task :setup, roles: :web do
      template nginx_template, "/tmp/nginx_conf"
      run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
      run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
      restart
    end
    after "deploy:setup", "nginx:setup"

    %w[start stop restart].each do |command|
      task command, roles: :web do
        run "#{sudo} service nginx #{command}"
      end
    end
  end
end
