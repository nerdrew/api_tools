require 'uuid'

module APITools
  module ScopeUUID
    def scope_uuid(association, options = {})
      scope :"with_#{association}_uuid", ->(uuid){
        if UUID.validate uuid
          joins(association).where(
            reflect_on_association(association).table_name => {uuid: uuid}
          )
        else
          where(connection.quoted_false)
        end
      }
    end
  end
end
