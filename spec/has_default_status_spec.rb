require 'spec_helper'

RSpec.describe APITools::HasDefaultStatus do
  build_model :modely do
    extend APITools::HasDefaultStatus
    has_default_status

    integer :status_id
  end

  build_model :status do
    string :name
  end

  subject { Modely.new }
  it_behaves_like 'has_default_status'
end
