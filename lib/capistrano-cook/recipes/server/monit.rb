Capistrano::Configuration.instance.load do
  set_default :rails_server,      :unicorn
  set_default :monit_mem_restart, "120.0 MB"
  set_default :monit_cpu_alert,   "22%"
  set_default :monit_cpu_restart, "25%"

  namespace :monit do
    desc "Install monit. Works with unicorn server"
    task :install, :roles => :app do
      run "#{sudo} apt-get install monit -y"
    end

    desc "Create configuration files for monit"
    task :setup, :roles => :app do
      template "monit.erb", "/tmp/monit"
      run "#{sudo} mv /tmp/monit /etc/monit/conf.d/#{application}"
      reload
    end

    %w[start stop restart reload].each do |command|
      desc "#{command} monit"
      task command, :roles => :web do
        run "#{sudo} service monit #{command}"
      end
    end

    after "deploy:install" do
      install if rails_server == :unicorn
    end

    after "deploy:setup" do
      setup if rails_server == :unicorn
    end

    after "unicorn:update_config" do
      setup if rails_server == :unicorn
    end
  end
end
