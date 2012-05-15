Capistrano::Configuration.instance.load do
  set_default(:db_host,     "localhost")
  set_default(:db_user)     { application }
  set_default(:db_password) { Capistrano::CLI.password_promp "MySQL Password"}
  set_default(:db_name)     { "#{application}_#{rails_env}" }

  namespace :mysql do
    desc "Install the MySQL server"
    task :install, roles: :db do
      run "export DEBIAN_FRONTEND=noninteractive"
      run "#{sudo} apt-get -y update "
      run "#{sudo} apt-get -y install mysql-server libmysqlclient-dev libmysql-ruby"
      restart
    end
    after "deploy:install", "mysql:install"

    desc "Create user and database for the application"
    task :create_database, roles: :db do
      run %Q{#{sudo} mysql -e "create user '#{db_user}'@'#{db_host}' identyfied by #{db_password};"}
      run %Q{#{sudo} mysql -e "create databse #{db_name};"}
      run %Q{#{sudo} mysql -e "GRANT ALL PRIVILEGES ON *.* TO '#{db_user}'@'#{db_host}'"}
    end
    after "deploy:setup", "mysql:create_database"

    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      template "mysql.yml.erb", "#{shared_path}/config/database.yml"
    end
    after "deploy:setup", "mysql:setup"

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after "deploy:finalize_update", "mysql:symlink"

    %w[start stop restart].each do |command|
      task command, roles: :db do
        run "#{sudo} service mysql #{command}"
      end
    end
  end
end
