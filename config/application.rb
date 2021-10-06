require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Xxx8110io
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.


    config.api_only = true

    #devise_token_authの設定(クッキーオーバーフローのエラー関連で一旦コメントアウト)
    #session_storeからactive_recored_storeに変更（gem activerecord-session_store）
    # config.session_store :active_record_store, key: '_interslice_session'
    # config.middleware.use ActionDispatch::Cookies # Required for all session management
    # config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
    # config.middleware.use ActionDispatch::Flash

    #devise_token_authの設定
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
                 :headers => :any,
                 :expose => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
                 :methods => [:get, :post, :options, :delete, :put]
      end
    end

    #RSpecのFile生成設定
    config.generators do |g|
      g.test_framework :rspec,
                        fixtures: false,
                        view_specs: false,
                        helper_specs: false,
                        routing_specs: false,
                        controller_specs: false,
                        request_specs: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

  end
end
