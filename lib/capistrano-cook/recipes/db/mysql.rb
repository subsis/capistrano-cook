Capistrano::Configuration.instance.load do
  set_default(:db_host,     "localhost")
  set_default(:db_user)     { application }
  set_default(:db_generate_password, true)
  set_default(:db_generate_root_password, false)
  set_default(:db_name)     { "#{application}_#{rails_env}" }
  set_default(:mysql_template) { "mysql.yml.erb" }
  set_default(:db_server, :mysql)
  set_default(:db_password) {
    if db_generate_password
     logger.info "Database password will be generated"
     passwd = generate_password(24)
    else
     passwd = Capistrano::CLI.password_prompt "MySQL Password: "
    end
    passwd
  }
  set_default(:db_root_password) {
    if db_generate_root_password
      logger.info "Mysql root password will be generated"
      root_passwd = generate_password(16)
      logger.info "Mysql root password: #{root_passwd} \n You have to save this password"
    else
      root_passwd = Capistrano::CLI.password_prompt "MySQL root password: "
    end
    root_passwd
  }

  namespace :mysql do
    desc "Install the MySQL server"
    task :install, roles: :db do
      run "#{sudo} su -c \"echo 'mysql-server mysql-server/root_password select #{db_root_password}' | debconf-set-selections\""
      run "#{sudo} su -c \"echo 'mysql-server mysql-server/root_password_again select #{db_root_password}' | debconf-set-selections\""
      run "#{sudo} apt-get -y update "
      run "#{sudo} apt-get -y install mysql-server libmysqlclient-dev libmysql-ruby"
      restart
    end

    desc "Create user and database for the application"
    task :create_database, roles: :db do
      run %Q{mysql -u root --password=#{db_root_password} -e "create user '#{db_user}'@'#{db_host}' identified by '#{db_password}';"}
      run %Q{mysql -u root --password=#{db_root_password} -e "CREATE DATABASE #{db_name};"}
      run %Q{mysql -u root --password=#{db_root_password} -e "GRANT ALL PRIVILEGES ON *.* TO '#{db_user}'@'#{db_host}'"}
    end

    desc "Create database.yml file"
    task :setup, roles: :app do
      run "#{sudo} mkdir -p #{shared_path}/config"
      template mysql_template, "/tmp/mysql.yml"
      run "#{sudo} mv -f /tmp/mysql.yml #{shared_path}/config/database.yml"
    end

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end

    after "deploy:install" do
      install if db_server == :mysql
    end
    after "deploy:setup" do
      if db_server == :mysql
        create_database
        setup
      end
    end
    after "deploy:finalize_update" do
      symlink if db_server == :mysql
    end


    %w[start stop restart].each do |command|
      task command, roles: :db do
        run "#{sudo} service mysql #{command}"
      end
    end
  end
end
