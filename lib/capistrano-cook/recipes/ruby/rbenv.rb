Capistrano::Configuration.instance.load do
  set_default :ruby_version, "1.9.3-p125"
  set_default :rbenv_bootstrap, "bootstrap-ubuntu-10-04"
  set_default :ruby_installer, :rbenv

  namespace :rbenv do
    desc "Install rbenv, Ruby, and the Bundler gem"
    task :install, roles: :app do
      logger.info "ruby_installer set to #{ruby_installer}"
      run "#{sudo} apt-get -y install curl git-core libreadline-dev"
      run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
      bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
BASHRC
      put bashrc, "/tmp/rbenvrc"
      run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
      run "mv ~/.bashrc.tmp ~/.bashrc"
      run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
      run %q{eval "$(rbenv init -)"}
      #run "#{sudo} rbenv #{rbenv_bootstrap}"
      run "rbenv install #{ruby_version}"
      run "rbenv global #{ruby_version}"
      run "gem install bundler --no-ri --no-rdoc"
      run "rbenv rehash"
    end


    after "deploy:install" do
      install if ruby_installer == :rbenv
    end

    desc "Reinstall Ruby, and the Bundler gem"
    task :reinstall_ruby, roles: :app do
      run "rbenv install #{ruby_version}"
      run "rbenv global #{ruby_version}"
      run "gem install bundler --no-ri --no-rdoc"
      run "rbenv rehash"
    end
  end
end
