# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION
RAILS_GEM_VERSION = '2.0.2'
#if RUBY_PLATFORM =~ /java/
#  require 'rubygems'
#  RAILS_CONNECTION_ADAPTERS = %w(jdbc)
#end
#puts "PROCESS: before boot join"
# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
puts  "PROCESS: after boot join about to call initializer env #{RAILS_ENV}"
Rails::Initializer.run do |config|
#puts "PROCESS: first line of rails:: initalizes #{config.inspect}"
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  #SCOTT 
    log_file_name=ENV['JRUBY_HOME']+'/log/'+'process_web_app.log'
    puts "creating log file: #{log_file_name}: SEE THIS FOR RAILS LOG"
    file = File.open(log_file_name, File::WRONLY | File::APPEND | File::CREAT)
    config.logger = Logger.new(file,5,1024000)
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
 config.action_controller.session = { :session_key => "_process_session", :secret => "testing the limits of cure mobile" }
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below

eng = File.join(File.dirname(__FILE__), 'openwferuengine.rb')
#puts "AFTER INITIALIZE: file location #{eng} loadpath #{$LOAD_PATH}"
require 'openwferuengine.rb'
#require File.join(File.dirname(__FILE__), 'openwferuengine')
#require 'openwferuengine'
#require 'config/openwferu_engine'
puts "after config/openwfe"
ExceptionNotifier.exception_recipients = %w(scott.sproule@ficonab.com)
ActionMailer::Base.smtp_settings = {
  :address =>        "smtp.gmail.com",
  :port =>           587,
  :domain => "ficonab.com",
  :authentication => :plain,
   :user_name =>      "reports@ficonab.com",
   :password =>       "321reports123"

   #  :address => "localhost",
   #  :domain => "facebook.ficonab.com"

}
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.default_content_type = "text/html"

# REQUIRED FOR WARBLER
#ActionController::Base.page_cache_directory = "#{RAILS_ROOT}/.."
# NOT certain about this  ENV["RAILS_ASSET_ID"] = '1001' 