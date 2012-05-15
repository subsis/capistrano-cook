Capistrano::Configuration.instance.load do
  set_default(:db_host,     "localhost")
  set_default(:db_user)     { application }
  set_default(:db_password) { Capistrano::CLI.password_prompt "MySQL Password: "}
  set_default(:db_root_password) { Capistrano::CLI.password_prompt "MySQL root password: "}
  set_default(:db_name)     { "#{application}_#{rails_env}" }

  namespace :mysql do
    desc "Install the MySQL server"
    task :install, roles: :db do
      run "#{sudo} su -c \"echo 'mysql-server mysql-server/root_password select #{db_root_password}' | debconf-set-selections\""
      run "#{sudo} su -c \"echo 'mysql-server mysql-server/root_password_again select #{db_root_password}' | debconf-set-selections\""
      run "#{sudo} apt-get -y update "
      run "#{sudo} apt-get -y install mysql-server libmysqlclient-dev libmysql-ruby"
      restart
    end
    after "deploy:install", "mysql:install"

    desc "Create user and database for the application"
    task :create_database, roles: :db do
      run %Q{mysql -u root -p=#{db_root_password} -e "create user '#{db_user}'@'#{db_host}' identyfied by '#{db_password}';"}
      run %Q{mysql -u root -p=#{db_root_password} -e "create databse #{db_name};"}
      run %Q{mysql -u root -p=#{db_root_password} -e "GRANT ALL PRIVILEGES ON *.* TO '#{db_user}'@'#{db_host}'"}
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
