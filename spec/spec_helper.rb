require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end