Capistrano::Configuration.instance.load do
  set_default :rails_server,      :unicorn
  set_default :monit_mem_restart, "120.0 MB"
  set_default :monit_cpu_alert,   "22%"
  set_default :monit_cpu_restart, "25%"

  namespace :monit do
    task :install, roles: :app do
      run "#{sudo} apt-get install monit -y"
    end

    task :setup, roles: :app do
      template "monit.erb", "/tmp/monit"
      run "#{sudo} mv /tmp/monit /etc/monit/conf.d/#{application}"
      reload
    end

    %w[start stop restart reload].each do |command|
      task command, roles: :web do
        run "#{sudo} service monit #{command}"
      end
    end

    if rails_server == :unicorn
      after "deploy:install",        "monit:install"
      after "unicorn:update_config", "monit:setup"
      after "deploy:setup",          "monit:setup"
    end
  end
end
