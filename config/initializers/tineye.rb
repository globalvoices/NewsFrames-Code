Tinplate.configure do |config|
  config.public_key = ENV['TINEYE_PUBLIC_KEY']
  config.private_key = ENV['TINEYE_PRIVATE_KEY']
  config.test = ENV['RAILS_ENV'] == 'test'
end
