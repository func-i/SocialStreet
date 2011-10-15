SocialStreet
================

### Description

SocialStreet is a web app that makes it easy for people to plan/find and attend local events.

### Initial Setup for Development:

- Download the source
- Setup a new config/database.yml file based on config/database.example.yml
- Setup a new config/secrets.yml file based on config/secrets.example.yml
  - For the secret keys, setup a Facebook app under your real/developer account: http://www.facebook.com/developers
  - Set the site URL to: http://localhost:3000/ (Site Domain can be left blank)
  - You can call it something like: SocialStreet-dev
  - You do not need to give other developers access to this app, since its just for your development sandbox
- Install PostgreSQL 8.3, 8.4 or 9
- Install the pg gem (might be a bit of a pain on OSX)
- Download and install Redis: http://redis.io/download
- Start Redis Server:
  - Open a terminal tab to the [REDIS_ROOT (where you extracted and installed it) dir, and run: ./src/redis-server
- Run 1 Resque Worker:
  - Open a terminal tab to the [APP_ROOT] dir, and run: QUEUE=* rake environment resque:work
- Run 1 Resque Scheduler:
  - Open a terminal tab to the [APP_ROOT] dir, and run: rake resque:scheduler 
- Start Resque Web Server (optional, for debugging):
  - Open a terminal tab to the [APP_ROOT] dir, and run: bundle exec resque-web ~/yourapp/config/resque_config.rb
  - This will start another web server here: http://localhost:5678/
  - This page should show 1 worker waiting for a job: http://0.0.0.0:5678/workers
- Start the SocialStreet App Server (duh):
  - Open a terminal tab to the [APP_ROOT] dir, and run: rails server

### Running Tests (RSpec specs)

For all tests, from the [APP_ROOT], run the command:

    rspec spec

If that doesn't work, try running:

    bundle exec rake spec

For a single test based on its line number, run the command: 

    rspec spec/models/searchable_date_range_spec.rb:69

In this example, it runs the first spec ("it" statement) that it can find at or above line 69 in searchable_date_range

### Using Facebook (IMPORTANT)

You should create and use facebook "test" users to test in development mode, using the following steps:

    rails c # go into rails console (development mode)
    app = FbGraph::Application.new(FACEBOOK_APP_ID, :secret=>FACEBOOK_APP_SECRET) # Create an fb_graph app instance
    user1 = app.test_user!(:installed => true, :permissions => :read_stream) # Create a 1st test user
    user2 = app.test_user!(:installed => true, :permissions => :read_stream) # Create a 2nd test user
    user1.friend!(user2) # Friend the 2 users
    user1.login_url # Get user1's login_url (so you can login into SS w/ that user)

Now, assuming you are not signed into Facrbook, Paste the login URL into your browser
Goto your local SS instance (http://localhost:3000) and click Sign-in
Facebook info on Test Users: https://developers.facebook.com/docs/test_users/

### Background jobs (For SearchSubscription Email Digests)

On our Staging/Production server(s)... Daily and Weekly search subscription email digests are sent by leveraging Crontab + Rake + Redis + Resque
On the server, a cron task executes a sh script which runs our rake commands located in lib/tasks/crons.rake

These rake tasks go through Redis looking for any subscriptions that have items that need to be emailed out
Each subscription has its own key ("digest_actions:#{subscription.id}") and is an ordered set of ActionIDs in Redis
For each SearchSubscription that needs to be emailed, a Resque Job is enqueued to send out that 1 email to the owner of the subscription

To test the daily/weekly tasks locally (in development mode), we simulate the end-of-day/week triggers:

For Daily Rake, run the command:

    bundle exec rake ss:crons:email_daily_digests RAILS_ENV=development

For Weekly Rake, run the command:

    bundle exec rake ss:crons:email_weekly_digests RAILS_ENV=development

Other helpful tips:

To see what's pending in the Redis (queues) order sets for email digests, run:

    rails c # go into rails console (development mode)
    r = Redis.new
    r.keys 'digest_actions:*' # returns list of subscriptions that have ActionIds to be emailed in the next digest email
    key = r.keys 'digest_actions:*'.first # as an example, lets use the first key ...
    r.zcard key # returns size of bucket (# of actions to email)
    r.zrevrange(key, 0, 999) # returns up to 1000 ActionIDs that need to be sent to the subscription associated with this 'key'
    r.quit # disconnect from Redis

### Docs:

- http://redis.io/download
- https://github.com/defunkt/resque
- http://redis.io/topics/data-types#sorted-sets
- https://github.com/ezmobius/redis-rb
- http://blog.waxman.me/how-to-build-a-fast-news-feed-in-redis
- https://developers.facebook.com/docs/test_users/

### Article used for Slicehost Server setup:

- http://library.linode.com/databases/redis/ubuntu-10.04-lucid


Production Servers
================

### Production Server Layout / Access

 - There are 2 servers, a small instance for Web/Redis/BG Tasks and a micro instance for 'DB'
 - Both servers allow SSH access but only the Web one has a static (Elastic IP) assigned
 - There will only be one user 'ubuntu' on the host servers
 - Every developer will have their own key pair generated via AWS, and the public key will be added to the web/db server
 - The Postgres server (on the 'DB' instance) accepts TCP/IP connects only from the EC2 Web instance's PRIVATE IP address

### Deployment (Capistrano)

- There are various deployment related commands, but the 2 main ones you should know about are:

    cap deploy # run when deploying code changes that do not have any migrations 
    cap deploy:migrations # run instead of cap deploy when you have migrations to run as well
    cap deploy -S quick_update=true  # use if you just want to update the git, create the current and all symlinks
                                     # but want to skip restarting god, running jammit, notifying newrelic and hb

- Before running capistrano, make sure you install capistrano gem (not managed by bundler):  gem install capistrano
- Capistrano deploy code is located in config/deploy.rb
- Only deploy from 'master' branch (see Git Flow for release workflow)

### Adding a new developer (for Josh)

- Generate new keypair from AWS Management Console
- Generate public key as per instructions here: http://seabourneinc.com/2011/01/19/change-key-pairs-on-aws-ec2-instance/
- Provide developer private key and public key
- Developer should save the private key as ~/.ssh/socialstreet-web.pem
- Josh should append the public key contents to the /home/ubuntu/.ssh/authorized_keys file
- Developer should add the following two aliases to their ~/.bash_profile or ~/.bash_aliases file:

    alias sswebssh='ssh -i ~/.ssh/socialstreet-web.pem ubuntu@50.19.254.128'
    alias ssdbssh='ssh -i ~/.ssh/socialstreet-web.pem ubuntu@ec2-184-72-194-208.compute-1.amazonaws.com'

- Open a new Terminal tab/window and try running sswebssh to make sure you can connect to the Web server. Ditto for the DB server

### Removing a developer from the servers (for Josh)

- Remove their public key from authorized_keys
- Remove their key pair from AWS Management Console
- If they were given access to the management console / AWS Account API, remove that access via the management console

### Git Flow usage / Release workflow

- Git Flow is being used on top of Git
- Please watch the screencast and ALWAYS use gitflow (for creating feature branches, performing hot fixes, releases, etc.)
- Code: https://github.com/nvie/gitflow
- Screencast: http://codesherpas.com/screencasts/on_the_path_gitflow.mov

### Heartbeat monitoring (NewRelic)

- URL: http://www.socialstreet.com/hb
- Controller: HeartbeatController
- Excluded from new relic performance calculations
- Using SmartRackLogger to exclude any .log entries for URL /hb (See application.rb) otherwise production.log will be too noisy

### Error simulation (Airbrake)

- URL: http://www.socialstreet.com/sim_error
- Causes a string exception to be thrown

### GOD

- Starting GOD
/usr/local/rvm/rubies/ruby-1.9.2-p180-patched/bin/ruby /usr/local/rvm/gems/ruby-1.9.2-p180-patched/bin/god -P /var/run/god/god.pid -l /var/log/god/god.log