Capistrano::Configuration.instance.load do
  set_default(:db_host,     "localhost")
  set_default(:db_user)     { application }
  set_default(:db_generate_password, true)
  set_default(:db_name)     { "#{application}_#{rails_env}" }
  set_default(:postgresql_template) { "postgresql.yml.erb" }
  set_default(:db_server, :postgresql)
  set_default(:db_password) {
    if db_generate_password
      logger.info "Database password will be generated"
      passed = generate_password(24)
    else
      passwd = Capistrano::CLI.password_prompt "PostgreSQL Password: "
    end
    passwd
  }

  namespace :postgresql do
    desc "Install the latest reales of PostgreSQL"
    task :install, roles: :db do
      run "#{sudo} add-apt-repository -y ppa:pitti/postgresql"
      run "#{sudo} apt-get -y update "
      run "#{sudo} apt-get -y install postgresql libpq-dev"
    end

    desc "Create user and database for the application"
    task :create_database, roles: :db do
      run %Q{#{sudo} -u postgres psql -c "create user #{db_user} with password '#{db_password}';"}
      run %Q{#{sudo} -u postgres psql -c "create database #{db_name} owner #{db_user};"}
    end

    desc "Create database.yml file. Task should be run together with postgres:create_database."
    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      template postgresql_template, "#{shared_path}/config/database.yml"
    end

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end

    after "deploy:install" do
      install if db_server == :postgresql
    end
    after "deploy:setup" do
      if db_server == :postgresql
        create_database
        setup
      end
    end
    after "deploy:finalize_update" do
      symlink if db_server == :postgresql
    end

    %w[start stop restart].each do |command|
      desc "#{command} PostgreSQL server"
      task command, roles: :db do
        run "#{sudo} service postgresql #{command}"
      end
    end
  end
end
