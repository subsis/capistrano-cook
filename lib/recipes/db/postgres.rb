Capistrano::Configuration.instance.load do
  set_default(:db_host,     "localhost")
  set_default(:db_user)     { application }
  set_default(:db_password) { Capistrano::CLI.password_promp "PostgreSQL Password"}
  set_default(:db_name)     { "#{application}_production" }

  namespace :postgresql do
    desc "Install the latest reales of PostgreSQL"
    task :install, roles: :db do
      run "#{sudo} add-apt-repository ppa:pitti/postgresql"
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
      template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
    end
    after "deploy:setup", "postgresql:setup"

    %w[start stop restart].each do |command|
      task command, roles: :db do
        run "#{sudo} service postgresql #{command}"
      end
    end
  end
end
