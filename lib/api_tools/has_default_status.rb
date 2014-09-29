module APITools
  module HasDefaultStatus
    def has_default_status
      self.send :include, InstanceMethods

      belongs_to :status
      before_validation :set_default_status, on: :create
      validates :status, presence: true
    end

    module InstanceMethods
      def status_name
        status.try(:name)
      end

      def status_name=(name)
        self.status = Status.where(name: name).first
      end

      def active?
        status == Status.active
      end

      private

      def set_default_status
        self.status ||= Status.active
      end
    end
  end
end
