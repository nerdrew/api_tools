# In the API we want to do this:
#
#   Foo.new bar_uuid: 'MERCH-123'
#
# and have the new Foo lookup the Bar by UUID or this:
#
#   Baz.new goat_name: 'Visa'
#
# and have the Baz lookup the Goat by name.
#
# You can't do:
#
#   belongs_to :contactable, polymorphic: true
#
#   def contactable_uuid= uuid
#     ContactableIsNotAClass.find_by_uuid uuid
#   end
#
# if the association is polymorphic (hence the before_validation and instance variable).
#
# What this does:
# - Creates a belongs_to <name>
# - Adds reader/writer methods: <name>_<attribute_name>
# - Adds a before_validation callback that does a lookup on the association by the <attribute_name>
# - Overwrites the standard association so that we can set the associated model if we need to
#
# E.g. for a non-polymorphic association:
#
#   belongs_to_with :name, :goat
#
# is the same as the following (as long as it isn't polymorphic)
#
#   belongs_to :goat
#
#   def goat_name
#     goat.name
#   end
#
#   def goat_name= name
#     self.goat = Goat.find_by_name name
#   end
#

module APITools
  module BelongsToWith
    def belongs_to_with(attribute_name, name, options = {})
      belongs_to name, options

      attr_writer :"#{name}_#{attribute_name}"
      before_validation :"set_#{name}_from_#{attribute_name}"
      alias_method :"old_#{name}", :"#{name}"

      if attribute_name.to_s == 'uuid'
        finder = "find_uuid(@#{name}_#{attribute_name})"
      else
        finder = "where(#{attribute_name}: @#{name}_#{attribute_name}).first"
      end

      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}
          if @#{name}_#{attribute_name}.nil?
            old_#{name}
          else
            set_#{name}_from_#{attribute_name}
          end
        end

        def #{name}_#{attribute_name}
          @#{name}_#{attribute_name} || #{name}.#{attribute_name}
        end

        private

        def set_#{name}_from_#{attribute_name}
          if @#{name}_#{attribute_name}
            other_class = association(:"#{name}").klass
            return if other_class.nil?
            self.#{name} = other_class.#{finder}
          end
        end
      CODE
    end

    def belongs_to_with!(attribute_name, name, options = {})
      belongs_to_with attribute_name, name, options

      if attribute_name.to_s == 'uuid'
        finder = "find_uuid!(@#{name}_#{attribute_name})"
      else
        replacements = {
          attribute: attribute_name,
          value: "@#{name}_#{attribute_name}"
        }
        finder = 'where(%{attribute}: %{value}).first || raise(APITools::RecordNotFound.new("Could not find #{other_class} with %{attribute}: #{%{value}}", other_class, %{attribute}: %{value}))' % replacements
      end

      class_eval <<-CODE, __FILE__, __LINE__ + 1
        private

        def set_#{name}_from_#{attribute_name}
          if @#{name}_#{attribute_name}
            other_class = association(:"#{name}").klass
            return if other_class.nil?
            self.#{name} = other_class.#{finder}
          end
        end
      CODE
    end
  end
end
