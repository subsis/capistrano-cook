Capistrano::Configuration.instance.load do
  set_default :libv8_version,       "3.3.10.2"
  set_default :system_architecture, "x86-linux"

  set_default :fix_libv8,    false

  namespace :gem_dependences do

    before "bundle:install" do
      libv8 if fix_libv8 == true
    end

    after "deploy:setup" do
      gemfile_lock = File.read("Gemfile.lock")

      %w{nokogiri patron dragonfly}.each do |gem|
        send(:"#{gem}") if gemfile_lock =~ /#{gem}/
      end
    end

    desc "v8 libraries"
    task :libv8, :role => :app do
      run "cd #{release_path}/vendor/cache; wget 'http://rubygems.org/downloads/libv8-#{libv8_version}-#{system_architecture}.gem'"
    end

    desc "Installs nokogiri's library dependencies"
    task :nokogiri, :role => :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libxml2 libxml2-dev libxslt1-dev"
    end

    desc "Installs patron's library dependencies"
    task :patron, :role => :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libcurl4-openssl-dev"
    end

    desc "Installs dragonfly's library dependencies"
    task :dragonfly, :role => :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install imagemagick"
    end
  end
end
