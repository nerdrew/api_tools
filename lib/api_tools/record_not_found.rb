module APITools
  class RecordNotFound < ActiveRecord::RecordNotFound
    attr_reader :klass, :attribute, :value

    def initialize(message, klass = nil, finder = {})
      @klass = klass
      raise ArgumentError.new("only one finder pair allowed: #{finder.inspect}") if finder.size > 1
      key, value = finder.first
      if key
        raise ArgumentError.new("finder key must respond to to_sym: #{key}") unless key.respond_to?(:to_sym)
        @attribute = key.to_sym
        @value = value
      end
      super(message)
    end
  end
end
