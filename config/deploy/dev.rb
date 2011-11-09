set :deploy_to, "/home/ubuntu/rails/staging.socialstreet.com"
set :branch, "feature-groups"
server "ec2-184-73-88-200.compute-1.amazonaws.com", :app, :web, :db, :primary => true

after "deploy:update_code", "deploy:generate_assets" unless fetch(:quick_update, false)
after "deploy:update", "newrelic:notice_deployment" unless fetch(:quick_update, false)

