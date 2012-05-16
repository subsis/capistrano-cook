Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :assets do
      set_default :assets, :lazy

      desc "precompile assets"
      task :precompile, :roles => :web, :except => { :no_release => true } do
        if assets == :local
           local_precompile
        elsif assets == :lazy
           lazy_precompile
        else
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} assets:precompile}
        end
      end
    end
  end
end
