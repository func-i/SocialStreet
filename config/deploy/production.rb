set :deploy_to, "/home/ubuntu/rails/socialstreet.com"

server "ec2-184-73-88-200.compute-1.amazonaws.com", :app, :web, :db, :primary => true

before "deploy:update", "god:stop_resque" unless fetch(:quick_update, false)
after "deploy:update", "god:start_resque" unless fetch(:quick_update, false)

after "deploy:update", "newrelic:notice_deployment" unless fetch(:quick_update, false)