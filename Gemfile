source "https://rubygems.org"

gem "rails", "~> 8.1.2"

gem "bootsnap", require: false
gem "connection_pool"
gem "google-cloud-discovery_engine"
gem "jsonpath"
gem "loofah"
gem "publishing_platform_app_config"
gem "publishing_platform_message_queue_consumer"
gem "redis"
gem "redlock"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "publishing_platform_rubocop"
  gem "rspec-rails"
  gem "timecop"
end

group :test do
  gem "climate_control"
  gem "simplecov"
end
