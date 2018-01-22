Recaptcha.configure do |config|
  config.site_key  = Configuration[:recaptcha_site]
  config.secret_key = Configuration[:recaptcha_secret]
end