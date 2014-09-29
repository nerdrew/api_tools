module APITools
  class Railtie < Rails::Railtie
    initializer 'api_tools.initializer' do
      APITools.logger = Rails.logger

      ActiveSupport.on_load(:active_record) do
        extend APITools::HasUuid
        extend APITools::IsSoftDeletable
        extend APITools::BelongsToWith
        extend APITools::HasDefaultStatus
        extend APITools::ScopeUUID
      end

      ActiveSupport.on_load(:action_controller) do
        ActionController::Parameters.send :include, APITools::StrongerParameters
      end
    end

    rake_tasks do
      load 'api_tools/tasks/schema.rake'
    end
  end
end
