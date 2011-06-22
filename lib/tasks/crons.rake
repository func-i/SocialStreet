
namespace :ss do
  namespace :crons do

    desc "daily digest for search subscriptions - to be run by crontab"
    task :email_daily_digests => :environment do
      Crons::DailySubscriptionDigester::run
    end

    desc "weekly digest for search subscriptions - to be run by crontab"
    task :email_weekly_digests => :environment do
      Crons::WeeklySubscriptionDigester::run
    end
  end
end