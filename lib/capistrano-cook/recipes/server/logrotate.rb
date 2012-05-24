Capistrano::Configuration.instance.load do
  namespace :logrotate do
    task :setup, roles: :web do
      template "logrotate.erb", "/tmp/logrotate"
      run "#{sudo} mv /tmp/logrotate /etc/logrotate.d/#{application}"
    end

    after "deploy:setup", "logrotate:setup"
  end
end
