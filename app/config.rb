# config.rb

set :views, File.dirname(__FILE__) + '/../app/views'
set :haml, :format => :html5
set :file_root, File.dirname(__FILE__) + '/../files'
set :temp_dir, File.dirname(__FILE__) + '/../tmp'

configure do
  config = YAML::load(File.open('config/database.yml'))
  environment = Sinatra::Application.environment.to_s
  ActiveRecord::Base.logger       = Logger.new($stdout)
  ActiveRecord::Base.logger.level = 1
  ActiveRecord::Base.establish_connection(
    config[environment]
  )
  ActiveRecord::Base.connection.execute "SET collation_connection = 'utf8_general_ci'"
end

