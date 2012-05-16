Capistrano::Configuration.instance(true).load do
  set :default_shell do
    shell = File.join(rvm_bin_path, "rvm-shell")
    ruby = rvm_ruby_string.to_s.strip
    if "#{ruby}" == "release_path"
      shell = "rvm_path=#{rvm_path} #{shell} --path '#{release_path}'"
    else
      shell = "rvm_path=#{rvm_path} #{shell} '#{ruby}'" unless ruby.empty?
    end
    shell
  end

 set_default(:rvm_type, :user)

 set_default(:rvm_path) do
    case rvm_type
    when :root, :system
      "/usr/local/rvm"
    when :local, :user, :default
      "$HOME/.rvm/"
    else
      rvm_type.to_s.empty? ?  "$HOME/.rvm" : rvm_type.to_s
    end
  end

  set_default :ruby_version, "1.9.3-p125"
  set_default :rvm_gemset, "rails"
  set_default(:rvm_install_with_sudo, false)
  set_default(:rvm_install_shell, :bash)
  set_default(:rvm_install_ruby_threads, "$(cat /proc/cpuinfo | grep vendor_id | wc -l)")

  namespace :rvm do
    desc "Install RVM, Ruby, create Gemset and install bundler"
    task :install, roles: :app do
      command_fetch="curl -L get.rvm.io | "
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
      run "#{File.join(rvm_bin_path, "rvm")} install #{ruby_version} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_bin_path, "rvm")} #{ruby_version} do rvm gemset create #{rvm_gemset}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_bin_path, "rvm")} use #{ruby_version} --default"
      run "#{File.join(rvm_bin_path, "gem"} install bundler --no-ri --no-rdoc"
    end

    desc "Reinstall Ruby, and the Bundler gem"
    task :reinstall_ruby, roles: :app do
      run "#{File.join(rvm_bin_path, "rvm")} reinstall #{ruby_version} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_bin_path, "rvm")} #{ruby_version} do rvm gemset create #{rvm_gemset}", :shell => "#{rvm_install_shell}"
      run "#{File.join(rvm_bin_path, "rvm")} use #{ruby_version} --default"
      run "#{File.join(rvm_bin_path, "gem"} install bundler --no-ri --no-rdoc"
    end
  end
end
