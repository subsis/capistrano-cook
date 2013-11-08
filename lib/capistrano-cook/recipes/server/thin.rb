Capistrano::Configuration.instance(:must_exist).load do
  set_default(:thin_user)          { user }
  set_default(:thin_template)      { "thin.yml.erb" }
  set_default(:thin_config)        { "/etc/thin/#{application}.yml" }
  set_default(:thin_log)           { "#{shared_path}/log/thin.log" }
  set_default(:thin_pid)           { "#{current_path}/tmp/pids/thin.pid" }
  set_default(:thin_sock)          { "/tmp/#{application}_thin.sock" }
  set_default(:thin_servers, 4)
  set_default(:thin_timeout, 30)
  set_default(:rails_server, :thin)
  set_default(:thin_max_conn, 1024)
  set_default(:thin_max_persistentconn, 100)
  set_default(:thin_wait, 30)

  namespace :thin do
    desc "Update thin app configuration"
    task :update_config, :roles => :app do
      template thin_template, "/tmp/thin.yml"
      run "#{sudo} mv /tmp/thin.yml #{puma_config}"
    end

    desc "Install thin services"
    task :install, :roles => :app do
      run "git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo"
      run "rbenv sudo thin install"
    end

    desc "Setup puma initializer and app configuration"
    task :setup, :roles => :app do
      update_config
    end

    %w[start stop restart].each do |command|
      desc "#{command.capitalize} thin"
      task command, :roles => :app do
        run "#{sudo} service thin #{command}"
      end
    end

    after "deploy:start" do
      start if rails_server == :thin
    end

    after "deploy:stop" do
      stop if rails_server == :thin
    end

    after "deploy:restart" do
      restart if rails_server == :thin
    end

    after "deploy:setup" do
      setup if rails_server == :thin
    end

    after "deploy:update_code" do
      update_config if rails_server == :thin
    end
  end
end
