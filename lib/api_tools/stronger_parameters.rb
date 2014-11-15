require 'api_tools/key'

module APITools
  module StrongerParameters
    class Error < StandardError
      def initialize(missing, mismatch = [], unpermitted = [])
        msg = []
        msg << "Missing params: #{missing.inspect}" unless missing.empty?
        msg << "Unpermitted params: #{unpermitted.inspect}" unless unpermitted.empty?
        msg << "Mismatched type params: #{mismatch.inspect}" unless mismatch.empty?
        super(msg.join('; '))
      end
    end

    def lint!(fields)
      params, missing, unpermitted, mismatch = lint_hash(self, fields)
      fail Error.new(missing, mismatch, unpermitted) if !missing.empty? ||
        !unpermitted.empty? || !mismatch.empty?
      params
    end

    def lint(fields)
      params, missing, unpermitted, mismatch = lint_hash(self, fields)
      APITools.logger.info "Unpermitted params: #{unpermitted.inspect}" unless unpermitted.empty?
      APITools.logger.info "Mismatched type params: #{mismatch.inspect}" unless mismatch.empty?
      fail Error.new(missing, mismatch) if !missing.empty? || !mismatch.empty?
      params
    end

    private

    def lint_hash(original_params, fields)
      missing_params = []
      unpermitted_params = []
      type_mismatches = []

      params = original_params.is_a?(Hash) ? original_params.dup : {}
      tracker = params.dup

      fields.each do |field, value|
        key = Key.parse field
        tracker.delete key.name

        missing_params << key.name if key_missing?(params, key)
        next if params[key.name].nil?

        if value.is_a?(Class)
          if value == Date
            begin
              params[key.name] = Date.iso8601(params[key.name])
            rescue ArgumentError
              type_mismatches << key.name
            end
          elsif value == Time
            begin
              params[key.name] = Time.iso8601(params[key.name])
            rescue ArgumentError
              type_mismatches << key.name
            end
          elsif value == TrueClass || value == FalseClass
            type_mismatches << key.name unless params[key.name] == true || params[key.name] == false
          else
            type_mismatches << key.name unless params[key.name].is_a?(value)
          end
        elsif value.is_a?(Array) && value.size == 1
          if !params[key.name].is_a?(Array)
            type_mismatches << key.name
          elsif value[0].is_a?(Hash)
            params[key.name].map! do |nested|
              nested, tmp_missing_params, tmp_unpermitted_params, tmp_type_mismatches = lint_hash(nested, value[0])

              missing_params << {key.name => tmp_missing_params} if !tmp_missing_params.empty?
              unpermitted_params << {key.name => tmp_unpermitted_params} if !tmp_unpermitted_params.empty?
              type_mismatches << {key.name => tmp_type_mismatches} if !tmp_type_mismatches.empty?
              nested
            end
          elsif value[0] && !all_correct_types?(params[key.name], value[0])
            type_mismatches << key.name
          end
        elsif value.is_a?(Hash)
          params[key.name], tmp_missing_params, tmp_unpermitted_params, tmp_type_mismatches = lint_hash(params[key.name], value)

          missing_params << {key.name => tmp_missing_params} if !tmp_missing_params.empty?
          unpermitted_params << {key.name => tmp_unpermitted_params} if !tmp_unpermitted_params.empty?
          type_mismatches << {key.name => tmp_type_mismatches} if !tmp_type_mismatches.empty?
        else
          raise "bad value: #{value.inspect}"
        end
      end
      tracker.keys.each do |unpermitted_param|
        params.delete(unpermitted_param)
        unpermitted_params << unpermitted_param
      end

      [params, missing_params, unpermitted_params, type_mismatches]
    end

    def all_correct_types?(values, klass)
      values.all? {|value| value.is_a?(klass) }
    end

    def key_missing?(params, key)
      key.required? && !params.has_key?(key.name)
    end
  end
end
