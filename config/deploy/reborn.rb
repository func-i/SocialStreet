set :deploy_to, "/home/ubuntu/rails/reborn.socialstreet.com"
set :branch, "reborn"
server "50.19.254.128", :app, :web, :db, :primary => true

after "deploy:update_code", "deploy:generate_assets" unless fetch(:quick_update, false)
after "deploy:update", "newrelic:notice_deployment" unless fetch(:quick_update, false)
