source 'https://rubygems.org'

# For heroku
ruby '2.2.4'

gem 'rails',    '3.2.22'
gem 'sidekiq',  '~> 2.13.0'
gem 'sinatra', require: false # required by sidekiq web interface mounted on /sidekiq

gem 'magic_encoding'
# Turns every field on a editable one
gem 'best_in_place'

# State machine for attributes on models
gem 'state_machine', require: 'state_machine/core'

# paranoid stuff
gem 'paper_trail', '~> 2.7.1'

gem 'tokens'

# Better logs
gem "lograge"
gem 'quiet_assets'

# Database and data related
gem 'pg'
gem 'pg_search'
gem 'postgres-copy'
gem 'schema_plus'
gem 'schema_associations'
gem 'chartkick'

#recaptcha API
gem "recaptcha", require: "recaptcha/rails"
#Invisible captcha for spam bots
gem 'invisible_captcha'

# Payment engine using Paypal
# gem 'catarse_paypal_express', git: 'git://github.com/cesvald/catarse_paypal_express.git',  ref: 'e4f4113be9cb9f684a272e5d04a2dd4f808bb6ff'
# gem 'catarse_paypal_express', git: 'git://github.com/cesvald/catarse_paypal_express.git',  branch: 'test'
# gem 'catarse_paypal_express', path: '../catarse_paypal_express'

# Payment engine using PayU Latam

# gem 'mercadopago-sdk'

gem 'payulatam', git: 'git://github.com/cesvald/payulatam.git',  ref: 'e87c399c90a3650e74698c13481a446359508e67'
#gem 'catarse_payulatam', git: 'git://github.com/cesvald/catarse_payulatam.git',  ref: '8c270c8aa0994f28973b4098f34c3bccd83bcbff'
gem 'catarse_payulatam', git: 'git://github.com/cesvald/catarse_payulatam.git',  branch: 'test'
# gem 'payulatam', path: '../payulatam'
# gem 'catarse_payulatam', path: '../catarse_payulatam'

# Payment engine using Bancard
gem 'bancard', git: 'https://github.com/cesvald/bancard.git', branch: 'sb_confirmations'

# Payment engine using PayU Latam
# gem 'catarse_payroll', git: 'git://github.com/danielweinmann/catarse_payroll.git',  ref: '90e0b1e01c7a3d2eff10a3c16286138e54397a1e'
# gem 'catarse_payroll', path: '../catarse_payroll'

# gem 'catarse_lbm_gift_cards', path: '../catarse_lbm_gift_cards'
  # gem for testing
    gem 'catarse_lbm_gift_cards', git: 'git://github.com/cesvald/catarse_lbm_gift_cards.git',  branch: 'test'
  # gem for production
  #gem 'catarse_lbm_gift_cards', git: 'git://github.com/cesvald/catarse_lbm_gift_cards.git',  ref: '0e87dd8d364ea8a0cc2878865113ea949a317457'

# Payment engine using Mercadopago
#gem 'catarse_mercadopago', git: 'git://github.com/cesvald/catarse_mercadopago.git',  ref: '473ff04967c05c346729e6e1cccc6204c967c07e'

# Decorators
gem 'draper'

# Frontend stuff
gem 'slim-rails', '~> 1.1.1'
gem 'jquery-rails'
gem 'initjs'

# Authentication and Authorization
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'devise'
gem 'ezcrypto'

# See https://github.com/ryanb/cancan/tree/2.0 for help about this
# In resume: this version of cancan allow checking for authorization on specific fields on the model
gem 'cancan', git: 'git://github.com/ryanb/cancan.git', branch: '2.0', ref: 'f1cebde51a87be149b4970a3287826bb63c0ac0b'

# Email marketing
gem 'catarse_mailchimp', git: 'git://github.com/cesvald/catarse_mailchimp.git', ref: '45dc426'

# HTML manipulation and formatting
gem 'formtastic',   '~> 2.1.1'
gem "auto_html",    '= 1.4.2'
gem 'kaminari'

# Uploads
gem 'carrierwave', '~> 0.8.0'
gem 'rmagick'

# Other Tools
gem 'ranked-model'
gem 'feedzirra'
gem 'curb', '0.9.1'
gem 'validation_reflection',      git: 'git://github.com/ncri/validation_reflection.git'
gem 'inherited_resources',        '1.6.0'
gem 'has_scope', '0.6.0'
gem 'spectator-validates_email',  require: 'validates_email'
gem 'video_info', '>= 1.1.1'
gem 'enumerate_it'
gem 'httparty', '~> 0.6.1' # this version is required by moip gem, otherwise payment confirmation will break
gem 'nokogiri'
gem "recaptcha", require: "recaptcha/rails"

gem 'test-unit'
gem 'jbuilder'
gem 'gon' # from controller to js
# docx replace template
gem 'rubyzip' # will load new rubyzip version
gem 'axlsx_rails', '>= 0.4.0'
gem 'docx_replace', git: 'git://github.com/cesvald/replace.git'
gem 'zip-zip' # will load compatibility for old rubyzip API.


# apis
gem 'gmaps4rails'

# Translations
gem 'http_accept_language'
gem 'routing-filter'
gem 'web_translate_it'
gem 'i18n_viz'

# Payment
gem 'activemerchant', '>= 1.17.0', require: 'active_merchant'
gem 'httpclient',     '>= 2.2.5'

group :production do

  # Gem used to handle image uploading
  gem 'fog', '>= 1.3.1'

  # Workers, forks and all that jazz
  gem 'unicorn'

  # Enabling Gzip on Heroku
  # If you don't use Heroku, please comment the line below.
  gem 'heroku-deflater', '>= 0.4.1'


  # Monitoring with the new new relic
  gem 'newrelic_rpm'

  gem 'rails_12factor'
  
  # Using dalli and memcachier have not presented significative performance gains
  # Probably this is due to our pattern of cache usage
  # + the lack of concurrent procs in our deploy
  #gem 'memcachier'
  #gem 'dalli'
end

group :development do
  gem "letter_opener"
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
  #gem 'rack-mini-profiler'
end

group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara',   '~> 2.0.2'
  gem 'jasmine'
  gem 'coveralls', require: false
  gem "selenium-webdriver", "~> 2.34.0"
end


group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem "compass-rails"
  gem 'uglifier'
  gem 'semantic-mixins', '~> 0.1.9'
  gem 'compass-960-plugin'
  gem 'jquery-fileupload-rails'
end



# FIXME: Not-anymore-on-development
# Gems that are with 1 or more years on the vacuum
gem 'weekdays'
gem "rack-timeout"

# TODO: Take a look on dependencies. Why not auto_html?
gem 'rails_autolink', '~> 1.0.7'

# TODO: Take a look on dependencies
gem "RedCloth"

#gem 'rack-wwwhisper', '~> 1.0'