$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require 'bundler/capistrano'


set :application, "SocialStreet"
set :repository,  "git@github.com:JBorts/SocialStreet.git"
set :deploy_to, "/home/ubuntu/rails/socialstreet.com"

set :scm, :git

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "50.19.254.128"                          # Your HTTP server, Apache/etc
#role :app, "50.19.254.128"                          # This may be the same as your `Web` server
#role :db,  "50.19.254.128", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
server "50.19.254.128", :app, :web, :db, :primary => true
set :user, "ubuntu"
ssh_options[:keys] = [File.join(ENV["HOME"], "socialstreet-web.pem")]

set :use_sudo, false

after "deploy:update_code", "db:symlink"
after "deploy:update_code", "secrets:symlink"
after "deploy:symlink",     "deploy:generate_assets"

# Passenger restart hook
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "curl -I http://aws.socialstreet.com/"
  end
end

namespace :secrets do 
  desc "Make symlink for secrets yml"
  task :symlink do
    run "#{try_sudo} ln -nfs #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml" 
  end
end

namespace :db do
  desc "Make symlink for database yaml" 
  task :symlink do
    run "#{try_sudo} ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
end

namespace :deploy do
  desc "Generate assets with Jammit"
  task :generate_assets do
    run "cd #{deploy_to}/current && bundle exec jammit"
  end
end
