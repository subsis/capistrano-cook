Capistrano::Configuration.instance.load do
  set_default :libv8_version, "3.3.10.2"
  set_default :system_architecture, "x86-linux"

  namespace :gem_dependences do
    desc "lib v8 libraries"
    task :libv8, role: :app do
      run "cd #{release_path}/vendor/cache; wget 'http://rubygems.org/downloads/libv8-#{libv8_version}-#{system_architecture}.gem'"
    end
    before "bundle:install", "gem_dependences:libv8"

    desc "nokogiri dependendce library"
    task :nokogiri, role: :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libxml2 libxml2-dev libxslt1-dev"
    end
    after "deploy:setup", "gem_dependences:nokogiri"
  end
end
