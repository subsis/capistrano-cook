Capistrano::Configuration.instance.load do
  set_default(:db_host,     "localhost")
  set_default(:db_user)     { application }
  set_default(:db_password) { Capistrano::CLI.password_prompt "PostgreSQL Password"}
  set_default(:db_name)     { "#{application}_#{rails_env}" }
  set_default(:postgresql_template) { File.expand_path("../../templates/postgresql.yml.erb", __FILE__) }

  namespace :postgresql do
    desc "Install the latest reales of PostgreSQL"
    task :install, roles: :db do
      run "#{sudo} add-apt-repository -y ppa:pitti/postgresql"
      run "#{sudo} apt-get -y update "
      run "#{sudo} apt-get -y install postgresql libpq-dev"
    end
    after "deploy:install", "postgresql:install"

    desc "Create user and database for the application"
    task :create_database, roles: :db do
      run %Q{#{sudo} -u postgres psql -c "create user #{db_user} with password #{db_password};"}
      run %Q{#{sudo} -u postgres psql -c "create databse #{db_name} owner #{db_user};"}
    end
    after "deploy:setup", "postgresql:create_database"

    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      template postgresql_template, "#{shared_path}/config/database.yml"
    end
    after "deploy:setup", "postgresql:setup"

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after "deploy:finalize_update", "postgresql:symlink"

    %w[start stop restart].each do |command|
      task command, roles: :db do
        run "#{sudo} service postgresql #{command}"
      end
    end
  end
end
