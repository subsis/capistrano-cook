Capistrano::Configuration.instance(true).load do
  set_default :ruby_installer, :rbenv
  set_default(:rvm_type, :user)

  set_default(:rvm_path) do
    case rvm_type
    when :root, :system
      "/usr/local/rvm"
    when :local, :user, :default
      "$HOME/.rvm"
    else
      rvm_type.to_s.empty? ?  "$HOME/.rvm" : rvm_type.to_s
    end
  end

  set_default :ruby_version, "1.9.3-p125"
  set_default :rvm_gemset, "rails"
  set_default :rvm_install_ruby_params, ""
  set_default(:rvm_install_with_sudo, false)
  set_default(:rvm_install_shell, :bash)
  set_default(:rvm_install_ruby_threads, "$(cat /proc/cpuinfo | grep vendor_id | wc -l)")

  namespace :rvm do
    desc "Install RVM, Ruby, create Gemset and install bundler"
    task :install, roles: :app do
      command_fetch="curl -L get.rvm.io | "
      command_install = ""
      case rvm_type
      when :root, :system
        if use_sudo == false && rvm_install_with_sudo == false
          raise ":use_sudo is set to 'false' but sudo is needed to install rvm_type: #{rvm_type}. You can enable use_sudo within rvm for use only by this install operation by adding to deploy.rb: set :rvm_install_with_sudo, true"
        else
          command_install = "#{sudo} "
        end
      end
      command_install << "#{rvm_install_shell} -s stable --path #{rvm_path}"

      run "#{command_fetch} #{command_install}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_path, "bin/rvm")} install #{ruby_version} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_path, "bin/rvm")} install #{ruby_version} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_path, "bin/rvm")} #{ruby_version} do rvm gemset create #{rvm_gemset}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_path, "bin/rvm")} use #{ruby_version} --default"
      run "#{File.join(rvm_path, "bin/gem")} install bundler --no-ri --no-rdoc"
    end

    after "deploy:install" do
      install if ruby_installer == :rvm
    end

    desc "Reinstall Ruby, and the Bundler gem"
    task :reinstall_ruby, roles: :app do
      run "rvm reinstall #{ruby_version} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}", :shell => "#{rvm_install_shell}"
      run "rvm #{ruby_version} do rvm gemset create #{rvm_gemset}", :shell => "#{rvm_install_shell}"
      run "rvm use #{ruby_version} --default"
      run "gem install bundler --no-ri --no-rdoc"
    end
  end
end
