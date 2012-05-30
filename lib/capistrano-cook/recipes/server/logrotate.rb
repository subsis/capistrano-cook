Capistrano::Configuration.instance.load do
  set_default(:logorate, true)
  namespace :logrotate do
    task :setup, roles: :web do
      template "logrotate.erb", "/tmp/logrotate"
      run "#{sudo} mv /tmp/logrotate /etc/logrotate.d/#{application}"
    end

    after "deploy:setup" do
      setup if logrotate
    end
  end
end
