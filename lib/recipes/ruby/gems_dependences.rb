Capistrano::Configuration.instance.load do
  namespace :gem_dependences do
    desc "lib v8 libraries"
    task :libv8, role: :app do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install libv8-3.7.12.22 libv8-dev"
    end
    before "bundle:install", "gem_dependences:libv8"
  end
end
