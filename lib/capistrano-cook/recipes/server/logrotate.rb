Capistrano::Configuration.instance(:must_exist).load do
  set_default(:install_logorate, true)
  namespace :logrotate do
    desc "Setup logorate"
    task :setup, :roles => :web do
      template "logrotate.erb", "/tmp/logrotate"
      run "#{sudo} mv /tmp/logrotate /etc/logrotate.d/#{application}"
    end

    after "deploy:setup" do
      setup if install_logorate == true
    end
  end
end
