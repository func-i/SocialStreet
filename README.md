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
- Start Resque Web Server (optional, for debugging):
  - Open a terminal tab to the [APP_ROOT] dir, and run: bundle exec resque-web
  - This will start another web server here: http://localhost:5678/
  - This page should show 1 worker waiting for a job: http://0.0.0.0:5678/workers
- Start the SocialStreet App Server (duh):
  - Open a terminal tab to the [APP_ROOT] dir, and run: rails server

### Running Tests (RSpec specs)
- For all tests, from the [APP_ROOT], run the command: rspec spec
  - If that doesn't work, try running: rake spec
- For a single test based on its line number, run the command: rspec spec/models/searchable_date_range_spec.rb:69
  - In this example, it runs the first spec ("it" statement) that it can find at or above line 69 in searchable_date_range

### Using Facebook (IMPORTANT)
- You should create and use facebook "test" users to test in development mode, using the following steps:

    rails c # Open a rails console with command
    app = FbGraph::Application.new(FACEBOOK_APP_ID, :secret=>FACEBOOK_APP_SECRET) # Create an fb_graph app instance
    user1 = app.test_user!(:installed => true, :permissions => :read_stream) # Create a 1st test user
    user2 = app.test_user!(:installed => true, :permissions => :read_stream) # Create a 2nd test user
    user1.friend!(user2) # Friend the 2 users
    user1.login_url # Get user1's login_url (so you can login into SS w/ that user)

- Now, assuming you are not signed into Facrbook, Paste the login URL into your browser
- Goto your local SS instance (http://localhost:3000) and click Sign-in
- Facebook info on Test Users: https://developers.facebook.com/docs/test_users/

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

    rails c development # go into rails console
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
