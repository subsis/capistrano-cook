Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :assets do
      desc "precompile assets"
      task :precompile, :roles => :web, :except => { :no_release => true } do
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} assets:precompile}
      end
    end
  end
end
