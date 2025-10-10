source "https://rubygems.org"

gem "rails", "~> 8.0.3"

gem "bootsnap", require: false
gem "publishing_platform_app_config"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "publishing_platform_rubocop"
end

group :test do
  gem "simplecov"
end
