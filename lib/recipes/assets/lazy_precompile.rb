Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :assets do
      task :precompile, :roles => :web, :except => { :no_release => true } do
        if capture("cd #{latest_release} && #{source.local.log(current_revision)} app/assets/ lib/assets/ vendor/assets/ | wc -l").to_i > 0
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} assets:precompile}
        else
          logger.info "Skipping asset pre-compilation because there were no asset changes."
        end
      end
    end
  end
end
