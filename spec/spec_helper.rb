$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'api_tools'
require 'api_tools_specs'
require 'shoulda/matchers'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

RSpec.configure do |config|
  config.extend APIToolsSpecs::AnonymousModel
end
