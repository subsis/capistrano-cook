Capistrano::Configuration.instance.load do
  set_default :libv8_version, "3.3.10.2"
  set_default :system_architecture, "x86-linux"

  set_default :fix_libv8,    false
  set_default :fix_nokogiri, false
  set_default :fix_patron,   false

  namespace :gem_dependences do
    desc "lib v8 libraries"
    task :libv8, :role => :app do
      run "cd #{release_path}/vendor/cache; wget 'http://rubygems.org/downloads/libv8-#{libv8_version}-#{system_architecture}.gem'"
    end

    desc "nokogiri dependency library"
    task :nokogiri, :role => :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libxml2 libxml2-dev libxslt1-dev"
    end

    desc "patron dependency library"
    task :patron, :role => :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libcurl4-openssl-dev"
    end

    before "bundle:install" do
      libv8  if fix_libv8 == true
    end
    after "deploy:setup" do
      nokogiri if fix_nokogiri == true
      patron if fix_patron == true
    end
  end
end
