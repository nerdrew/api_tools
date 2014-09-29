require 'logger'
require 'api_tools/belongs_to_with'
require 'api_tools/has_default_status'
require 'api_tools/has_uuid'
require 'api_tools/is_soft_deletable'
require 'api_tools/stronger_parameters'
require 'api_tools/railtie' if defined?(Rails)
require 'api_tools/record_not_found'
require 'api_tools/scope_uuid'
require 'api_tools/version'

module APITools
  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
