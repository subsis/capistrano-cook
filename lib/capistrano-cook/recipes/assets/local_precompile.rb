Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :assets do
      desc "Compiles assets on local machine"
      task :local_precompile, :roles => :web, :except => { :no_release => true } do
        run_locally "bundle exec rake assets:precompile"
        find_servers_for_task(current_task).each do |server|
          run_locally "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{server.host}:#{shared_path}"
        end
      end
    end
  end
end
