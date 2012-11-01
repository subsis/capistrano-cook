Capistrano::Configuration.instance.load do
  set_default(:apache2_template) { "apache2.erb" }
  set_default(:http_server, :apache2)
  set_default(:unicorn_port_or_socket, "5000")

  namespace :apache2 do
    desc "Install Apache2 server"
    task :install, :roles => :web do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install apache2"
      start
    end

    desc "Setup apache2 configuration"
    task :setup, :roles => :web do
      template apache2_template, "/tmp/apache2_conf"
      run "#{sudo} mv /tmp/apache2_conf /etc/apache2/sites-available/#{application}"
      run "#{sudo} ln -s /etc/apache2/sites-available/#{application} /etc/apache2/sites-enabled/#{application}"
      run "#{sudo} rm -f /etc/apache2/sites-enabled/default"
      run "#{sudo} a2enmod proxy"
      run "#{sudo} a2enmod proxy_balancer"
      run "#{sudo} a2enmod proxy_http"
      run "#{sudo} a2enmod rewrite"
      restart
    end

    %w[start stop restart reload].each do |command|
      desc "#{command} Apache2 server"
      task command, :roles => :web do
        run "#{sudo} service apache2 #{command}"
      end
    end

    after "deploy:install" do
      install if http_server == :apache2
    end

    after "deploy:setup" do
      setup if http_server == :apache2
    end
  end
end
