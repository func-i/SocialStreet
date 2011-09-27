set :deploy_to, "/home/ubuntu/rails/staging.socialstreet.com"
set :branch, "reborn"
server "ec2-184-73-88-200.compute-1.amazonaws.com", :app, :web, :db, :primary => true

