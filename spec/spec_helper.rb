require 'rspec'
# require 'database_cleaner'

API_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__ + "/../../..")))
# Support files
Dir[API_ROOT + "spec/support/**/*.rb"].each { |f| require f }

require API_ROOT + "spec/dummy/config/environment"

# Dir[API_ROOT + "app/models/**/*.rb"].each { |f| require f }

# # Truncate the database when the tests are done
# DatabaseCleaner.strategy = :truncation
# 
# RSpec.configure do |c|
#   c.after(:each) do
#     DatabaseCleaner.clean
#   end
# end

# def p(*args)
#   puts caller.join("\n")
#   super
# end