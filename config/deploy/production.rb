set :deploy_to, "/home/ubuntu/rails/socialstreet.com"

server "50.19.254.128", :app, :web, :db, :primary => true

before "deploy:update", "god:stop_resque" unless fetch(:quick_update, false)
after "deploy:update", "god:start_resque" unless fetch(:quick_update, false)

after "deploy:update", "newrelic:notice_deployment" unless fetch(:quick_update, false)