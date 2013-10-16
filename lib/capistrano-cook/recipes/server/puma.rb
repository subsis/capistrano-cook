Capistrano::Configuration.instance(:must_exist).load do
  set_default(:puma_user)          { user }
  set_default(:puma_template)      { "puma.rb.erb" }
  set_default(:puma_config)        { "#{shared_path}/config/puma.rb" }
  set_default(:puma_log)           { "#{shared_path}/log/puma.log" }
  set_default(:puma_workers, 1)
  set_default(:puma_min_threads, 1)
  set_default(:puma_max_threads, 16)
  set_default(:puma_timeout, 30)
  set_default(:rails_server, :puma)

  namespace :puma do
    desc "Update Puma app configuration"
    task :update_config, :roles => :app do
      run "#{sudo} mkdir -p #{shared_path}/config"
      template puma_template, "/tmp/puma.rb"
      run "#{sudo} mv /tmp/puma.rb #{puma_config}"
    end

    desc "Install puma jungle services"
    task :install, :roles => :app do
      run "#{sudo} wget 'https://raw.github.com/puma/puma/master/tools/jungle/init.d/puma' -O /etc/init.d/puma"
      run "#{sudo} chmod +x /etc/init.d/puma"
      run "#{sudo} update-rc.d -f puma defaults"

      run "#{sudo} wget 'https://raw.github.com/puma/puma/master/tools/jungle/init.d/run-puma' -O /usr/local/bin/run-puma"
      run "#{sudo} chmod +x /usr/local/bin/run-puma"
      run "#{sudo} touch /etc/puma.conf"
    end

    desc "Setup puma initializer and app configuration"
    task :setup, :roles => :app do
      update_config

      run "#{sudo} /etc/init.d/puma remove #{ current_path }"
      run "#{sudo} /etc/init.d/puma add #{ current_path } #{ puma_user } #{ puma_config } #{ puma_log }"
    end

    %w[start stop restart].each do |command|
      desc "#{command.capitalize} puma"
      task command, :roles => :app do
        run "service puma #{command}"
      end
      after "deploy:#{command}", "puma:#{command}" if rails_server == :puma
    end

    after "deploy:setup" do
      setup if rails_server == :puma
    end

    after "deploy:update_code" do
      update_config if rails_server == :puma
    end
  end
end
