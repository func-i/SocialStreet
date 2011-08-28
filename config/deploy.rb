$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'airbrake/capistrano'

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
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "socialstreet-web.pem")]

set :use_sudo, false

after "deploy:update_code", "db:symlink"
after "deploy:update_code", "secrets:symlink"
after "deploy:update_code", "environment:symlink"
after "deploy:update_code", "deploy:generate_assets"

before "deploy:update", "god:stop_resque"
after "deploy:update", "god:start_resque"

# Passenger restart hook
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "curl -I -s http://www.socialstreet.com/hb; exit 0;"
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

namespace :environment do
  desc "Make symlink for database yaml" 
  task :symlink do
    run "#{try_sudo} ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/environments/production.rb" 
  end
end

namespace :deploy do
  desc "Generate assets with Jammit"
  task :generate_assets do
    run "cd #{release_path} && bundle exec jammit"
  end
end

namespace :god do 
  def god_command
    # use rvm wrapper for God, generated via instructions: http://beginrescueend.com/integration/god/
    "sudo /usr/local/rvm/bin/bootup_god"
  end
  desc "Stop all 'resque' tasks using God"
  task :stop_resque do 
    run "#{god_command} stop resque"
  end
  desc "Start all 'resque' tasks using God"
  task :start_resque do 
    run "#{god_command} start resque"
  end
  desc "Get a status on all 'resque' tasks using God"
  task :status do
    sudo "#{god_command} status resque"
  end
end

