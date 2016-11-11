Capistrano::Configuration.instance(:must_exist).load do
  set_default(:unicorn_user)          { user }
  set_default(:unicorn_template)      { "unicorn.rb.erb" }
  set_default(:unicorn_init_template) { "unicorn_init.erb" }
  set_default(:unicorn_pid)           { "#{current_path}/tmp/pids/unicorn.pid" }
  set_default(:unicorn_config)        { "#{shared_path}/config/unicorn.rb" }
  set_default(:unicorn_log)           { "#{shared_path}/log/unicorn.log" }
  set_default(:unicorn_workers, 2)
  set_default(:unicorn_timeout, 30)
  set_default(:rails_server, :unicorn)

  namespace :unicorn do
    desc "Update Unicorn app configuration"
    task :update_config, :roles => :app do
      run "#{sudo} mkdir -p #{shared_path}/config"
      template unicorn_template, "/tmp/unicorn.rb"
      run "#{sudo} mv /tmp/unicorn.rb #{unicorn_config}"
    end

    desc "Setup Unicorn initializer and app configuration"
    task :setup, :roles => :app do
      update_config

      template unicorn_init_template, "/tmp/unicorn_init"
      run "chmod +x /tmp/unicorn_init"
      run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
      run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
    end

    %w[start stop reload restart].each do |command|
      desc "#{command.capitalize} unicorn"
      task command, :roles => :app do
        run "#{sudo} service unicorn_#{application} #{command}"
      end
    end

    after "deploy:start" do
      start if rails_server == :unicorn
    end

    after "deploy:stop" do
      stop if rails_server == :unicorn
    end

    after "deploy:restart" do
      reload if rails_server == :unicorn
    end

    after "deploy:setup" do
      setup if rails_server == :unicorn
    end

    after "deploy:update_code" do
      update_config if rails_server == :unicorn
    end
  end
end
