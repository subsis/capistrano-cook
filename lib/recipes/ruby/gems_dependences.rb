Capistrano::Configuration.instance.load do
  set_default :libv8_version, "3.3.10.2"

  namespace :gem_dependences do
    desc "lib v8 libraries"
    task :libv8, role: :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libv8-3.7.12.22 libv8-dev"
      run "gem install --version '=#{libv8_version}' libv8"
    end
    before "bundle:install", "gem_dependences:libv8"
  end
end
