require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module SocialStreet
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :action_observer, :feed_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    if ["production", "staging"].include?(Rails.env)
      config.action_view.stylesheet_expansions[:application] = ["assets/common"]
      config.action_view.javascript_expansions = {:defaults => "assets/common"}
    else
      config.action_view.stylesheet_expansions[:application] = ["all", "../jquery-ui-1.8.11.custom/css/smoothness/jquery-ui-1.8.11.custom.css"]
      config.action_view.javascript_expansions[:defaults] = ['jquery-1.5.1', '../jquery-ui-1.8.11.custom/js/jquery-ui-1.8.11.custom.min', 'rails', 'application', 'autoresize.jquery.min', 'jquery.ui.autocomplete.html', 'infobubble']    end

  end
end
